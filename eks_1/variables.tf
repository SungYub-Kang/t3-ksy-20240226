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

########## EKS Cluster Definition ########## {
variable "vpc_id" {
    description = <<-EOF
        description: VPC ID to create EKS cluster
        type: string
        required: yes
        example: vpc_id = "vpc-XXXXXXXX"
    EOF
    type = string
}

variable "cluster_subnet_ids" {
    description = <<-EOF
        description: Subnet ID List for CNIs to connect EKS control plane (more than 2 IDs)
        type: list(string)
        required: yes
        example: cluster_subnet_ids = ["subnet-xxxxx","subnet-xxxxx"]
    EOF
    type = list(string)
}

variable "ingress_subnet_ids" {
    description = <<-EOF
        description: k8s에서 ingress를 설치할 때 사용할 subnet ID 리스트
        type: list(string)
        required: no
        default: []
    EOF
    type = list(string)
    default = []
}

variable "cluster_name" {
    description = <<-EOF
        description: EKS Cluster의 이름
        type: string
        required: yes
    EOF
    type = string
}

variable "cluster_version" {
    description = <<-EOF
        description: '''EKS Cluster version
                     refer to https://docs.aws.amazon.com/eks/latest/userguide/kubernetes-versions.htm'''
        type: string
        required: yes
        example: cluster_version = "1.28"
    EOF
    type = string
}

variable "enable_public_access" {
    description = <<-EOF
        description: EKS Cluster api server를 외부 public에 오픈할지 여부 설정
        type: bool
        required: no
        default: false
        example: enable_public_access = false
    EOF
    type = bool
    default = false
}

variable "public_access_cidrs" {
    description = <<-EOF
        description: public_access = true일 경우, 외부에 접근을 허용할 source IPv4 CIDR 리스트
        type: list(string)
        required: no
        default: []
        example: public_access_cidrs = ["203.244.212.0/24"]
    EOF
    type = list(string)
    default = []
}

variable "cluster_addons" {
    description = <<-EOF
        description: '''EKS cluster에 addon(vpc-cni, kubeproxy, coredns, efs/ebs_cni)으로 설치할 기능을 기술
                     refer to https://docs.aws.amazon.com/eks/latest/userguide/eks-add-ons.html'''
        type: list(object({
            name    = string                        #(Required) addon name
            version = optional(string, "latest")    #(Optional) addon version (default: latest)
        }))
        required: no
        default: []
        example: '''
            cluster_addons = [
                { name = "vpc-cni", version = "v1.11.4-eksbuild.1" },
                { name = "kube-proxy", version = "v1.23.8-eksbuild.2" },
                { name = "coredns", version = "v1.8.7-eksbuild.2" },
                { name = "aws-ebs-csi-driver", version = "v1.11.4-eksbuild.1" }
            ]'''
    EOF
    type = list(object({
        name    = string                        #(Required) addon name
        version = optional(string, "latest")    #(Optional) addon version (default: latest)
    }))
    default = []
}

variable "cluster_security_group_ids" {
    description = <<-EOF
        description: '''EKS에 설정할 additional security group ID 리스트
                     EKS Cluster가 내부 사용 용도로 자동으로 생성하는 security group id에 대한 정의가 아니고, 추가적인 security group입니다.'''
        type: list(string)
        required: no
        default: []
    EOF
    type = list(string)
    default = []
}

variable "enable_cluster_encryption" {
    description = <<-EOF
        description: Cluster의 Resource를 Encryption하여 보관할 것인지 여부설정
        type: bool
        required: no
        default: true
    EOF
    type = bool
    default = true
}

variable "cluster_iam_additional_policies" {
    description = <<-EOF
        description: '''EKS cluster에 설정할 Additional IAM Policy 
                     AmazonEKSLocalOutpostClusterPolicy, AmazonEKSClusterPolicy, AmazonEKSVPCResourceController 이외에 추가로 설정할 policy'''
        type: list(string)
        required: no
        default: []
    EOF
    type = list(string)
    default = []
}

variable "enable_additional_iam_access" {
    description = <<-EOF
        description: '''Whether to allow additional IAM Role or IAM User Access for EKS Cluster.
                     If it is set to `true`, access items can be added to aws-auth ConfigMap.
                     Only applicable with `aws_auth_roles`, `aws_auth_fargate_roles`, `aws_auth_users`, `aws_auth_accounts` and `aws_auth_nodes` set to `true`'''
        type: bool
        required: no
        default: false
        example: enable_additional_iam_access = true
    EOF
    type = bool
    default = false
}

