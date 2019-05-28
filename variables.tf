variable "vpc_cidr" {
  type = "string"
}

variable "subnet_cidr" {
  type = "string"
}

variable "region" {
  type = "string"
}

variable "s3bucket" {
  type = "string"
}

variable "keyterraform" {
  type    = "string"
  default = "vpc/terraform.tfstate"
}
