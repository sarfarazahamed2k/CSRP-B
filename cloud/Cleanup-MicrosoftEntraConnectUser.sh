#!/bin/bash

# Define variables
userName="AzureConnect"
domain="sarfarazahamed2018gmail.onmicrosoft.com"
excludeUser="sarfaraz.ahamed2018_gmail.com#EXT#@sarfarazahamed2018gmail.onmicrosoft.com"

# Delete the Azure AD user
az ad user delete --id "$userName@$domain"

# Fetch all users with their identities
users=$(az ad user list --query "[].{userPrincipalName:userPrincipalName}" --output tsv)

# Loop through each user and delete if it's not the excluded user
while IFS=$'\t' read -r userPrincipalName; do
    if [[ "$userPrincipalName" != "$excludeUser" ]]; then
        az ad user delete --id "$userPrincipalName"
    fi
done <<< "$users"