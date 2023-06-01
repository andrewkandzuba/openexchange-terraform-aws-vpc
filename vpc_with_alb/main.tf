provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Environment = "Dev"
      Name        = "Provider Tag",
      Purpose     = "CDA 2023"
      Stack       = "test"
    }
  }
}

module "vpc" {
  source = "../modules/vpc"
}

module "ec2" {
  source = "../modules/ec2"

  cda_public_subnets = module.vpc.cda_public_subnets
  cda_security_groups = [aws_security_group.ec2_sg_http.id, aws_security_group.ec2_sg_ssh.id]
  cda_availability_zones = [module.vpc.cda_availability_zones]
  boot-script = pathexpand("./ec2-user-data.sh")
}

module "alb" {
  source = "../modules/alb"
  cda_vpc_id = module.vpc.cda_vpc_id
  cda_public_subnets = module.vpc.cda_public_subnets
  cda_instances = module.ec2.cda_instances
  all_subnets_cidr = [module.vpc.all_subnets_cidr]
}

resource "aws_security_group" "ec2_sg_http" {
  vpc_id = module.vpc.cda_vpc_id

  egress {
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = [module.vpc.all_subnets_cidr]
  }

  // Only reachable via ALB instance
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    # cidr_blocks = [var.all_subnets]
    security_groups = [module.alb.cda_alb_sg.id]
  }

  tags = {
    Name = "cda-ec2-sg-http"
  }
}

resource "aws_security_group" "ec2_sg_ssh" {
  vpc_id = module.vpc.cda_vpc_id

  egress {
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = [module.vpc.all_subnets_cidr]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [module.vpc.all_subnets_cidr]
  }

  tags = {
    Name = "cda-ec2-sg-ssh"
  }
}