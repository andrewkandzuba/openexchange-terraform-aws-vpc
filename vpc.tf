resource "aws_vpc" "dev-vpc-1" {
  cidr_block           = var.main_vpc_cidr
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  instance_tenancy     = "default"

  tags = {
    Name = "dev-vpc-1"
  }
}

resource "aws_subnet" "dev-public-subnet-1" {
  vpc_id = aws_vpc.dev-vpc-1.id

  cidr_block = var.public_subnets
  map_public_ip_on_launch = "true"
  availability_zone = var.availability_zone_names[0]

  tags = {
    Name = "dev-public-subnet-1"
  }
}