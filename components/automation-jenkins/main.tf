
data "aws_ami" "ami" {
    most_recent = true
    owners           = ["amazon"]
    filter {
    name = "name"
    values = ["amzn-ami-hvm-*.*x86_64-gp2"]
    }
}

data "aws_caller_identity" "current" {}

# EFS Volume for detached state

resource "aws_security_group" "jenkins_efs_sg" {
  name        = "${var.project}-${var.env}-jenkins-efs-sg"
  description = "Allow nfs inbound traffic to jenkins efs"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"
  tags = {
    Name = "${var.project}-${var.env}-${var.aws_region}-jenkins-efs-sg"
  }
  lifecycle {
    create_before_destroy = "true"
  }
}

resource "aws_security_group_rule" "jenkins_efs_ingress" {
  type        = "ingress"
  from_port   = 2049
  to_port     = 2049
  protocol    = "tcp"
  source_security_group_id = "${aws_security_group.jenkins_sg.id}"
  security_group_id = "${aws_security_group.jenkins_efs_sg.id}"
}

resource "aws_security_group_rule" "jenkins_efs_egress" {
  type              = "egress"
  from_port         = "0"
  to_port           = "0"
  protocol          = "-1"
  source_security_group_id = "${aws_security_group.jenkins_elb_sg.id}"
  #cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.jenkins_efs_sg.id}"
}


# EFS Filesystem and mounts

resource "aws_efs_file_system" "jenkins" {
  creation_token = "${var.project}-${var.env}-${var.aws_region}-jenkins"
  encrypted = "true"
  kms_key_id = "${var.kms_key_arn}"
  throughput_mode = "${var.throughput_mode}"
  provisioned_throughput_in_mibps = "${var.jenkins_efs_throughput}"
  tags = {
    Name = "${var.project}-${var.env}-${var.aws_region}-jenkins"
  }
}

resource "aws_efs_mount_target" "targets" {
  count          = "${var.az_count}"
  file_system_id = "${aws_efs_file_system.jenkins.id}"
  subnet_id      = "${element(data.terraform_remote_state.vpc.private_subnet_ids, count.index)}"
#  subnet_id      = "${data.terraform_remote_state.vpc.private_subnet_1_id}"
  security_groups = ["${aws_security_group.jenkins_efs_sg.id}"]
}

/*
resource "aws_efs_mount_target" "b" {
  file_system_id = "${aws_efs_file_system.jenkins.id}"
  subnet_id      = "${var.private_subnet_id_b}"
  security_groups = ["${aws_security_group.jenkins_efs_sg.id}"]
}
*/

# ELB Security Group
resource "aws_security_group" "jenkins_elb_sg" {
  name        = "${var.project}-${var.env}-jenkins-elb-sg"
  description = "Allow ssh inbound traffic to jenkins elb"
  tags = {
    Name = "${var.project}-${var.env}-${var.aws_region}-jenkins-elb-sg"
  }
  lifecycle {
    create_before_destroy = "true"
  }
}


resource "aws_security_group_rule" "jenkins_elb_ssh_ingress" {
  type        = "ingress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  source_security_group_id = "${data.terraform_remote_state.bastion.bastion_sg_id}"
  security_group_id = "${aws_security_group.jenkins_elb_sg.id}"
}


resource "aws_security_group_rule" "jenkins_elb_jenkins_ingress" {
  type        = "ingress"
  from_port   = 8080
  to_port     = 8080
  protocol    = "tcp"
  source_security_group_id = "${data.terraform_remote_state.bastion.bastion_sg_id}"
  security_group_id = "${aws_security_group.jenkins_elb_sg.id}"
}

resource "aws_security_group_rule" "jenkins_elb_egress" {
  type              = "egress"
  from_port         = "0"
  to_port           = "0"
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.jenkins_elb_sg.id}"
}

# 
resource "aws_elb" "jenkins_access" {
  internal           = true
  name               = "${var.project}-${var.env}-${var.aws_region}-jenkins-elb"
  subnets = [
    "${data.terraform_remote_state.vpc.public_subnet_ids}"
  ]
  security_groups      = ["${aws_security_group.jenkins_elb_sg.id}"]

  /*
  access_logs {
    bucket = "${var.account_name}-${var.aws_region}-life-logs"
    bucket_prefix = "${var.env}-jenkins-hosts"
    # TODO: Change the interval to 60 when deploying production
    interval = 5
  }
*/

  listener {
    instance_port     = 22
    instance_protocol = "TCP"
    lb_port           = 22
    lb_protocol       = "TCP"
  }


  listener {
    instance_port       = 8080
    instance_protocol   = "HTTP"
    lb_port             = 443
    lb_protocol         = "HTTPS"
    ssl_certificate_id  = "arn:aws:acm:us-west-2:052188317850:certificate/1ba4d3b1-4499-4dc8-8b20-6b2064d371a5"
  }
/*
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "TCP:22"
    interval            = 30
  }
*/
  cross_zone_load_balancing   = true
  idle_timeout                = 3000
  connection_draining         = true
  connection_draining_timeout = 600
  tags {
    Name        = "${var.env}-${var.aws_region}-jenkins-access-elb"
    Environment = "${var.env}"
    Terraform   = "True"
  }
}

