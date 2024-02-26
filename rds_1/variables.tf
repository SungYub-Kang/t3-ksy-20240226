########## Project Definition ########## {
variable "project" {
    description = <<-EOF
        description: Project name or service name
        type: string
        required: yes
        example: project = "gitops"
    EOF
    type = string
}

variable "stage" {
    description = <<-EOF
        description: Service stage of project (dev, stg, prd etc)
        type: string
        required: yes
        example: stage = "dev"
    EOF
    type = string
}

variable "region" {
    description = <<-EOF
        description: '''Region name to create resources
                     refer to https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.RegionsAndAvailabilityZones.html#Concepts.RegionsAndAvailabilityZones.Regions'''
        type: string
        required: yes
        default: ap-northeast-2
        example: region = "ap-northeast-2"
    EOF
    type    = string
}

variable "region_code" {
    description = <<-EOF
        description: '''Country code for region
                     refer to https://countrycode.org'''
        type: string
        required: yes
        default: kr
        example: region_code = "kr"
    EOF
    type = string
}
########## Project Definition ########## }

########## Network Definition ########## {
variable "subnet_ids" {
    description = <<-EOF
        description: A list of VPC subnet IDs to install RDS
        type: list(string)
        required: yes
        example: subnet_ids = ["subnet-xxxxx","subnet-xxxxx"]
    EOF
    type = list(string)
}

variable "multi_az" {
    description = <<-EOF
        description: Specifies if the RDS instance is multi-AZ
        type: bool
        required: no
        default: false
        example: multi_az = false
    EOF
    type    = bool
    default = false
}

variable "availability_zone" {
    description = <<-EOF
        description: '''The Availability Zone of the RDS instance 
                     (single-az instance에 해당하며, multi-az variable과 exclusive합니다.)'''
        type: string
        required: no
        default: null
        example: availability_zone = "ap-northeast-2c"
    EOF
    type    = string
    default = null
}

variable "enable_public_access" {
    description = <<-EOF
        description:  Bool to control if instance is publicly accessible
        type: bool
        required: no
        default: false
        example: enable_public_access = false
    EOF
    type    = bool
    default = false
}

variable "security_group_ids" {
    description = <<-EOF
        description: List of VPC security groups to associate for RDS
        type: list(string)
        required: yes
        example: security_group_id = ["sg-xxxxxxxx"]
    EOF
    type    = list(string)
}
########## Network Definition ########## }

########## DBMS Definition ########## {
variable "instance_type" {
    description = <<-EOF
        description: '''The instance type of the RDS instance
                     refer to: https://aws.amazon.com/rds/instance-types/'''
        type: string
        required: yes
        example: instance_type = "db.t3.large"
    EOF
    type    = string
}

variable "storage_type" {
    description = <<-EOF
        description: One of 'standard' (magnetic), 'gp2' (general purpose SSD), 'gp3' (new generation of general purpose SSD), or 'io1' (provisioned IOPS SSD). The default is 'io1' if iops is specified, 'gp2' if not. If you specify 'io1' or 'gp3' , you must also include a value for the 'iops' parameter
        type: string
        required: no
        default: "gp2"
        example: storage_type = "gp2"
    EOF
    type    = string
    default = "gp2"
    validation {
        condition = contains(["standard", "gp2", "gp3", "io1"], var.storage_type)
        error_message = "[ERROR] storage type must be one of standard, gp2, gp3, io1"
    }
}

variable "storage_size" {
    description = <<-EOF
        description: The allocated storage in gigabytes
        type: number
        required: no
        default: 200
        example: storage_size = 200
    EOF
    type    = number
    default = 200
}

variable "max_storage_size" {
    description = <<-EOF
        description: Specifies the value for Storage Autoscaling
        type: number
        required: no
        default: 1000
        example: max_allocated_storage = 1000
    EOF
    type    = number
    default = 1000
}

variable "iops" {
    description = <<-EOF
        description: The amount of provisioned IOPS. Setting this implies a storage_type of 'io1' or `gp3`. See `notes` for limitations regarding this variable for `gp3`
        type: number
        required: no
        default: 1000
        example: iops = 1000
    EOF
    type    = number
    default = 1000
}

