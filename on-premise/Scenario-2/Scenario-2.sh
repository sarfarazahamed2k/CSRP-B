#!/bin/bash

# Define variables
resourceGroupName="on-premise"
winServerVmName="CSRP-DC"

# Paths to the scripts
scriptLLMNRPoisoning="./Create-LLMNR-Poisioning.ps1"

# Execute configuration scripts on the VMs

# Invoke script to configure Domain Controller
az vm run-command invoke --resource-group $resourceGroupName --name $winServerVmName --command-id RunPowerShellScript --scripts @$scriptLLMNRPoisoning
