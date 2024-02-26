provider "aws" {
    region = var.region
}

locals {
    tag_suffix = "${var.project}_${var.stage}_${var.region_code}"
    subnets = { for i, v in var.subnet_ids: tostring(i) => v } # to-be data select ( data.aws_subnet.current[v].availability_zone )
}

# data "aws_subnet" "current" {
#     for_each = toset(var.subnet_ids)
#     id = each.value
# }

module "efs" {
    source = "terraform-aws-modules/efs/aws"
    version = "1.4.0"

    ##### General Definition ##### {
    name = "${var.name}_${local.tag_suffix}"
    creation_token = "${var.name}_${local.tag_suffix}"
    encrypted = var.encrypted
    ##### General Definition ##### }

    ##### Network Definition ##### {
    create_security_group = false
    mount_targets = { for k, v in local.subnets: k => { subnet_id = v, security_groups = var.security_group_ids } }
    ##### Network Definition ##### }

    ##### Backup & Lifecycle Definition ##### {
    enable_backup_policy = var.enable_automatic_backups
    lifecycle_policy = var.lifecycle_policy
    ##### Backup & Lifecycle Definition ##### }

    ##### Performance Definition ##### {
    performance_mode = var.performance_mode
    throughput_mode = var.throughput_mode
    provisioned_throughput_in_mibps = var.provisioned_throughput_in_mibps
    ##### Performance Definition ##### }

    ##### Policy Definition ##### {
    attach_policy = true
    deny_nonsecure_transport = true
    ##### Policy Definition ##### }

    ##### Access points Definition ##### {
    access_points = var.access_points
    ##### Access points Definition ##### }

    tags = var.tags
}