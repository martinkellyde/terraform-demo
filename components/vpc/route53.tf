# Create an internal, private zone that the environment components use to reach each other

resource "aws_route53_zone" "internal_zone" {
  name    = "private"
  comment = "${var.env}-${var.aws_region}-vpc internal DNS zone"

  vpc {
    vpc_id = "${aws_vpc.main.id}"
  }
}

output "internal_dns_zone_id" {
  value = "${aws_route53_zone.internal_zone.zone_id}"
}

# Create an environment specific zone so peered networks can resolve resources using names

resource "aws_route53_zone" "environment_zone" {
  name    = "${var.env}"
  comment = "${var.env}-${var.aws_region}-vpc environment DNS zone"

  vpc {
    vpc_id = "${aws_vpc.main.id}"
  }
}

output "environment_dns_zone_id" {
  value = "${aws_route53_zone.environment_zone.zone_id}"
}


resource "aws_route53_zone" "external" {
  name = "martinkelly.io"
}


output "external_dns_zone_id" {
  value = "${aws_route53_zone.external.zone_id}"
}