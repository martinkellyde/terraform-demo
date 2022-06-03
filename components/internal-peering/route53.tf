# associate the environment vpc with the account level route53 zone, so instances
# in the environment vpcs can use dns to connect to hosts in the account level vpc
resource "aws_route53_zone_association" "account" {
  vpc_id  = "${data.terraform_remote_state.vpc.vpc_id}"
  zone_id = "${data.terraform_remote_state.account_vpc.environment_dns_zone_id}"
}

# opposite of above, allows instances in the account vpc to use dns to connect to
# instances in the environment level vpcs
resource "aws_route53_zone_association" "environment" {
  vpc_id  = "${data.terraform_remote_state.account_vpc.vpc_id}"
  zone_id = "${data.terraform_remote_state.vpc.environment_dns_zone_id}"
}
