provider "aws" {
    region = var.region
}

########## Local Block ########## {
locals {
    rules = { for k, v in var.security_groups:
        k => flatten( 
            [[ for rule in try(v.ingresses, []):
                [ for port_range in rule.port_ranges:
                    [ for idx, src_sg in flatten([ join(",", try(rule.cidr_blocks, [])), try(rule.sg_ids, []), try(rule.sg_names, []) ]):
                        {
                            type = "ingress"
                            protocol = try(rule.protocol, "tcp")
                            
                            cidr_blocks = idx < 1 ? split(",", src_sg) : null
                            source_security_group_id = idx > 0 ? src_sg : null
                            
                            from_port = split("-", port_range)[0]
                            to_port = length(split("-", port_range)) > 1 ? split("-", port_range)[1] : split("-", port_range)[0]
                            description = try(rule.description, null)
                        } if src_sg != ""
                    ]
                ]
            ], 
            [ for rule in try(v.egresses, []):
                [ for port_range in rule.port_ranges:
                    [ for idx, dst_sg in flatten([ join(",", try(rule.cidr_blocks, [])), try(rule.sg_ids, []), try(rule.sg_names, []) ]):
                        {
                            type = "egress"
                            protocol = try(rule.protocol, "tcp")
                            
                            cidr_blocks = idx < 1 ? split(",", dst_sg) : null
                            source_security_group_id = idx > 0 ? dst_sg : null
                            
                            from_port = split("-", port_range)[0]
                            to_port = length(split("-", port_range)) > 1 ? split("-", port_range)[1] : split("-", port_range)[0]
                            description = try(rule.description, null)
                        } if dst_sg != ""
                    ]
                ]
            ]
        ])
    }
    tag_suffix = "${var.project}_${var.stage}_${var.region_code}"
}
########## Local Block ########## }

########## Security Group Block ########## {
resource "aws_security_group" "main" {
    for_each        = var.security_groups
    name            = "${each.key}_${local.tag_suffix}"
    description     = each.value.description
    vpc_id          = var.vpc_id
    tags            = {
        "Name" = format("%s_%s", each.key, local.tag_suffix),
        "vpc_id" = var.vpc_id
    }
    lifecycle {
        precondition {
            condition = var.vpc_id != null
            error_message = "VPC ID must not be null, Please check net_id input variable"
        }
    }
}
########## Security Group Block ########## }

########## Security Group Rules Block ########## {
resource "aws_security_group_rule" "main" {
    for_each = merge([ for sg_name, sg_rules in local.rules: 
                       { for sg_rule in sg_rules: 
                            format("%s^%s^%s^%s-%s^%s", sg_rule.type, sg_name, sg_rule.protocol, sg_rule.from_port, sg_rule.to_port, 
                                (try(sg_rule.cidr_blocks, null) != null ? join(",", sg_rule.cidr_blocks) : sg_rule.source_security_group_id)) => sg_rule }
                ]...)
    security_group_id = aws_security_group.main[split("^", each.key)[1]].id
    type = each.value.type
    protocol = each.value.protocol
    from_port = each.value.from_port
    to_port = each.value.to_port
    cidr_blocks = each.value.cidr_blocks
    # if security group name then change it security group ID
    source_security_group_id = ( try(each.value.source_security_group_id, null) != null ?
                                    length(regexall("sg-", each.value.source_security_group_id)) > 0 ? 
                                        each.value.source_security_group_id : aws_security_group.main[each.value.source_security_group_id].id 
                                    : null )
    description = each.value.description
    ipv6_cidr_blocks = null # Not support
    prefix_list_ids = null # Not support
    lifecycle {
        create_before_destroy = true
    }
    depends_on = [ aws_security_group.main ]
}
########## Security Group Rules Block ########## }