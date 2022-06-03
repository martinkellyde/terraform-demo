# Do not define routes inline - makes this overwrite any routes added by other components
# just create the route table then later add routes using an aws_route resource

resource "aws_route_table" "public_subnet_route_table" {
  vpc_id = "${aws_vpc.main.id}"

  tags {
    Name        = "${var.env}-public_subnet_route_table"
    Environment = "${var.env}"
    Terraform   = "True"
  }
}

resource "aws_route" "internet_gw" {
  route_table_id = "${aws_route_table.public_subnet_route_table.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = "${aws_internet_gateway.internet_gw.id}"
}

resource "aws_route_table" "private_subnet_route_table" {
  vpc_id = "${aws_vpc.main.id}"

  tags {
    Name        = "${var.env}-private_subnet_route_table"
    Environment = "${var.env}"
    Terraform   = "True"
  }
}

resource "aws_route" "nat_gw" {
  route_table_id = "${aws_route_table.private_subnet_route_table.id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = "${aws_nat_gateway.nat_gw.id}"
}

resource "aws_route_table_association" "public_subnet_1" {
  subnet_id      = "${aws_subnet.public_subnet_1.id}"
  route_table_id = "${aws_route_table.public_subnet_route_table.id}"
}

resource "aws_route_table_association" "public_subnet_2" {
  subnet_id      = "${aws_subnet.public_subnet_2.id}"
  route_table_id = "${aws_route_table.public_subnet_route_table.id}"
}

resource "aws_route_table_association" "public_subnet_3" {
  subnet_id      = "${aws_subnet.public_subnet_3.id}"
  route_table_id = "${aws_route_table.public_subnet_route_table.id}"
}

resource "aws_route_table_association" "private_subnet_1" {
  subnet_id      = "${aws_subnet.private_subnet_1.id}"
  route_table_id = "${aws_route_table.private_subnet_route_table.id}"
}

resource "aws_route_table_association" "private_subnet_2" {
  subnet_id      = "${aws_subnet.private_subnet_2.id}"
  route_table_id = "${aws_route_table.private_subnet_route_table.id}"
}

resource "aws_route_table_association" "private_subnet_3" {
  subnet_id      = "${aws_subnet.private_subnet_3.id}"
  route_table_id = "${aws_route_table.private_subnet_route_table.id}"
}

# Export the route table IDs so peering modules can add routes to them
#

output "public_subnet_route_table_id" {
  value = "${aws_route_table.public_subnet_route_table.id}"
}

output "private_subnet_route_table_id" {
  value = "${aws_route_table.private_subnet_route_table.id}"
}
