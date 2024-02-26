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

########## Network Definition ########## {
variable "subnet" {
    description = <<-EOF
        description: subnet name or id to create instance
        type: string
        required: yes
        example: subnet = "privateSubnet"
    EOF
    type = string
}

variable "availabilty_zone" {
    description = <<-EOF
        description: '''Availability zone name to create instance
                     refer to https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.RegionsAndAvailabilityZones.html#Concepts.RegionsAndAvailabilityZones.AvailabilityZones'''
        type: string
        required: no
        default: null
        example: availability_zone = "ap-northeast-2a"
    EOF
    type = string
    default = null
}

variable "private_ips" {
    description = <<-EOF
        description: User specific private ip address for instance
        type: list(string)
        required: no
        default: []
        example: private_ips = ["10.0.0.21/32"]
    EOF
    type = list(string)
    default = []
}

variable "enable_public_access" {
    description = <<-EOF
        description: Assign public ip address to instance in public subnet (public accessible EC2 instance)
        type: bool
        required: no
        default: false
        example: enable_public = true
    EOF
    type = bool
    default = false
}

variable "security_group_ids" {
    description = <<-EOF
        description: Security group or firewall ID for instance access
        type: list(string)
        required: no
        default: []
        example: security_group_ids = ["sg-********", "sg-********"]
    EOF
    type = list(string)
    default = []
}
########## Network Definition ########## }

########## Compute Definition ########## {
variable "names" {
    description = <<-EOF
        description: '''names of instance (VM)
                     동일한 type(configuration)의 EC2 인스턴스를 여러개 만드려면 이름을 나열합니다.'''
        type: list(string)
        required: yes
        example: names = ["bastion"]
    EOF
    type = list(string)
}

variable "ami_id" {
    description = <<-EOF
        description: '''Image ID to create instance OS
                     AMI ID는 region에 따라 모두 다르므로, https://docs.aws.amazon.com/en_us/AWSEC2/latest/UserGuide/finding-an-ami.html을 참조하여 AMI ID를 참조 합니다.'''
        type: string
        required: yes
        example: ami_id = "ami-058165de3b7202099"
    EOF
    type = string
}

variable "instance_type" {
    description = <<-EOF
        description: '''EC2 machine type (instance type)
                     refer to https://aws.amazon.com/ec2/instance-types/'''
        type: string
        required: yes
        example: machine_type = "c5.xlarge"
    EOF
    type = string
}

variable "enable_detail_monitoring" {
    description = <<-EOF
        description: Enable detail monitoring (1 min period)
        type: bool
        required: no
        default: false
        example: enable_detail_monitoring = false
    EOF
    type = bool
    default = false
}
variable "tags" {
    description = <<-EOF
        description: AWS Resource tags
        type: map(string)
        required: no
        default: {}
        example: tags = { vpc_id : "vpc-********" }
    EOF
    type = map(string)
    default = {}
}
########## Compute Definition ########## }

########## OS Definition ########## {
variable "ssh_public_key" {
    description = <<-EOF
        description: ssh key id or public key for instance to access
        type: string
        required: no
        default: null
        example: ssh_key = "ssh-rsa public key"
    EOF
    type = string
    default = null
    sensitive = true
}

variable "ssh_keypair_name" {
    description = <<-EOF
        description: ssh key pair name
        type: string
        required: no
        default: null
        example: ssh_key = "ssh_keypair_name"
    EOF
    type = string
    default = null
    sensitive = true
}

variable "userdata" {
    description = <<-EOF
        description: cloud init script (bash or cloud_init)
        input_type: string(textarea)
        required: no
        default: null
        example: '''
            userdata = <<-EOT
                #!/bin/bash
                sudo echo "
                     ******************************************************************
                     * This system is for the use of authorized users only. Usage of  *
                     * this system may be monitored and recorded by system personnel. *
                     * Anyone using this system expressly consents to such monitoring *
                     * and is advised that if such monitoring reveals possible        *
                     * evidence of criminal activity, system personnel may provide    *
                     * the evidence from such monitoring to law enforcement officials.*
                     ******************************************************************
                " > /etc/sshd_banner
                sudo echo "Banner /etc/sshd_banner" >> /etc/ssh/sshd_config
                sudo echo "[configuration] restarting sshd service"
                sudo service sshd restart 
            EOT'''
    EOF
    type = string
    default = null
    sensitive = true
}
########## OS Definition ########## }

########## Storage Definition ########## {
variable "encrypt_key" {
    description = <<-EOF
        description: KMS key ID to encrypt disk
        type: string
        required: no
        default: null
        example: encrypt_key = "disk_enc_key_id"
    EOF
    type = string
    default = null
}

variable "delete_os_disk_on_termination" {
    description = <<-EOF
        description: if true, os disk deleted when instance terminated
        type: bool
        required: no
        default: true
        example: delete_os_disk_on_termination = true
    EOF
    type = bool
    default = true
}

variable "delete_data_disk_on_termination" {
    description = <<-EOF
        description: if true, data disk deleted when instance terminated
        type: bool
        required: no
        default: true
        example: delete_data_disk_on_termination = true
    EOF
    type = bool
    default = true
}

variable "disks" {
    description = <<-EOF
        description: '''storage disks(EBS) definition, 
                     리스트의 첫번째 디스크가 root disk입니다.
                     type: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ebs-volume-types.html'''
        type: list(object({
            name        = string                    #(Required) name of disk
            type        = optional(string, "gp2")   #(Required) os disk type
            size        = optional(number, 100)     #(Required) size in gb
            iops        = optional(number, null)    #(Optional) aws ebs optimized instance only
            throughput  = optional(number, null)    #(Optional) aws ebs optimized instance only
            snapshot    = optional(string, null)    #(Optional) snapshot for recovey of data disk
            tags        = optional(map(string), {}) #(Optional) disk resource tags
        }))
        required: no
        example: disks = [{ name = "sda" }, { name = "sdf", size = 50}]
    EOF
    type = list(object({
        name        = string                    #(Required) name of disk
        type        = optional(string, "gp2")   #(Required) os disk type
        size        = optional(number, 100)     #(Required) size in gb
        iops        = optional(number, null)    #(Optional) aws ebs optimized instance only
        throughput  = optional(number, null)    #(Optional) aws ebs optimized instance only
        snapshot    = optional(string, null)    #(Optional) snapshot for recovey of data disk
        tags        = optional(map(string), {}) #(Optional) disk resource tags
    }))
}
########## Storage Definition ########## }

########## IAM Definition ########## {
variable "instance_profile" {
    description = <<-EOF
        description: Access IAM Identity to access AWS resource 
        type: string
        required: no
        default: null
        example: instance_profile = "EC2_profile"
    EOF
    type = string
    default = null
}

variable "iam_policies" {
    description = <<-EOF
        description: Access IAM role definition to create iam_instance_profile (exclusive with service_access_identity)
        type: list(string)
        required: no
        default: []
        example: iam_policies = [ "AdministratorAccess" ]
    EOF
    type = list(string)
    default = []
}
########## IAM Definition ########## }