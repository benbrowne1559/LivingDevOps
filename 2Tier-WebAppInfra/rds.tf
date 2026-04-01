module "db" {
  source = "terraform-aws-modules/rds/aws"

  identifier = var.db_name

  # All available versions: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_PostgreSQL.html#PostgreSQL.Concepts
  engine                   = "postgres"
  engine_version           = "17"
  engine_lifecycle_support = "open-source-rds-extended-support-disabled"
  family                   = "postgres17" # DB parameter group
  major_engine_version     = "17"         # DB option group
  instance_class           = "db.t3.micro"

  skip_final_snapshot = true

  allocated_storage     = 20
  max_allocated_storage = 30

  db_name  = "postgres"
  username = "postgres"
  port     = 5432

  # Setting manage_master_user_password_rotation to false after it
  # has previously been set to true disables automatic rotation
  # however using an initial value of false (default) does not disable
  # automatic rotation and rotation will be handled by RDS.
  # manage_master_user_password_rotation allows users to configure
  # a non-default schedule and is not meant to disable rotation
  # when initially creating / enabling the password management feature
  manage_master_user_password = true
  // get this as an output and
  manage_master_user_password_rotation                   = true
  master_user_password_rotation_automatically_after_days = 7

  multi_az               = false
  db_subnet_group_name   = aws_db_subnet_group.rds-sng.name
  vpc_security_group_ids = [aws_security_group.rds-sg.id]

  enabled_cloudwatch_logs_exports = ["postgresql"]
  create_cloudwatch_log_group     = true

  tags = var.tags
}

resource "aws_db_subnet_group" "rds-sng" {
  name       = "postgres private subnet group"
  subnet_ids = aws_subnet.private-rds-sn[*].id

  tags = {
    Name = "Private RDS Subnet Group"
  }
}
