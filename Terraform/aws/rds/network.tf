data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  selected_availability_zones = slice(
    data.aws_availability_zones.available.names,
    0,
    length(var.private_subnet_cidrs)
  )
}

resource "aws_vpc" "rds" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "mypawsbnb-${var.environment}-vpc"
  }
}

resource "aws_subnet" "database" {
  count = length(var.private_subnet_cidrs)

  vpc_id            = aws_vpc.rds.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = local.selected_availability_zones[count.index]

  map_public_ip_on_launch = false

  tags = {
    Name = "mypawsbnb-${var.environment}-db-${count.index + 1}"
    Tier = "Database"
  }
}

resource "aws_route_table" "database" {
  vpc_id = aws_vpc.rds.id

  tags = {
    Name = "mypawsbnb-${var.environment}-database-rt"
  }
}

resource "aws_route_table_association" "database" {
  count = length(aws_subnet.database)

  subnet_id      = aws_subnet.database[count.index].id
  route_table_id = aws_route_table.database.id
}

resource "aws_db_subnet_group" "postgres" {
  name        = "mypawsbnb-${var.environment}-postgres"
  description = "Private subnet group for the mypawsbnb PostgreSQL database"

  subnet_ids = aws_subnet.database[*].id

  tags = {
    Name = "mypawsbnb-${var.environment}-postgres"
  }
}

resource "aws_security_group" "postgres" {
  name        = "mypawsbnb-${var.environment}-postgres"
  description = "Controls access to the mypawsbnb PostgreSQL database"
  vpc_id      = aws_vpc.rds.id

  tags = {
    Name = "mypawsbnb-${var.environment}-postgres"
  }
}

resource "aws_vpc_security_group_ingress_rule" "postgres_cidr" {
  for_each = var.allowed_postgres_cidr_blocks

  security_group_id = aws_security_group.postgres.id
  description       = "PostgreSQL access from ${each.value}"

  cidr_ipv4   = each.value
  from_port   = 5432
  to_port     = 5432
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "postgres" {
  security_group_id = aws_security_group.postgres.id
  description       = "Allow outbound traffic"

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}