#!/bin/bash


az group delete --name entraid --yes --no-wait

az monitor diagnostic-settings delete \
  --name "hrdepartmentstorage-setting" \
  --resource "/subscriptions/8b54ea3d-2a10-44ff-9038-fcb1ecd8df39/resourceGroups/HR-Department/providers/Microsoft.Storage/storageAccounts/hrdepartmentstorage/blobServices/default" 

# az monitor log-analytics workspace delete --resource-group WebApp --workspace-name WebApp-workspace -y

# az monitor log-analytics workspace update \
#   --resource-group WebApp \
#   --workspace-name WebApp-workspace \
#   --retention-time 1

# az vm extension delete \
#   --resource-group WebApp \
#   --vm-name UbuntuVM \
#   --name AzureMonitorLinuxAgent

# VM_RESOURCE_ID=$(az vm show \
#   --resource-group WebApp \
#   --name UbuntuVm \
#   --query "id" \
#   --output tsv)

# az monitor data-collection rule association delete \
#   --name "UbuntuVM-DCR-Association" \
#   --resource "$VM_RESOURCE_ID" -y



# az monitor data-collection rule delete \
#   --name "UbuntuVM-DCR" \
#   --resource-group WebApp --yes


# az monitor data-collection rule association delete \
#   --name "UbuntuVM-DCR-Association" \
#   --resource "/subscriptions/8b54ea3d-2a10-44ff-9038-fcb1ecd8df39/resourceGroups/WebApp/providers/Microsoft.Compute/virtualMachines/UbuntuVM" -y 


# az monitor diagnostic-settings delete \
#   --name "UbuntuVM-diagnostic-setting" \
#   --resource "/subscriptions/8b54ea3d-2a10-44ff-9038-fcb1ecd8df39/resourceGroups/WebApp/providers/Microsoft.Compute/virtualMachines/UbuntuVM"

