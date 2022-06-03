resource "aws_s3_bucket" "account_logs" {
  bucket = "${var.account_name}-${var.account_number}-${var.aws_region}-logs"
}