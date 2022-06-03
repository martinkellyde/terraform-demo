data "terraform_remote_state" "vpc" {
  backend = "s3"

  config {
    bucket = "${var.account_name}-${var.account_number}-${var.aws_region}"
    key    = "${var.project}/${var.account_number}/${var.aws_region}/${var.env}/vpc.tfstate"
    region = "${var.aws_region}"
  }
}