variable "aws_auth_roles" {
    description = <<-EOF
        description: EKS cluster에 Admin접근 가능한 IAM role을 설정. IAM role object 형식으로 입력.
        type: list(any)
        required: no
        default: []
        example: '''
            aws_auth_roles = [
                {
                    rolearn  = "arn:aws:iam::66666666666:role/role1"
                    username = "role1"
                    groups   = ["system:masters"]
                }
            ]'''
    EOF
    type = list(any)
    default = []
}

variable "aws_auth_fargate_roles" {
    description = <<-EOF
        description: EKS cluster에 Admin 접근 가능한 Fargate execution IAM role ARN 설정
        type: list(string)
        required: no
        default: []
        example: aws_auth_fargate_roles = [ "arn:aws:iam::111111111111:role/fargateExecutionRole1" ]
    EOF
    type = list(string)
    default = []
}

variable "aws_auth_users" {
    description = <<-EOF
        description: EKS cluster에 Admin접근 가능한 IAM user 설정
        type: list(string)
        required: no
        default: []
        example: aws_auth_users = [ "user1", "user2" ]
    EOF
    type = list(string)
    default = []
}

variable "aws_auth_accounts" {
    description = <<-EOF
        description: EKS cluster에 Admin접근 가능한 AWS account 설정 (12자리 숫자 형식)
        type: list(string)
        required: no
        default: []
        example: aws_auth_accounts = [ "123412341234", "789078907890" ]
    EOF
    type = list(string)
    default = []
}

variable "aws_auth_nodes" {
    description = <<-EOF
        description: EKS cluster에 Admin접근 가능한 EC2 instance의 node IAM role ARN 설정 (non-windows만 적용)
        type: list(string)
        required: no
        default: []
        example: aws_auth_nodes = [ "arn:aws:iam::111111111111:role/nodeRole1" ]
    EOF
    type = list(string)
    default = []
}

variable "cluster_logs" {
    description = <<-EOF
        description: EKS Cluster의 로그 중 저장할 로그 타입 (api, audit, authenticator, controllerManager, scheduler)을 설정
        type: list(string)
        required: no
        default: [ "audit", "api", "authenticator" ]
        example: cluster_logs = [ "audit", "api", "authenticator", "controllerManager", "scheduler" ]
    EOF
    type = list(string)
    default = [ "audit", "api", "authenticator" ]
}

variable "cluster_log_retention" {
    description = <<-EOF
        description: EKS Cluster 로그를 cloudwatch log group에 저장할 기간설정 (기본 90일, Production의 경우 일반적으로 1년)
        type: number
        required: no
        default: 90
        example: cluster_log_retention = 365
    EOF
    type = number
    default = 90
}

variable "enable_container_insights" {
    description = <<-EOF
        description: cloudwatch container insights를 사용할지 여부 설정
        type: bool
        required: no
        default: false
        example: enable_container_insights = false
    EOF
    type = bool
    default = false
}

variable "container_insights_additional_log_groups" {
    description = <<-EOF
        description: '''Cloudwatch container insights에서 사용하는 기본적인 log group이외에 추가적인 log group을 설정 (ex, prometheus) 
                     기본적인 log groups : ["alication", "dataplane", "host", "performance"]'''
        type: list(string)
        required: no
        default: []
        example: ["prometheus"]
    EOF
    type = list(string)
    default = []
}

variable "cluster_tags" {
    description = <<-EOF
        description: Cluster에 설정할 Resource Tag 정보
        type: map(string)
        required: no
        default: {}
    EOF
    type = map(string)
    default = {}
}
########## EKS Cluster Definition ########## }

