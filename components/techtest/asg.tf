
data "aws_ami" "ami" {
    most_recent = true
    owners = ["amazon"]

    filter {
    name = "name"
    values = ["amzn-ami-hvm-*.*x86_64-gp2"]
    }
}




resource "aws_security_group" "asg" {
  name        = "${var.env}-asg-sg"
  description = "Allow ASG inbound traffic"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"

    security_groups = ["${aws_security_group.elb.id}"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

resource "aws_autoscaling_group" "techtest-host-asg" {
  name = "${var.env}-${var.aws_region}-techtest-host-asg"

  vpc_zone_identifier = [
    "${data.terraform_remote_state.vpc.private_subnet_1_id}",
    "${data.terraform_remote_state.vpc.private_subnet_2_id}",
    "${data.terraform_remote_state.vpc.private_subnet_3_id}",
  ]

  min_size = "1"
  max_size = "1"
  launch_configuration = "${aws_launch_configuration.techtest-host-lc.name}"

  load_balancers         = ["${aws_elb.techtest_access.name}"]
  health_check_type      = "ELB"
  health_check_grace_period = 300

  tag {
    key                 = "Name"
    value               = "${var.env}-${var.aws_region}-techtest-host-asg"
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

data "template_file" "techtest_user_data" {
  template = "${file("template/${var.env}-user_data.sh")}"

  vars {
    region      = "${var.aws_region}"
    environment = "${var.env}"
  }
}

resource "aws_launch_configuration" "techtest-host-lc" {
  name_prefix          = "${var.env}-${var.aws_region}-techtest-host-"
  image_id             = "${data.aws_ami.ami.id}"
  instance_type        = "${var.techtest_host_instance_type}"
  user_data            = "${data.template_file.techtest_user_data.rendered}"
  key_name             = "${var.ssh_key_name}"
  iam_instance_profile = "${aws_iam_instance_profile.techtest.id}"
  security_groups      = ["${aws_security_group.asg.id}"]
  lifecycle {
    create_before_destroy = true
  }
}
