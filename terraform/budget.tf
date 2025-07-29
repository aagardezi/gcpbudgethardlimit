resource "google_billing_budget" "budget" {
  billing_account = var.billing_account
  display_name    = "Billing Budget"

  budget_filter {
    projects = ["projects/${var.project_id}"]
  }

  amount {
    specified_amount {
      currency_code = "USD"
      units         = "100"
    }
  }

  threshold_rules {
    threshold_percent = 1.0
    spend_basis       = "CURRENT_SPEND"
  }

  notifications_rule {
    pubsub_topic = google_pubsub_topic.billing_notifications.id
    schema_version = "1.0"
  }
}

resource "google_pubsub_topic" "billing_notifications" {
  name = "billing-notifications"
}

resource "google_project_iam_member" "pubsub_publisher" {
  project = var.project_id
  role    = "roles/pubsub.publisher"
  member  = "serviceAccount:cloud-billing-notification-sender@gcp-sa-billing.iam.gserviceaccount.com"
}

resource "google_pubsub_subscription" "billing_subscription" {
  name  = "billing-subscription"
  topic = google_pubsub_topic.billing_notifications.name

  push_config {
    oidc_token {
      service_account_email = google_service_account.disable_billing_sa.email
    }
    push_endpoint = google_cloud_run_v2_service.disable_billing.uri
  }
}