########## Managed node group definition ########## {
variable "managed_node_groups" {
    description = <<-EOF
        description: '''EKS worker node group을 정의
                     ami_type: AL2_x86_64, AL2_ARM_64, AL2_X86_64_GPU, BOTTLEROCKET_ARM_64, BOTTLEROCKET_X86_64, WINDOWS_CORE_2019_X86_64, WINDOWS_CORE_2022_X86_64, WINDOWS_FULL_2019_X86_64, WINDOWS_FULL_2022_X86_64
                     capacity_type: ON_DEMAND, SPOT
                     instance_types: https://aws.amazon.com/ec2/instance-types
                     disk_type: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ebs-volume-types.html'''
        type: map(object({
            subnet_ids                  = list(string)                                                  #(Required) Worker node를 설치하기 위한 subnet ID 리스트 (반드시 2개 이상을 입력해야 합니다.)
            security_group_ids          = list(string)                                                  #(Required) Worker node group에 적용할 security group ID 리스트를 설정합니다.
            ami_type                    = string                                                        #(Required) AMI 의 Machine/Architecture type을 설정합니다. (ex, AL2_x86_64)
            ssh_keypair_name            = optional(string, null)                                        #(Optional) Worker node에 접속하기 위한 SSH keypair name (만일 제공하지 않으면, Worker node에 접속하지 않음)
            min_size                    = number                                                        #(Required) Min worker node 의 댓수를 입력합니다.
            max_size                    = number                                                        #(Required) Max worker node 의 댓수를 입력합니다.
            desired_size                = number                                                        #(Required) Desired worker node 의 댓수를 입력합니다.
            capacity_type               = optional(string, "ON_DEMAND")                                 #(Optional) Instance type을 설정합니다. (ON_DEMAND or SPOT)
            disk_type                   = optional(string, "gp2")                                       #(Optional) Worker node가 사용할 OS disk의 타입 (default: gp2)
            disk_size                   = optional(number, 100)                                         #(Optional) Worker node가 사용할 OS disk의 크기 (default: 100(GB))
            instance_types              = list(string)                                                  #(Required) Worker node instance types (ex, [ t2.micro, c5.xlarge])
            labels                      = optional(map(string), {})                                     #(Optional) Worker node에 설정할 label (k8s) (default: {})
            taints                      = optional(map(string), {})                                     #(Optional) Worker node에 설정할 taints (k8s) <key>/<value>/<effect>의 순서로 정의 (ex { dedicated = {"dedicated/gpuGroup/NO_SCHEDULE"} }) (default: {})
            update_config               = optional(map(string), { max_unavailable_percentage = 25 })    #(Optioanl) Worker node을 update할 때 사용할 rolling update 방식 (max_unavailable_percentage = 25의 경우, 25%씩 순차적으로 update를 진행함을 의미) (default: { max_unavailable_percentage = 25 })
            enable_detail_monitoring    = optional(bool, false)                                         #(Optional) cloudwatch detailed monitoring(1분 간격, 유료)를 사용할지 여부 설정 (default: false)
            iam_additional_policies     = optional(list(string), [])                                    #(Optional) IAM Additional Policies (AmazonEKSWorkerNodePolicy, AmazonEC2ContainerRegistryReadOnly, AmazonEKS_CNI_Policy가 기본적으로 설정되며, 이외의 다른 policy를 붙일 때 사용)
            tags                        = optional(map(string), {})                                     #(Optional) Worker node group에 설정할 Resource tag (default: {})
        }))
        required: no
        default: {}
    EOF
    type = map(object({
        subnet_ids                  = list(string)                                                  #(Required) Worker node를 설치하기 위한 subnet ID 리스트 (반드시 2개 이상을 입력해야 합니다.)
        security_group_ids          = list(string)                                                  #(Required) Worker node group에 적용할 security group ID 리스트를 설정합니다.
        ami_type                    = string                                                        #(Required) AMI 의 Machine/Architecture type을 설정합니다. (ex, AL2_x86_64)
        ssh_keypair_name            = optional(string, null)                                        #(Optional) Worker node에 접속하기 위한 SSH keypair name (만일 제공하지 않으면, Worker node에 접속하지 않음)
        min_size                    = number                                                        #(Required) Min worker node 의 댓수를 입력합니다.
        max_size                    = number                                                        #(Required) Max worker node 의 댓수를 입력합니다.
        desired_size                = number                                                        #(Required) Desired worker node 의 댓수를 입력합니다.
        capacity_type               = optional(string, "ON_DEMAND")                                 #(Optional) Instance type을 설정합니다. (ON_DEMAND or SPOT)
        disk_type                   = optional(string, "gp2")                                       #(Optional) Worker node가 사용할 OS disk의 타입 (default: gp2)
        disk_size                   = optional(number, 100)                                         #(Optional) Worker node가 사용할 OS disk의 크기 (default: 100(GB))
        instance_types              = list(string)                                                  #(Required) Worker node instance types (ex, [ t2.micro, c5.xlarge])
        labels                      = optional(map(string), {})                                     #(Optional) Worker node에 설정할 label (k8s) (default: {})
        taints                      = optional(map(string), {})                                     #(Optional) Worker node에 설정할 taints (k8s) <key>/<value>/<effect>의 순서로 정의 (ex { dedicated = {"dedicated/gpuGroup/NO_SCHEDULE"} }) (default: {})
        update_config               = optional(map(string), { max_unavailable_percentage = 25 })    #(Optioanl) Worker node을 update할 때 사용할 rolling update 방식 (max_unavailable_percentage = 25의 경우, 25%씩 순차적으로 update를 진행함을 의미) (default: { max_unavailable_percentage = 25 })
        enable_detail_monitoring    = optional(bool, false)                                         #(Optional) cloudwatch detailed monitoring(1분 간격, 유료)를 사용할지 여부 설정 (default: false)
        iam_additional_policies     = optional(list(string), [])                                    #(Optional) IAM Additional Policies (AmazonEKSWorkerNodePolicy, AmazonEC2ContainerRegistryReadOnly, AmazonEKS_CNI_Policy가 기본적으로 설정되며, 이외의 다른 policy를 붙일 때 사용)
        tags                        = optional(map(string), {})                                     #(Optional) Worker node group에 설정할 Resource tag (default: {})
    }))
    default = {}
    validation {
        condition = length([ for k, v in var.managed_node_groups: v.capacity_type if !contains(["ON_DEMAND", "SPOT"], v.capacity_type)]) == 0
        error_message = "[ERROR] capacity type must be one of ON_DEMAND, SPOT"
    }
    validation {
        condition = length([ for k, v in var.managed_node_groups: v.ami_type if !contains(["AL2_x86_64", "AL2_ARM_64", "AL2_X86_64_GPU", "BOTTLEROCKET_ARM_64", "BOTTLEROCKET_X86_64", "WINDOWS_CORE_2019_X86_64", "WINDOWS_CORE_2022_X86_64", "WINDOWS_FULL_2019_X86_64", "WINDOWS_FULL_2022_X86_64"], v.ami_type)]) == 0
        error_message = "[ERROR] ami_type must be one of AL2_x86_64, AL2_ARM_64, AL2_X86_64_GPU, BOTTLEROCKET_ARM_64, BOTTLEROCKET_X86_64, WINDOWS_CORE_2019_X86_64, WINDOWS_CORE_2022_X86_64, WINDOWS_FULL_2019_X86_64, WINDOWS_FULL_2022_X86_64"
    }
}
########## Managed node group definition ########## }

