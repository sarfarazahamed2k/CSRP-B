#!/bin/bash

# Variables
resourceGroupName="RedTeam"

# Delete the resource group
echo "Deleting resource group $resourceGroupName and all its resources..."
az group delete --name $resourceGroupName --yes --no-wait

# Confirmation message
echo "Deletion request for resource group $resourceGroupName has been submitted."
