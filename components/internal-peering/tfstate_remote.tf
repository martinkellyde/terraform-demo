data "terraform_remote_state" "vpc" {
  backend = "s3"

  config {
    bucket = "${var.project}-${var.account_number}-terraform"
    key    = "${var.project}/${var.aws_region}/${var.env}/vpc.tfstate"
    region = "${var.aws_region}"
  }
}

data "terraform_remote_state" "account_vpc" {
  backend = "s3"

  config {
    bucket = "${var.account_name}-${var.account_number}-${var.aws_region}"
    key    = "${var.project}/${var.account_number}/${var.aws_region}/${var.account_environment}/vpc.tfstate"
    region = "${var.aws_region}"
  }
}

data "terraform_remote_state" "account_tools" {
  backend = "s3"

  config {
    bucket = "${var.account_name}-${var.account_number}-${var.aws_region}"
    key    = "${var.project}/${var.account_number}/${var.aws_region}/${var.account_environment}/account-tools.tfstate"
    region = "${var.aws_region}"
  }
}

data "terraform_remote_state" "openvpn_as" {
  backend = "s3"

  config {
    bucket = "${var.account_name}-${var.account_number}-${var.aws_region}"
    key    = "${var.project}/${var.account_number}/${var.aws_region}/${var.account_environment}/openvpn-as.tfstate"
    region = "${var.aws_region}"
  }
}

