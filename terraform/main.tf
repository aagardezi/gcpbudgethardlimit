terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_cloud_run_v2_service" "disable_billing" {
  name     = "disable-billing-service"
  location = var.region

  template {
    containers {
      image = "gcr.io/${var.project_id}/disable-billing"
      ports {
        container_port = 8080
      }
    }
    service_account = google_service_account.disable_billing_sa.email
  }
}

resource "google_service_account" "disable_billing_sa" {
  account_id   = "disable-billing-sa"
  display_name = "Disable Billing Service Account"
}

resource "google_project_iam_member" "disable_billing_sa_billing_admin" {
  project = var.project_id
  role    = "roles/billing.admin"
  member  = "serviceAccount:${google_service_account.disable_billing_sa.email}"
}

resource "google_storage_bucket" "bucket" {
  name     = "${var.project_id}-billing-functions"
  location = "US"
}

resource "google_storage_bucket_object" "archive" {
  name   = "source.zip"
  bucket = google_storage_bucket.bucket.name
  source = data.archive_file.source.output_path
}

data "archive_file" "source" {
  type        = "zip"
  source_dir  = "${path.module}/../functions/disable_billing"
  output_path = "/tmp/source.zip"
}