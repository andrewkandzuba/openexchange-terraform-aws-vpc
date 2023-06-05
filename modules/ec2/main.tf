resource "aws_instance" "cda_instance" {
  count                  = length(var.cda_public_subnets)

  ami                    = var.ami_id
  instance_type          = var.instance_type

  # VPC
  subnet_id              = var.cda_public_subnets[count.index]

  # Security Group
  vpc_security_group_ids = var.cda_security_groups

  # the Public SSH key
  key_name = aws_key_pair.ec2_ssh_pub_key.id

  # Public IP assignment
  associate_public_ip_address = true

  # Root EBS volume
  root_block_device {
    volume_type = "gp2"
    volume_size = "8"
  }

  # nginx installation
  provisioner "file" {
    source      = var.boot-script
    destination = "/tmp/${var.boot-script}"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/${var.boot-script}",
      "sudo /tmp/${var.boot-script}"
    ]
  }

  connection {
    user        = var.ec2-user
    private_key = tls_private_key.ec2_ssh_pk.private_key_pem
    host        = self.public_ip
  }

  tags = {
    Name = "cda-instance-${count.index}"
  }
}

# Generate RSA private key
resource "tls_private_key" "ec2_ssh_pk" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Sends your public key to the instance
resource "aws_key_pair" "ec2_ssh_pub_key" {
  key_name   = var.key_name
  public_key = tls_private_key.ec2_ssh_pk.public_key_openssh
}