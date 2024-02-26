output "address" {
    description = <<-EOF
        description: The address of the RDS instance
    EOF
    value = module.db.db_instance_address
}

output "endpoint" {
    description = <<-EOF
        description: The connection endpoint
    EOF
    value = module.db.db_instance_endpoint
}

output "engine" {
    description = <<-EOF
        description: The database engine
    EOF
    value = module.db.db_instance_engine
}

output "version" {
    description = <<-EOF
        description: The database The running version of the database
    EOF
    value = module.db.db_instance_engine_version_actual
}

output "identifier" {
    description = <<-EOF
        description: The RDS instance identifier
    EOF
    value = module.db.db_instance_identifier
}

output "port" {
    description = <<-EOF
        description: The database port
    EOF
    value = module.db.db_instance_port
}

output "master_user_secret_arn" {
    description = <<-EOF
        description: The ARN of the master user secret (Only available when manage_master_user_password is set to true)  
    EOF
    value = module.db.db_instance_master_user_secret_arn
}