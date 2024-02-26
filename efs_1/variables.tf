########## Project Definition ########## {
variable "project" {
    description = <<-EOF
        description: Project name or service name
        type: string
        required: yes
        example: project = "gitops"
    EOF
    type = string
}

variable "stage" {
    description = <<-EOF
        description: Service stage of project (dev, stg, prd etc)
        type: string
        required: yes
        example: stage = "dev"
    EOF
    type = string
}

variable "region" {
    description = <<-EOF
        description: '''Region name to create resources
                     refer to https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.RegionsAndAvailabilityZones.html#Concepts.RegionsAndAvailabilityZones.Regions'''
        type: string
        required: yes
        default: ap-northeast-2
        example: region = "ap-northeast-2"
    EOF
    type = string
}

variable "region_code" {
    description = <<-EOF
        description: '''Country code for region
                     refer to https://countrycode.org'''
        type: string
        required: yes
        default: kr
        example: region_code = "kr"
    EOF
    type = string
}
########## Project Definition ########## }

########## General Definition ########## {
variable "name" {
    description = <<-EOF
        description: Name of the EFS volume
        type: string
        required: yes
        example: name = "sample"
    EOF
    type = string  
}

variable "encrypted" {
    description = <<-EOF
        description: Specifies whether EFS data encryption is enabled. If true, the disk will be encrypted.
        type: bool
        required: no
        default: true
        example: encrypted = true
    EOF
    type = bool
    default = true
}
########## General Definition ########## }

##### Network Definition ##### {
variable "subnet_ids" {
    description = <<-EOF
        description: Subnet ID List to add the EFS mount target in.
        type: list(string)
        required: yes
        example: subnet_ids = ["subnet-xxxxxxxx", "subnet-xxxxxxxx"]
    EOF
    type = list(string)
    validation {
        condition = length(var.subnet_ids) > 0
        error_message = "[ERROR] Subnet id value is required. please enter at least one subnet id in List"
    }
}

variable "security_group_ids" {
    description = <<-EOF
        description: List of VPC security groups to associate for EFS mount target
        type: list(string)
        required: yes
        example: security_group_ids = ["sg-xxxxxxxx"]
    EOF
    type = list(string)
}
##### Network Definition ##### }

##### Backup & Lifecycle Definition ##### {
variable "enable_automatic_backups" {
    description = <<-EOF
        description: Specifies whether Automatic Backups are enabled
        type: bool
        required: no
        default: true
        example: enable_automatic_backups = true
    EOF
    type = bool
    default = true
}

variable "lifecycle_policy" {
    description = <<-EOF
        description: '''EFS filesystem lifecycle management rule
                     refer to: https://docs.aws.amazon.com/efs/latest/ug/API_LifecyclePolicy.html'''
        type: map(string)
        required: no
        default: {}
        example: '''
            lifecycle_policy = {
                transition_to_ia = "AFTER_7_DAYS"
                transition_to_primary_storage_class = "AFTER_1_ACCESS"
            }'''
    EOF
    type = map(string)
    default = {}
    validation {
        condition = alltrue([for k, v in var.lifecycle_policy : contains(["transition_to_ia", "transition_to_primary_storage_class", "transition_to_archive"], k)])
        error_message = "lifecycle_policy key name must be one of 'transition_to_ia', 'transition_to_primary_storage_class', 'transition_to_archive'"
    }
    validation {
        condition = contains(["AFTER_1_DAY", "AFTER_7_DAYS", "AFTER_14_DAYS", "AFTER_30_DAYS", "AFTER_60_DAYS", "AFTER_90_DAYS"], try(var.lifecycle_policy["transition_to_ia"], "AFTER_30_DAYS"))
        error_message = "'transition_to_ia' must be one of 'AFTER_1_DAY', 'AFTER_7_DAYS', 'AFTER_14_DAYS', 'AFTER_30_DAYS', 'AFTER_60_DAYS', 'AFTER_90_DAYS'"
    }
    validation {
        condition = contains(["AFTER_1_ACCESS"], try(var.lifecycle_policy["transition_to_primary_storage_class"], "AFTER_1_ACCESS"))
        error_message = "'transition_to_primary_storage_class' must be 'AFTER_1_ACCESS'"
    }
    validation {
        condition = contains(["AFTER_1_DAY", "AFTER_7_DAYS", "AFTER_14_DAYS", "AFTER_30_DAYS", "AFTER_60_DAYS", "AFTER_90_DAYS"], try(var.lifecycle_policy["transition_to_archive"], "AFTER_90_DAYS"))
        error_message = "'transition_to_archive' must be one of 'AFTER_1_DAY', 'AFTER_7_DAYS', 'AFTER_14_DAYS', 'AFTER_30_DAYS', 'AFTER_60_DAYS', 'AFTER_90_DAYS'"
    }
}
##### Backup & Lifecycle Definition ##### }

##### Performance Definition ##### {
variable "performance_mode" {
    description = <<-EOF
        description: The file system performance mode. The default is "generalPurpose". Valid Values: ("generalPurpose", "maxIO")
        type: string
        required: no
        default: "generalPurpose"
        example: performance_mode = "generalPurpose"
    EOF
    type = string
    default = "generalPurpose"
}

variable "throughput_mode" {
    description = <<-EOF
        description: Throughput mode for the file system. Defaults to "bursting". Valid values: ("bursting", "elastic", "provisioned")
        type: string
        required: no
        default: "bursting"
        example: throughput_mode = "bursting"
    EOF
    type = string
    default = "bursting"
}

variable "provisioned_throughput_in_mibps" {
    description = <<-EOF
        description: The throughput, measured in MiB/s, that you want to provision for the file system. Only applicable with "throughput_mode" set to "provisioned"
        type: number
        required: no
        default: 100
        example: provisioned_throughput_in_mibps = 100
    EOF
    type = number
    default = 100
}
##### Performance Definition ##### }

##### Access Points Definition ##### {
variable "access_points" {
    description = <<-EOF
        description: A map of access point definitions to create
        type: any
        default: {}
        example: '''
            access_points = {
                posix_example = {
                    name = "posix-example"
                    posix_user = {
                        gid            = 1001
                        uid            = 1001
                        secondary_gids = [1002]
                    }

                    tags = {
                        Additionl = "yes"
                    }
                }
                root_example = {
                    root_directory = {
                        path = "/example"
                        creation_info = {
                            owner_gid   = 1001
                            owner_uid   = 1001
                            permissions = "755"
                        }
                    }
                }
            }'''
    EOF
    type = any
    default = {}
}
##### Access Points Definition ##### }

##### ETC Definition ##### {
variable "tags" {
    description = <<-EOF
        description: AWS EFS Resource tags
        type: map(string)
        required: no
        default: {}
        example: tags = { "vpc_id": "vpc-****" }
    EOF
    type = map(string)
    default = {}
}
##### ETC Definition ##### }