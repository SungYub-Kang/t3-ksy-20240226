output "private_key" {
    description = <<-EOF
        description: AWS instance SSH private key, sensitive value
    EOF
    value = try(tls_private_key.main[0].private_key_pem, "")
    sensitive = true
}

output "public_key" {
    description = <<-EOF
        description: AWS instance SSH public key, sensitive value
    EOF
    value = try(tls_private_key.main[0].public_key_pem, "")
    sensitive = true
}

output "name" {
    description = <<-EOF
        description: SSH keypair name
    EOF
    value = aws_key_pair.main.key_name
    sensitive = false
}

output "id" {
    description = <<-EOF
        description: SSH keypair id
    EOF
    value = aws_key_pair.main.id
    sensitive = false
}