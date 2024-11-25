#!/bin/bash

# Variables for common VNet and NSG
resourceGroupName="RedTeam"
vmName="KaliVM"

location="Australia Central"
vnetName="on-premise-vnet"
kaliNsgName="kaliVM-nsg"            # Shared NSG for both VMs
subnetName="on-premise-subnet"
vnetAddressPrefix="10.0.0.0/16"     # VNet address range
subnetAddressPrefix="10.0.2.0/24"   # Subnet address range

# Variables for Kali VM
vmName="KaliVM"
adminUsername="kaliadmin"
adminPassword="yourSecurePassword!"
kaliNicName="KaliNic"
kaliPublicIpName="kali-ip"
kali11PrivateIp="10.0.2.6"
osDiskSku="Standard_LRS"
priority="Spot"
evictionPolicy="Deallocate"
scriptSetup="./setup.sh"
scriptSetupRDP="./Setup-RDP.sh"

# Variables for Windows 11 VM
# windowsVmName="Win11VM"
# windowsAdminUsername="winadmin"
# windowsAdminPassword="anotherSecurePassword!"
# windowsNicName="Win11Nic"
# windowsPublicIpName="win11-ip"
# windowsPrivateIp="10.0.2.7"

# Accept the legal terms for the Kali Linux image
az vm image terms accept --publisher kali-linux --offer kali --plan kali-2024-3

# Create resource group
az group create --name $resourceGroupName --location "$location"

# Create VNet and Subnet
az network vnet create --resource-group $resourceGroupName \
                       --name $vnetName \
                       --address-prefix $vnetAddressPrefix \
                       --subnet-name $subnetName \
                       --subnet-prefix $subnetAddressPrefix

# Create a shared Network Security Group for both VMs
az network nsg create --resource-group $resourceGroupName --name $kaliNsgName

az network nsg rule create --resource-group $resourceGroupName \
                           --nsg-name $kaliNsgName \
                           --name Allow-FrontDoor-HTTP \
                           --priority 100 \
                           --source-address-prefixes "AzureFrontDoor.Backend" \
                           --destination-port-ranges 80 \
                           --direction Inbound \
                           --access Allow \
                           --protocol Tcp \
                           --description "Allow inbound HTTP traffic on port 80 from Azure Front Door backend."

# Create Public IP Address for Kali VM
az network public-ip create --resource-group $resourceGroupName --name $kaliPublicIpName --allocation-method Static

# Create Network Interface Card (NIC) for Kali VM with the shared NSG
az network nic create --resource-group $resourceGroupName --name $kaliNicName \
                      --vnet-name $vnetName --subnet $subnetName \
                      --network-security-group $kaliNsgName --private-ip-address $kali11PrivateIp \
                      --public-ip-address $kaliPublicIpName

# Create the Kali VM with the specified credentials
az vm create --resource-group $resourceGroupName \
             --name $vmName \
             --location "$location" \
             --admin-username $adminUsername \
             --admin-password $adminPassword \
             --image kali-linux:kali:kali-2024-3:2024.3.0 \
             --size Standard_D2a_v4 \
             --nics $kaliNicName \
             --storage-sku $osDiskSku \
             --priority $priority \
             --eviction-policy $evictionPolicy \
             --ssh-key-values "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC+IO5szDz3DWcB/FBJOyTUdiy7YNa2E2qy9mcljfDM/s7u7pzl+RC7paHX5aFt6ifho7LvtpDsc9EVsLZBJDSRyaePniPQlBIb1YTAYAJpv9xGFXs8alv57Tx13aPHJ4KoQPBEr6NED53w/2Aqm/RmIDdEvPNLBG7UeMF43RmzhoA6fyajTTjJPDXXfd9vq/Kcf2PoNHL6f0fx98oJFmN1R4FzkcXvii7y43SGU942Eq9IfKPskbV9nCtZyyKJNmWIVwLE5gGMGJNKPylQfzXfzvu2FCdO+n3dvhy/M9xQKQMYLjYu0t7RWkD23LIe4z6ggLVlm1uN3E0WMSTPqtw9 azureuser"

# Open necessary ports for Kali VM
az vm open-port --resource-group $resourceGroupName --name $vmName --port 22 --priority 1000
az vm open-port --resource-group $resourceGroupName --name $vmName --port 3389 --priority 1001
az vm open-port --resource-group $resourceGroupName --name $vmName --port 8080 --priority 1002
az vm open-port --resource-group $resourceGroupName --name $vmName --port 8081 --priority 1003


az vm run-command invoke --resource-group $resourceGroupName --name $vmName --command-id RunShellScript --scripts @$scriptSetup

az vm run-command invoke --resource-group $resourceGroupName --name $vmName --command-id RunShellScript --scripts @$scriptSetupRDP


# # Create Public IP Address for Windows 11 VM
# az network public-ip create --resource-group $resourceGroupName --name $windowsPublicIpName --allocation-method Static

# # Create Network Interface Card (NIC) for Windows 11 VM with the shared NSG
# az network nic create --resource-group $resourceGroupName --name $windowsNicName \
#                       --vnet-name $vnetName --subnet $subnetName \
#                       --network-security-group $kaliNsgName --private-ip-address $windowsPrivateIp \
#                       --public-ip-address $windowsPublicIpName

# # Create the Windows 11 VM
# az vm create --resource-group $resourceGroupName \
#              --name $windowsVmName \
#              --location "$location" \
#              --admin-username $windowsAdminUsername \
#              --admin-password $windowsAdminPassword \
#              --image MicrosoftWindowsDesktop:Windows-11:win11-23h2-pro:latest \
#              --size Standard_D2as_v4 \
#              --nics $windowsNicName \
#              --storage-sku $osDiskSku \
#              --priority $priority \
#              --eviction-policy $evictionPolicy
             

# # Open necessary ports for Windows 11 VM
# az vm open-port --resource-group $resourceGroupName --name $windowsVmName --port 3389 --priority 2000
