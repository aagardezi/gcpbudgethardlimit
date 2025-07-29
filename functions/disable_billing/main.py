
import os
import json
from google.cloud import billing

def disable_billing_account(request):
    """
    Disables the billing account associated with the project.
    """
    project_id = os.environ.get("GCP_PROJECT")
    if not project_id:
        return "GCP_PROJECT environment variable not set.", 400

    try:
        billing_client = billing.CloudBillingClient()
        project_billing_info = billing_client.get_project_billing_info(
            name=f"projects/{project_id}"
        )
        billing_account_name = project_billing_info.billing_account_name

        if billing_account_name:
            billing_client.update_project_billing_info(
                name=f"projects/{project_id}",
                project_billing_info={"billing_account_name": ""},
            )
            return f"Billing account {billing_account_name} disabled for project {project_id}.", 200
        else:
            return f"Billing already disabled for project {project_id}.", 200
    except Exception as e:
        return f"Error disabling billing: {e}", 500
