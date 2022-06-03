data "terraform_remote_state" "vpc" {
  backend = "s3"

  config {
    bucket = "${var.backend_name}"
    key    = "${var.project}/${var.aws_region}/${var.env}/vpc.tfstate"
    region = "${var.aws_region}"
  }
}