provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
  zone    = var.gcp_zone
}

# Cloud storage bucket
resource "google_storage_bucket" "storage-bucket-anihils" {
  name          = "terraform-bucket"
  location      = var.gcp_region
  force_destroy = true
  uniform_bucket_level_access = true
}

# VPC Network
resource "google_compute_network" "vpc_network" {
  name                    = "terraform-network"
  auto_create_subnetworks = "true"
}

# SQL Database
resource "google_sql_database" "sql-database" {
  name     = "terraform-database"
  instance = google_sql_database_instance.sql-database-instance.name
}

resource "google_sql_database_instance" "sql-database-instance" {
  name             = "terraform-database-instance"
  region           = var.gcp_region
  database_version = "MYSQL_8_0"
  settings {
    tier = "db-f1-micro"
  }
  deletion_protection  = "true"
}

# BigQuery Dataset
resource "google_bigquery_dataset" "bq-dataset" {
  dataset_id                  = "terraform_dataset"
  description                 = "BigQuery Dataset generated using terraform script"
  location                    = var.gcp_region
  depends_on                  = [ google_service_account.bqowner ]

  access {
    role          = "OWNER"
    user_by_email = google_service_account.bqowner.email
  }

  access {
    role   = "READER"
    domain = "hashicorp.com"
  }
}

resource "google_service_account" "bqowner" {
  account_id = "bqowner"
}
