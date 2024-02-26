provider "aws" {
    region = var.region
}

data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}

locals {
    tag_suffix = "${var.project}_${var.stage}_${var.region_code}"
    iam_role_policy_prefix = "arn:${data.aws_partition.current.partition}:iam::aws:policy"
    cluster_name = "${var.cluster_name}_${local.tag_suffix}"
    aws_auth_users = [ for user in var.aws_auth_users : {
                            userarn  = strcontains(user, "arn:${data.aws_partition.current.partition}") ? user : "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:user/${user}"
                            username = user
                            groups = [ "system:master" ]
                     }]
    cluster_addons = { for k, v in var.cluster_addons: k => { name = k, version = (v == "latest") ? null : v } if length(var.managed_node_groups) > 0 }
    
    timeouts = { create = "60m", update = "60m", delete = "30m" }
}

########## Create EKS Cluster ########## {
module "eks_cluster" {
    source = "terraform-aws-modules/eks/aws"
    version = "~> 19.16"
    
    #### Network Definition #### {
    vpc_id = var.vpc_id
    control_plane_subnet_ids = var.cluster_subnet_ids
    cluster_name = local.cluster_name
    cluster_version = var.cluster_version
    cluster_endpoint_public_access = var.enable_public_access
    cluster_endpoint_public_access_cidrs = var.enable_public_access ? var.public_access_cidrs : null
    cluster_endpoint_private_access = true
    create_cluster_security_group = false
    create_node_security_group = false
    cluster_additional_security_group_ids = var.cluster_security_group_ids
    #### Network Definition #### }
    
    #### Encryption Definition #### {
    cluster_encryption_config = var.enable_cluster_encryption ? { resources = ["secrets"] } : {}
    attach_cluster_encryption_policy = true
    create_kms_key = true
    kms_key_description = "KMS key for ${local.cluster_name}"
    kms_key_deletion_window_in_days = 30
    enable_kms_key_rotation  = true
    #### Encryption Definition #### }
    
    #### Logging Definition #### {
    cluster_enabled_log_types = var.cluster_logs
    cloudwatch_log_group_retention_in_days = var.cluster_log_retention
    cloudwatch_log_group_kms_key_id = null # log group을 암호화 하지는 않음.
    #### Logging Definition #### }
    
    #### IRSA Definition #### {
    enable_irsa = true
    #### IRSA Definition #### }
    
    #### IAM Definition #### {
    create_iam_role = true
    iam_role_name = "r_eks-cluster-${local.cluster_name}"
    iam_role_use_name_prefix = false
    iam_role_description = "EKS cluster role for ${local.cluster_name}"
    iam_role_additional_policies =  { for policy in var.cluster_iam_additional_policies: 
                                        reverse(split("/", policy))[0] => strcontains(policy, "arn:${data.aws_partition.current.partition}") ? policy : "${local.iam_role_policy_prefix}/${policy}"
                                    }
    iam_role_tags = {
        "Name" = "r_eks-cluster-${local.cluster_name}"
        "eks_cluster" = local.cluster_name
    }
    
    cluster_encryption_policy_name = "p_eks-enc_${local.cluster_name}"
    cluster_encryption_policy_use_name_prefix = false
    cluster_encryption_policy_description = "EKS Cluuster encryption policy for ${local.cluster_name}"
    cluster_encryption_policy_tags = {
        "Name" = "p_eks-enc_${local.cluster_name}"
        "eks_cluster" = local.cluster_name
    }
    dataplane_wait_duration = "30s" # use default
    #### IAM Definition #### }

    #### Cluster addons Definition #### {
    # cluster_addons = { for k, v in local.cluster_addons: k => { name = k, addon_version = (v == "latest") ? null : v } }
    # cluster_addons_timeouts = { create = "60m", update = "60m", delete = "30m" }
    #### Cluster addons Definition #### }
    
