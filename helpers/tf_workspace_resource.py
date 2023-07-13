#pip3 install terrasnek
#python3 tf_workspace_resource.py

import os
from terrasnek.api import TFC

TFE_TOKEN = os.getenv("TFE_TOKEN", None)
TFE_URL = os.getenv("TFE_URL", "https://app.terraform.io")  # ex: https://app.terraform.io
TFE_ORG = os.getenv("TFE_ORG", "hashi-demos-apj")

api = TFC(TFE_TOKEN, url=TFE_URL)
api.set_org(TFE_ORG)

all_workspaces = api.workspaces.list_all()['data']

rum = 0

for workspace in all_workspaces:
    print(workspace['attributes']['name'], workspace['attributes']['resource-count'])
    rum += int(workspace['attributes']['resource-count'])

print("\nTotal RUM:", rum)