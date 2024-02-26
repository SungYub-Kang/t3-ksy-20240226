security_groups = {
    "bastion" = {
        description = "Bastion server security group"
        ingresses   = [
            {
                cidr_blocks = ["123.123.123.123/32"]
                port_ranges = ["22"]
                description = "[changeme] allow ssh inbound traffic from Your location"
            }
        ]
        egresses    = [
            {
                cidr_blocks = ["0.0.0.0/0"]
                port_ranges = ["443"]
                description = "allow all outbound https traffic"
            },
            {
                sg_names = ["rds"]
                port_ranges = ["3306"]
                description = "allow outbound mariadb traffic"
            }
        ]
    }
    "rds" = {
        description = "RDS security group"
        ingresses   = [
            {
                sg_names = ["eks_nodegrp", "bastion"]
                port_ranges = ["3306"]
                description = "allow inbound mariadb traffic"
            }
        ]
        egresses    = []
    }
    "efs" = {
        description = "EFS mount target security group"
        ingresses   = [
            {
                sg_names = ["eks_nodegrp"]
                port_ranges = ["2049"]
                description = "allow inbound NFS traffic"
            }
        ]
        egresses    = []
    }
    "eks_api"       = {
        description = "EKS API Server additional security group"
        ingresses   = [
            {
                sg_names = ["bastion"]
                port_ranges = ["443"]
                description = "allow inbound kubectl api traffic"
            }
        ]
        egresses   = []
    }
    "eks_nodegrp"   = {
        description = "EKS nodegroup security group"
        ingresses   = []
        egresses    = [
            {
                cidr_blocks = ["0.0.0.0/0"]
                port_ranges = ["443"]
                description = "allow all outbound https traffic"
            },
            {
                sg_names = ["rds"]
                port_ranges = ["3306"]
                description = "allow outbound rds traffic"
            },
            {
                sg_names = ["efs"]
                port_ranges = ["2049"]
                description = "allow outbound nfs traffic"
            }
        ]
    }
}
stage = "dev"
vpc_id = "$vpc.results.id.value"
project = "cta"
region = "ap-northeast-2"
region_code = "kr"
