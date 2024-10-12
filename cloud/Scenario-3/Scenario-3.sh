#!/bin/bash

# Define variables
jeffUserName="JeffMcJunkin"
jeffDisplayName="Jeff McJunkin"
jeffPassword="SecureP@ssw0rd!"
domain="sarfarazahamed2018gmail.onmicrosoft.com"
applicationAdminRoleId="9b895d92-2cd3-44c7-9d02-a6ac2d5ea5c3"
privilegedRoleAdminRoleId="e8611ab8-c189-46e8-94e1-60213ab1f814"
resourceGroupName="myRG1"
resourceGroupLocation="Australia Central"
servicePrincipalName="myServicePrincipalName1"

# Get the subscription ID
subscriptionId=$(az account show --query 'id' --output tsv)

# Create the resource group in Australia Central
az group create --name $resourceGroupName --location "$resourceGroupLocation"

# Create a new user and capture the userId
jeffUserId=$(az ad user create --display-name "$jeffDisplayName" \
                               --password "$jeffPassword" \
                               --user-principal-name "$jeffUserName@$domain" \
                               --mail-nickname "$jeffUserName" \
                               --query 'id' \
                               --output tsv)

# Assign the user to the application admin role
az rest --method POST --uri 'https://graph.microsoft.com/v1.0/roleManagement/directory/roleAssignments' \
                      --body "{'principalId': '$jeffUserId', 'roleDefinitionId': '$applicationAdminRoleId', 'directoryScopeId': '/'}"

# Create an Azure service principal and assign it the reader role for the specified scope
az ad sp create-for-rbac --name $servicePrincipalName --role reader --scopes /subscriptions/$subscriptionId/resourceGroups/$resourceGroupName

# Get the Object ID of the service principal
servicePrincipalId=$(az ad sp list --display-name $servicePrincipalName --query '[0].id' --output tsv)

# Assign the service principal to the privileged role admin role
az rest --method POST --uri 'https://graph.microsoft.com/v1.0/roleManagement/directory/roleAssignments' \
                      --body "{'principalId': '$servicePrincipalId', 'roleDefinitionId': '$privilegedRoleAdminRoleId', 'directoryScopeId': '/'}"
