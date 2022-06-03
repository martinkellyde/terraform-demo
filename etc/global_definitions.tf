variable "aws_region" {}
variable "account_number" {}
variable "account_alias" {}
variable "env" {}
variable "project" {}
variable "r53_zone_id" {}
variable "backend_name" {}
variable "kms_key_arn" {}
variable "kms_key" {}
variable "tls_certificate" {}
variable "techtest_public_dns_name" {}
variable "bastion_public_dns_name" {}
variable "jira_public_dns_name" {}
variable "jira_host_instance_type" {}
variable "build_public_dns_name" {}
variable "techtest_host_instance_type" { default     = "t2.nano" }
variable "ssh_key_name" { default     = "mdkelly_ssh" }
variable "techtest_database_storage_size" {}
variable "techtest_database_master_instance_type" {}
variable "techtest_database_replica_instance_type" {}
variable "techtest_database_master_monitoring_interval" {}
variable "techtest_database_replica_monitoring_interval" {}
variable "techtest_backup_retention_period" {}
variable "techtest_master_database_password" {}
variable "techtest_database_username" {}
variable "techtest_database_port" {}
variable "logbucket_name" {}
variable "nat_gateway_eip" {}

variable "ingress_cidr_blocks" {}


variable "vpc_cidr" {}
variable "public_subnet_1_cidr" {}
variable "public_subnet_1_az" {}
variable "public_subnet_2_cidr" {}
variable "public_subnet_2_az" {}
variable "public_subnet_3_cidr" {}
variable "public_subnet_3_az" {}


variable "private_subnet_1_cidr" {}
variable "private_subnet_1_az" {}
variable "private_subnet_2_cidr" {}
variable "private_subnet_2_az" {}
variable "private_subnet_3_cidr" {}
variable "private_subnet_3_az" {}
