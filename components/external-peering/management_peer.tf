resource "aws_vpc_peering_connection" "man" {
  vpc_id        = "${data.terraform_remote_state.vpc.vpc_id}"
  peer_vpc_id   = "${var.management_vpc_id}"
  peer_owner_id = "${var.management_account_number}"
  auto_accept   = false

  tags {
    Side = "Requester"
  }
}

resource "aws_vpc_peering_connection_accepter" "man" {
  provider                  = "aws.management"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.man.id}"
  auto_accept               = true

  tags {
    Side = "Accepter"
  }
}

# Create a route to the management VPC on the local VPC private subnet route table
resource "aws_route" "local" {
  route_table_id            = "${data.terraform_remote_state.vpc.private_subnet_route_table_id}"
  destination_cidr_block    = "${var.management_vpc_cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.man.id}"
}

# Create a route to the local VPC on the management VPC private subnet route table
resource "aws_route" "remote" {
  provider                  = "aws.management"
  route_table_id            = "${var.management_route_table}"
  destination_cidr_block    = "${var.vpc_cidr}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.man.id}"
}


# Add each side's default private security group ID to the other's

# Add management private security group to environment private security group

resource "aws_security_group_rule" "management_ingress" {
  depends_on   = ["aws_vpc_peering_connection.man"]
  type        = "ingress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  source_security_group_id = "${var.management_security_group}"

  security_group_id = "${data.terraform_remote_state.vpc.private_sg_id}"
}

# Add environment private security group to management private security group

resource "aws_security_group_rule" "environment_ingress" {
  depends_on   = ["aws_vpc_peering_connection.man"]
  provider                  = "aws.management"
  type        = "ingress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  source_security_group_id = "${data.terraform_remote_state.vpc.private_sg_id}"

  security_group_id = "${var.management_security_group}"
}