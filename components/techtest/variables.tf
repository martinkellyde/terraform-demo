variable "aws_region" {}
variable "account_number" {}
variable "env" {}
variable "project" {}
variable "r53_zone_id" {}
variable "backend_name" {}

variable "techtest_public_dns_name" {}
variable "techtest_host_instance_type" {
  default     = "t2.micro"
  description = "The AWS instance type to start new techtest hosts as."
}

variable "ssh_key_name" {
  default     = "mdkelly_ssh"
  description = "The name of the master SSH keypair (created manually)."
}

variable "database_storage_size" {}
variable "database_master_instance_type" {}
variable "database_replica_instance_type" {}
variable "database_master_monitoring_interval" {}
variable "database_replica_monitoring_interval" {}
variable "backup_retention_period" {}
variable "master_database_password" {}
variable "database_username" {}
variable "techtest_database_port" {}
