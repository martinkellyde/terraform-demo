resource "aws_db_subnet_group" "database" {
  name = "${var.env}-${var.aws_region}-postgres-subnets"

  description = "${var.env} postgres subnet group"

  subnet_ids = [
    "${data.terraform_remote_state.vpc.private_subnet_1_id}",
    "${data.terraform_remote_state.vpc.private_subnet_2_id}",
    "${data.terraform_remote_state.vpc.private_subnet_3_id}",
  ]


  tags {
    Name        = "${var.env}-postgres-subnets"
    Environment = "${var.env}"
    Terraform   = "True"
  }
}


resource "aws_db_parameter_group" "logging" {
    name = "${var.env}-slow-logging"
    family = "postgres9.5"

    parameter {
      name = "log_min_duration_statement"
      value = "500"
    }

  }

resource "aws_security_group" "database" {
  name        = "${var.env}-database-sg"
  description = "Allow databaseW"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"

  ingress {
    # TLS (change to whatever ports you need)
    from_port   = "${var.techtest_database_port}"
    to_port     = "${var.techtest_database_port}"
    protocol    = "TCP"
    security_groups = ["${aws_security_group.asg.id}"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "master" {
  allocated_storage = "${var.database_storage_size}"

  engine              = "postgres"
  engine_version      = "9.6.6"
  instance_class      = "db.t2.medium"
  identifier          = "${var.env}-postgres-master"
  multi_az            = "true"
  publicly_accessible = "false"
  name                = "techtest"
  username            = "${var.database_username}"
  password            = "${var.master_database_password}"
  backup_retention_period = "${var.backup_retention_period}"

  vpc_security_group_ids = ["${aws_security_group.database.id}"]

  db_subnet_group_name = "${aws_db_subnet_group.database.name}"
#  parameter_group_name = "${var.env}-slow-logging"

#  monitoring_role_arn = "${aws_iam_role.enhanced_metrics.arn}"
#  monitoring_interval = "${var.database_master_monitoring_interval}"

  backup_window           = "00:00-04:00"

  skip_final_snapshot = "true"
  final_snapshot_identifier = "techtest"

  apply_immediately = "true"

  tags {
    Name        = "${var.env}-postgres-master"
    Environment = "${var.env}"
    Terraform   = "True"
  }


}




resource "aws_route53_record" "cms_web_r53_internal" {
  zone_id = "${data.terraform_remote_state.vpc.internal_dns_zone_id}"
  name    = "database.private"
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_db_instance.master.address}"]
}

output "database_username" { 
  value = "${var.database_username}" 
}