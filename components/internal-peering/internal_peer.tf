resource "aws_vpc_peering_connection" "internal" {
  vpc_id        = "${data.terraform_remote_state.vpc.vpc_id}"
  peer_vpc_id   = "${var.account_vpc_id}"
  peer_owner_id = "${var.account_number}"
  auto_accept   = true

  tags {
    Side = "Requester"
  }

  accepter {
    allow_remote_vpc_dns_resolution = true
  }

  requester {
    allow_remote_vpc_dns_resolution = true
  }
}

# Create a route to the account VPC on the environment vpc route table
resource "aws_route" "outgoing" {
  route_table_id            = "${data.terraform_remote_state.vpc.private_subnet_route_table_id}"
  destination_cidr_block    = "${var.account_vpc_cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.internal.id}"
}

# Create a route to the environment VPC on the account vpc route table
resource "aws_route" "incoming" {
  route_table_id            = "${data.terraform_remote_state.account_vpc.private_subnet_route_table_id}"
  destination_cidr_block    = "${var.vpc_cidr}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.internal.id}"
}

# Create a route to the environment VPC on the public account vpc route table for VPN traffic
resource "aws_route" "vpn" {
  route_table_id            = "${data.terraform_remote_state.account_vpc.public_subnet_route_table_id}"
  destination_cidr_block    = "${var.vpc_cidr}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.internal.id}"
}

# Add each side's default private security group ID to the other's

# Add account private security group to environmentprivate security group

resource "aws_security_group_rule" "account_ingress" {
  depends_on   = ["aws_vpc_peering_connection.internal"]
  type        = "ingress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  source_security_group_id = "${data.terraform_remote_state.account_vpc.private_sg_id}"

  security_group_id = "${data.terraform_remote_state.vpc.private_sg_id}"
}

# Add environment private security group to account private security group

resource "aws_security_group_rule" "environment_ingress" {
  depends_on   = ["aws_vpc_peering_connection.internal"]
  type        = "ingress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  source_security_group_id = "${data.terraform_remote_state.vpc.private_sg_id}"

  security_group_id = "${data.terraform_remote_state.account_vpc.private_sg_id}"
}

resource "aws_security_group_rule" "vpn_ingress" {
  depends_on = ["aws_vpc_peering_connection.internal"]
  type       = "ingress"
  from_port  = 0
  to_port    = 0
  protocol   = "-1"
  security_group_id = "${data.terraform_remote_state.vpc.private_sg_id}"

  source_security_group_id = "${data.terraform_remote_state.openvpn_as.openvpnas_sg_id}"
}

