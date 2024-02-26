project = "cta"
security_group_ids = [
  "$securitygroup.results.ids.value.rds"
]
password = "password00!"
engine = "mariadb"
subnet_ids = [
  "$vpc.results.subnet_ids.value.privateSubnet-a",
  "$vpc.results.subnet_ids.value.privateSubnet-c"
]
identifier = "rds"
stage = "dev"
region = "ap-northeast-2"
engine_version = "10.5.23"
instance_type = "db.t3.medium"
region_code = "kr"
username = "admin"
storage_type = "gp2"
snapshot_identifier = null
auto_minor_version_upgrade = true
multi_az = false
maintenance_window = null
manage_master_user_password = false
performance_insights_retention = 7
enable_performance_insights = false
enable_enhanced_monitoring = false
skip_final_snapshot = true
max_storage_size = 100
iops = 1000
options = []
copy_tags_to_snapshot = false
availability_zone = null
backup_retention = 1
export_log_types = []
master_user_secret_kms_key_id = null
deletion_protection = false
monitoring_role_arn = null
tags = {}
enable_public_access = false
port = "3306"
storage_size = 50
performance_insights_kms_key_id = null
monitoring_interval = 60
parameters = []