########## Fargate profile definition ########## {
variable "fargate_profiles" {
    description = <<-EOF
        description: EKS에서 EC2 타입의 worker node group 이 아니라, fargate(serverless)를 사용할 경우 설정합니다.
        type: map(object({
            subnet_ids  = list(string)                  #(Required) Fargate service와 연결하기 위한 ENI를 설치할 subnet ID리스트 (반드시 2개 이상을 설정합니다.)
            selectors   = list(object({                 #(Required) Selector 설정
                namespace   = string                    #(Required) fargate에 생성할 pods의 namespace
                labels      = optional(map(string), {}) #(Optional) fargate에 생성할 pods의 labels (default: {})
            ))
            tags        = optional(map(string), {})     #(Optional) fargate profile에 설정할 resource tag (default: {})
        }))
        required: no
        default: {}
    EOF
    type = map(object({
        subnet_ids  = list(string)                  #(Required) Fargate service와 연결하기 위한 ENI를 설치할 subnet ID리스트 (반드시 2개 이상을 설정합니다.)
        selectors   = list(object({                 #(Required) Selector 설정
            namespace   = string                    #(Required) fargate에 생성할 pods의 namespace
            labels      = optional(map(string), {}) #(Optional) fargate에 생성할 pods의 labels (default: {})
        }))
        tags        = optional(map(string), {})     #(Optional) fargate profile에 설정할 resource tag (default: {})
    }))
    default = {}
}
########## Fargate profile definition ########## }