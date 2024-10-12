# Define variables
resourceGroupName="WebApp"
vmName="UbuntuVM"

# Create dir1
az vm run-command invoke \
  --command-id RunShellScript \
  --name $vmName \
  --resource-group $resourceGroupName \
  --scripts "mkdir -p /home/azureuser/dir1"

# Create symbolic links for dir2 pointing to dir1
az vm run-command invoke \
  --command-id RunShellScript \
  --name $vmName \
  --resource-group $resourceGroupName \
  --scripts "ln -s /home/azureuser/dir1 /home/azureuser/dir1/dir2"

# Create symbolic links for dir3 pointing to dir1
az vm run-command invoke \
  --command-id RunShellScript \
  --name $vmName \
  --resource-group $resourceGroupName \
  --scripts "ln -s /home/azureuser/dir1 /home/azureuser/dir1/dir3"

