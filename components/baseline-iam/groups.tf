# Readonly Group

resource "aws_iam_group" "readonly" {
  name = "${var.env}-ReadOnly"
  path = "/"
}

resource "aws_iam_group_policy_attachment" "readonly-attach" {
  group      = "${aws_iam_group.readonly.name}"
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

resource "aws_iam_group_policy_attachment" "readonly-forcemfa-attach" {
  group      = "${aws_iam_group.readonly.name}"
  policy_arn = "${aws_iam_policy.force-mfa-managed.arn}"
}

# Admin Group

resource "aws_iam_group" "admin" {
  name = "${var.env}-Admin"
  path = "/"
}

resource "aws_iam_group_policy_attachment" "admin-attach" {
  group      = "${aws_iam_group.admin.name}"
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_group_policy_attachment" "admin-forcemfa-attach" {
  group      = "${aws_iam_group.admin.name}"
  policy_arn = "${aws_iam_policy.force-mfa-managed.arn}"
}