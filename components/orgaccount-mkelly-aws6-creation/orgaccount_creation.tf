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

output "account_id" {
  value = "${aws_organizations_account.account.id}"
}

output "account_arn" {
  value = "${aws_organizations_account.account.arn}"
}

output "account_admin_role" {
  value = "arn:aws:iam::${aws_organizations_account.account.id}:role/${var.aws_account_name}-admin"
}