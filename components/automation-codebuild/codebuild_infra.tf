
data "aws_caller_identity" "current" {}

resource "aws_security_group" "codebuild_infra_sg" {
  name = "${var.project}-${var.env}-codebuild-infra-sg"
  vpc_id = "${data.terraform_remote_state.vpc.vpc_id}"
}



resource "aws_iam_role" "codebuild_infra_role" {
  name = "${var.project}-${var.env}-codebuild-infra-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "codebuild_infra_policy" {
  role = "${aws_iam_role.codebuild_infra_role.name}"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Resource": [
        "*"
      ],
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:CreateNetworkInterface",
        "ec2:DescribeDhcpOptions",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DeleteNetworkInterface",
        "ec2:DescribeSubnets",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeVpcs"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:*"
      ],
      "Resource": [
        "${aws_s3_bucket.codebuild_cache.arn}",
        "${aws_s3_bucket.codebuild_cache.arn}/*"
      ]
    }
  ]
}
POLICY
}

resource "aws_codebuild_project" "infra" {
  name          = "${var.project}-${var.env}-codebuild-infra-project"
  description   = "Codebuild project for infrastructure"
  build_timeout = "5"
  service_role  = "${aws_iam_role.codebuild_infra_role.arn}"

  artifacts {
    type = "NO_ARTIFACTS"
  }

  cache {
    type     = "S3"
    location = "${aws_s3_bucket.codebuild_cache.bucket}"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:1.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      "name"  = "project"
      "value" = "${var.project}"
    }
  }

  source {
    type            = "GITHUB"
    location        = "https://github.com/martinkellyde/sandbox.git"
    git_clone_depth = 1
  }

  vpc_config {
    vpc_id = "${data.terraform_remote_state.vpc.vpc_id}"

  subnets = [
    "${data.terraform_remote_state.vpc.private_subnet_1_id}",
    "${data.terraform_remote_state.vpc.private_subnet_2_id}",
    "${data.terraform_remote_state.vpc.private_subnet_3_id}",
  ]

    security_group_ids = [
      "${aws_security_group.codebuild_infra_sg.id}",
    ]
  }

  tags = {
    "Environment" = "${var.env}"
  }
}