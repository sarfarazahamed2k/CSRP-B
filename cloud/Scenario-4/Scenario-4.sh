#!/bin/bash

# Define essential variables
domain="sarfarazahamed2018gmail.onmicrosoft.com"
resourceGroupName="WebApp"
vmName="UbuntuVM"
location="Australia Central"
publicIpName="web-app-ip"
adminUsername="azureuser"
adminPassword="Password@123!"
nsgName="${vmName}NSG"

# Get the user ID
userId=$(az ad user show --id "MSSQLSvc@$domain" --query 'id' --output tsv)

# Step 1: Create Resource Group
az group create --name $resourceGroupName --location "$location"

# Step 2: Create a network security group
az network nsg create --resource-group $resourceGroupName --name $nsgName

# Step 3: Create an NSG rule to allow inbound traffic on port 22 (SSH)
az network nsg rule create --resource-group $resourceGroupName \
                           --nsg-name $nsgName \
                           --name Allow-SSH-22 \
                           --priority 200 \
                           --destination-port-ranges 22 \
                           --protocol Tcp \
                           --access Allow \
                           --direction Inbound

# Step 4: Create the VM with the specified credentials
az vm create --resource-group $resourceGroupName \
             --name $vmName \
             --location "$location" \
             --admin-username $adminUsername \
             --admin-password $adminPassword \
             --image Canonical:0001-com-ubuntu-confidential-vm-jammy:22_04-lts-cvm:22.04.202210040 \
             --size Standard_B2als_v2 \
             --public-ip-address $publicIpName \
             --priority "Spot" \
             --eviction-policy "Deallocate" \
             --nsg $nsgName \
             --ssh-key-values "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC+IO5szDz3DWcB/FBJOyTUdiy7YNa2E2qy9mcljfDM/s7u7pzl+RC7paHX5aFt6ifho7LvtpDsc9EVsLZBJDSRyaePniPQlBIb1YTAYAJpv9xGFXs8alv57Tx13aPHJ4KoQPBEr6NED53w/2Aqm/RmIDdEvPNLBG7UeMF43RmzhoA6fyajTTjJPDXXfd9vq/Kcf2PoNHL6f0fx98oJFmN1R4FzkcXvii7y43SGU942Eq9IfKPskbV9nCtZyyKJNmWIVwLE5gGMGJNKPylQfzXfzvu2FCdO+n3dvhy/M9xQKQMYLjYu0t7RWkD23LIe4z6ggLVlm1uN3E0WMSTPqtw9 azureuser"

# Step 5: Assign user as the owner of the VM
roleId=$(az role definition list --name "Owner" --query "[0].id" --output tsv)
vmResourceId=$(az vm show --resource-group $resourceGroupName --name $vmName --query "id" --output tsv)

az role assignment create --assignee $userId --role $roleId --scope $vmResourceId
