# Create an internal zone that the environment components use to reach each other

resource "aws_route53_zone" "internal_zone" {
  name    = "private"
  comment = "${var.env}-${var.aws_region}-vpc internal DNS zone"

  vpc_region = "${var.aws_region}"
  vpc_id     = "${aws_vpc.main.id}"
}

output "internal_dns_zone_id" {
  value = "${aws_route53_zone.internal_zone.zone_id}"
}

# Create an environment specific zone so peered networks can resolve resources

resource "aws_route53_zone" "environment_zone" {
  name    = "${var.env}"
  comment = "${var.env}-${var.aws_region}-vpc environment DNS zone"

  vpc_region = "${var.aws_region}"
  vpc_id     = "${aws_vpc.main.id}"
}

output "environment_dns_zone_id" {
  value = "${aws_route53_zone.environment_zone.zone_id}"
}

/*

resource "aws_route53_zone" "reverse_zone" {
  name   = "${format(
    "%s.%s.in-addr.arpa",
    element(split(".", element(split("/", var.vpc_cidr), 0)), 1),
    element(split(".", element(split("/", var.vpc_cidr), 0)), 0)
  )}"
  comment = "${var.env}-${var.aws_region}-vpc reverse DNS zone"

  vpc_region = "${var.aws_region}"
  vpc_id     = "${aws_vpc.main.id}"
}

output "reverse_dns_zone_id" {
  value = "${aws_route53_zone.reverse_zone.zone_id}"
}


*/