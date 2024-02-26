provider "aws" {
    region = var.region
}

locals {
    tag_suffix = "${var.project}_${var.stage}_${var.region_code}"
    public_key = coalesce(var.public_key, "non-key")
}

# Create instance key pair RSA4096 private key
resource "tls_private_key" "main" {
    count = local.public_key != "non-key" ? 0 : 1
    algorithm = "RSA"
    rsa_bits = 4096
}

# key enrollment to AWS
resource "aws_key_pair" "main" {
    key_name = "${var.name}_${local.tag_suffix}"
    public_key = local.public_key != "non-key" ? local.public_key : tls_private_key.main[0].public_key_openssh
    tags = {
        # Naming rule: 
        Name = "${var.name}_${local.tag_suffix}"
    }
}