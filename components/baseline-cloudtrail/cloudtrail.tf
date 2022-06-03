resource "aws_cloudtrail" "account" {
  name                          = "tf-trail-${var.account_name}"
  s3_bucket_name                = "${aws_s3_bucket.cloudtrail_bucket.id}"
  include_global_service_events = true
  is_multi_region_trail         = true
  cloud_watch_logs_role_arn     = "${aws_iam_role.cloudtrail_cloudwatch_role.arn}"
  cloud_watch_logs_group_arn    = "${aws_cloudwatch_log_group.cloudtrail_log_group.arn}"
#  kms_key_id                    = "${aws_kms_key.cloudtrail_key.arn}"
  depends_on                    = ["aws_s3_bucket.cloudtrail_bucket"]
}


resource "aws_kms_key" "cloudtrail_key" {
  description             = "${var.account_name}-cloudtrail-key"
  enable_key_rotation     = "true"
#  policy                  = "${data.template_file.key_policy_template.rendered}"
}


resource "aws_cloudwatch_log_group" "cloudtrail_log_group" {
  name = "${var.account_name}-cloudtrail-log-group"

  tags {
    Environment = "${var.env}"
    Application = "CloudTrail"
  }
}


resource "aws_s3_bucket" "cloudtrail_bucket" {
  bucket        = "${var.account_name}-${var.account_number}-cloudtrail-bucket"
  force_destroy = true
  logging {
    target_bucket = "${var.account_name}-${var.account_number}-${var.aws_region}-logs"
    target_prefix = "log/"
  }
}


resource "aws_s3_bucket_policy" "cloudtrail_bucket_policy" {
  bucket = "${aws_s3_bucket.cloudtrail_bucket.id}"
  policy = "${data.template_file.s3_policy_template.rendered}"
}


data "template_file" "s3_policy_template" {
  template = "${file("${path.module}/templates/bucket_policy.json")}"
  vars {
    cloudtrail_bucket_arn  = "${aws_s3_bucket.cloudtrail_bucket.arn}"
  }
}



data "template_file" "key_policy_template" {
  template = "${file("${path.module}/templates/key_policy.json")}"
  vars {
    account_number  = "${var.account_number}"
  }
}



resource "aws_iam_role" "cloudtrail_cloudwatch_role" {
  name = "${var.account_name}-cloudtrail_cloudwatch_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "cloudtrail.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "cloudtrail_cloudwatch_policy" {
  name = "cloudtrail_cloudwatch_policy"
  role = "${aws_iam_role.cloudtrail_cloudwatch_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": [
        "kms:Decrypt",
        "kms:DescribeKey",
        "kms:Encrypt",
        "kms:GenerateDataKey",
        "kms:GenerateDataKeyWithoutPlaintext",
        "kms:ReEncrypt*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}