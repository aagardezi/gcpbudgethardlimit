# GCP Budget Hard Limit

This project demonstrates how to use GCP budgets to trigger a Cloud Run function that disables the billing account in the project, effectively setting a hard limit on spending.

## Project Structure

- `functions/disable_billing`:
  - `main.py`: The Python Cloud Function that disables the billing account.
  - `requirements.txt`: The Python dependencies for the Cloud Function.
- `terraform`:
  - `main.tf`: The main Terraform file that defines the GCP resources.
  - `variables.tf`: The Terraform variables.
  - `outputs.tf`: The Terraform outputs.
  - `budget.tf`: The Terraform file that defines the GCP budget.

## Setup

1. **Clone the repository:**

   ```bash
   git clone https://github.com/your-username/gcp-budget-hard-limit.git
   cd gcp-budget-hard-limit
   ```

2. **Enable the required APIs:**

   ```bash
   gcloud services enable \
     cloudbilling.googleapis.com \
     cloudbuild.googleapis.com \
     cloudfunctions.googleapis.com \
     cloudresourcemanager.googleapis.com \
     run.googleapis.com
   ```

3. **Create a `terraform.tfvars` file:**

   Create a file named `terraform.tfvars` in the `terraform` directory with the following content:

   ```
   project_id      = "your-gcp-project-id"
   billing_account = "your-gcp-billing-account-id"
   ```

4. **Initialize and apply Terraform:**

   ```bash
   cd terraform
   terraform init
   terraform apply
   ```

## How it works

1. The Terraform code creates a Cloud Run service that, when triggered, disables the billing account for the project.
2. A GCP budget is created with a specified amount (e.g., $100).
3. When the budget's threshold is reached (e.g., 100% of the budgeted amount), a message is sent to a Pub/Sub topic.
4. The Pub/Sub topic is configured to trigger the Cloud Run service.
5. The Cloud Run service receives the message and disables the billing account for the project.

## Important Notes

- **This is a hard limit.** Once the billing account is disabled, you will not be able to use any GCP services that require billing.
- **Be careful.** Make sure you understand the implications of disabling the billing account before using this project.
- **The budget amount is set to $100 by default.** You can change this value in `terraform/budget.tf`.