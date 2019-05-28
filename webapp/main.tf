provider "aws" {
  region  = "${var.region}"
  version = "~> 2.0"
}

terraform {
  backend "s3" {
    bucket         = "s3terraform44"
    key            = "webapp/terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "dbterraform"
  }
}

data "terraform_remote_state" "mainvpc" {
  backend = "s3"

  config {
    bucket = "s3terraform44"
    key    = "vpc/terraform.tfstate"
    region = "eu-west-1"
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  owners = ["099720109477"] # Canonical id developper }
}

data "template_file" "YYYY" {
  template = "${file("${path.module}/userdata.tpl")}"

  vars {
    username = "..."
  }
}

resource "aws_security_group" "allow_all" {
  name        = "allow_all"
  description = "Allow all inbound traffic"
  vpc_id      = "${data.terraform_remote_state.mainvpc.id_vpc}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "mykey" {
  key_name   = "mykey"
  public_key = "${var.keypub}"
}

resource "aws_instance" "web" {
  ami                         = "${data.aws_ami.ubuntu.id}"
  instance_type               = "t2.micro"
  key_name                    = "${aws_key_pair.mykey.key_name}"
  vpc_security_group_ids      = ["${aws_security_group.allow_all.id}"]
  user_data                   = "${data.template_file.YYYY.rendered}"
  subnet_id                   = "${data.terraform_remote_state.mainvpc.id_subnet[0]}"
  associate_public_ip_address = 1

  tags {
    Name = "HelloWorld"
  }
}
