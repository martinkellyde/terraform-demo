
resource "aws_iam_instance_profile" "techtest" {
  name = "${var.env}_techtest"
  role = "${aws_iam_role.techtest.name}"
}

resource "aws_iam_role" "techtest" {
    name = "${var.env}_techtest"
    assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "techtest" {
  name = "${var.env}_techtest"
  role = "${aws_iam_role.techtest.id}"
    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt1471562879000",
      "Effect": "Allow",
      "Action": [
        "iam:ListUsers",
        "iam:GetGroup"
      ],
      "Resource": [
        "*"
      ]
    },
    {
      "Sid": "Stmt1471562943000",
      "Effect": "Allow",
      "Action": [
        "iam:GetSSHPublicKey",
        "iam:ListSSHPublicKeys"
      ],
      "Resource": [
        "arn:aws:iam::*:user/*"
      ]
    }
  ]
}
EOF
}
