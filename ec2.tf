resource "aws_instance" "cda-instance" {
  count                  = length(lookup(var.availability_zones_by_region, var.region_name))

  ami                    = lookup(var.ami-image, var.region_name)
  instance_type          = var.instance_type

  # VPC
  subnet_id              = aws_subnet.cda-public-subnet[count.index].id

  # Security Group
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  # the Public SSH key
  key_name               = aws_key_pair.generated_key.id

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
    private_key = tls_private_key.demo_key.private_key_pem
    host = self.public_ip
  }

  tags = {
    Name = "cda-instance-${count.index}"
  }
}