
data "aws_ami" "ami" {
    most_recent = true
    owners           = ["amazon"]
    filter {
    name = "name"
    values = ["amzn-ami-hvm-*.*x86_64-gp2"]
    }
}


data "aws_caller_identity" "current" {}

# Security Group for ELB
resource "aws_security_group" "bastion_elb_sg" {
  name        = "${var.project}-${var.env}-bastion-elb-sg"
  description = "Allow ssh inbound traffic to bastion elb"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"
}

resource "aws_security_group_rule" "bastion_elb_ingress" {
  type        = "ingress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["${var.ingress_cidr_blocks}"]
  security_group_id = "${aws_security_group.bastion_elb_sg.id}"
}

resource "aws_security_group_rule" "bastion_elb_egress" {
  type              = "egress"
  from_port         = "0"
  to_port           = "0"
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.bastion_elb_sg.id}"
}


# ELB 
resource "aws_elb" "bastion_access" {
  name = "${var.env}-${var.aws_region}-bastion-elb"
  subnets = [
    "${data.terraform_remote_state.vpc.public_subnet_1_id}",
    "${data.terraform_remote_state.vpc.public_subnet_2_id}",
    "${data.terraform_remote_state.vpc.public_subnet_3_id}",
  ]
  security_groups = [
    "${aws_security_group.bastion_elb_sg.id}"
  #sg.public_subnet_sg.id}"
  ]

/*
  access_logs {
    bucket = "${var.account_name}-${var.aws_region}-sporting-life-logs"
    bucket_prefix = "${var.env}-bastion-hosts"
    # TODO: Change the interval to 60 when deploying production
    interval = 5
  }
*/

  listener {
    instance_port = 22
    instance_protocol = "TCP"
    lb_port = 22
    lb_protocol = "TCP"
  }

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    target = "TCP:22"
    interval = 30
  }

  # instances = ["${aws_instance.bastion-1.id}"]
  cross_zone_load_balancing = true
  idle_timeout = 3000
  connection_draining = true
  connection_draining_timeout = 600

  tags {
    Name = "${var.env}-${var.aws_region}-bastion-access-elb"
    Environment = "${var.env}"
    Terraform   = "True"
  }
}


resource "aws_route53_record" "bastion_alias" {
  zone_id = "${var.r53_zone_id}"
  name    = "${var.bastion_public_dns_name}"
  type    = "A"

  alias {
    name                   = "${aws_elb.bastion_access.dns_name}"
    zone_id                = "${aws_elb.bastion_access.zone_id}"
    evaluate_target_health = false
  }
}


# Security Group for ELB
resource "aws_security_group" "bastion_asg_sg" {
  name        = "${var.project}-${var.env}-bastion-asg-sg"
  description = "Allow ssh inbound traffic to bastion elb"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"
}

resource "aws_security_group_rule" "bastion_asg_ingress" {
  type        = "ingress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  source_security_group_id = "${aws_security_group.bastion_elb_sg.id}"
  security_group_id = "${aws_security_group.bastion_asg_sg.id}"
}

resource "aws_security_group_rule" "bastion_asg_egress" {
  type              = "egress"
  from_port         = "0"
  to_port           = "0"
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.bastion_asg_sg.id}"
}


resource "aws_autoscaling_group" "bastion-host-asg" {
  name = "${var.env}-${var.aws_region}-bastion-host-asg"

  vpc_zone_identifier = [
    "${data.terraform_remote_state.vpc.private_subnet_1_id}",
    "${data.terraform_remote_state.vpc.private_subnet_2_id}",
    "${data.terraform_remote_state.vpc.private_subnet_3_id}",
  ]

  min_size = "1"
  max_size = "1"
  launch_configuration = "${aws_launch_configuration.bastion-host-lc.name}"

  load_balancers         = ["${aws_elb.bastion_access.name}"]
  health_check_type      = "EC2"
  health_check_grace_period = 300

  tag {
    key                 = "Name"
    value               = "${var.env}-${var.aws_region}-bastion-host-asg"
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

data "template_file" "bastion_user_data" {
  template = "${file("template/${var.env}-user_data.sh")}"

  vars {
    region      = "${var.aws_region}"
    environment = "${var.env}"
  }
}

resource "aws_launch_configuration" "bastion-host-lc" {
  name_prefix          = "${var.env}-${var.aws_region}-bastion-host-"
  image_id             = "${data.aws_ami.ami.id}"
  instance_type        = "${var.bastion_instance_type}"
  user_data            = "${data.template_file.bastion_user_data.rendered}"
  key_name             = "${var.ssh_key_name}"
  iam_instance_profile = "${aws_iam_instance_profile.bastion.id}"
  security_groups      = ["${aws_security_group.bastion_asg_sg.id}"]
  lifecycle {
    create_before_destroy = true
  }
}


# Outputs

output "bastion_sg_id" {
  value = "${aws_security_group.bastion_asg_sg.id}"
}
