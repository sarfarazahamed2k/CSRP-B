resourceGroupName="on-premise"
winServerVmName="CSRP-DC"
win11VmName="workstation-1"
scriptDCLocalAdmin="./DCLocalAdmin.ps1"
scriptPasswordReset="./PasswordReset.ps1"
scriptCreateUser="./Create-User.ps1"
scriptAssignLocalAdmin="./Assign-Local-Admin.ps1"

az vm run-command invoke --resource-group $resourceGroupName --name $winServerVmName --command-id RunPowerShellScript --scripts @$scriptCreateUser

# az vm run-command invoke --resource-group $resourceGroupName --name $winServerVmName --command-id RunPowerShellScript --scripts @$scriptDCLocalAdmin

# sleep 60

# az vm run-command invoke --resource-group $resourceGroupName --name $winServerVmName --command-id RunPowerShellScript --scripts @$scriptPasswordReset

# sleep 60

az vm run-command invoke --resource-group $resourceGroupName --name $win11VmName --command-id RunPowerShellScript --scripts @$scriptAssignLocalAdmin

# az vm run-command invoke --resource-group $resourceGroupName --name $winServerVmName --command-id RunPowerShellScript --scripts @$scriptPasswordReset
