resource "aws_s3_bucket" "codebuild_cache" {
  bucket = "${var.project}-${data.aws_caller_identity.current.account_id}-${var.aws_region}-${var.env}-codebuild-cache"
}