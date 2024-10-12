# Set variables
resourceGroupName="on-premise"
location="Australia Central"
vnetName="on-premise-vnet"
subnetName="on-premise-subnet"
nsgName="on-premise-nsg"
winServerVmName="CSRP-DC"
win11VmName="workstation-1"
velociraptorPublicIpName="velociraptor-vm-ip"
velociraptorVmName="velociraptorVM"
velociraptorNicName="velociraptor-vm-nic"
velociraptorPrivateIp="10.0.1.11"
vnetAddressPrefix="10.0.0.0/16"
subnetAddressPrefix="10.0.1.0/24"
scriptSetupRDP="./Setup-RDP.sh"
scriptSetupVelociraptor="./Setup-Velociraptor.sh"
scriptSetupVelociraptorAgent="./Setup-VelociraptorAgent.ps1"
storageAccountName="velociraptorconfig"
containerName="files"
localFileClientConfigPath="./client.config.yaml"
localFileClientConfigName="client.config.yaml"
destinationClientConfigPath="C:\\Users\\Public\\client.config.yaml"
localFileServerDebPath="./velociraptor_server_0.72.4_amd64.deb"
localFileServerDebName="velociraptor_server_0.72.4_amd64.deb"
destinationServerDebPath="/home/azureuser/velociraptor_server_0.72.4_amd64.deb"
priority="Spot"
evictionPolicy="Deallocate"
osDiskSku="Standard_LRS"

# Create a Public IP for the velociraptor VM
az network public-ip create --resource-group $resourceGroupName --name $velociraptorPublicIpName

# Create a Network Interface (NIC) for the velociraptor VM 
az network nic create --resource-group $resourceGroupName --name $velociraptorNicName --vnet-name $vnetName --subnet $subnetName --private-ip-address $velociraptorPrivateIp --network-security-group $nsgName --public-ip-address $velociraptorPublicIpName

# Create the Ubuntu VM
az vm create --resource-group $resourceGroupName --name $velociraptorVmName --location "$location" --nics $velociraptorNicName --image Canonical:0001-com-ubuntu-server-jammy:22_04-lts-gen2:latest --admin-username "azureuser" --admin-password "cJkIgLf610r7G3kK6nyA" --size Standard_B2als_v2 --priority $priority --eviction-policy $evictionPolicy --storage-sku $osDiskSku #--ssh-key-values "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC+IO5szDz3DWcB/FBJOyTUdiy7YNa2E2qy9mcljfDM/s7u7pzl+RC7paHX5aFt6ifho7LvtpDsc9EVsLZBJDSRyaePniPQlBIb1YTAYAJpv9xGFXs8alv57Tx13aPHJ4KoQPBEr6NED53w/2Aqm/RmIDdEvPNLBG7UeMF43RmzhoA6fyajTTjJPDXXfd9vq/Kcf2PoNHL6f0fx98oJFmN1R4FzkcXvii7y43SGU942Eq9IfKPskbV9nCtZyyKJNmWIVwLE5gGMGJNKPylQfzXfzvu2FCdO+n3dvhy/M9xQKQMYLjYu0t7RWkD23LIe4z6ggLVlm1uN3E0WMSTPqtw9 azureuser"

# # Open port 22 for SSH on the NSG (for remote access)
# az network nsg rule create --resource-group $resourceGroupName --nsg-name $nsgName --name "allow-ssh" --priority 1004 --access Allow --direction Inbound --protocol Tcp --source-address-prefix "*" --source-port-range "*" --destination-address-prefix $velociraptorPrivateIp --destination-port-range 22

# # Open port 3389 for RDP on the NSG (for remote access)
# az network nsg rule create --resource-group $resourceGroupName --nsg-name $nsgName --name "allow-rdp" --priority 1005 --access Allow --direction Inbound --protocol Tcp --source-address-prefix "*" --source-port-range "*" --destination-address-prefix $velociraptorPrivateIp --destination-port-range 3389

# Invoke script to configure RDP
az vm run-command invoke --resource-group $resourceGroupName --name $velociraptorVmName --command-id RunShellScript --scripts @$scriptSetupRDP



# Create a storage account
az storage account create --name $storageAccountName --resource-group $resourceGroupName --location "$location" --sku Standard_LRS

# Get the storage account key
accountKey=$(az storage account keys list --resource-group $resourceGroupName --account-name $storageAccountName --query '[0].value' --output tsv)

# Create a container in the storage account
az storage container create --name $containerName --account-name $storageAccountName --account-key $accountKey

# Upload server.config.yaml file to the container
az storage blob upload --account-name $storageAccountName --account-key $accountKey --container-name $containerName --name $localFileServerDebName --file "$localFileServerDebPath"

# Upload client.config.yaml file to the container
az storage blob upload --account-name $storageAccountName --account-key $accountKey --container-name $containerName --name $localFileClientConfigName --file "$localFileClientConfigPath"

# Generate the SAS token
expiry=$(python3 -c "from datetime import datetime, timedelta; print((datetime.utcnow() + timedelta(minutes=30)).strftime('%Y-%m-%dT%H:%MZ'))")
sasToken=$(az storage container generate-sas --account-name $storageAccountName --name $containerName --permissions dlrw --expiry $expiry --account-key $accountKey --output tsv)

# Construct the server.config.yaml file URL
fileServerDebUrl="https://$storageAccountName.blob.core.windows.net/$containerName/$localFileServerDebName?$sasToken"

# Construct the client.config.yaml file URL
fileClientConfigUrl="https://$storageAccountName.blob.core.windows.net/$containerName/$localFileClientConfigName?$sasToken"

# Command to download the server.config.yaml file on the Velociraptor VM
downloadServerDebCommand="curl -o '$destinationServerDebPath' '$fileServerDebUrl'"

# Command to download the client.config.yaml file on the workstation-1 and CSRP-DC VMs
downloadClientConfigCommand="powershell -Command \"Invoke-WebRequest -Uri '$fileClientConfigUrl' -OutFile '$destinationClientConfigPath'\""

# Invoke download command on the Velociraptor VM
az vm run-command invoke --resource-group $resourceGroupName --name $velociraptorVmName --command-id RunShellScript --scripts "$downloadServerDebCommand"

# Invoke download command on the Windows Server DC VM
az vm run-command invoke --resource-group $resourceGroupName --name $winServerVmName --command-id RunPowerShellScript --scripts "$downloadClientConfigCommand"

# Invoke download command on the Windows 11 VM
az vm run-command invoke --resource-group $resourceGroupName --name $win11VmName --command-id RunPowerShellScript --scripts "$downloadClientConfigCommand"

# Delete the storage account
az storage account delete --name $storageAccountName --resource-group $resourceGroupName --yes

az vm run-command invoke --resource-group $resourceGroupName --name $velociraptorVmName --command-id RunShellScript --scripts @$scriptSetupVelociraptor

az vm run-command invoke --resource-group $resourceGroupName --name $winServerVmName --command-id RunPowerShellScript --scripts @$scriptSetupVelociraptorAgent

az vm run-command invoke --resource-group $resourceGroupName --name $win11VmName --command-id RunPowerShellScript --scripts @$scriptSetupVelociraptorAgent