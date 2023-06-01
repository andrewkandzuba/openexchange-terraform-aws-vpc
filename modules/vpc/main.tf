resource "aws_vpc" "cda_vpc" {
  cidr_block           = var.main_vpc_cidr
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  instance_tenancy     = "default"

  tags = {
    Name = "cda-vpc"
  }
}

resource "aws_subnet" "cda_public_subnets" {
  count = length(data.aws_availability_zones.available.names)

  vpc_id = aws_vpc.cda_vpc.id
  cidr_block = cidrsubnet(var.public_subnets_cidr, 8, count.index)
  map_public_ip_on_launch = "true"
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "cda-public-subnet-${count.index}"
  }
}

# Find all available AZs in the given AWS region
data "aws_availability_zones" "available" {
  state = "available"

  filter {
    name = "region-name"
    values = [var.region_name]
  }
}

# IGW and RT
resource "aws_internet_gateway" "cda-igw" {
  vpc_id = aws_vpc.cda_vpc.id

  tags = {
    Name = "cda-igw"
  }
}

resource "aws_route_table" "cda-public-crt" {

  vpc_id = aws_vpc.cda_vpc.id

  route {
    cidr_block = var.all_subnets_cidr
    gateway_id = aws_internet_gateway.cda-igw.id
  }

  tags = {
    Name = "cda-public-rt"
  }
}

resource "aws_route_table_association" "cda-crta-public-subnet" {
  count = length(aws_subnet.cda_public_subnets)

  subnet_id = aws_subnet.cda_public_subnets[count.index].id
  route_table_id = aws_route_table.cda-public-crt.id
}