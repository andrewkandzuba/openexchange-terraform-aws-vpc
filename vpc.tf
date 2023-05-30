resource "aws_vpc" "cda-vpc" {
  cidr_block           = var.main_vpc_cidr
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  instance_tenancy     = "default"

  tags = {
    Name = "cda-vpc"
  }
}

resource "aws_subnet" "cda-public-subnet" {
  count = length(lookup(var.availability_zones_by_region, var.region_name))

  vpc_id = aws_vpc.cda-vpc.id
  cidr_block = cidrsubnet(var.public_subnets, 8, count.index)
  map_public_ip_on_launch = "true"
  availability_zone = lookup(var.availability_zones_by_region, var.region_name)[count.index]

  tags = {
    Name = "cda-public-subnet-${count.index}"
  }
}