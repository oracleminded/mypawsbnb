output "vpc_id" {
  description = "VPC containing the PostgreSQL database."
  value       = aws_vpc.rds.id
}

output "private_subnet_ids" {
  description = "Private subnets in the RDS DB subnet group."
  value       = aws_subnet.database[*].id
}

output "database_security_group_id" {
  description = "Security group controlling PostgreSQL access."
  value       = aws_security_group.postgres.id
}

output "database_identifier" {
  description = "RDS DB instance identifier."
  value       = aws_db_instance.postgres.identifier
}

output "database_endpoint" {
  description = "PostgreSQL DNS endpoint."
  value       = aws_db_instance.postgres.address
}

output "database_port" {
  description = "PostgreSQL TCP port."
  value       = aws_db_instance.postgres.port
}

output "database_name" {
  description = "Initial PostgreSQL database name."
  value       = aws_db_instance.postgres.db_name
}

output "database_master_username" {
  description = "PostgreSQL master username."
  value       = aws_db_instance.postgres.username
}

output "master_user_secret_arn" {
  description = "Secrets Manager ARN containing the RDS master credentials."
  value       = aws_db_instance.postgres.master_user_secret[0].secret_arn
}

output "database_connection_details" {
  description = "Connection details excluding the password."

  value = {
    host     = aws_db_instance.postgres.address
    port     = aws_db_instance.postgres.port
    database = aws_db_instance.postgres.db_name
    username = aws_db_instance.postgres.username
    sslmode  = "require"
  }
}