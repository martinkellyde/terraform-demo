
# Force MFA Policy
# Creates a policy to attach to console users that requires them to configure and use MFA

data "template_file" "mfa_policy_template" {
  template = "${file("${path.module}/policy-templates/force-mfa.json")}"
  vars {
    environment     = "${var.env}"
    account_number  = "${var.account_number}"
  }
}

resource "aws_iam_policy" "force-mfa-managed" {
  name        = "force-mfa-managed"
  path        = "/"
  description = "force-mfa-managed"
  policy = "${data.template_file.mfa_policy_template.rendered}"
}

# SSH Access Key Policy
# This allows instances to get SSH keys for iam managed ssh login

data "template_file" "ssh_policy_template" {
  template = "${file("${path.module}/policy-templates/get-ssh-access-key.json")}"
  vars {
    environment     = "${var.env}"
    account_number  = "${var.account_number}"
  }
}

resource "aws_iam_policy" "get-ssh-accesskey-managed" {
  name        = "get-ssh-access-key-managed"
  path        = "/"
  description = "get-ssh-access-key-managed"
  policy = "${data.template_file.ssh_policy_template.rendered}"
}

# Describe tags policy
# Allows a machine to get its own tags to determine which environment it is in.


resource "aws_iam_policy" "describe-tags-managed" {
  name        = "describe-tags"
  path        = "/"
  description = "describe-tags"
  policy = "${file("${path.module}/policy-templates/describe-tags.json")}"
}



output "ssh_accesskey_policy_arn" {
  value = "${aws_iam_policy.get-ssh-accesskey-managed.arn}"
}


resource "aws_iam_account_password_policy" "strict" {
  minimum_password_length        = 8
  require_lowercase_characters   = true
  require_numbers                = true
  require_uppercase_characters   = true
  require_symbols                = true
  allow_users_to_change_password = true
  password_reuse_prevention      = 7
  max_password_age               = 90
}