resource "aws_instance" "cda-instance" {
  count                  = length(lookup(var.availability_zones_by_region, var.region_name))

  ami                    = lookup(var.aims, var.region_name)
  instance_type          = var.instance_type

  # VPC
  subnet_id              = aws_subnet.cda-public-subnet[count.index].id

  # Security Group
  vpc_security_group_ids = [aws_security_group.ssh-allowed.id]

  # the Public SSH key
  key_name               = aws_key_pair.default-region-key-pair.id

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
    private_key = file(var.private-key-path)
    host = self.public_ip
  }

  tags = {
    Name = "cda-instance-${count.index}"
  }
}

resource "aws_security_group" "ssh-allowed" {
  vpc_id = aws_vpc.cda-vpc.id

  egress {
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = [var.all_subnets]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    // This means, all ip address are allowed to ssh !
    // Do not do it in the production.
    // Put your office or home address in it!
    cidr_blocks = [var.all_subnets]
  }

  //If you do not add this rule, you can not reach the NGIX
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [var.all_subnets]
  }

  tags = {
    Name = "ssh-allowed"
  }
}