variable "engine" {
    description = <<-EOF
        description: '''DB engine to create RDS DB(aurora-mysql, mariadb, mysql, oracle-ee, postgres, sqlserver-ee etc.)
                     refer to: ttps://docs.aws.amazon.com/ko_kr/AmazonRDS/latest/APIReference/API_CreateDBInstance.html'''
        type: string
        required: yes
        example: engine = "mysql"
    EOF
    type    = string
    validation {
        condition = contains(["mysql", "aurora-mysql", "mariadb", "postgres", "aurora-postgresql", "oracle-ee", "oracle-ee-cdb", "oracle-se2", "oracle-se2-cdb", "sqlserver-ee", "sqlserver-ex", "sqlserver-se", "sqlserver-web", "custom-sqlserver-ee", "custom-sqlserver-se", "custom-sqlserver-web"], var.engine)
        error_message = "[ERROR] engine must be one of mysql, aurora-mysql, mariadb, postgres, aurora-postgresql, oracle-ee, oracle-ee-cdb, oracle-se2, oracle-se2-cdb, sqlserver-ee, sqlserver-ex, sqlserver-se, sqlserver-web, custom-sqlserver-ee, custom-sqlserver-se, custom-sqlserver-web" 
    }
}

variable "engine_version" {
    description = <<-EOF
        description: The engine version to use
        type: string
        required: yes
        example: engine = "5.7"
    EOF
    type = string
}

variable "port" {
    description = <<-EOF
        description: The port on which the DB accepts connections (varies by engine type)
        type: string
        required: no
        default: "3306"
        example: port = "3306"
    EOF
    type    = string
    default = "3306"
}
########## DBMS Definition ########## }

########## Database Definition ########## {
variable "identifier" {
    description = <<-EOF
        description: DB identifier to create RDS DB 
        type: string
        required: yes
        example: identifier = "db-demo"
    EOF
    type = string
}

variable "parameters" {
    description = <<-EOF
        description: A list of DB parameters (map) to apply
        type: list(map(string))
        required: no
        default: []
        example: '''
            parameters = [
                             {
                                 name  = "character_set_client"
                                 value = "utf8mb4"
                             },
                             {
                                 name  = "character_set_server"
                                 value = "utf8mb4"
                             }
                         ]'''
    EOF
    type = list(map(string))
    default = []
}

variable "options" {
    description = <<-EOF
        description: A list of Options to apply
        type: any
        required: no
        default: []
        example: '''
            options = [
                           {
                                option_name = "MARIADB_AUDIT_PLUGIN"
                                option_settings = [
                                    {
                                        name  = "SERVER_AUDIT_EVENTS"
                                        value = "CONNECT"
                                    },
                                    {
                                        name  = "SERVER_AUDIT_FILE_ROTATIONS"
                                        value = "37"
                                    },
                                ]
                           },
                       ]'''
    EOF
    type = any
    default = []
}

variable "auto_minor_version_upgrade"{
    description = <<-EOF
        description: Indicates that minor engine upgrades will be applied automatically to the DB instance during the maintenance window
        type: bool
        required: no
        default: true
        example: auto_minor_version_upgrade = true
    EOF
    type    = bool
    default = true
}

variable "username" {
    description = <<-EOF
        description: Username for the master DB user(postgresql:postgres)
        type: string
        required: yes
        example: username = "admin"
    EOF
    type    = string
    sensitive = true
}

variable "manage_master_user_password" {
    description = <<-EOF
        description: Set to true to allow RDS to manage the master user password in Secrets Manager
        type: bool
        required: no
        default: false
        example: manage_master_user_password = true
    EOF
    type    = bool
    default = false
}

variable "master_user_secret_kms_key_id" {
    description = <<-EOF
        description: The key ARN, key ID, alias ARN or alias name for the KMS key to encrypt the master user password secret in Secrets Manager. If not specified, the default KMS key for your Amazon Web Services account is used.
        type: string
        required: no
        default: null
        example: master_user_secret_kms_key_id = "arn:aws:kms:region_code:accountid:key/xxx"
    EOF
    type    = string
    default = null
}

variable "password" {
    description = <<-EOF
        description: password for the master DB user. Note that this may show up in logs, and it will be stored in the state file. 
        type: string
        input_type: string(password)
        required: yes
        example: password = "password"
    EOF
    type    = string
    sensitive = true
}
########## Database Definition ########## }

########## Monitoring Definition ########## {
variable "enable_performance_insights" {
    description = <<-EOF
        description: Specifies whether Performance Insights are enabled
        type: bool
        required: no
        default: false
        example: enable_performance_insights = false
    EOF
    type    = bool
    default = false
}

