resource "aws_iam_group" "iam-ssh-users" {
  name = "${var.env}-${var.aws_region}-iam-ssh-users"
}

resource "aws_iam_instance_profile" "bastion" {
  name = "${var.env}_bastion"
  role = "${aws_iam_role.bastion.name}"
}

resource "aws_iam_role" "bastion" {
    name = "${var.env}_bastion"
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

resource "aws_iam_role_policy" "bastion" {
  name = "${var.env}_bastion"
  role = "${aws_iam_role.bastion.id}"
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
