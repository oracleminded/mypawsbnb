terraform {
  required_version = ">= 1.5.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 7.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

variable "project_id" {
  description = "Google Cloud project ID"
  type        = string
}

variable "region" {
  description = "Google Cloud region"
  type        = string
  default     = "us-central1"
}

variable "instance_name" {
  description = "Cloud SQL PostgreSQL instance name"
  type        = string
  default     = "postgres-minimal"
}

variable "database_name" {
  description = "Application database name"
  type        = string
  default     = "appdb"
}

variable "db_user" {
  description = "PostgreSQL user name"
  type        = string
  default     = "appuser"
}

variable "authorized_network_cidr" {
  description = "Optional public CIDR allowed to connect directly, for example YOUR_PUBLIC_IP/32. Leave null to avoid direct public client access."
  type        = string
  default     = null
}

resource "google_project_service" "sqladmin" {
  project = var.project_id
  service = "sqladmin.googleapis.com"

  disable_on_destroy = false
}

resource "random_password" "db_password" {
  length  = 20
  special = true
}

resource "google_sql_database_instance" "postgres" {
  name             = var.instance_name
  database_version = "POSTGRES_18"
  region           = var.region

  deletion_protection = false

  settings {
    edition           = "ENTERPRISE"
    tier              = "db-f1-micro"
    availability_type = "ZONAL"
    disk_size         = 10
    disk_autoresize   = true

    backup_configuration {
      enabled = false
    }

    ip_configuration {
      ipv4_enabled = true

      dynamic "authorized_networks" {
        for_each = var.authorized_network_cidr == null ? [] : [var.authorized_network_cidr]

        content {
          name  = "laptop"
          value = authorized_networks.value
        }
      }
    }
  }

  depends_on = [google_project_service.sqladmin]
}

resource "google_sql_database" "database" {
  name     = var.database_name
  instance = google_sql_database_instance.postgres.name
}

resource "google_sql_user" "user" {
  name     = var.db_user
  instance = google_sql_database_instance.postgres.name
  password = random_password.db_password.result
}

output "instance_name" {
  value = google_sql_database_instance.postgres.name
}

output "connection_name" {
  value = google_sql_database_instance.postgres.connection_name
}

output "database_name" {
  value = google_sql_database.database.name
}

output "db_user" {
  value = google_sql_user.user.name
}

output "db_password" {
  value     = random_password.db_password.result
  sensitive = true
}