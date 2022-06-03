variable "aws_region" {}
variable "account_number" {}
variable "backend_name" {}
variable "env" {}
variable "project" {}
variable "ssh_key_name" {}
variable "bastion_instance_type" { default = "t2.micro" }
variable "bastion_public_dns_name" {}
variable "ingress_cidr_blocks" { type = "list" }
variable "r53_zone_id" {}


