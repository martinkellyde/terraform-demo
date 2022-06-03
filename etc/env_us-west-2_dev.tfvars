project = "mdk"
account_alias = "mkelly-aws1"
aws_region = "us-west-2"
env = "dev"
account_number = "052188317850"
backend_name = "mkelly-aws1-scaffold"
tls_certificate = "arn:aws:acm:us-west-2:052188317850:certificate/1ba4d3b1-4499-4dc8-8b20-6b2064d371a5"
r53_zone_id = "Z06131332BDNG47SH0R5J"
ssh_key_name = "mdkelly_ssh"
kms_key = "38a91c92-3f7e-4789-9a8c-40fedaef9ec5"
kms_key_arn = "arn:aws:kms:us-west-2:052188317850:key/38a91c92-3f7e-4789-9a8c-40fedaef9ec5" # For EFS config

default_tags = {
  "Project"     = "mdk"
  "Environment" = "dev"
  "Owner"       = "Martin Kelly"
  "Client"      = "Sandbox"
}

ingress_cidr_blocks = [
"156.109.18.2/32", # F5
"3.120.7.71/32", # GP Germany
]

# Network Variables (Should be derivable)

nat_gateway_eip="eipalloc-0cdb568c84762d314"


vpc_cidr="10.1.0.0/16"
public_subnet_1_cidr="10.1.1.0/24"
public_subnet_1_az="us-west-2a"
public_subnet_2_cidr="10.1.2.0/24"
public_subnet_2_az="us-west-2b"
public_subnet_3_cidr="10.1.3.0/24"
public_subnet_3_az="us-west-2c"

private_subnet_1_cidr="10.1.101.0/24"
private_subnet_1_az="us-west-2a"
private_subnet_2_cidr="10.1.102.0/24"
private_subnet_2_az="us-west-2b"
private_subnet_3_cidr="10.1.103.0/24"
private_subnet_3_az="us-west-2c"


# Jira Variables

jira_host_instance_type="t2.medium"


# Techest Instance Size Override
techtest_host_instance_type="t3.nano"

database_username="masteruser"
master_database_password="masterpassword123"

techtest_database_port="5432"
database_master_instance_type="db.t2.small"
database_replica_instance_type="db.t2.small"
database_master_monitoring_interval="0"
database_replica_monitoring_interval="0"
database_storage_size="50"
backup_retention_period="0"

# DNS Variables

bastion_public_dns_name="bastion"
techtest_public_dns_name="techtest"
build_public_dns_name="build"
jira_public_dns_name="jira"