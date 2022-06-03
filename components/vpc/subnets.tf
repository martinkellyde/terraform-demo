resource "aws_subnet" "public_subnet_1" {
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "${var.public_subnet_1_cidr}"
  availability_zone = "${var.public_subnet_1_az}"

  tags {
    Name        = "${var.env}-public_subnet_1"
    Environment = "${var.env}"
    Terraform   = "True"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "${var.public_subnet_2_cidr}"
  availability_zone = "${var.public_subnet_2_az}"

  tags {
    Name        = "${var.env}-public_subnet_2"
    Environment = "${var.env}"
    Terraform   = "True"
  }
}

resource "aws_subnet" "public_subnet_3" {
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "${var.public_subnet_3_cidr}"
  availability_zone = "${var.public_subnet_3_az}"

  tags {
    Name        = "${var.env}-public_subnet_3"
    Environment = "${var.env}"
    Terraform   = "True"
  }
}

resource "aws_subnet" "private_subnet_1" {
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "${var.private_subnet_1_cidr}"
  availability_zone = "${var.private_subnet_1_az}"

  tags {
    Name        = "${var.env}-private_subnet_1"
    Environment = "${var.env}"
    Terraform   = "True"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "${var.private_subnet_2_cidr}"
  availability_zone = "${var.private_subnet_2_az}"

  tags {
    Name        = "${var.env}-private_subnet_2"
    Environment = "${var.env}"
    Terraform   = "True"
  }
}

resource "aws_subnet" "private_subnet_3" {
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "${var.private_subnet_3_cidr}"
  availability_zone = "${var.private_subnet_3_az}"

  tags {
    Name        = "${var.env}-private_subnet_3"
    Environment = "${var.env}"
    Terraform   = "True"
  }
}

output "public_subnet_1_id" {
  value = "${aws_subnet.public_subnet_1.id}"
}

output "public_subnet_2_id" {
  value = "${aws_subnet.public_subnet_2.id}"
}

output "public_subnet_3_id" {
  value = "${aws_subnet.public_subnet_3.id}"
}

output "private_subnet_1_id" {
  value = "${aws_subnet.private_subnet_1.id}"
}

output "private_subnet_2_id" {
  value = "${aws_subnet.private_subnet_2.id}"
}

output "private_subnet_3_id" {
  value = "${aws_subnet.private_subnet_3.id}"
}

output "private_subnet_ids" {
  value = [
    "${aws_subnet.private_subnet_1.id}",
    "${aws_subnet.private_subnet_2.id}",
    "${aws_subnet.private_subnet_3.id}",
  ]
}

output "public_subnet_ids" {
  value = [
    "${aws_subnet.public_subnet_1.id}",
    "${aws_subnet.public_subnet_2.id}",
    "${aws_subnet.public_subnet_3.id}",
  ]
}


