provider "aws" {
  region  = "${var.region}"
  version = "~> 2.0"
}

# Create a VPC
resource "aws_vpc" "myvpc" {
  cidr_block = "${var.vpc_cidr}"

  tags = {
    Name = "myvpc"
  }
}

resource "aws_subnet" "first_sb" {
  vpc_id     = "${aws_vpc.myvpc.id}"
  cidr_block = "${var.subnet_cidr}"

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

terraform {
  backend "s3" {
    bucket = "s3terraform44"
    key    = "vpc/terraform.tfstate"
    region = "eu-west-1"
  }
}
