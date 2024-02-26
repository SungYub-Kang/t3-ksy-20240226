subnet = "$vpc.results.subnet_ids.value.publicSubnet-a"
project = "sample"
ami_id = "ami-0c7217cdde317cfec"
names = [
  "bastion"
]
stage = "dev"
region = "us-east-1"
instance_type = "t2.micro"
region_code = "us"
ssh_keypair_name = "$keypair.results.name.value"
enable_detail_monitoring = false
encrypt_key = null
disks = [
  {
    "name" = "sda",
    "size" = 50
  }
]
delete_data_disk_on_termination = true
instance_profile = null
security_group_ids = [
  "$securitygroup.results.ids.value.bastion"
]
tags = {}
enable_public_access = true
ssh_public_key = null
userdata = null
private_ips = []
delete_os_disk_on_termination = true
iam_policies = [
  "AmazonSSMManagedInstanceCore"
]
