#!/bin/bash

# Define variables
adminUserName="JohnStrandAdmin"
adminUserDisplayName="John Strand Admin"
adminUserPassword="P@ssw0rd!"
domain="sarfarazahamed2018gmail.onmicrosoft.com"
globalAdminRoleId="62e90394-69f5-4237-9190-012177145e10"
adminDescription="JohnStrandAdmin@sarfarazahamed2018gmail.onmicrosoft.com: P@ssw0rd!"
readerUserName="CoreyHam"
readerUserDisplayName="Corey Ham"
readerUserPassword="P@ssw0rd!"
globalReaderRoleId="f2ef992c-3afb-46b9-b7cf-a126ee74c451"
resourceGroupName="WebApp"
vmName="UbuntuVM"

# Create the first user and capture the userId
adminUserId=$(az ad user create --display-name "$adminUserDisplayName" \
                                --password "$adminUserPassword" \
                                --user-principal-name "$adminUserName@$domain" \
                                --mail-nickname "$adminUserName" \
                                --query 'id' \
                                --output tsv)


# Assign the first user to the Global Administrator role
az rest --method POST --uri 'https://graph.microsoft.com/beta/roleManagement/directory/roleAssignments' \
                      --body "{'principalId': '$adminUserId', 'roleDefinitionId': '$globalAdminRoleId', 'directoryScopeId': '/'}"


# Create the second user and capture the userId
readerUserId=$(az ad user create --display-name "$readerUserDisplayName" \
                                 --password "$readerUserPassword" \
                                 --user-principal-name "$readerUserName@$domain" \
                                 --mail-nickname "$readerUserName" \
                                 --query 'id' \
                                 --output tsv)

# Assign the second user to the Global Reader role
az rest --method POST --uri 'https://graph.microsoft.com/beta/roleManagement/directory/roleAssignments' \
                      --body "{'principalId': '$readerUserId', 'roleDefinitionId': '$globalReaderRoleId', 'directoryScopeId': '/'}"

# Read contents of creds1.txt into a variable
creds1_content=$(<creds1.txt)

# Read contents of creds2.txt into a variable
creds2_content=$(<creds2.txt)

# Upload creds1.txt to the VM
az vm run-command invoke \
  --command-id RunShellScript \
  --name $vmName \
  --resource-group $resourceGroupName \
  --scripts "echo '$creds1_content' > /home/azureuser/creds1.txt"

# Upload creds2.txt to the VM
az vm run-command invoke \
  --command-id RunShellScript \
  --name $vmName \
  --resource-group $resourceGroupName \
  --scripts "echo '$creds2_content' > /home/azureuser/creds2.txt"