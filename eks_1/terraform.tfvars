vpc_id = "$vpc.results.id.value"
project = "sample"
cluster_version = "1.28"
cluster_name = "eks_cluster"
cluster_subnet_ids = [
  "$vpc.results.subnet_ids.value.privnatSubnet-a",
  "$vpc.results.subnet_ids.value.privnatSubnet-c"
]
stage = "dev"
region = "us-east-1"
region_code = "us"
cluster_security_group_ids = [
  "$securitygroup.results.ids.value.eks_api"
]
aws_auth_accounts = []
cluster_logs = [
  "audit",
  "api",
  "authenticator"
]
managed_node_groups = {
  "worker" = {
    "subnet_ids" = [
      "$vpc.results.subnet_ids.value.privnatSubnet-a",
      "$vpc.results.subnet_ids.value.privnatSubnet-c"
    ],
    "security_group_ids" = [
      "$securitygroup.results.ids.value.eks_nodegrp"
    ],
    "ami_type" = "AL2_x86_64",
    "ssh_keypair_name" = "$keypair.results.name.value",
    "min_size" = 1,
    "max_size" = 3,
    "desired_size" = 1,
    "instance_types" = [
      "t3.medium"
    ],
    "disk_size" = 50,
    "iam_additional_policies" = [
      "CloudWatchFullAccess",
      "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy",
      "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"
    ]
  }
}
enable_cluster_encryption = true
container_insights_additional_log_groups = []
cluster_iam_additional_policies = []
public_access_cidrs = []
cluster_tags = {}
ingress_subnet_ids = [
  "$vpc.results.subnet_ids.value.publicSubnet-a",
  "$vpc.results.subnet_ids.value.publicSubnet-c"
]
enable_additional_iam_access = false
cluster_log_retention = 30
enable_public_access = false
cluster_addons = [
  {
    "name" = "vpc-cni"
  },
  {
    "name" = "kube-proxy"
  },
  {
    "name" = "coredns"
  },
  {
    "name" = "aws-ebs-csi-driver"
  },
  {
    "name" = "aws-efs-csi-driver"
  }
]
aws_auth_roles = []
aws_auth_users = []
aws_auth_fargate_roles = []
aws_auth_nodes = []
enable_container_insights = false
