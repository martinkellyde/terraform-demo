

resource "aws_s3_bucket" "config_delivery" {
  bucket = "${var.project}-${var.account_number}-awsconfig"
}

resource "aws_config_configuration_recorder_status" "account" {
  name       = "${aws_config_configuration_recorder.account.name}"
  is_enabled = true
#  depends_on = ["aws_config_delivery_channel.account"]
}

resource "aws_iam_role_policy_attachment" "config" {
  role       = "${aws_iam_role.config.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSConfigRole"
}


resource "aws_iam_role_policy_attachment" "delivery" {
    depends_on = ["aws_iam_policy.config_bucket_access_policy"]
    role       = "${aws_iam_role.config.name}"
    policy_arn = "${aws_iam_policy.config_bucket_access_policy.arn}"
}


resource "aws_config_configuration_recorder" "account" {
  name     = "account"
  role_arn = "${aws_iam_role.config.arn}"
  recording_group = {
    all_supported                 = true
    include_global_resource_types = true
  }
}

resource "aws_iam_role" "config" {
  name = "netdespatch-awsconfig"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "config.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY
}


resource "aws_iam_policy" "config_bucket_access_policy" {
  name   = "econfig_bucket_access_policy"
  path   = "/"
  policy = "${data.aws_iam_policy_document.config_access.json}"
}


data "aws_iam_policy_document" "config_access" {
  statement {
    sid = "1"

    actions = [
      "s3:ListAllMyBuckets",
      "s3:GetBucketLocation",
    ]

    resources = [
      "arn:aws:s3:::*",
    ]
  }

  statement {
    actions = [
      "s3:PutObject*",
    ]

    resources = [
      "${aws_s3_bucket.config_delivery.arn}/AWSLogs/${var.account_number}/*",
    ]

    condition {
      test     = "StringLike"
      variable = "s3:x-amz-acl"

      values = [
        "bucket-owner-full-control"
      ]
    }

    actions = [
      "s3:GetBucketAcl",
    ]

    resources = [
      "${aws_s3_bucket.config_delivery.arn}"
    ]



  }
}

/*


resource "aws_iam_policy" "config_bucket_access_policy" {
  name        = "config_bucket_access_policy"
  path        = "/"
  description = "config_bucket_access_policy"

  policy = <<EOF

resource "aws_iam_policy"

{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:PutObject*"
            ],
            "Resource": [
                "${aws_s3_bucket.config_delivery.arn}AWSLogs/175764588233/*"
            ],
            "Condition": {
                "StringLike": {
                    "s3:x-amz-acl": "bucket-owner-full-control"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetBucketAcl"
            ],
            "Resource": "${aws_s3_bucket.config_delivery.arn}"
        }
    ]
}
EOF
}

*/
