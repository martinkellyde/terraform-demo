resource "aws_vpc" "main" {
  cidr_block = "${var.vpc_cidr}"

  enable_dns_hostnames = "true"
  enable_dns_support   = "true"

  tags {
    Name        = "${var.env}-${var.aws_region}-vpc"
    Environment = "${var.env}"
    Terraform   = "True"
  }
}

output "vpc_id" {
  value = "${aws_vpc.main.id}"
}



resource "aws_internet_gateway" "internet_gw" {
  vpc_id = "${aws_vpc.main.id}"

  tags {
    Name        = "${var.env}-${var.aws_region}-igw"
    Environment = "${var.env}"
    Terraform   = "True"
  }
}

/*
resource "aws_nat_gateway" "nat_gw" {
  allocation_id = "${var.nat_gateway_eip}"
  subnet_id     = "${aws_subnet.public_subnet_1.id}"

  depends_on = ["aws_internet_gateway.internet_gw"]
}
*/
resource "aws_vpc_dhcp_options" "search_path" {
  domain_name = "${var.aws_region}.compute.internal private"
  domain_name_servers = ["AmazonProvidedDNS"]
}

resource "aws_vpc_dhcp_options_association" "search_path" {
  vpc_id          = "${aws_vpc.main.id}"
  dhcp_options_id = "${aws_vpc_dhcp_options.search_path.id}"
}
