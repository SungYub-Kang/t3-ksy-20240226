project = "sample"
security_group_ids = [
  "$securitygroup.results.ids.value.efs"
]
stage = "dev"
name = "efs"
subnet_ids = [
  "$vpc.results.subnet_ids.value.privateSubnet-a",
  "$vpc.results.subnet_ids.value.privateSubnet-c"
]
region = "us-east-1"
region_code = "us"
provisioned_throughput_in_mibps = 100
performance_mode = "generalPurpose"
tags = {}
encrypted = true
enable_automatic_backups = true
throughput_mode = "bursting"
lifecycle_policy = {}
access_points = {}
