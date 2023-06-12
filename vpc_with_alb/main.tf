provider "aws" {
  region = var.region_name

  default_tags {
    tags = {
      Environment = "Dev"
      Name        = "Provider Tag",
      Purpose     = "CDA 2023"
      Stack       = "test"
    }
  }
}

module "ami" {
  source = "../modules/ami"
}

module "vpc" {
  source = "../modules/vpc"
  region_name = var.region_name
}

module "alb" {
  source = "../modules/alb"
  cda_vpc_id = module.vpc.cda_vpc_id
  cda_public_subnets = module.vpc.cda_public_subnets
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

module "ec2" {
  source = "../modules/ec2"

  ami_id = module.ami.ami_linux_id

  cda_public_subnets = module.vpc.cda_public_subnets
  cda_security_groups = [aws_security_group.ec2_sg_http.id, aws_security_group.ec2_sg_ssh.id]
  cda_availability_zones = [module.vpc.cda_availability_zones]

  boot-script = pathexpand(var.boot-script-file)
}

resource "aws_lb_target_group_attachment" "cad_tg_at" {
  count = length(module.ec2.cda_instances)

  target_group_arn = module.alb.cda_alb_tg_arn
  target_id        = module.ec2.cda_instances[count.index]
}