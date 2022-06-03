# Variables

variable "env" {}
variable "account_alias" {}
variable "account_number" {}
variable "project" {}
variable "aws_region" {}
variable "aws_account_name" {}
variable "aws_account_engineers" { type = "list" }

# Local provider for local account operations

provider "aws" {
 version = "~> 2.18"
 region = "${var.aws_region}"
}

# Remote provider for remote account operations

provider "aws" {
 version = "~> 2.18"
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

# Create account alias for remote account

resource "aws_iam_account_alias" "alias" {
  provider = "aws.remote"
  account_alias = "${var.aws_account_name}"
}

# Set password policy for the remote account

resource "aws_iam_account_password_policy" "strict" {
  provider = "aws.remote"
  minimum_password_length        = 8
  require_lowercase_characters   = true
  require_numbers                = true
  require_uppercase_characters   = true
  require_symbols                = true
  allow_users_to_change_password = true
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
  name = "techops_state_kms_policy"
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
  name = "techops_state_bucket_policy"
  description = "Policy to allow use of S3 bucket"
  policy = "${data.aws_iam_policy_document.s3_use.json}"
}


resource "aws_iam_role_policy_attachment" "s3_use" {
  provider = "aws.remote"
  role = "${aws_iam_role.remote_techops_admin.name}"
  policy_arn = "${aws_iam_policy.s3_use.arn}"
}

# Attach admin policy to remote techops account


resource "aws_iam_role_policy_attachment" "admin" {
  provider = "aws.remote"
  role = "${aws_iam_role.remote_techops_admin.name}"
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# Create and admin limitation policy 

data "aws_iam_policy_document" "iam_limit" {
  statement {
    sid = "IamLimit"
    effect = "Deny"
    actions = [
      "iam:AttachRolePolicy"
    ]
    resources = [
      "${aws_iam_role.remote_techops_admin.arn}"
    ]
  }
}

resource "aws_iam_policy" "iam_limit" {
  provider = "aws.remote"
  name = "techops_iamlimit_policy"
  description = "Policy to allow use of S3 bucket"
  policy = "${data.aws_iam_policy_document.iam_limit.json}"
}

# Attach admin limitation policy to remote techops account

resource "aws_iam_role_policy_attachment" "iam_limit" {
  provider = "aws.remote"
  role = "${aws_iam_role.remote_techops_admin.name}"
  policy_arn = "${aws_iam_policy.iam_limit.arn}"
}


# Create group in local account for assuming admin role in remote account

resource "aws_iam_group" "remote_techops_group" {
  name = "${var.aws_account_name}-group-techops"
}

resource "aws_iam_group_membership" "remote_techops_group" {
  name = "remote-techops-group-membership"
  users = "${var.aws_account_engineers}"
  group = "${aws_iam_group.remote_techops_group.name}"
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


#### Terraform Backend

# create a dynamodb table in the remote account for locking the state file

resource "aws_dynamodb_table" "dynamodb-terraform-state-lock" {
  provider = "aws.remote"
  name = "${var.aws_account_name}-lock"
  hash_key = "LockID"
  read_capacity = 20
  write_capacity = 20
 
  attribute {
    name = "LockID"
    type = "S"
  }
 
  tags {
    Name = "DynamoDB Terraform State Lock Table for ${var.aws_account_name}"
  }
}



# Create CMK for state encryption on org account bucket
# Delegate permissions to remote account with resource policy

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

# Create bucket for remote account state in local account
# Delegate permissions to remote account with S3 policy


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
