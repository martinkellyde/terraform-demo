# Security Groups

resource "aws_security_group" "public_subnet_sg" {
  name        = "${var.env}-${var.aws_region}-public-subnet-sg"
  vpc_id      = "${aws_vpc.main.id}"
  description = "Allow access restricted to BJSS egress addresses"

  tags {
    Name        = "${var.env}-${var.aws_region}-public-subnet-sg"
    Environment = "${var.env}"
    Terraform   = "True"
    CFAutoUpdate = "True"
    Protocol = "https"
  }
}


output "public_sg_id" {
  value = "${aws_security_group.public_subnet_sg.id}"
}

resource "aws_security_group" "private_subnet_sg" {
  name        = "${var.env}-${var.aws_region}-private-subnet-sg"
  vpc_id      = "${aws_vpc.main.id}"
  description = "Allow access from public subnet"

  tags {
    Name        = "${var.env}-${var.aws_region}-private-subnet-sg"
    Environment = "${var.env}"
    Terraform   = "True"
  }
}

output "private_sg_id" {
  value = "${aws_security_group.private_subnet_sg.id}"
}

# Rules

# New MPLS BJSS Global Egress

resource "aws_security_group_rule" "public_sg_allow_bjss_global_ingress" {
  type        = "ingress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["148.253.134.213/32"]

  security_group_id = "${aws_security_group.public_subnet_sg.id}"
}


resource "aws_security_group_rule" "public_sg_allow_bjss_leeds_ingress" {
  type        = "ingress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["77.86.30.0/25"]

  security_group_id = "${aws_security_group.public_subnet_sg.id}"
}

# Allows incoming connections to the public security group from the hide nat


resource "aws_security_group_rule" "public_sg_allow_nat_gateway_ingress" {
  type        = "ingress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["${aws_nat_gateway.nat_gw.public_ip}/32"]

  security_group_id = "${aws_security_group.public_subnet_sg.id}"
}

# Allows incoming connections to the public security group from objects in the private security group

resource "aws_security_group_rule" "public_sg_allow_private_sg_ingress" {
  type      = "ingress"
  from_port = 0
  to_port   = 0
  protocol  = "-1"

  security_group_id        = "${aws_security_group.public_subnet_sg.id}"
  source_security_group_id = "${aws_security_group.private_subnet_sg.id}"
}

# Allows outgoing connections from resouces in the public sg

resource "aws_security_group_rule" "public_sg_allow_egress" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.public_subnet_sg.id}"
}

# allows connections to the private sg from anything in the public SG


resource "aws_security_group_rule" "private_sg_allow_public_sg_ingress" {
  type      = "ingress"
  from_port = 0
  to_port   = 0
  protocol  = "-1"

  security_group_id        = "${aws_security_group.private_subnet_sg.id}"
  source_security_group_id = "${aws_security_group.public_subnet_sg.id}"
}

# allows connections to the private sg from anything else in the private sg

resource "aws_security_group_rule" "private_sg_allow_internal_traffic" {
  type      = "ingress"
  from_port = 0
  to_port   = 0
  protocol  = "-1"
  self      = "true"

  security_group_id = "${aws_security_group.private_subnet_sg.id}"
}

# Allows outgoing connections from resouces in the private SG via nat

resource "aws_security_group_rule" "private_sg_allow_egress" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.private_subnet_sg.id}"
}
