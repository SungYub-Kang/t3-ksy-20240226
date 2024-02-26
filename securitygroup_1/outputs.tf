output "ids" {
    description = <<-EOF
        description: Security Group id map
        ref_var_name: security_groups
        ref_var_type: map
        ref_var_keys: null
        ref_var_filt: null
    EOF
    value = { for k, v in aws_security_group.main: k => v.id }
}