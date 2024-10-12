# Set variables
resourceGroupName="on-premise"
location="Australia Central"
vnetName="on-premise-vnet"
subnetName="on-premise-subnet"
nsgName="on-premise-nsg"
winServerVmName="CSRP-DC"
win11VmName="workstation-1"
wazuhVmName="WazuhVM"
wazuhNicName="wazuh-vm-nic"
wazuhPrivateIp="10.0.1.10"
vnetAddressPrefix="10.0.0.0/16"
subnetAddressPrefix="10.0.1.0/24"
scriptSetupRDP="./Setup-RDP.sh"
scriptSetupWazuh="./Setup-Wazuh.sh"
scriptSetupWazuhAgent="./Setup-WazuhAgent.ps1"
priority="Spot"
evictionPolicy="Deallocate"
osDiskSku="Standard_LRS"


# Create a Network Interface (NIC) with a static private IP for the Wazuh VM (no public IP)
az network nic create --resource-group $resourceGroupName --name $wazuhNicName --vnet-name $vnetName --subnet $subnetName --private-ip-address $wazuhPrivateIp --network-security-group $nsgName

# Create the Ubuntu VM (no public IP)
az vm create --resource-group $resourceGroupName --name $wazuhVmName --location "$location" --nics $wazuhNicName --image Canonical:0001-com-ubuntu-server-jammy:22_04-lts-gen2:latest --admin-username "azureuser" --admin-password "Password@123!" --size Standard_B2als_v2 --priority $priority --eviction-policy $evictionPolicy --storage-sku $osDiskSku #--ssh-key-values "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC+IO5szDz3DWcB/FBJOyTUdiy7YNa2E2qy9mcljfDM/s7u7pzl+RC7paHX5aFt6ifho7LvtpDsc9EVsLZBJDSRyaePniPQlBIb1YTAYAJpv9xGFXs8alv57Tx13aPHJ4KoQPBEr6NED53w/2Aqm/RmIDdEvPNLBG7UeMF43RmzhoA6fyajTTjJPDXXfd9vq/Kcf2PoNHL6f0fx98oJFmN1R4FzkcXvii7y43SGU942Eq9IfKPskbV9nCtZyyKJNmWIVwLE5gGMGJNKPylQfzXfzvu2FCdO+n3dvhy/M9xQKQMYLjYu0t7RWkD23LIe4z6ggLVlm1uN3E0WMSTPqtw9 azureuser"

# # Open port 22 for SSH on the NSG (for remote access)
# az network nsg rule create --resource-group $resourceGroupName --nsg-name $nsgName --name "allow-ssh" --priority 1002 --access Allow --direction Inbound --protocol Tcp --source-address-prefix "*" --source-port-range "*" --destination-address-prefix $wazuhPrivateIp --destination-port-range 22

# # Open port 3389 for RDP on the NSG (for remote access)
# az network nsg rule create --resource-group $resourceGroupName --nsg-name $nsgName --name "allow-rdp" --priority 1003 --access Allow --direction Inbound --protocol Tcp --source-address-prefix "*" --source-port-range "*" --destination-address-prefix $wazuhPrivateIp --destination-port-range 3389

# Invoke script to configure RDP
az vm run-command invoke --resource-group $resourceGroupName --name $wazuhVmName --command-id RunShellScript --scripts @$scriptSetupRDP

az vm run-command invoke --resource-group $resourceGroupName --name $wazuhVmName --command-id RunShellScript --scripts @$scriptSetupWazuh

az vm run-command invoke --resource-group $resourceGroupName --name $winServerVmName --command-id RunPowerShellScript --scripts @$scriptSetupWazuhAgent

az vm run-command invoke --resource-group $resourceGroupName --name $win11VmName --command-id RunPowerShellScript --scripts @$scriptSetupWazuhAgent
