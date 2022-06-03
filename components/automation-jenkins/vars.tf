variable "az_count" { default = "3" }
variable "aws_region" {}
variable "account_number" {}
variable "backend_name" {}
variable "env" {}
variable "project" {}
variable "jenkins_host_instance_type" { default = "t3.medium"}
variable "ssh_key_name" {}
variable "kms_key" {}
variable "kms_key_arn" {}

variable "ingress_cidr_blocks" {
  type = "list"
}

variable "throughput_mode" {
  default = "provisioned"
}
variable "jenkins_efs_throughput" {
  default = "10"
}


variable "timed_recycle" {
  description = "Controls if autoscaling groups run scale in and scale out to update from latest launch config"
  default = true
}