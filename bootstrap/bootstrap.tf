# The default AWS provider in the default region
provider "aws" {
  region = "${var.region}"

  # For no reason other than redundant safety
  # we only allow the use of the AWS Account
  # specified in the environment variables.
  # This helps to prevent accidents.
  allowed_account_ids = [
    "${var.aws_account_id}",
  ]
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

/*
data "aws_kms_key" "byok" {
  key_id = "arn:aws:kms:us-east-1:${data.aws_caller_identity.current.account_id}:alias/*-tenant1-byok1-${data.aws_region.current.name}-key"
}
*/

variable "kms_key" {}
variable "aws_account_id" {}
variable "project" {}
variable "region" {}
variable "backend_name" {}

resource "aws_s3_bucket" "bucket" {
  bucket = "${var.backend_name}"
  acl    = "private"

  force_destroy = "false"
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = "${var.kms_key}"
        sse_algorithm     = "aws:kms"
      }
    }
  }
  versioning {
    enabled = "true"
  }

  lifecycle_rule {
    prefix  = "/"
    enabled = "true"

    noncurrent_version_transition {
      days          = "30"
      storage_class = "STANDARD_IA"
    }

    noncurrent_version_transition {
      days          = "60"
      storage_class = "GLACIER"
    }

    noncurrent_version_expiration {
      days = "90"
    }
  }

  # This does not use default tag map merging because bootstrapping is special
  # You should use default tag map merging elsewhere
  tags {
    "Name"        = "${var.backend_name}"
    "Project"     = "${var.project}"
    "Account"     = "${var.aws_account_id}"
  }
}


resource "aws_s3_bucket_public_access_block" "bucket" {
  bucket = "${aws_s3_bucket.bucket.id}"

  block_public_acls   = true
  block_public_policy = true
}


# create a dynamodb table for locking the state file
resource "aws_dynamodb_table" "dynamodb-terraform-state-lock" {
  name = "${var.backend_name}-lock"
  hash_key = "LockID"
  read_capacity = 20
  write_capacity = 20
 
  attribute {
    name = "LockID"
    type = "S"
  }
 
  tags {
    Name = "DynamoDB Terraform State Lock Table for ${var.backend_name}"
  }
}


output "bucket_name" {
  value = "${aws_s3_bucket.bucket.id}"
}

output "lock_table_name" {
  value = "${aws_dynamodb_table.dynamodb-terraform-state-lock.id}"
}