    #### AWS-auth Definition #### {
    create_aws_auth_configmap = var.enable_additional_iam_access
    manage_aws_auth_configmap = var.enable_additional_iam_access
    aws_auth_node_iam_role_arns_non_windows = var.aws_auth_nodes
    aws_auth_node_iam_role_arns_windows = []
    aws_auth_fargate_profile_pod_execution_role_arns = var.aws_auth_fargate_roles
    aws_auth_roles = var.aws_auth_roles
    aws_auth_users = local.aws_auth_users
    aws_auth_accounts = var.aws_auth_accounts
    #### AWS-auth Definition #### }
    cluster_tags = merge(var.cluster_tags, {
        "Name" = local.cluster_name
        "vpc_id" = var.vpc_id, 
        "subnet_ids" = join(" ", var.cluster_subnet_ids)
    })
    # cluster_timeouts = local.timeouts
}
########## Create EKS Cluster ########## }

########## Managed Node group Definition ########## {
module "managed_node_group" {
    for_each = var.managed_node_groups
    source = "terraform-aws-modules/eks/aws//modules/eks-managed-node-group"
    version = "~> 19.16"
    cluster_name = module.eks_cluster.cluster_name
    cluster_version = module.eks_cluster.cluster_version
    
    platform = "linux"
    enable_bootstrap_user_data = false
    subnet_ids = each.value.subnet_ids
    
    cluster_primary_security_group_id = module.eks_cluster.cluster_primary_security_group_id
    vpc_security_group_ids = each.value.security_group_ids

    launch_template_name = "lt_eks-${each.key}_${local.tag_suffix}"
    launch_template_use_name_prefix = false
    launch_template_description = "Launch template for ${each.key}_${local.tag_suffix} node group"
    launch_template_tags = {
        "Name" = "${each.key}_${local.tag_suffix}"
        "eks_node_group" = "${each.key}_${local.tag_suffix}"
    }
    update_launch_template_default_version = true
    disable_api_termination = false
    maintenance_options = { auto_recovery = "default" }
            
    name = "${each.key}_${local.tag_suffix}"
    use_name_prefix = false
    min_size = each.value.min_size
    max_size = each.value.max_size
    desired_size = each.value.desired_size
    ami_type = try(each.value.ami_type, "AL2_x86_64")
    capacity_type = try(each.value.capacity_type, "ON_DEMAND")
    instance_types = each.value.instance_types
    key_name = try(each.value.ssh_keypair_name, null)
    
    ebs_optimized = false
    block_device_mappings = [{ 
            device_name = "/dev/xvda"
            ebs = {
                delete_on_termination = true
                encrypted = true
                volume_size = try(each.value.disk_size, 100)
                volume_type = try(each.value.disk_type, "gp2")
            }}
    ]

    force_update_version = true
    labels = try(each.value.labels, {})
    taints = try({ for k, v in each.value.taints: k => { key = k, value = split("/", v)[0], effect = split("/", v)[1]} }, {})
    update_config = try(each.value.update_config, { max_unavailable_percentage = 33 })
            
    create_iam_role = true
    iam_role_name = "r_eks-nodegrp-${each.key}_${local.tag_suffix}"
    iam_role_use_name_prefix = false
    iam_role_description = "IAM Role for ${each.key}_${local.tag_suffix} EKS node group"
    iam_role_attach_cni_policy = true
    iam_role_additional_policies = { for policy in try(each.value.iam_additional_policies, []): 
                                        reverse(split("/", policy))[0] => strcontains(policy, "arn:${data.aws_partition.current.partition}") ? policy : "${local.iam_role_policy_prefix}/${policy}"
                                  }
    iam_role_tags = {
        "Name" = "r_eks-nodegrp-${each.key}_${local.tag_suffix}"
        "eks_node_group" = "${each.key}_${local.tag_suffix}"
    }
            
    enable_monitoring = try(each.value.enable_detail_monitoring, false)
    create_schedule = false
    schedules = {}

