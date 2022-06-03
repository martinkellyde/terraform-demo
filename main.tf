module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "ops4-sandbox-vpc-dev"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = false
  enable_vpn_gateway = false
  public_dedicated_network_acl = true
  private_dedicated_network_acl = true
  default_security_group_egress = []
  default_security_group_ingress = []
  default_security_group_name = "ops4-sandbox-sg-dev"
  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}