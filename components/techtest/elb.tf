# Route SSH to techtest hosts in each AZ


resource "aws_security_group" "elb" {
  name        = "${var.env}-elb-sg"
  description = "Allow ELB inbound traffic"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"

    cidr_blocks = ["52.56.81.222/32", "92.186.16.67/32"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

resource "aws_elb" "techtest_access" {
  name = "${var.env}-${var.aws_region}-techtest-elb"
  subnets = [
    "${data.terraform_remote_state.vpc.public_subnet_1_id}",
    "${data.terraform_remote_state.vpc.public_subnet_2_id}",
    "${data.terraform_remote_state.vpc.public_subnet_3_id}",
  ]
  security_groups = [
    "${aws_security_group.elb.id}"
  ]


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

  cross_zone_load_balancing = true
  idle_timeout = 3000
  connection_draining = true
  connection_draining_timeout = 600

  tags {
    Name = "${var.env}-${var.aws_region}-techtest-access-elb"
    Environment = "${var.env}"
    Terraform   = "True"
  }
}


resource "aws_route53_record" "techtest_alias" {
  zone_id = "${var.r53_zone_id}"
  name    = "${var.techtest_public_dns_name}"
  type    = "A"

  alias {
    name                   = "${aws_elb.techtest_access.dns_name}"
    zone_id                = "${aws_elb.techtest_access.zone_id}"
    evaluate_target_health = false
  }
}

output "techtest_ssh_url" {
  value = "${aws_elb.techtest_access.dns_name}"
}
