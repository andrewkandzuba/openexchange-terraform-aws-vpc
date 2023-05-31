resource "aws_security_group" "alb_sg" {
  vpc_id = aws_vpc.cda-vpc.id

  egress {
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = [var.all_subnets]
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [var.all_subnets]
  }

  tags = {
    Name = "cda-alb-sg"
  }
}

resource "aws_security_group" "ec2_sg" {
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
    cidr_blocks = [var.all_subnets]
  }

  // Only reachable via ALB instance
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    # cidr_blocks = [var.all_subnets]
    security_groups = [aws_security_group.alb_sg.id]
  }

  tags = {
    Name = "cda-ec2-sg"
  }
}