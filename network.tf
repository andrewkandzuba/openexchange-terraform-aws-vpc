resource "aws_internet_gateway" "dev-igw-1" {
  vpc_id = aws_vpc.dev-vpc-1.id

  tags = {
    Name = "dev-igw-1"
  }
}

resource "aws_route_table" "dev-public-crt-1" {

  vpc_id = aws_vpc.dev-vpc-1.id

  route {
    cidr_block = var.all_subnets
    gateway_id = aws_internet_gateway.dev-igw-1.id
  }

  tags = {
    Name = "dev-public-rt-1"
  }
}

resource "aws_route_table_association" "dev-crta-public-subnet-1" {
  subnet_id = aws_subnet.dev-public-subnet-1.id
  route_table_id = aws_route_table.dev-public-crt-1.id
}

resource "aws_security_group" "ssh-allowed" {
  vpc_id = aws_vpc.dev-vpc-1.id

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