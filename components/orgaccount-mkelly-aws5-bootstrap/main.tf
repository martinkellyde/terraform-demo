# Variables

variable "env" {}
variable "account_alias" {}
variable "project" {}
variable "aws_region" {}
variable "aws_account_name" {}
variable "aws_account_engineers" { type = "list" }

# Local provider for local account operations

provider "aws" {
 version = "~> 2.18"
 region = "${var.aws_region}"
}

# Remote provider for remote account operations

provider "aws" {
 version = "~> 2.18"
 alias = "remote"
 region = "${var.aws_region}"
 assume_role = {
   role_arn = "arn:aws:iam::${data.terraform_remote_state.remote_account.account_id}:role/${var.aws_account_name}-admin"
 }
}

data "aws_caller_identity" "current" {}

# Grab the terraform state for the remote account

data "terraform_remote_state" "remote_account" {
  backend = "s3"

  config {
    bucket = "${var.account_alias}-scaffold"
    key    = "${var.project}/${var.aws_region}/${var.env}/orgaccount-${var.aws_account_name}-creation.tfstate"
    region = "${var.aws_region}"
  }
}

module "orgaccount_bootstrap" {
  source = "../../modules/orgaccount-bootstrap"
  env = "${var.env}"
  account_alias = "${var.account_alias}"
  account_number = "${data.aws_caller_identity.current.account_id}"
  project = "${var.project}"
  aws_region = "${var.aws_region}"
  aws_account_name = "${var.aws_account_name}"
  aws_account_engineers = "${var.aws_account_engineers}"
}
