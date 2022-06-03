resource "aws_iam_role" "default_managed_role" {
  name = "${var.env}-default_managed_role"

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

resource "aws_iam_role_policy_attachment" "default_ssm_attach" {
    role       = "${aws_iam_role.default_managed_role.name}"
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

# Allow instances to download public SSH keys for iam backed ssh

resource "aws_iam_role_policy_attachment" "default_sshkey_attach" {
    role       = "${aws_iam_role.default_managed_role.name}"
    policy_arn = "${aws_iam_policy.get-ssh-accesskey-managed.arn}"
}


# Allow instances to describe tags so they can get their own hostname

resource "aws_iam_role_policy_attachment" "describe_tags_attach" {
    role       = "${aws_iam_role.default_managed_role.name}"
    policy_arn = "${aws_iam_policy.describe-tags-managed.arn}"
}

resource "aws_iam_instance_profile" "default_managed_profile" {
  name  = "${var.env}-default_managed_profile"
  role = "${aws_iam_role.default_managed_role.name}"
}

output "default_role_policy_arn" {
  value = "${aws_iam_role.default_managed_role.arn}"
}