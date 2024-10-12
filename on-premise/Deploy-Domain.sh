#!/bin/bash

# Define variables
resourceGroupName="on-premise"
winServerVmName="CSRP-DC"
win11VmName="workstation-1"

# Paths to the scripts
scriptPathDCDomain="./Configure-DC-Domain.ps1"
scriptPathDCUsers="./Configure-DC-Users.ps1"
scriptPathJoinDomain="./Join-Domain.ps1"
scriptAssignLocalAdmin="./Assign-Local-Admin.ps1"

# Execute configuration scripts on the VMs

# Invoke script to configure Domain Controller
az vm run-command invoke --resource-group $resourceGroupName --name $winServerVmName --command-id RunPowerShellScript --scripts @$scriptPathDCDomain

# Wait for the restart to complete before proceeding
sleep 60

# Invoke script to configure Domain Controller Users
az vm run-command invoke --resource-group $resourceGroupName --name $winServerVmName --command-id RunPowerShellScript --scripts @$scriptPathDCUsers

# Wait for the restart to complete before proceeding
sleep 120

# Invoke script to join the Windows 11 machine to the domain
az vm run-command invoke --resource-group $resourceGroupName --name $win11VmName --command-id RunPowerShellScript --scripts @$scriptPathJoinDomain

# Wait for the restart to complete before proceeding
sleep 60

# Invoke script to assign local admin on workstation-1
az vm run-command invoke --resource-group $resourceGroupName --name $win11VmName --command-id RunPowerShellScript --scripts @$scriptAssignLocalAdmin

# Wait for the restart to complete before proceeding
sleep 60