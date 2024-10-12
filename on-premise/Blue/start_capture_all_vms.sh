#!/bin/bash

# Variables
resourceGroupName="on-premise"
CAPTURE_NAME_PREFIX="myPacketCapture"
storageAccountName="csrppacketcapture" 
STORAGE_CONTAINER="pcapfiles"
location="Australia Central"

# Create a storage account
az storage account create --name $storageAccountName --resource-group $resourceGroupName --location "$location" --sku Standard_LRS

# Get the storage account key
accountKey=$(az storage account keys list --account-name $storageAccountName --resource-group $resourceGroupName --query "[0].value" -o tsv)

# Create a storage container
az storage container create --name $STORAGE_CONTAINER --account-name $storageAccountName --account-key $accountKey

# Get all VM names and their operating system type in the specified resource group
VM_LIST=$(az vm list -g $resourceGroupName --query "[].{name:name,os:storageProfile.osDisk.osType}" -o tsv)

# Install Network Watcher extension on each Windows VM
while IFS=$'\t' read -r VM_NAME OS_TYPE
do
    if [[ "$OS_TYPE" == "Windows" ]]; then
        echo "Installing Network Watcher extension on Windows VM: $VM_NAME"
        az vm extension set \
            --resource-group $resourceGroupName \
            --vm-name $VM_NAME \
            --name NetworkWatcherAgentWindows \
            --publisher Microsoft.Azure.NetworkWatcher \
            --version 1.4 \
            --settings '{"enableDiagnostics": true}'
        echo "Network Watcher extension installed for VM: $VM_NAME"
    else
        echo "Skipping VM: $VM_NAME as it is not a Windows VM."
    fi
done <<< "$VM_LIST"

# Loop through each Windows VM and start a packet capture
while IFS=$'\t' read -r VM_NAME OS_TYPE
do
    if [[ "$OS_TYPE" == "Windows" ]]; then
        CAPTURE_NAME="${CAPTURE_NAME_PREFIX}-${VM_NAME}"
        echo "Starting packet capture for Windows VM: $VM_NAME with capture name: $CAPTURE_NAME"

        # Specify the storage URI with account key
        STORAGE_URI="https://${storageAccountName}.blob.core.windows.net/${STORAGE_CONTAINER}?${accountKey}"

        az network watcher packet-capture create \
            --resource-group $resourceGroupName \
            --vm $VM_NAME \
            --name $CAPTURE_NAME \
            --storage-account $storageAccountName \
            --storage-path $STORAGE_URI \
            --filters '[{"protocol": "TCP"}, {"protocol": "UDP"}]'

        echo "Packet capture started for VM: $VM_NAME"
    else
        echo "Skipping packet capture for VM: $VM_NAME as it is not a Windows VM."
    fi
done <<< "$VM_LIST"
