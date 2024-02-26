provider "aws" {
    region = var.region
}

locals {
    tag_suffix = "${var.project}_${var.stage}_${var.region_code}"
    iam_policies = ( var.iam_policies != null ? 
                            { for policy in var.iam_policies:
                                reverse(split("/", policy))[0] => strcontains(policy, "arn:") ? policy : "arn:${data.aws_partition.current.partition}:iam::aws:policy/${policy}"
                            } : null
                        )
}

data "aws_ami" "selected" {
    filter {
        name = "image-id"
        values = [ var.ami_id ]
    }
}

data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}

resource "aws_key_pair" "main" {
    count = var.ssh_keypair_name != null && var.ssh_public_key != null ? 1 : 0
    key_name = "${var.ssh_keypair_name}_${local.tag_suffix}"
    public_key = var.ssh_public_key
    tags = {
        # Naming rule: 
        "Name" = "${var.ssh_keypair_name}_${local.tag_suffix}"
        "instances" = join(",", formatlist("%s_${local.tag_suffix}", var.names))
    }
}

resource "null_resource" "verification" {
    lifecycle {
        precondition {
            condition = data.aws_ami.selected.platform != "Windows" && var.ssh_keypair_name != null
            error_message = "[ERROR] EC2 ssh key must be set (please check ssh_keypair_name and ssh_public_key variable)"
        }
        precondition {
            condition = (var.instance_profile != null && var.iam_policies == null) || (var.instance_profile == null && var.iam_policies != null) || (var.instance_profile == null && var.iam_policies == null)
            error_message = "[ERROR] instance_profile and iam_policies are exclusive, please check variables"
        }
        precondition {
            condition = length(var.private_ips) > 0 ? length(var.names) == length(var.private_ips) : true
            error_message = "[ERROR] ec2 names and private ip addresss count is not match please check variables."
        }
    }
}

module "ec2" {
    for_each = toset(var.names)
    source  = "terraform-aws-modules/ec2-instance/aws"
    version = "~> 5.2"
    
    ##### Network Definition ##### {
    subnet_id = var.subnet
    associate_public_ip_address = var.enable_public_access
    private_ip = length(var.private_ips) > 1 ? var.private_ips[each.value] : null
    vpc_security_group_ids = var.security_group_ids
    ##### Network Definition ##### }
    
    ##### Compute Definition ##### {
    name = replace("${each.key}_${local.tag_suffix}", "-0", "") # 0 index는 이름에서 삭제
    ami = var.ami_id
    ignore_ami_changes = false
    instance_type = var.instance_type
    tags = merge(var.tags, {
        "Name" = replace("${each.key}_${local.tag_suffix}", "-0", "")
        "subnet_id" = var.subnet
    })
    monitoring = var.enable_detail_monitoring
    ##### Compute Definition ##### }
    
    ##### OS Definition ##### {
    key_name = var.ssh_keypair_name
    user_data = var.userdata
    user_data_replace_on_change = true
    ##### OS Definition ##### }
    
    ##### Storage Definition ##### {
    root_block_device = [ for disk in slice(var.disks, 0, 1):
        {
            volume_type = try(disk.type, "gp2")
            volume_size = disk.size
            iops = try(disk.iops, null)
            throughput = try(disk.throughput, null)
            delete_on_termination = var.delete_os_disk_on_termination
            encrypted = true
            kms_key_id = var.encrypt_key
            tags = merge(try(disk.tags, {}), {
                "Name" = replace("${try(disk.name, "sda")}_${each.key}_${local.tag_suffix}", "-0", "")
                "instance_name" = replace("${each.key}_${local.tag_suffix}", "-0", "")
            })
        }
    ]
    ebs_block_device = [ for disk in slice(var.disks, 1, length(var.disks)):
        {
            device_name = "/dev/${disk.name}"
            volume_type = try(disk.type, "gp2")
            volume_size = disk.size
            iops = try(disk.iops, null)
            throughput = try(disk.throughput, null)
            delete_on_termination = var.delete_data_disk_on_termination
            encrypted = true
            kms_key_id = var.encrypt_key
            snapshot_id = try(disk.snapshot, null)
            tags = merge(try(disk.tags, {}), {
                "Name" = replace("${disk.name}_${each.key}_${local.tag_suffix}", "-0", "")
                "instance_name" = replace("${each.key}_${local.tag_suffix}", "-0", "")
            })
        }
    ]
    enable_volume_tags = false
    ##### Storage Definition ##### }
    
    ##### IAM Definition ##### {
    iam_instance_profile = var.instance_profile
    
    create_iam_instance_profile = var.iam_policies != null ? true : false
    iam_role_name = var.iam_policies != null ? "${each.key}_${var.project}_${var.region_code}" : null
    iam_role_description = var.iam_policies != null ? "IAM role for EC2 instance" : null
    iam_role_policies = local.iam_policies
    
    
    ##### IAM Definition ##### }
    depends_on = [null_resource.verification]
}