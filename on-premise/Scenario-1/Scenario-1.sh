#!/bin/bash

# Variables
resourceGroupName="on-premise"
winServerVmName="CSRP-DC"
scriptSetupVPN="./Setup-VPN.ps1"

az vm run-command invoke --resource-group $resourceGroupName --name $winServerVmName --command-id RunPowerShellScript --scripts @$scriptSetupVPN