resourceGroupName="on-premise"
winServerVmName="CSRP-DC"
win11VmName="workstation-1"
scriptDisableRTM="./Disable-RTM.ps1"

az vm run-command invoke --resource-group $resourceGroupName --name $winServerVmName --command-id RunPowerShellScript --scripts @$scriptDisableRTM

az vm run-command invoke --resource-group $resourceGroupName --name $win11VmName --command-id RunPowerShellScript --scripts @$scriptDisableRTM
