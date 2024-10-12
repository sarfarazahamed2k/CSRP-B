#!/bin/bash

# Variables
resourceGroupName="HR-Department"

# Delete the resource group
az group delete --name $resourceGroupName --yes --no-wait
