provider "aws" {
  region = "${var.aws_region}"
}

provider "aws"
{
    alias = "management"
    region = "${var.aws_region}"
    assume_role {
 #   role_arn = "arn:aws:iam::"${var.management_account_number}":role/peeringrole"
    role_arn = "arn:aws:iam::${var.management_account_number}:role/crossaccount-peering-manual"
    }
 }