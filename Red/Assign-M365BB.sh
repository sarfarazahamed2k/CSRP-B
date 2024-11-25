#!/bin/bash

# Bash script to assign Microsoft 365 Business Basic license to a user using Azure CLI
# USER_EMAIL is now taken from an environment variable

# Variables
USAGE_LOCATION="AU"  

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

# Update the user's usage location using Microsoft Graph API
echo "Updating usage location for user: $USER_EMAIL to $USAGE_LOCATION..."

az rest --method PATCH \
  --url "https://graph.microsoft.com/v1.0/users/$USER_OBJECT_ID" \
  --headers "Content-Type=application/json" \
  --body "{\"usageLocation\": \"$USAGE_LOCATION\"}"

if [ $? -ne 0 ]; then
  echo "Error: Could not update usage location for $USER_EMAIL."
  exit 1
else
  echo "Successfully updated usage location to $USAGE_LOCATION."
fi

# Get the SKU ID for Microsoft 365 Business Basic license
echo "Retrieving SKU ID for Microsoft 365 Business Basic license..."

SKU_ID=$(az rest --method GET \
  --url "https://graph.microsoft.com/v1.0/subscribedSkus" \
  --headers "Content-Type=application/json" \
  --query "value[?skuPartNumber=='O365_BUSINESS_ESSENTIALS'].skuId" \
  --output tsv)

if [ -z "$SKU_ID" ]; then
  echo "Error: Could not find SKU ID for Microsoft 365 Business Basic license."
  exit 1
else
  echo "Found SKU ID: $SKU_ID"
fi

# Assign the license to the user
echo "Assigning license to user: $USER_EMAIL..."

az rest --method POST \
  --url "https://graph.microsoft.com/v1.0/users/$USER_OBJECT_ID/assignLicense" \
  --headers "Content-Type=application/json" \
  --body "{
    \"addLicenses\": [
      {
        \"skuId\": \"$SKU_ID\"
      }
    ],
    \"removeLicenses\": []
  }"

if [ $? -ne 0 ]; then
  echo "Error: Could not assign license to $USER_EMAIL."
  exit 1
else
  echo "Successfully assigned license."
fi

# Verify the license assignment
echo "Verifying license assignment..."

LICENSES=$(az rest --method GET \
  --url "https://graph.microsoft.com/v1.0/users/$USER_OBJECT_ID/licenseDetails" \
  --headers "Content-Type=application/json" \
  --query "value[].skuPartNumber" \
  --output tsv)

echo "Assigned Licenses for $USER_EMAIL:"
echo "$LICENSES"

echo "License assignment script completed."
