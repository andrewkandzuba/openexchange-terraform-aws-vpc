resource "aws_internet_gateway" "cda-igw" {
  vpc_id = aws_vpc.cda-vpc.id

  tags = {
    Name = "cda-igw"
  }
}

resource "aws_route_table" "cda-public-crt" {

  vpc_id = aws_vpc.cda-vpc.id

  route {
    cidr_block = var.all_subnets
    gateway_id = aws_internet_gateway.cda-igw.id
  }

  tags = {
    Name = "cda-public-rt"
  }
}

resource "aws_route_table_association" "cda-crta-public-subnet" {
  count = length(lookup(var.availability_zones_by_region, var.region_name))

  subnet_id = aws_subnet.cda-public-subnet[count.index].id
  route_table_id = aws_route_table.cda-public-crt.id
}