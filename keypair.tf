# Generate RSA private key
resource "tls_private_key" "demo_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Sends your public key to the instance
resource "aws_key_pair" "generated_key" {
  key_name   = var.key_name
  public_key = tls_private_key.demo_key.public_key_openssh
}

output "private_key" {
  value     = tls_private_key.demo_key.private_key_pem
  sensitive = true
}