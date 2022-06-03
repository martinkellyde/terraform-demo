
variable "aws_region" {
  type = "string"
}

variable "env" {
  type = "string"
}

variable "project" {
  type = "string"
}

variable "vpc_cidr" {
  type = "string"
}

variable "public_subnet_1_cidr" {
  type = "string"
}

variable "public_subnet_2_cidr" {
  type = "string"
}

variable "public_subnet_3_cidr" {
  type = "string"
}

variable "private_subnet_1_cidr" {
  type = "string"
}

variable "private_subnet_2_cidr" {
  type = "string"
}

variable "private_subnet_3_cidr" {
  type = "string"
}

variable "public_subnet_1_az" {
  type = "string"
}

variable "public_subnet_2_az" {
  type = "string"
}

variable "public_subnet_3_az" {
  type = "string"
}

variable "private_subnet_1_az" {
  type = "string"
}

variable "private_subnet_2_az" {
  type = "string"
}

variable "private_subnet_3_az" {
  type = "string"
}

variable "nat_gateway_eip" {
  type = "string"
}
