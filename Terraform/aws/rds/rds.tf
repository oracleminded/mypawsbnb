resource "aws_db_instance" "postgres" {
  identifier = "mypawsbnb-${var.environment}-postgres"

  engine         = "postgres"
  engine_version = var.postgres_engine_version
  instance_class = var.db_instance_class

  db_name  = var.database_name
  username = var.master_username
  port     = 5432

  manage_master_user_password = true

  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = "gp2"
  storage_encrypted     = true

  db_subnet_group_name   = aws_db_subnet_group.postgres.name
  vpc_security_group_ids = [aws_security_group.postgres.id]

  publicly_accessible = false
  multi_az            = var.multi_az

  backup_retention_period = var.backup_retention_period
  backup_window           = "07:00-08:00"
  maintenance_window      = "sun:08:30-sun:09:30"

  auto_minor_version_upgrade  = true
  allow_major_version_upgrade = false
  apply_immediately           = true

  enabled_cloudwatch_logs_exports = [
    "postgresql",
    "upgrade"
  ]

  copy_tags_to_snapshot = true

  deletion_protection      = false
  skip_final_snapshot      = true
  delete_automated_backups = true

  tags = {
    Name = "mypawsbnb-${var.environment}-postgres"
  }
}
