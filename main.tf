provider "aws" {
  region  = "eu-west-1"
  version = "~> 2.0"
}

# Create a VPC
resource "aws_vpc" "myvpc" {
  cidr_block = "172.23.0.0/16"

  tags = {
    Name = "myvpc"
  }
}

resource "aws_subnet" "first_sb" {
  vpc_id     = "${aws_vpc.myvpc.id}"
  cidr_block = "172.23.1.0/24"

  tags = {
    Name = "First_sb"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.myvpc.id}"

  tags = {
    Name = "IG"
  }
}

resource "aws_route_table" "r" {
  vpc_id = "${aws_vpc.myvpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }

  tags = {
    Name = "Route Table"
  }
}

resource "aws_route_table_association" "route_first_sb" {
  subnet_id      = "${aws_subnet.first_sb.id}"
  route_table_id = "${aws_route_table.r.id}"
}
