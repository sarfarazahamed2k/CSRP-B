resourceGroupName="WebApp"
vmName="UbuntuVM"
storageAccountName="cyberdeception1"
containerName="files"
location="Australia Central"
localFileCustomerAccountsDetailsPath="./Customer_Accounts_Details.xlsx"
localFileCustomerAccountsDetailsName="Customer_Accounts_Details.xlsx"
destinationCustomerAccountsDetailsPath="/home/azureuser/Customer_Accounts_Details.xlsx"
localFileExecutiveCompensationPath="./Executive_Compensation_2024.xlsx"
localFileExecutiveCompensationName="Executive_Compensation_2024.xlsx"
resourceGroupNam1="HR-Department"
storageAccountName1="hrdepartmentstorage"
containerName1="employee-container"

# Upload Executive_Compensation_2024.xlsx file to the container
az storage blob upload --account-name $storageAccountName1 --container-name $containerName1 --file $localFileExecutiveCompensationPath --name $localFileExecutiveCompensationName

# Create a storage account
az storage account create --name $storageAccountName --resource-group $resourceGroupName --location "$location" --sku Standard_LRS

# Get the storage account key
accountKey=$(az storage account keys list --resource-group $resourceGroupName --account-name $storageAccountName --query '[0].value' --output tsv)

# Create a container in the storage account
az storage container create --name $containerName --account-name $storageAccountName --account-key $accountKey

# Upload Customer_Accounts_Details.xlsx file to the container
az storage blob upload --account-name $storageAccountName --account-key $accountKey --container-name $containerName --name $localFileCustomerAccountsDetailsName --file "$localFileCustomerAccountsDetailsPath"

# Generate the SAS token
expiry=$(python3 -c "from datetime import datetime, timedelta; print((datetime.utcnow() + timedelta(minutes=30)).strftime('%Y-%m-%dT%H:%MZ'))")
sasToken=$(az storage container generate-sas --account-name $storageAccountName --name $containerName --permissions dlrw --expiry $expiry --account-key $accountKey --output tsv)

# Construct the CustomerAccountsDetails file URL
fileCustomerAccountsDetailsUrl="https://$storageAccountName.blob.core.windows.net/$containerName/$localFileCustomerAccountsDetailsName?$sasToken"

# Command to download the CustomerAccountsDetails file on the Ubuntu VM
downloadCustomerAccountsDetailsCommand="wget -O '$destinationCustomerAccountsDetailsPath' '$fileCustomerAccountsDetailsUrl'"

# Invoke download command on the Ubuntu VM
az vm run-command invoke --resource-group $resourceGroupName --name $vmName --command-id RunShellScript --scripts "$downloadCustomerAccountsDetailsCommand"

# Delete the storage account
az storage account delete --name $storageAccountName --resource-group $resourceGroupName --yes

