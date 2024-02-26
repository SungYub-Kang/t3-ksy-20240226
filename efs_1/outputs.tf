output "id" {
    description = <<-EOF
        description: The ID that identifies the file system (e.g., fs-ccfc0d65)
    EOF
    value = module.efs.id
}

output "dns_name" {
    description = <<-EOF
        description: The DNS name for the filesystem (e.g., file-system-id.efs.aws-region.amazonaws.com)
    EOF
    value = module.efs.dns_name
}

output "arn" {
    description = <<-EOF
        description: Amazon Resource Name of the file system
    EOF
    value = module.efs.arn
}

output "mount_targets" {
    description = <<-EOF
        description: Map of mount targets created and their attributes
    EOF
    value = module.efs.mount_targets
}