#!/bin/bash

# Define variables
resourceGroupName="on-premise"
vmName="kaliVM"
location="Australia Central"
serverPublicIpName="server-ip"
sshPublicKeyName="DebianSSHKey"
adminUsername="azureuser"
adminPassword="Password@123!"
kali11PrivateIp="10.0.1.6"
vnetAddressPrefix="10.0.0.0/16"
subnetAddressPrefix="10.0.1.0/24"
kaliNsgName="kaliVM-nsg"
kaliNicName="kaliNic"
vnetName="on-premise-vnet"
subnetName="on-premise-subnet"
osDiskSku="Standard_LRS"
priority="Spot"
evictionPolicy="Deallocate"

# Accept the legal terms for the Kali Linux image
az vm image terms accept --publisher kali-linux --offer kali --plan kali-2023-3

# Create Public IP Address
az network public-ip create --resource-group $resourceGroupName --name $serverPublicIpName --allocation-method Static

# Create Network Security Group for kaliVM
az network nsg create --resource-group $resourceGroupName --name $kaliNsgName

# Create Network Interface Card (NIC) with the new NSG
az network nic create --resource-group $resourceGroupName --name $kaliNicName --vnet-name $vnetName --subnet $subnetName --network-security-group $kaliNsgName --private-ip-address $kali11PrivateIp --public-ip-address $serverPublicIpName

# Create the VM with the specified credentials
az vm create --resource-group $resourceGroupName \
             --name $vmName \
             --location "$location" \
             --admin-username $adminUsername \
             --admin-password $adminPassword \
             --image kali-linux:kali:kali-2023-3:2023.3.0 \
             --size Standard_B2als_v2 \
             --nics $kaliNicName \
             --storage-sku $osDiskSku \
             --priority $priority \
             --eviction-policy $evictionPolicy \
             --ssh-key-values "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC+IO5szDz3DWcB/FBJOyTUdiy7YNa2E2qy9mcljfDM/s7u7pzl+RC7paHX5aFt6ifho7LvtpDsc9EVsLZBJDSRyaePniPQlBIb1YTAYAJpv9xGFXs8alv57Tx13aPHJ4KoQPBEr6NED53w/2Aqm/RmIDdEvPNLBG7UeMF43RmzhoA6fyajTTjJPDXXfd9vq/Kcf2PoNHL6f0fx98oJFmN1R4FzkcXvii7y43SGU942Eq9IfKPskbV9nCtZyyKJNmWIVwLE5gGMGJNKPylQfzXfzvu2FCdO+n3dvhy/M9xQKQMYLjYu0t7RWkD23LIe4z6ggLVlm1uN3E0WMSTPqtw9 azureuser"

# Open port 22 to allow SSH traffic to the VM
az vm open-port --resource-group $resourceGroupName --name $vmName --port 22

# Retrieve the Public IP address of the VM
publicIp=$(az network public-ip show --resource-group $resourceGroupName --name $serverPublicIpName --query ipAddress --output tsv)

# Add NSG rule to allow all ports (1-65535) for kaliVM's private IP
az network nsg rule create --resource-group $resourceGroupName --nsg-name $kaliNsgName --name AllowAllPortsPrivate \
  --priority 100 --direction Inbound --access Allow --protocol Tcp --source-address-prefixes '*' \
  --source-port-ranges '*' --destination-address-prefixes $kali11PrivateIp --destination-port-ranges 1-65535

# Add NSG rule to allow all ports (1-65535) for kaliVM's public IP
az network nsg rule create --resource-group $resourceGroupName --nsg-name $kaliNsgName --name AllowAllPortsPublic \
  --priority 200 --direction Inbound --access Allow --protocol Tcp --source-address-prefixes '*' \
  --source-port-ranges '*' --destination-address-prefixes $publicIp --destination-port-ranges 1-65535


# Output kali VM details
az vm show --resource-group $resourceGroupName --name $vmName --show-details

# Update the package list on the VM
az vm run-command invoke \
  --command-id RunShellScript \
  --name $vmName \
  --resource-group $resourceGroupName \
  --scripts "sudo apt-get update"

# Install the portspoof package on the VM
az vm run-command invoke \
  --command-id RunShellScript \
  --name $vmName \
  --resource-group $resourceGroupName \
  --scripts "apt install portspoof"

# Redirect TCP traffic on ports 1-21 to port 4444 using iptables
az vm run-command invoke \
  --command-id RunShellScript \
  --name $vmName \
  --resource-group $resourceGroupName \
  --scripts "iptables -t nat -A PREROUTING -p tcp -m tcp --dport 1:21 -j REDIRECT --to-ports 4444"

# Redirect TCP traffic on ports 23-65535 to port 4444 using iptables
az vm run-command invoke \
  --command-id RunShellScript \
  --name $vmName \
  --resource-group $resourceGroupName \
  --scripts "iptables -t nat -A PREROUTING -p tcp -m tcp --dport 23:65535 -j REDIRECT --to-ports 4444"

# Start portspoof with the specified signature file
az vm run-command invoke \
  --command-id RunShellScript \
  --name $vmName \
  --resource-group $resourceGroupName \
  --scripts "portspoof &"