variable "performance_insights_retention" {
    description = <<-EOF
        description: The amount of time in days to retain Performance Insights data. Valid values are `7`, `731` (2 years) or a multiple of `31`
        type: number
        required: no
        default: 7
        example: performance_insights_retention = 7
    EOF
    type    = number
    default = 7
}

variable "performance_insights_kms_key_id" {
    description = <<-EOF
        description: The ARN for the KMS key to encrypt Performance Insights data
        type: string
        required: no
        default: null
        example: performance_insights_kms_key_id = "arn:aws:kms:region_code:accountid:key/xxx"
    EOF
    type    = string
    default = null
}

variable "enable_enhanced_monitoring" {
    description = <<-EOF
        description: Specifies whether enhanced monitoring are enabled
        type: bool
        required: no
        default: false
        example: enable_enhanced_monitoring = false
    EOF
    type    = bool
    default = false
}

variable "monitoring_interval" {
    description = <<-EOF
        description: The interval, in seconds, between points when Enhanced Monitoring metrics are collected for the DB instance. To disable collecting Enhanced Monitoring metrics, specify 0. The default is 0. Valid Values: 0, 1, 5, 10, 15, 30, 60
        type: number
        required: no
        default: 60
        example: monitoring_interval = 60
    EOF
    type    = number
    default = 60
}

variable "monitoring_role_arn"{
    description = <<-EOF
        description: The ARN for the IAM role that permits RDS to send enhanced monitoring metrics to CloudWatch Logs. Must be specified if monitoring_interval is non-zero
        type: string
        required: no
        default: null
        example: monitoring_role_arn = "arn:aws:iam::acount-id:role/xxxxxx"
    EOF
    type    = string
    default = null
}

variable "export_log_types"{
    description = <<-EOF
        description: List of log types to enable for exporting to CloudWatch logs. If omitted, no logs will be exported. Valid values (depending on engine): alert, audit, error, general, listener, slowquery, trace, postgresql (PostgreSQL), upgrade (PostgreSQL)
        type: list(string)
        required: no
        default: []
        example: export_log_types = ["audit", "error"]
    EOF
    type    = list(string)
    default = []
}
########## Monitoring Definition ########## }

########## Backup/Restore Definition ########## {
variable "backup_retention"{
    description = <<-EOF
        description: The days to retain backups for (7 to 35 days)
        type: number
        required: no
        default: 7
        example: backup_retention = 1
    EOF
    type    = number
    default = 7
}

variable "snapshot_identifier" {
    description = <<-EOF
        description: Specifies whether or not to create this database from a snapshot. This correlates to the snapshot ID you would find in the RDS console.
        type: string
        required: no
        default: null
        example: snapshot_identifier= "rds:production-2015-06-26-06-05"
    EOF
    type = string
    default = null
}
########## Backup/Restore Definition ########## }

########## ETC Definition ########## {
variable "maintenance_window"{
    description = <<-EOF
        description: The window to perform maintenance in. Syntax: 'ddd:hh24:mi-ddd:hh24:mi'. Eg: 'Mon:00:00-Mon:03:00'
        type: string
        required: no
        default: null
        example: maintenance_window = "Mon:00:00-Mon:03:00"
    EOF
    type    = string
    default = null
}

variable "deletion_protection"{
    description = <<-EOF
        description: The database cannot be deleted when this value is set to true
        type: bool
        required: no
        default: bool
        example: deletion_protection = false
    EOF
    type    = bool
    default = false
}

variable "skip_final_snapshot"{
    description = <<-EOF
        description: Determines whether a final DB snapshot is created before the DB instance is deleted. If true is specified, no DBSnapshot is created. If false is specified, a DB snapshot is created before the DB instance is deleted
        type: bool
        required: no
        default: true
        example: skip_final_snapshot = true
    EOF
    type    = bool
    default = true
}

variable "copy_tags_to_snapshot"{
    description = <<-EOF
        description: On delete, copy all Instance tags to the final snapshot
        type: bool
        required: no
        default: false
        example: copy_tags_to_snapshot = false
    EOF
    type    = bool
    default = false
}

variable "tags" {
    description = <<-EOF
        description: AWS RDS Resource tags
        type: map(string)
        required: no
        default: {}
        example: tags = { "vpc_id": "vpc-****" }
    EOF
    type = map(string)
    default = {}
}
########## ETC Definition ########## }