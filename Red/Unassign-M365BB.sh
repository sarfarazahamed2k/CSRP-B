#!/bin/bash

# Bash script to unassign a specific license from a user using Azure CLI
# USER_EMAIL is now taken from an environment variable

# Variables
SKU_PART_NUMBER="O365_BUSINESS_ESSENTIALS"  # Replace with the SKU part number of the license to unassign

# Check if USER_EMAIL environment variable is set
if [ -z "$USER_EMAIL" ]; then
  echo "Error: USER_EMAIL environment variable is not set. Please set it before running the script."
  exit 1
else
  echo "Using USER_EMAIL from environment variable: $USER_EMAIL"
fi

# Log in to Azure CLI (uncomment if you need to log in interactively)
# az login

# Retrieve the user's Object ID
echo "Retrieving Object ID for user: $USER_EMAIL..."

USER_OBJECT_ID=$(az ad user show --id "$USER_EMAIL" --query "id" --output tsv)

if [ -z "$USER_OBJECT_ID" ]; then
  echo "Error: Could not find user with email $USER_EMAIL."
  exit 1
else
  echo "Found User Object ID: $USER_OBJECT_ID"
fi

# Get the SKU ID for the specified license
echo "Retrieving SKU ID for license with SKU part number: $SKU_PART_NUMBER..."

SKU_ID=$(az rest --method GET \
  --url "https://graph.microsoft.com/v1.0/subscribedSkus" \
  --headers "Content-Type=application/json" \
  --query "value[?skuPartNumber=='$SKU_PART_NUMBER'].skuId" \
  --output tsv)

if [ -z "$SKU_ID" ]; then
  echo "Error: Could not find SKU ID for license with SKU part number $SKU_PART_NUMBER."
  exit 1
else
  echo "Found SKU ID: $SKU_ID"
fi

# Unassign the specified license from the user
echo "Unassigning license from user: $USER_EMAIL..."

az rest --method POST \
  --url "https://graph.microsoft.com/v1.0/users/$USER_OBJECT_ID/assignLicense" \
  --headers "Content-Type=application/json" \
  --body "{
    \"addLicenses\": [],
    \"removeLicenses\": [
      \"$SKU_ID\"
    ]
  }"

if [ $? -ne 0 ]; then
  echo "Error: Could not remove license from $USER_EMAIL."
  exit 1
else
  echo "Successfully removed license with SKU part number $SKU_PART_NUMBER."
fi

echo "License unassignment script completed."
