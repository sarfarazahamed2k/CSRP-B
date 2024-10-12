# Set variables
resourceGroupName="on-premise"
location="Australia Central"
winServerVmName="CSRP-DC"
win11VmName="workstation-1"
storageAccountName="openedrconfig"
containerName="files"
localFileOpenEDRAgentPath="./installer_Win8_Win11_x64_fc8751e37740a.exe"
localFileOpenEDRAgentName="installer_Win8_Win11_x64_fc8751e37740a.exe"
destinationOpenEDRAgentPath="C:\\Users\\Public\\installer_Win8_Win11_x64_fc8751e37740a.exe"
scriptSetupOpenEDRAgent="./Setup-OpenEDRAgent.ps1"


# Create a storage account
az storage account create --name $storageAccountName --resource-group $resourceGroupName --location "$location" --sku Standard_LRS

# Get the storage account key
accountKey=$(az storage account keys list --resource-group $resourceGroupName --account-name $storageAccountName --query '[0].value' --output tsv)

# Create a container in the storage account
az storage container create --name $containerName --account-name $storageAccountName --account-key $accountKey

# Upload OpenEDR Installer file to the container
az storage blob upload --account-name $storageAccountName --account-key $accountKey --container-name $containerName --name $localFileOpenEDRAgentName --file "$localFileOpenEDRAgentPath"

# Generate the SAS token
expiry=$(python3 -c "from datetime import datetime, timedelta; print((datetime.utcnow() + timedelta(minutes=30)).strftime('%Y-%m-%dT%H:%MZ'))")
sasToken=$(az storage container generate-sas --account-name $storageAccountName --name $containerName --permissions dlrw --expiry $expiry --account-key $accountKey --output tsv)

# Construct the OpenEDR Installer file URL
fileOpenEDRAgentUrl="https://$storageAccountName.blob.core.windows.net/$containerName/$localFileOpenEDRAgentName?$sasToken"

# Command to download the OpenEDR Installer file on the Velociraptor VM
downloadOpenEDRAgentCommand="powershell -Command \"Invoke-WebRequest -Uri '$fileOpenEDRAgentUrl' -OutFile '$destinationOpenEDRAgentPath'\""

# Invoke download command on the Windows Server DC VM
az vm run-command invoke --resource-group $resourceGroupName --name $winServerVmName --command-id RunPowerShellScript --scripts "$downloadOpenEDRAgentCommand"

# Invoke download command on the Windows 11 VM
az vm run-command invoke --resource-group $resourceGroupName --name $win11VmName --command-id RunPowerShellScript --scripts "$downloadOpenEDRAgentCommand"

# Delete the storage account
az storage account delete --name $storageAccountName --resource-group $resourceGroupName --yes

az vm run-command invoke --resource-group $resourceGroupName --name $winServerVmName --command-id RunPowerShellScript --scripts @$scriptSetupOpenEDRAgent

az vm run-command invoke --resource-group $resourceGroupName --name $win11VmName --command-id RunPowerShellScript --scripts @$scriptSetupOpenEDRAgent