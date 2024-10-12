#!/bin/bash

# Define variables
resourceGroupName="on-premise"
location="Australia Central"
vnetName="on-premise-vnet"
subnetName="on-premise-subnet"
nsgName="on-premise-nsg"
winServerPublicIpName="win-server-ip"
win11PublicIpName="win-11-ip"
winServerNicName="win-server-nic"
win11NicName="win-11-nic"
winServerVmName="CSRP-DC"
win11VmName="workstation-1"
vnetAddressPrefix="10.0.0.0/16"
subnetAddressPrefix="10.0.1.0/24"
winServerPrivateIp="10.0.1.4"
win11PrivateIp="10.0.1.5"
vmSize="Standard_B2als_v2"
winServerImage="MicrosoftWindowsServer:WindowsServer:2022-Datacenter:latest"
win11Image="MicrosoftWindowsDesktop:Windows-11:win11-23h2-pro:latest"
priority="Spot"
evictionPolicy="Deallocate"
adminUsername="user_administrator"
adminPassword="Password@123!"
osDiskSku="Standard_LRS" # or StandardSSD_LRS

# Create Resource Group
az group create --name $resourceGroupName --location "$location"

# Create Virtual Network and Subnet
az network vnet create --name $vnetName --resource-group $resourceGroupName --location "$location" --address-prefix $vnetAddressPrefix --subnet-name $subnetName --subnet-prefix $subnetAddressPrefix

# Create Network Security Group and Security Rule
az network nsg create --resource-group $resourceGroupName --name $nsgName --location "$location"
az network nsg rule create --resource-group $resourceGroupName --nsg-name $nsgName --name "allow-rdp" --priority 1001 --access Allow --direction Inbound --protocol Tcp --source-address-prefix "*" --source-port-range "*" --destination-address-prefix "*" --destination-port-range 3389
az network nsg rule create --resource-group $resourceGroupName --nsg-name $nsgName --name "allow-ssh" --priority 1002 --access Allow --direction Inbound --protocol Tcp --source-address-prefix "*" --source-port-range "*" --destination-address-prefix "*" --destination-port-range 22


# Create Public IP Addresses
az network public-ip create --name $winServerPublicIpName --resource-group $resourceGroupName --location "$location" --allocation-method Static
az network public-ip create --name $win11PublicIpName --resource-group $resourceGroupName --location "$location" --allocation-method Static

# Create Network Interfaces for the VMs with Static Private IP Address
az network nic create --resource-group $resourceGroupName --name $winServerNicName --vnet-name $vnetName --subnet $subnetName --network-security-group $nsgName --public-ip-address $winServerPublicIpName --private-ip-address $winServerPrivateIp
az network nic create --resource-group $resourceGroupName --name $win11NicName --vnet-name $vnetName --subnet $subnetName --network-security-group $nsgName --public-ip-address $win11PublicIpName --private-ip-address $win11PrivateIp

# Create the Domain Controller VM
az vm create --resource-group $resourceGroupName --name $winServerVmName --location "$location" --nics $winServerNicName --image $winServerImage --admin-username $adminUsername --admin-password $adminPassword --size $vmSize --priority $priority --eviction-policy $evictionPolicy --storage-sku $osDiskSku

# Create the Windows 11 VM
az vm create --resource-group $resourceGroupName --name $win11VmName --location "$location" --nics $win11NicName --image $win11Image --admin-username $adminUsername --admin-password $adminPassword --size $vmSize --priority $priority --eviction-policy $evictionPolicy --storage-sku $osDiskSku

# Output VM details
az vm show --resource-group $resourceGroupName --name $winServerVmName --show-details
az vm show --resource-group $resourceGroupName --name $win11VmName --show-details
