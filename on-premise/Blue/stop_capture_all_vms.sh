#!/bin/bash

# Variables
resourceGroupName="on-premise"
CAPTURE_NAME_PREFIX="myPacketCapture"
storageAccountName="csrppacketcapture"
STORAGE_CONTAINER="pcapfiles"
location="Australia Central"  # This is the Network Watcher's location
downloadFolder="packetcaptures"

# Create a directory to store the packet captures
mkdir -p $downloadFolder

# Get the storage account key
accountKey=$(az storage account keys list --account-name $storageAccountName --resource-group $resourceGroupName --query "[0].value" -o tsv)

# Stop packet capture on each Windows VM
VM_LIST=$(az vm list -g $resourceGroupName --query "[].{name:name,os:storageProfile.osDisk.osType}" -o tsv)

while IFS=$'\t' read -r VM_NAME OS_TYPE
do
    if [[ "$OS_TYPE" == "Windows" ]]; then
        CAPTURE_NAME="${CAPTURE_NAME_PREFIX}-${VM_NAME}"
        echo "Stopping packet capture for VM: $VM_NAME with capture name: $CAPTURE_NAME"

        # Stop the packet capture for the current VM
        az network watcher packet-capture stop \
            --location "$location" \
            --name "$CAPTURE_NAME"

        echo "Packet capture stopped for VM: $VM_NAME"
    else
        echo "Skipping VM: $VM_NAME as it is not a Windows VM."
    fi
done <<< "$VM_LIST"

# Download all packet capture files from the storage container
echo "Downloading all .pcap files from the storage container: $STORAGE_CONTAINER"
az storage blob download-batch \
    --account-name $storageAccountName \
    --account-key $accountKey \
    --destination $downloadFolder \
    --source $STORAGE_CONTAINER
echo "All packet capture files downloaded to folder: $downloadFolder"

while IFS=$'\t' read -r VM_NAME OS_TYPE
do
    if [[ "$OS_TYPE" == "Windows" ]]; then
        CAPTURE_NAME="${CAPTURE_NAME_PREFIX}-${VM_NAME}"
        echo "Stopping packet capture for VM: $VM_NAME with capture name: $CAPTURE_NAME"

        # Delete the packet capture for the current VM
        az network watcher packet-capture delete \
            --location "$location" \
            --name "$CAPTURE_NAME"

        echo "Packet capture stopped for VM: $VM_NAME"
    else
        echo "Skipping VM: $VM_NAME as it is not a Windows VM."
    fi
done <<< "$VM_LIST"

# Delete the storage account
echo "Deleting storage account: $storageAccountName"
az storage account delete --name $storageAccountName --resource-group $resourceGroupName --yes

echo "Storage account deleted: $storageAccountName"
