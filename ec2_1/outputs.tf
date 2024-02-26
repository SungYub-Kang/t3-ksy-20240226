output "ids" {
    description = <<-EOF
        description: EC2 instance의 이름과 instance ID를 mapping한 정보를 제공합니다.
        ref_var_name: names
        ref_var_type: list
        ref_var_keys: null
        ref_var_filt: null
    EOF
    value = { for k, v in module.ec2: k => v.id }
}

output "public_ips" {
    description = <<-EOF
        description: EC2 instance의 이름과 instance public ip address를 mapping한 정보를 제공합니다.
        ref_var_name: names
        ref_var_type: list
        ref_var_keys: null
        ref_var_filt: null
    EOF
    value = { for k, v in module.ec2: k => v.public_ip }
}

output "private_ips" {
    description = <<-EOF
        description: EC2 instance의 이름과 instance private ip address를 mapping한 정보를 제공합니다
        ref_var_name: names
        ref_var_type: list
        ref_var_keys: null
        ref_var_filt: null
    EOF
    value = { for k, v in module.ec2: k => v.private_ip }
}

output "keypair_name" {
    description = "EC2 instance가 사용하는 SSH keypair의 이름을 제공합니다."
    value = try(aws_key_pair.main[0].key_name, "")
    sensitive = true
}