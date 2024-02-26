endpoints = {
    "s3"        = ["public", "privnat"]
}
flowlog_retention = 10
stage = "dev"
enable_flowlog = false
project = "cta"
cidr_block = "10.0.0.0/16"
subnets = {
    publicSubnet-a  = {cidr = "10.0.1.0/24", type = "public",  az = "us-east-1a"},
    publicSubnet-c  = {cidr = "10.0.2.0/24", type = "public",  az = "us-east-1c"},
    privnatSubnet-a = {cidr = "10.0.3.0/24", type = "privnat", az = "us-east-1a"},
    privnatSubnet-c = {cidr = "10.0.4.0/24", type = "privnat", az = "us-east-1c"},
    privateSubnet-a = {cidr = "10.0.5.0/24", type = "private", az = "us-east-1a"},
    privateSubnet-c = {cidr = "10.0.6.0/24", type = "private", az = "us-east-1c"},
}
region = "ap-northeast-2"
nacls = {}
region_code = "kr"
