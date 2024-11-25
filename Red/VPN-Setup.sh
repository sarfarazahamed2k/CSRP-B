
#!/bin/bash

if [ -f /data/.env ]; then
    source /data/.env
else
    echo ".env file not found!"
    exit 1
fi

# Variables
resourceGroupName="on-premise"
win11VmName="workstation-1"
scriptSetupVPN="./Setup-VPN.sh"
resourceGroupNameKali="RedTeam"
vmName="KaliVM"

switch_azure_account $S2_ID

originalIp="server_ip"
win11IpAddress=$(az vm list-ip-addresses --resource-group $resourceGroupName --name $win11VmName --query "[].virtualMachine.network.publicIpAddresses[0].ipAddress" -o tsv)

# Replace server_ip with kaliIpAddress
sed -i "s/$originalIp/$win11IpAddress/g" $scriptSetupVPN

switch_azure_account $S1_ID

az vm run-command invoke --resource-group $resourceGroupNameKali --name $vmName --command-id RunShellScript --scripts @$scriptSetupVPN

# Revert kaliIpAddress back to server_ip
sed -i "s/$win11IpAddress/$originalIp/g" $scriptSetupVPN
