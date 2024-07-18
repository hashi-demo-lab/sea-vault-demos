import os
from terrasnek.api import TFC

# Get environment variables for Terraform Cloud configuration
TFE_TOKEN = os.getenv("TFE_TOKEN")
if not TFE_TOKEN:
    raise ValueError("Please set the TFE_TOKEN environment variable.")

TFE_URL = os.getenv("TFE_URL", "https://app.terraform.io")
TFE_ORG = os.getenv("TFE_ORG", "hashi-demos-apj")

# Initialize the Terraform Cloud API client
api = TFC(TFE_TOKEN, url=TFE_URL)
api.set_org(TFE_ORG)

# Fetch all workspaces for the organization
all_workspaces = api.workspaces.list_all()['data']

# Iterate over each workspace and calculate RUM
total_rum = 0
for workspace in all_workspaces:
    workspace_name = workspace['attributes']['name']
    workspace_id = workspace['id']

    # Fetch the resources for the workspace
    listed_resources = api.workspace_resources.list(workspace_id=workspace_id)["data"]

    rum = 0
    for resource in listed_resources:
        resource_provider_type = resource['attributes']['provider-type']
        # Check if the resource should be excluded
        if not (resource_provider_type.startswith("data") or 
                resource_provider_type == "terraform_data" or 
                resource_provider_type == "null_resources"):
            rum += 1

    total_rum += rum
    print(f"{workspace_name}: {rum} resources")

print("\nTotal RUM across all workspaces:", total_rum)