    tags = merge(try(each.value.tags, {}), {
        "Name" = "${each.key}_${local.tag_suffix}"
        "cluster_id" = local.cluster_name
        "subnet_ids" = join(" ", each.value.subnet_ids)
        "launch_template" = "lt_eks-${each.key}_${local.tag_suffix}"
    })
    # timeouts = local.timeouts
}
########## Managed Node group Definition ########## }

########## Fargate profile Definition ########## {
module "fargate_profile" {
    for_each = var.fargate_profiles
    source = "terraform-aws-modules/eks/aws//modules/fargate-profile"
    version = "~> 19.16"
    cluster_name = module.eks_cluster.cluster_name

    name = "${each.key}_${local.tag_suffix}"
    subnet_ids = each.value.subnet_ids
    selectors = { for k, v in each.value.selectors:
        k => { namespace = v.namespace, labels = try(v.labels, {}) }
    }
    create_iam_role = true
    iam_role_name = "r_eks-fargate-${each.key}_${local.tag_suffix}"
    iam_role_use_name_prefix = false
    iam_role_description = "IAM Role for ${each.key}_${local.tag_suffix} EKS fargate profile"
    iam_role_attach_cni_policy = true
    iam_role_additional_policies = { for policy in try(each.value.iam_additional_policies, []): 
                                     reverse(split("/", policy))[0] => strcontains(policy, "arn:${data.aws_partition.current.partition}") ? policy : "${local.iam_role_policy_prefix}/${policy}"
                              }
    iam_role_tags = {
         "Name" = "r_eks-fargate-${each.key}_${local.tag_suffix}"
         "eks_node_group" = "${each.key}_${local.tag_suffix}"
    }
    tags = merge(try(each.value.tags, {}), {
         "Name" = "${each.key}_${local.tag_suffix}"
         "cluster_id" = module.eks_cluster.cluster_name
         "subnet_ids" = join(" ", each.value.subnet_ids)
    })
    # timeouts = local.timeouts
}
########## Fargate profile Definition ########## }

########## Cluster Addon Definition ########## {
data "aws_eks_addon_version" "main" {
    for_each = { for v in var.cluster_addons: v.name => v if length(var.managed_node_groups) > 0 || length(var.fargate_profiles) > 0 }
    
    addon_name = each.key
    kubernetes_version = module.eks_cluster.cluster_version
    most_recent = true
}

resource "aws_eks_addon" "main" {
    for_each = { for v in var.cluster_addons: v.name => v if length(var.managed_node_groups) > 0 || length(var.fargate_profiles) > 0 }

    cluster_name = module.eks_cluster.cluster_name
    addon_name  = each.key
    addon_version = lower(each.value.version) == "latest" ? data.aws_eks_addon_version.main[each.key].version : each.value.version
    resolve_conflicts = "OVERWRITE" // deprecated from aws 5.0 version
    # resolve_conflicts_on_create = "OVERWRITE"
    # resolve_conflicts_on_update = "OVERWRITE"
    service_account_role_arn = null
    depends_on = [ module.managed_node_group, module.fargate_profile ]
}
########## Cluster Addon Definition ########## }

########## Add tags to vpc and subnets "kubernetes.io/cluster/${var.cluster_name}" = "shared", ########## {
resource "aws_ec2_tag" "vpc" {
    resource_id = var.vpc_id
    key = "kubernetes.io/cluster/${module.eks_cluster.cluster_name}"
    value = "shared"
    depends_on = [ module.eks_cluster ]
}

resource "aws_ec2_tag" "subnet" {
    # for_each key에 not applied resource variable을 넣을 수 없음.
    for_each = merge([ for idx, subnet_id in var.ingress_subnet_ids: {
                    for k, v in { "kubernetes.io/cluster/<YOUR_CLUSTER_ID>" = "shared", "kubernetes.io/role/elb" = "1", "kubernetes.io/role/internal-elb" = "1" }:
                        join("^", ["subnet-${idx}", k, v]) => subnet_id }]...)
                
    resource_id = each.value
    key = replace(split("^", each.key)[1], "<YOUR_CLUSTER_ID>", module.eks_cluster.cluster_name)
    value = split("^", each.key)[2]
    depends_on = [ module.eks_cluster ]
}
########## Add tags to vpc and subnets "kubernetes.io/cluster/${var.cluster_name}" = "shared", ########## }

