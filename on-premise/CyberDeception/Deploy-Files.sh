resourceGroupName="on-premise"
winServerVmName="CSRP-DC"
win11VmName="workstation-1"
storageAccountName="cyberdeception"
containerName="files"
location="Australia Central"
localFileTopClientsContractsPath="./Top_Clients_Contracts.xlsx"
localFileTopClientsContractsName="Top_Clients_Contracts.xlsx"
destinationTopClientsContractsPath="C:\\Users\\Public\\Documents\\Top_Clients_Contracts.xlsx"
localFileHigProfileLawsuitDetailsPath="./High_Profile_Lawsuit_Details.xlsx"
localFileHigProfileLawsuitDetailsName="High_Profile_Lawsuit_Details.xlsx"
destinationHigProfileLawsuitDetailsPath="C:\\Users\\Public\\Documents\\High_Profile_Lawsuit_Details.xlsx"

az provider register --namespace Microsoft.Storage

# Create a storage account
az storage account create --name $storageAccountName --resource-group $resourceGroupName --location "$location" --sku Standard_LRS

# Get the storage account key
accountKey=$(az storage account keys list --resource-group $resourceGroupName --account-name $storageAccountName --query '[0].value' --output tsv)

# Create a container in the storage account
az storage container create --name $containerName --account-name $storageAccountName --account-key $accountKey

# Upload Top_Clients_Contracts.xlsx file to the container
az storage blob upload --account-name $storageAccountName --account-key $accountKey --container-name $containerName --name $localFileTopClientsContractsName --file "$localFileTopClientsContractsPath"

# Upload High_Profile_Lawsuit_Details.xlsx file to the container
az storage blob upload --account-name $storageAccountName --account-key $accountKey --container-name $containerName --name $localFileHigProfileLawsuitDetailsName --file "$localFileHigProfileLawsuitDetailsPath"

# Generate the SAS token
expiry=$(python3 -c "from datetime import datetime, timedelta; print((datetime.utcnow() + timedelta(minutes=30)).strftime('%Y-%m-%dT%H:%MZ'))")
sasToken=$(az storage container generate-sas --account-name $storageAccountName --name $containerName --permissions dlrw --expiry $expiry --account-key $accountKey --output tsv)


# Construct the TopClientsContracts file URL
fileTopClientsContractsUrl="https://$storageAccountName.blob.core.windows.net/$containerName/$localFileTopClientsContractsName?$sasToken"

# Construct the HigProfileLawsuitDetails file URL
fileHigProfileLawsuitDetailsUrl="https://$storageAccountName.blob.core.windows.net/$containerName/$localFileHigProfileLawsuitDetailsName?$sasToken"


# Command to download the TopClientsContracts file on the Windows VM
downloadTopClientsContractsCommand="powershell -Command \"Invoke-WebRequest -Uri '$fileTopClientsContractsUrl' -OutFile '$destinationTopClientsContractsPath'\""

# Command to download the HigProfileLawsuitDetails file on the Windows VM
downloadHigProfileLawsuitDetailsCommand="powershell -Command \"Invoke-WebRequest -Uri '$fileHigProfileLawsuitDetailsUrl' -OutFile '$destinationHigProfileLawsuitDetailsPath'\""


# Invoke download command on the Windows Server DC VM
az vm run-command invoke --resource-group $resourceGroupName --name $winServerVmName --command-id RunPowerShellScript --scripts "$downloadTopClientsContractsCommand"

# Invoke download command on the Windows 11 VM
az vm run-command invoke --resource-group $resourceGroupName --name $win11VmName --command-id RunPowerShellScript --scripts "$downloadHigProfileLawsuitDetailsCommand"

# Delete the storage account
az storage account delete --name $storageAccountName --resource-group $resourceGroupName --yes