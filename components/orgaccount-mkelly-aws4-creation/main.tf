variable "aws_region" {}
variable "aws_account_name" {}

provider "aws" {
# version = "~> 1.6"
 region = "${var.aws_region}"
}

resource "aws_organizations_account" "account" {
  name  = "${var.aws_account_name}"
  email = "martinkelly+${var.aws_account_name}@gmail.com"
# Decide your IAM billing strategy at the start and stick to it. Payment method API fails are evil  
#  iam_user_access_to_billing = "ALLOW"
  role_name = "${var.aws_account_name}-admin"
  lifecycle {
    ignore_changes = ["role_name"]
  }
}




module "orgaccount_creation" {
  source = "../../modules/orgaccount-creation"
  aws_region = "${var.aws_region}"
  aws_account_name = "${var.aws_account_name}"
}

output "account_id" {
  value = "${module.orgaccount_creation.account_id}"
}

output "account_arn" {
  value = "${module.orgaccount_creation.account_arn}"
}

output "account_admin_role" {
  value = "arn:aws:iam::${module.orgaccount_creation.account_id}:role/${var.aws_account_name}-admin"
}