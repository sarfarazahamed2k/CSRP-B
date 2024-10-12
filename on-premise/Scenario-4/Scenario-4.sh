#!/bin/bash

# Define variables
resourceGroupName="on-premise"
winServerVmName="CSRP-DC"

# Paths to the scripts
scriptSetupKerberaosting="./Setup-Kerberoasting.ps1"

# Execute configuration scripts on the VMs

# Invoke script to configure Domain Controller
az vm run-command invoke --resource-group $resourceGroupName --name $winServerVmName --command-id RunPowerShellScript --scripts @$scriptSetupKerberaosting

# Wait for the restart to complete before proceeding
sleep 60