# Essential Variables
domain="sarfarazahamed2018gmail.onmicrosoft.com"
resourceGroupName="HR-Department"
location="Australia Central"
storageAccountName="hrdepartmentstorage"
containerName="employee-container"
blobName="Employee-Details.xlsx"
localFilePath="./Employee-Details.xlsx"

# Retrieve User ID
userId=$(az ad user show --id "JohnStrand@$domain" --query 'id' --output tsv)

# Step 1: Create a Resource Group
az group create --name $resourceGroupName --location "$location"

# Step 2: Create a Storage Account
az storage account create --name $storageAccountName \
  --resource-group $resourceGroupName \
  --location "$location" \
  --sku Standard_LRS

# Step 3: Retrieve the Storage Account Key
accountKey=$(az storage account keys list \
  --resource-group $resourceGroupName \
  --account-name $storageAccountName \
  --query '[0].value' \
  --output tsv)

# Step 4: Create a Blob Container
az storage container create \
  --name $containerName \
  --account-name $storageAccountName \
  --account-key $accountKey

# Step 5: Upload the Excel file to the Blob Container
az storage blob upload \
  --account-name $storageAccountName \
  --account-key $accountKey \
  --container-name $containerName \
  --name $blobName \
  --file $localFilePath

# Step 6: Retrieve Storage Account Scope (Resource ID)
scope=$(az storage account show \
  --name $storageAccountName \
  --resource-group $resourceGroupName \
  --query 'id' \
  --output tsv)

# Step 7: Assign Storage Blob Data Owner Role to the User
az role assignment create \
  --assignee $userId \
  --role "Storage Blob Data Owner" \
  --scope $scope

# Step 8: Assign Storage Blob Data Reader Role to the User
az role assignment create \
  --assignee $userId \
  --role "Storage Blob Data Reader" \
  --scope $scope