resource "aws_route53_record" "www" {
  zone_id = "${data.terraform_remote_state.vpc.external_dns_zone_id}"
  name    = "jenkins"
  type    = "A"

  alias {
    name                   = "${aws_elb.jenkins_access.dns_name}"
    zone_id                = "${aws_elb.jenkins_access.zone_id}"
    evaluate_target_health = true
  }
}

# Autoscaling Group

resource "aws_autoscaling_group" "jenkins_master_asg" {
  name = "${var.project}-${var.env}-${var.aws_region}-jenkins-asg"
  termination_policies = ["OldestLaunchConfiguration"]

  vpc_zone_identifier = [
    "${data.terraform_remote_state.vpc.private_subnet_1_id}",
    "${data.terraform_remote_state.vpc.private_subnet_2_id}",
    "${data.terraform_remote_state.vpc.private_subnet_3_id}",
  ]

  min_size             = "1"
  max_size             = "1"
  launch_configuration = "${aws_launch_configuration.jenkins_host_lc.name}"

  load_balancers            = ["${aws_elb.jenkins_access.name}"]
  health_check_type         = "EC2"
  health_check_grace_period = 300

  tag {
    key                 = "Name"
    value               = "${var.project}-${var.env}-${var.aws_region}-jenkins"
    propagate_at_launch = "true"
  }

  tag {
    key                 = "Environment"
    value               = "${var.env}"
    propagate_at_launch = true
  }

  tag {
    key                 = "Terraform"
    value               = "True"
    propagate_at_launch = true
  }
}

/*
resource "aws_autoscaling_schedule" "jenkins_scaleout" {
  count                  = "${var.timed_recycle ? 1 : 0}"
  scheduled_action_name  = "${var.env}-${var.aws_region}-jenkins-cycling-scaleout"
  min_size               = 1
  max_size               = 2
  desired_capacity       = 2
  recurrence             = "00 02 * * *"
  autoscaling_group_name = "${aws_autoscaling_group.jenkins_master_asg.name}"
}

resource "aws_autoscaling_schedule" "jenkins_scalein" {
  count                  = "${var.timed_recycle ? 1 : 0}"
  scheduled_action_name  = "${var.env}-${var.aws_region}-jenkins-cycling-scalein-"
  min_size               = 1
  max_size               = 1
  desired_capacity       = 1
  recurrence             = "00 03 * * *"
  autoscaling_group_name = "${aws_autoscaling_group.jenkins_master_asg.name}"
}
*/


# host security group

resource "aws_security_group" "jenkins_sg" {
  name        = "${var.project}-${var.env}-jenkins-master-sg"
  description = "Allow ssh inbound traffic to jenkins from lb"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"
  tags = {
    Name = "${var.project}-${var.env}-${var.aws_region}-jenkins-master-sg"
  }
}

resource "aws_security_group_rule" "jenkins_ingress" {
  type        = "ingress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  source_security_group_id = "${aws_security_group.jenkins_elb_sg.id}"
  security_group_id = "${aws_security_group.jenkins_sg.id}"
}


resource "aws_security_group_rule" "jenkins_egress" {
  type              = "egress"
  from_port         = "0"
  to_port           = "0"
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.jenkins_sg.id}"
}


# Launch Configuration

data "template_file" "jenkins_user_data" {
  template = "${file("template/user_data.sh")}"

  vars {
    region      = "${var.aws_region}"
    environment = "${var.env}"
    efs_id      = "${aws_efs_file_system.jenkins.id}"
  }
}


resource "aws_launch_configuration" "jenkins_host_lc" {
  name_prefix          = "${var.project}-${var.env}-${var.aws_region}-jenkins-"
  image_id             = "${data.aws_ami.ami.id}"
  instance_type        = "${var.jenkins_host_instance_type}"
  user_data            = "${data.template_file.jenkins_user_data.rendered}"
  key_name             = "${var.ssh_key_name}"
  iam_instance_profile = "${aws_iam_instance_profile.jenkins.id}"
  security_groups      = ["${aws_security_group.jenkins_sg.id}"]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role" "role" {
  name = "${var.project}-${var.env}-jenkins"
  path = "/"

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

resource "aws_iam_instance_profile" "jenkins" {
  name = "${var.env}_jenkins_profile"
  role = "${aws_iam_role.role.name}"
}

# Attach custom SSM policy (previous was too lax giving S3 permissions on *)
# No other policy attached to the jenkins master - IAM policies on workers only
/*
resource "aws_iam_role_policy_attachment" "ssm" {
  role       = "${aws_iam_role.role.name}"
  policy_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/${var.project}_${var.account_env}_ssm_policy"
}
*/