########## Container insights Definition ########## {
resource "aws_cloudwatch_log_group" "container_insights" {
    for_each = var.enable_container_insights ? toset(concat(["application", "dataplane", "host", "performance"], var.container_insights_additional_log_groups)) : []
    name = "/aws/containerinsights/${local.cluster_name}/${each.key}"
    retention_in_days = var.cluster_log_retention
    kms_key_id = null
    tags = {
        Name = "logs_containerinsights_${each.key}_${local.tag_suffix}"
    }
    depends_on = [ module.eks_cluster ]
}
########## Container insights Definition ########## }

########## Block outbound anyprotocol anyopen (Change 0.0.0.0/0 => EKS SecurityGroupID) ########## {
data "aws_eks_cluster_auth" "current" {
    name = module.eks_cluster.cluster_name
}

provider "kubernetes" {
    host = module.eks_cluster.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks_cluster.cluster_certificate_authority_data)
    token = data.aws_eks_cluster_auth.current.token
}

resource "null_resource" "cluster_sg" {
    #### python 3.8 & boto3 required ####
    triggers = {
        region = var.region
        security_group_id = module.eks_cluster.cluster_primary_security_group_id
    }
    
    provisioner "local-exec" {
        command = <<-EOT
            # if boto3 does not exist, then install modules (upgrade pip and install boto3)
            import sys, subprocess
            try:
                import boto3
            except:
                subprocess.check_call([sys.executable, "-m", "pip", "install", "--upgrade", "pip"])
                subprocess.check_call([sys.executable, "-m", "pip", "install", "--upgrade", "boto3"])
                
            import boto3, json, sys, os, warnings
            from botocore.exceptions import ClientError
            warnings.simplefilter("ignore")
            
            if __name__ == "__main__" :
                try:
                    os.environ["AWS_DEFAULT_REGION"] = "${self.triggers.region}"
                    SecurityGroupID = "${self.triggers.security_group_id}"
                    ec2 = boto3.client( "ec2", aws_access_key_id = os.environ["AWS_ACCESS_KEY_ID"], aws_secret_access_key = os.environ["AWS_SECRET_ACCESS_KEY"])
                    resMsg = "no outbound anyopen rules to change"
                    sgRules = ec2.describe_security_group_rules(Filters = [{"Name": "group-id", "Values": [SecurityGroupID]}])["SecurityGroupRules"]
                    for rule in sgRules:
                        if rule["IsEgress"] and rule["IpProtocol"] == "-1" and "CidrIpv4" in rule and rule["CidrIpv4"] == "0.0.0.0/0":
                            resData = ec2.revoke_security_group_egress(GroupId = SecurityGroupID, SecurityGroupRuleIds = [rule["SecurityGroupRuleId"]] )
                            if resData["Return"]:
                                resData = ec2.authorize_security_group_egress(GroupId = SecurityGroupID, 
                                            IpPermissions = [{"FromPort": -1, "ToPort": -1, "IpProtocol": "-1", "UserIdGroupPairs": [{"GroupId": SecurityGroupID, "Description": "Changed by terraform"}]}])
                                if resData["Return"]:
                                    resMsg = "outbound anyopen rule was successfully changed"
                                else:
                                    raise Exception("error during add new security group rule")
                            else:
                                raise Exception("error during delete old security group rule")
                except Exception as e:
                    print({"Error": e})
                    sys.exit(255)
                print({"Return": resMsg})
                sys.exit(0)
        EOT
        interpreter = ["python3", "-c"]
        quiet = true
    }
    depends_on = [ module.eks_cluster ]
}
########## Block outbound anyprotocol anyopen (Change 0.0.0.0/0 => EKS SecurityGroupID) ########## }