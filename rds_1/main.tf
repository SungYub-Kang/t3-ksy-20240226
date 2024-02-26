provider "aws" {
  region = var.region
}

locals {
  tag_suffix           = "${var.project}-${var.stage}-${var.region_code}"
  
  availability_zone    = var.multi_az ? var.availability_zone : null
  mysql_engines        = ["mysql", "aurora-mysql", "mariadb"]
  postgre_engines      = ["postgres", "aurora-postgresql"]
  oracle_engines       = ["oracle-ee", "oracle-ee-cdb", "oracle-se2", "oracle-se2-cdb"]
  mssql_engines        = ["sqlserver-ee", "sqlserver-ex", "sqlserver-se", "sqlserver-web", "custom-sqlserver-ee", "custom-sqlserver-se", "custom-sqlserver-web"]
  
  major_engine_version = ( contains(local.mysql_engines, var.engine) && length(split(".", var.engine_version)) < 2 ? var.engine_version :
                           contains(local.mysql_engines, var.engine) && length(split(".", var.engine_version)) > 1 ? join(".", slice(split(".", var.engine_version), 0, 2)) :
                           contains(local.postgre_engines, var.engine) ? split(".", var.engine_version)[0] :
                           contains(local.oracle_engines, var.engine)  ? split(".", var.engine_version)[0] :
                           contains(local.mssql_engines, var.engine)   ? "${split(".", var.engine_version)[0]}.0" : null )
  pg_family = ( contains(concat(local.mysql_engines, local.postgre_engines), var.engine)   ? "${var.engine}${local.major_engine_version}" :
                contains(concat(local.oracle_engines, local.mssql_engines), var.engine)  ? "${var.engine}-${local.major_engine_version}" : null )
}

module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "6.3.0"

  #Engine options
  engine         = var.engine
  engine_version = var.engine_version
  # aws rds describe-db-engine-versions --query "DBEngineVersions[].DBParameterGroupFamily"
  family         = local.pg_family

  #Availability and durability
  multi_az      = var.multi_az

  #Settings
  identifier    = "${var.identifier}-${local.tag_suffix}"
  username      = var.username
  manage_master_user_password = var.manage_master_user_password
  password = !var.manage_master_user_password ? var.password : null
  master_user_secret_kms_key_id = var.manage_master_user_password ? var.master_user_secret_kms_key_id : null

  #Instance configuration
  instance_class = var.instance_type

  #Storage
  storage_type          = var.storage_type
  iops                  = (var.storage_type == "io1" || var.storage_type == "gp3") ? var.iops : null
  allocated_storage     = var.storage_size
  max_allocated_storage = var.max_storage_size

  #Connectivity
  vpc_security_group_ids = var.security_group_ids
  create_db_subnet_group = true
  subnet_ids             = var.subnet_ids
  publicly_accessible    = var.enable_public_access
  availability_zone      = local.availability_zone
  port                   = var.port

  #Monitoring
  ##performance_insights
  performance_insights_enabled          = var.enable_performance_insights
  performance_insights_retention_period = var.enable_performance_insights ? var.performance_insights_retention : null
  performance_insights_kms_key_id       = var.enable_performance_insights ? var.performance_insights_kms_key_id : null

  ##enhanced_monitoring
  monitoring_interval    = var.enable_enhanced_monitoring ? var.monitoring_interval : 0
  monitoring_role_arn    = var.enable_enhanced_monitoring ? var.monitoring_role_arn : null
  create_monitoring_role = (var.enable_enhanced_monitoring && var.monitoring_role_arn == null) ? true : false

  #Parameter&Option Group configuration
  parameters = var.parameters
  options = var.options

  #Additional configuration 
  major_engine_version = local.major_engine_version
  ##backup
  backup_retention_period = var.backup_retention
  copy_tags_to_snapshot   = var.copy_tags_to_snapshot
  ##log export
  enabled_cloudwatch_logs_exports = var.export_log_types
  ##maintenace
  auto_minor_version_upgrade = var.auto_minor_version_upgrade
  maintenance_window         = var.auto_minor_version_upgrade ? var.maintenance_window : null
  skip_final_snapshot        = var.skip_final_snapshot


  # Database Deletion Protection
  deletion_protection = var.deletion_protection

  tags = var.tags

  #snapshot
  snapshot_identifier = var.snapshot_identifier

}
