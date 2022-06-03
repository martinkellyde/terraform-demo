# Variables

variable "env" {}
variable "account_alias" {}
variable "account_number" {}
variable "project" {}
variable "aws_region" {}
variable "aws_account_name" {}

# Local provider for local account operations

provider "aws" {
# version = "~> 1.6"
 region = "${var.aws_region}"
}

# Remote provider for remote account operations

provider "aws" {
#  version = "=> 1.6"
 alias = "remote"
 region = "${var.aws_region}"
 assume_role = {
   role_arn = "arn:aws:iam::${data.terraform_remote_state.remote_account.account_id}:role/${var.aws_account_name}-admin"
 }
}

# Grab the terraform state for the remote account

data "terraform_remote_state" "remote_account" {
  backend = "s3"

  config {
    bucket = "${var.account_alias}-scaffold"
    key    = "${var.project}/${var.aws_region}/${var.env}/orgaccount-${var.aws_account_name}-creation.tfstate"
    region = "${var.aws_region}"
  }
}

# Create account alias for remote account

resource "aws_iam_account_alias" "alias" {
  provider = "aws.remote"
  account_alias = "${var.aws_account_name}"
}


# Create limited admin role in remote account and delegate trust back to this account


resource "aws_iam_role" "remote_techops_admin" {
  provider = "aws.remote"
  name = "${var.aws_account_name}-role-techops"


  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "AWS": "${var.account_number}"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# Create remote policy to allow remote role to use local CMK and attach

data "aws_iam_policy_document" "kms_use" {
  statement {
    sid = "AllowKMSUse"
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey",
    ]
    resources = [
      "${aws_kms_key.key.arn}"
    ]
  }
}

resource "aws_iam_policy" "kms_use" {
  provider = "aws.remote"
  name = "kmsuse"
  description = "Policy to allow use of KMS Key"
  policy = "${data.aws_iam_policy_document.kms_use.json}"
}


resource "aws_iam_role_policy_attachment" "kms_use" {
  provider = "aws.remote"
  role = "${aws_iam_role.remote_techops_admin.name}"
  policy_arn = "${aws_iam_policy.kms_use.arn}"
}


data "aws_iam_policy_document" "s3_use" {
  statement {
    sid = "AllowS3Use"
    effect = "Allow"
    actions = [
      "s3:*"
    ]
    resources = [
      "${aws_s3_bucket.statebucket.arn}"
    ]
  }
}

resource "aws_iam_policy" "s3_use" {
  provider = "aws.remote"
  name = "s3use"
  description = "Policy to allow use of S3 bucket"
  policy = "${data.aws_iam_policy_document.s3_use.json}"
}


resource "aws_iam_role_policy_attachment" "s3_use" {
  provider = "aws.remote"
  role = "${aws_iam_role.remote_techops_admin.name}"
  policy_arn = "${aws_iam_policy.s3_use.arn}"
}



# Create group in local account for assuming admin role in remote account

resource "aws_iam_group" "remote_techops_group" {
  name = "${var.aws_account_name}-group-techops"
}


# Create local policy to assume that role and attach to group

resource "aws_iam_policy" "remote_techops_group_policy" {
  name        = "${var.aws_account_name}-policy-techops"
  path        = "/"
  description = "${var.aws_account_name}-policy-techops"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": {
    "Effect": "Allow",
    "Resource": "${aws_iam_role.remote_techops_admin.arn}",
    "Action": "sts:AssumeRole"
  }
}
EOF
}

# Create CMK for state encryption on org account bucket, with delegation policy

resource "aws_kms_key" "key" {
  description             = "${var.aws_account_name} CMK"
  deletion_window_in_days = 10
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Id": "keyresourcepolicy",
    "Statement": [
        {
            "Sid": "EnableLocalPermissions",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::052188317850:root"
            },
            "Action": "kms:*",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::${data.terraform_remote_state.remote_account.account_id}:root"
            },
            "Action": [
                "kms:Encrypt",
                "kms:Decrypt",
                "kms:ReEncrypt*",
                "kms:GenerateDataKey*",
                "kms:DescribeKey"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}


resource "aws_kms_alias" "alias" {
  name          = "alias/${var.aws_account_name}-CMK"
  target_key_id = "${aws_kms_key.key.key_id}"
}

# Create state bucket for remote account in local account


resource "aws_s3_bucket" "statebucket" {
  bucket = "${var.aws_account_name}-scaffold"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = "${aws_kms_key.key.arn}"
        sse_algorithm     = "aws:kms"
      }
    }
  }

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::${data.terraform_remote_state.remote_account.account_id}:root"
            },
            "Action": [
                "s3:GetObject",
                "s3:PutObject",
                "s3:PutObjectAcl"
            ],
            "Resource": [
                "arn:aws:s3:::${var.aws_account_name}-scaffold/*"
            ]
        },
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::${data.terraform_remote_state.remote_account.account_id}:root"
            },
            "Action": [
            "s3:GetBucketLocation",
            "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::${var.aws_account_name}-scaffold"
            ]
        }
    ]
}
EOF
}