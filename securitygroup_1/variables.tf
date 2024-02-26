########## Project Definition ########## {
variable "project" {
    description = <<-EOF
        description: Project name or service name
        type: string
        required: yes
        example: 
            project = "gitops"
    EOF
    type = string
}

variable "stage" {
    description = <<-EOF
        description: Service stage of project (dev, stg, prd etc)
        type: string
        required: yes
        example:
            stage = "dev"
    EOF
    type = string
}

variable "region" {
    description = <<-EOF
        description: Region name to create resources
                     refer to https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.RegionsAndAvailabilityZones.html#Concepts.RegionsAndAvailabilityZones.Regions
        type: string
        required: yes
        default: ap-northeast-2
        example: 
            region = ap-northeast-2
    EOF
    type    = string
}

variable "region_code" {
    description = <<-EOF
        description: Country code for region
                     refer to https://countrycode.org
        type: string
        required: yes
        default: kr
        example:
            region_code = "kr"
    EOF
    type = string
}
########## Project Definition ########## }

########## Security Group Definition ########## {
variable "vpc_id" {
    description = <<-EOF
        description: VPC ID to attach this security group
        type: string
        required: yes
    EOF
    type = string
}

variable "security_groups" {
    description = <<-EOF
        description: Network security group rule definition 
        type:  
            map(object({
                description     = string        #(Optional) security group description
                ingresses       = list(object({ #(Optional) security group ingress rule definition
                    protocol    = string        #(Required) inbound protocol
                    port_ranges = list(string)  #(Required) inbound port range to allow
                    cidr_blocks = list(string)  #(Required) inbound cidr blocks to allow
                    sg_ids      = list(string)  #(Optional) inbound security group ids to allow
                    sg_names    = list(string)  #(Optional) inbound security group name to allow (security group name is key of this rule)
                    description = string        #(Optional) inbound rule description
                })))
                egresses        = list(object({ #(Optional) security group egress rule definition
                    protocol    = string        #(Required) outbound protocol
                    port_ranges = list(string)  #(Required) outbound port range to allow
                    cidr_blocks = list(string)  #(Required) outbound cidr blocks to allow
                    sg_ids      = list(string)  #(Optional) outbound security group ids to allow
                    sg_names    = list(string)  #(Optional) outbound security group name to allow (security group name is key of this rule)
                    description = string        #(Optional) outbound rule description
                })))
            }))
        required: no
        default: {}
        example:
            nsg_rule_map = {
                "ec2-bastion" = {
                    description = "Bastion server security group"
                    ingresses = [
                        {
                            sg_ids      = ["sg-******", "sg-******"]
                            cidr_blocks = ["0.0.0.0/0"]
                            port_ranges = ["22", "2022"]
                            description = "allow ssh inbound traffic"
                        }
                    ]
                    egresses = [
                        {
                            cidr_blocks = ["0.0.0.0/0"]
                            port_ranges = ["443"]
                            descriptoin = "allow all outbound https traffic"
                        }
                    ]
                }
            }
    EOF
    type = any
    default = {}
}
########## Security Group Definition ########## }