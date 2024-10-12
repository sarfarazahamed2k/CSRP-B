#!/bin/bash

# Define variables
resourceGroupName="WebApp"
networkWatcherResourceGroupName="NetworkWatcherRG"

# Delete the Resource Group (and all its resources)
az group delete --name $resourceGroupName --yes --no-wait

# Delete the Network Watcher Resource Group and all resources within it
az group delete --name $networkWatcherResourceGroupName --yes --no-wait