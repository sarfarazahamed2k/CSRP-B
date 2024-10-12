#!/bin/bash

# Define variables
jeffUserName="JeffMcJunkin"
servicePrincipalName="myServicePrincipalName1"
domain="sarfarazahamed2018gmail.onmicrosoft.com"
resourceGroupName="myRG1"

# Delete the Azure AD user
az ad user delete --id "$jeffUserName@$domain"

# Get the Object ID of the service principal
servicePrincipalId=$(az ad sp list --display-name $servicePrincipalName --query '[0].id' --output tsv)

# Delete the service principal
az ad sp delete --id $servicePrincipalId

# Delete the Resource Group (and all its resources)
az group delete --name $resourceGroupName --yes --no-wait