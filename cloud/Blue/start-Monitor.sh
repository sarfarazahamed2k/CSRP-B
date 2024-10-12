#!/bin/bash

yum install -y jq

az provider register --namespace Microsoft.OperationalInsights

# az config set extension.dynamic_install_allow_preview=true

az extension add --name monitor-control-service --allow-preview true


az group create --name entraid --location "Australia Central"
az monitor log-analytics workspace create -g entraid -n entraid-workspace


az monitor log-analytics workspace create -g HR-Department -n HR-Department-workspace
az monitor log-analytics workspace create -g WebApp -n WebApp-workspace
az monitor log-analytics workspace create -g myRG1 -n myRG1-workspace


# Function to get diagnostic settings for a given resource URI
get_diagnostic_settings() {
    local resourceUri=$1

    if [[ -z "$resourceUri" ]]; then
        echo "Error: No resourceUri provided."
        return 1
    fi

    # Make the API request using az rest
    echo "Getting diagnostic settings for: $resourceUri"
    az rest --method GET \
        --uri "https://management.azure.com/${resourceUri}/providers/Microsoft.Insights/diagnosticSettingsCategories?api-version=2021-05-01-preview" \
        --output json | jq -r '.value[].name'
    echo ""
}

# get_diagnostic_settings https://hrdepartmentstorage.blob.core.windows.net/employee-container "/tenants/78b7869e-3bc0-4ad1-87cf-91b692c23ff8"

# Function to list all resource URIs in the current subscription and run get_diagnostic_settings on each
list_and_get_diagnostic_settings() {
    # Get all resource URIs in the subscription
    resourceUris=$(az resource list --query "[].id" -o tsv)

    # Loop through each resource URI and get diagnostic settings
    for resourceUri in $resourceUris; do
        echo "$resourceUri"
        get_diagnostic_settings "$resourceUri"
    done
}

# List all resources and get their diagnostic settings
# list_and_get_diagnostic_settings


# 1. hrdepartmentstorage blob
# Get storage account resource ID
STORAGE_RESOURCE_ID=$(az storage account show \
  --name hrdepartmentstorage \
  --resource-group HR-Department \
  --query "id" \
  --output tsv)

# Get Log Analytics workspace resource ID
WORKSPACE_ID=$(az monitor log-analytics workspace show \
  --resource-group HR-Department \
  --workspace-name HR-Department-workspace \
  --query "id" \
  --output tsv)

# Use the variables to create diagnostic settings
az monitor diagnostic-settings create \
  --resource "$STORAGE_RESOURCE_ID/blobServices/default" \
  --name "hrdepartmentstorage-setting" \
  --workspace "$WORKSPACE_ID" \
  --logs '[{"category": "StorageRead", "enabled": true},{"category": "StorageWrite", "enabled": true},{"category": "StorageDelete", "enabled": true}]' \
  --metrics '[{"category": "Transaction", "enabled": true, "retentionPolicy": {"enabled": false, "days": 0}}]'


# az storage blob url --account-name hrdepartmentstorage --container-name employee-container --name " "

# accountKey=$(az storage account keys list --resource-group HR-Department --account-name hrdepartmentstorage --query '[0].value' --output tsv)
# expiry=$(python3 -c "from datetime import datetime, timedelta; print((datetime.utcnow() + timedelta(minutes=30)).strftime('%Y-%m-%dT%H:%MZ'))")
# sasToken=$(az storage container generate-sas --account-name hrdepartmentstorage --name employee-container --permissions dlrw --expiry $expiry --account-key $accountKey --output tsv)
# az storage container show --name employee-container --account-name hrdepartmentstorage --query "id" --sas-token "$sasToken" --output tsv 

# az storage account show -n hrdepartmentstorage --query networkRuleSet

# hrdepartmentstoragecontainerUri=$(az storage account show --name hrdepartmentstorage --resource-group HR-Department --query "id" --output tsv)
# echo "$hrdepartmentstoragecontainerUri"

# accountKey=$(az storage account keys list --resource-group HR-Department --account-name hrdepartmentstorage --query '[0].value' --output tsv)
# expiry=$(python3 -c "from datetime import datetime, timedelta; print((datetime.utcnow() + timedelta(minutes=30)).strftime('%Y-%m-%dT%H:%MZ'))")
# sasToken=$(az storage container generate-sas --account-name hrdepartmentstorage --name employee-container --permissions dlrw --expiry $expiry --account-key $accountKey --output tsv)
# curl -X GET "https://hrdepartmentstorage.blob.core.windows.net/employee-container?restype=container" -H "Authorization: Bearer $sasToken"


# https://hrdepartmentstorage.blob.core.windows.net/employee-container?restype=container

# 2. WebApp UbuntuVM
# az monitor data-collection rule show \
#   --resource-group WebApp \
#   --name UbuntuVM-DCR \
#   --query "{dataFlows:dataFlows, destinations:destinations, dataSources:dataSources}" \
#   --output json > dcr-config.json

# RESOURCE_GROUP="WebApp"
# RULE_NAME="UbuntuVM-DCR"

# # Get the existing Data Collection Rule and save it to a JSON file
# az monitor data-collection rule show \
#   --resource-group "$RESOURCE_GROUP" \
#   --name "$RULE_NAME" \
#   --output json > "./Blue/rules.json"
sleep 60
RESOURCE_GROUP="WebApp"
LOCATION="australiacentral"
RULE_NAME="UbuntuVM-DCR"
WORKSPACE_NAME="WebApp-workspace"
ASSOCIATION_NAME="UbuntuVM-DCR-Association"
VM_NAME="UbuntuVM"

RESOURCE_GROUP_ID=$(az vm show \
  --resource-group "$RESOURCE_GROUP" \
  --name "$VM_NAME" \
  --query "id" \
  --output tsv)

# Retrieve VM_RESOURCE_ID dynamically
VM_RESOURCE_ID=$(az vm show \
  --resource-group $RESOURCE_GROUP \
  --name $VM_NAME \
  --query id -o tsv)

# Define data_flows
data_flows='[
  {
    "destinations": ["logAnalyticsDestination"],
    "outputStream": "Microsoft-Perf",
    "streams": ["Microsoft-Perf"],
    "transformKql": "source"
  },
  {
    "destinations": ["logAnalyticsDestination"],
    "outputStream": "Microsoft-Syslog",
    "streams": ["Microsoft-Syslog"],
    "transformKql": "source"
  }
]'

# Define data_sources
data_sources='{
  "performanceCounters": [
    {
      "counterSpecifiers": [
        "Processor(*)\\% Processor Time",
        "Processor(*)\\% Idle Time",
        "Processor(*)\\% User Time",
        "Processor(*)\\% Nice Time",
        "Processor(*)\\% Privileged Time",
        "Processor(*)\\% IO Wait Time",
        "Processor(*)\\% Interrupt Time",
        "Processor(*)\\% DPC Time",
        "Memory(*)\\Available MBytes Memory",
        "Memory(*)\\% Available Memory",
        "Memory(*)\\Used Memory MBytes",
        "Memory(*)\\% Used Memory",
        "Memory(*)\\Pages/sec",
        "Memory(*)\\Page Reads/sec",
        "Memory(*)\\Page Writes/sec",
        "Memory(*)\\Available MBytes Swap",
        "Memory(*)\\% Available Swap Space",
        "Memory(*)\\Used MBytes Swap Space",
        "Memory(*)\\% Used Swap Space",
        "Process(*)\\Pct User Time",
        "Process(*)\\Pct Privileged Time",
        "Process(*)\\Used Memory",
        "Process(*)\\Virtual Shared Memory",
        "Logical Disk(*)\\% Free Inodes",
        "Logical Disk(*)\\% Used Inodes",
        "Logical Disk(*)\\Free Megabytes",
        "Logical Disk(*)\\% Free Space",
        "Logical Disk(*)\\% Used Space",
        "Logical Disk(*)\\Logical Disk Bytes/sec",
        "Logical Disk(*)\\Disk Read Bytes/sec",
        "Logical Disk(*)\\Disk Write Bytes/sec",
        "Logical Disk(*)\\Disk Transfers/sec",
        "Logical Disk(*)\\Disk Reads/sec",
        "Logical Disk(*)\\Disk Writes/sec",
        "Network(*)\\Total Bytes Transmitted",
        "Network(*)\\Total Bytes Received",
        "Network(*)\\Total Bytes",
        "Network(*)\\Total Packets Transmitted",
        "Network(*)\\Total Packets Received",
        "Network(*)\\Total Rx Errors",
        "Network(*)\\Total Tx Errors",
        "Network(*)\\Total Collisions",
        "System(*)\\Uptime",
        "System(*)\\Load1",
        "System(*)\\Load5",
        "System(*)\\Load15",
        "System(*)\\Users",
        "System(*)\\Unique Users",
        "System(*)\\CPUs"
      ],
      "name": "perfCounterDataSource60",
      "samplingFrequencyInSeconds": 60,
      "streams": ["Microsoft-Perf"]
    }
  ],
  "syslog": [
    {
      "facilityNames": [
        "alert", "audit", "auth", "authpriv", "clock", "cron", "daemon", "ftp", "kern", 
        "local0", "local1", "local2", "local3", "local4", "local5", "local6", "local7", 
        "lpr", "mail", "news", "nopri", "ntp", "syslog", "user", "uucp"
      ],
      "logLevels": [
        "Debug", "Info", "Notice", "Warning", "Error", "Critical", "Alert", "Emergency"
      ],
      "name": "sysLogsDataSource-1688419672",
      "streams": ["Microsoft-Syslog"]
    }
  ]
}'


# Extract the workspaceResourceId from destinations
WORKSPACE_RESOURCE_ID=$(az monitor log-analytics workspace show \
  --resource-group "$RESOURCE_GROUP" \
  --workspace-name "$WORKSPACE_NAME" \
  --query "id" \
  --output tsv)

# Define the name for the Log Analytics destination (adjust as needed)
destination_name="logAnalyticsDestination"

# Format destinations correctly with the extracted workspaceResourceId and a non-empty name
destinations=$(jq -n --arg workspaceResourceId "$WORKSPACE_RESOURCE_ID" --arg name "$destination_name" \
    '{logAnalytics: [{name: $name, workspaceResourceId: $workspaceResourceId}]}')

# Correct data-flows to reference the destination name
# data_flows=$(jq --arg name "$destination_name" '.dataFlows | map(.destinations[0] = $name)' dcr-config.json)

# Create a new Data Collection Rule using the extracted data
az monitor data-collection rule create \
  --resource-group $RESOURCE_GROUP \
  --name $RULE_NAME \
  --location "Australia Central" \
  --data-flows "$data_flows" \
  --destinations "$destinations" \
  --data-sources "$data_sources" \
  --kind Linux




# az monitor data-collection rule create --resource-group $RESOURCE_GROUP_ID --location $LOCATION --name $RULE_NAME --rule-file "./Blue/rules.json"
sleep 60

DATA_COLLECTION_RULE_ID=$(az monitor data-collection rule show \
  --resource-group "$RESOURCE_GROUP" \
  --name "$RULE_NAME" \
  --query id -o tsv)

# # Create the Data Collection Rule Association
az monitor data-collection rule association create \
  --association-name "$ASSOCIATION_NAME" \
  --data-collection-rule "$DATA_COLLECTION_RULE_ID" \
  --resource "$VM_RESOURCE_ID"


# Variables
# RESOURCE_GROUP="WebApp"
# LOCATION="australiacentral"
# RULE_NAME="UbuntuVM-DCR"
# WORKSPACE_NAME="WebApp-workspace"
# DESTINATION_NAME="la-312004528"
# ASSOCIATION_NAME="UbuntuVM-DCR-Association"
# VM_NAME="UbuntuVM"

# # Retrieve WORKSPACE_RESOURCE_ID and WORKSPACE_ID dynamically
# WORKSPACE_RESOURCE_ID=$(az monitor log-analytics workspace show \
#   --resource-group $RESOURCE_GROUP \
#   --workspace-name $WORKSPACE_NAME \
#   --query id -o tsv)

# WORKSPACE_ID=$(az monitor log-analytics workspace show \
#   --resource-group $RESOURCE_GROUP \
#   --workspace-name $WORKSPACE_NAME \
#   --query customerId -o tsv)

# # Retrieve VM_RESOURCE_ID dynamically
# VM_RESOURCE_ID=$(az vm show \
#   --resource-group $RESOURCE_GROUP \
#   --name $VM_NAME \
#   --query id -o tsv)

# DATA_COLLECTION_RULE_ID=$(az monitor data-collection rule show \
#   --resource-group "$RESOURCE_GROUP" \
#   --name "$RULE_NAME" \
#   --query id -o tsv)

# # Create the Data Collection Rule
# az monitor data-collection rule create \
#   --resource-group $RESOURCE_GROUP \
#   --name $RULE_NAME \
#   --location $LOCATION \
#   --data-flows '[
#     {
#       "streams": ["Microsoft-Perf"],
#       "destinations": ["'$DESTINATION_NAME'"],
#       "transformKql": "source",
#       "outputStream": "Microsoft-Perf"
#     },
#     {
#       "streams": ["Microsoft-Syslog"],
#       "destinations": ["'$DESTINATION_NAME'"],
#       "transformKql": "source",
#       "outputStream": "Microsoft-Syslog"
#     }
#   ]' \
#   --data-sources '{
#     "syslog": [
#       {
#         "streams": ["Microsoft-Syslog"],
#         "facilityNames": [
#           "alert", "audit", "auth", "authpriv", "clock", "cron", "daemon", "ftp", 
#           "kern", "local0", "local1", "local2", "local3", "local4", "local5", 
#           "local6", "local7", "lpr", "mail", "news", "nopri", "ntp", "syslog", 
#           "user", "uucp"
#         ],
#         "logLevels": ["Debug", "Info", "Notice", "Warning", "Error", "Critical", "Alert", "Emergency"]
#       }
#     ],
#     "performanceCounters": [
#       {
#         "counterSpecifiers": [
#           "Processor(*)\\% Processor Time",
#           "Processor(*)\\% Idle Time",
#           "Processor(*)\\% User Time",
#           "Processor(*)\\% Nice Time",
#           "Processor(*)\\% Privileged Time",
#           "Processor(*)\\% IO Wait Time",
#           "Processor(*)\\% Interrupt Time",
#           "Processor(*)\\% DPC Time",
#           "Memory(*)\\Available MBytes Memory",
#           "Memory(*)\\% Available Memory",
#           "Memory(*)\\Used Memory MBytes",
#           "Memory(*)\\% Used Memory",
#           "Memory(*)\\Pages/sec",
#           "Memory(*)\\Page Reads/sec",
#           "Memory(*)\\Page Writes/sec",
#           "Memory(*)\\Available MBytes Swap",
#           "Memory(*)\\% Available Swap Space",
#           "Memory(*)\\Used MBytes Swap Space",
#           "Memory(*)\\% Used Swap Space",
#           "Process(*)\\Pct User Time",
#           "Process(*)\\Pct Privileged Time",
#           "Process(*)\\Used Memory",
#           "Process(*)\\Virtual Shared Memory",
#           "Logical Disk(*)\\% Free Inodes",
#           "Logical Disk(*)\\% Used Inodes",
#           "Logical Disk(*)\\Free Megabytes",
#           "Logical Disk(*)\\% Free Space",
#           "Logical Disk(*)\\% Used Space",
#           "Logical Disk(*)\\Logical Disk Bytes/sec",
#           "Logical Disk(*)\\Disk Read Bytes/sec",
#           "Logical Disk(*)\\Disk Write Bytes/sec",
#           "Logical Disk(*)\\Disk Transfers/sec",
#           "Logical Disk(*)\\Disk Reads/sec",
#           "Logical Disk(*)\\Disk Writes/sec",
#           "Network(*)\\Total Bytes Transmitted",
#           "Network(*)\\Total Bytes Received",
#           "Network(*)\\Total Bytes",
#           "Network(*)\\Total Packets Transmitted",
#           "Network(*)\\Total Packets Received",
#           "Network(*)\\Total Rx Errors",
#           "Network(*)\\Total Tx Errors",
#           "Network(*)\\Total Collisions",
#           "System(*)\\Uptime",
#           "System(*)\\Load1",
#           "System(*)\\Load5",
#           "System(*)\\Load15",
#           "System(*)\\Users",
#           "System(*)\\Unique Users",
#           "System(*)\\CPUs"
#         ],
#         "samplingFrequencyInSeconds": 60,
#         "streams": ["Microsoft-Perf"]
#       }
#     ]
#   }' \
#   --destinations '{
#     "logAnalytics": [
#       {
#         "workspaceResourceId": "'$WORKSPACE_RESOURCE_ID'",
#         "name": "'$DESTINATION_NAME'"
#       }
#     ]
#   }'


# # Create the Data Collection Rule Association
# az monitor data-collection rule association create \
#   --association-name "$ASSOCIATION_NAME" \
#   --data-collection-rule "$DATA_COLLECTION_RULE_ID" \
#   --resource "$VM_RESOURCE_ID"





# az deployment group create \
#   --resource-group WebApp \
#   --template-file ./template.json \
#   --parameters ./parameters.json




# Get VM resource ID
# VM_RESOURCE_ID=$(az vm show \
#   --resource-group WebApp \
#   --name UbuntuVm \
#   --query "id" \
#   --output tsv)

# # Get Log Analytics workspace resource ID
# WORKSPACE_RESOURCE_ID=$(az monitor log-analytics workspace show \
#   --resource-group WebApp \
#   --workspace-name WebApp-workspace \
#   --query "id" \
#   --output tsv)

# Create Data Collection Rule (DCR)
# cp dcr-config.json dcr-config-updated.json

# sed -i "s|REPLACE_WITH_WORKSPACE_ID|$WORKSPACE_RESOURCE_ID|g" dcr-config-updated.json

# az monitor data-collection rule create \
#   --resource-group WebApp \
#   --name UbuntuVM-DCR \
#   --location "Australia Central" \
#   --rule-file dcr-config-updated.json

# az monitor data-collection rule create \
#   --resource-group WebApp \
#   --name UbuntuVM-DCR \
#   --location "Australia Central" \
#   --data-flows '[{"streams": ["Microsoft-Syslog"], "destinations": ["logAnalyticsDest"]}, {"streams": ["Microsoft-InsightsMetrics"], "destinations": ["logAnalyticsDest"]}]' \
#   --destinations '[{"name": "logAnalyticsDest", "workspaceResourceId": "$WORKSPACE_RESOURCE_ID"}]' \
#   --data-sources '{
#     "syslog": [{"name": "SyslogCollection", "streams": ["Microsoft-Syslog"], "facilityNames": ["*"], "logLevels": ["Debug", "Info", "Notice", "Warning", "Error", "Critical", "Alert", "Emergency"], "destination": "logAnalyticsDest"}],
#     "performanceCounters": [{"name": "PerformanceCounterCollection", "streams": ["Microsoft-InsightsMetrics"], "counterSpecifiers": ["*"], "samplingFrequencyInSeconds": 60, "destination": "logAnalyticsDest"}]
#   }'

# az monitor data-collection rule create \
#   --resource-group WebApp \
#   --name UbuntuVM-DCR \
#   --location "Australia Central" \
#   --data-flows '[{"streams": ["Microsoft-Syslog", "Microsoft-InsightsMetrics"], "destinations": ["logAnalyticsDest"]}]' \
#   --destinations "log-analytics=[{\"name\": \"logAnalyticsDest\", \"workspaceResourceId\": \"$WORKSPACE_RESOURCE_ID\"}]" \
#   --data-sources '{
#     "syslog": [{"name": "SyslogCollection", "streams": ["Microsoft-Syslog"], "facilityNames": ["*"], "logLevels": ["Debug", "Info", "Notice", "Warning", "Error", "Critical", "Alert", "Emergency"]}],
#     "performanceCounters": [{"name": "PerformanceCounterCollection", "streams": ["Microsoft-InsightsMetrics"], "counterSpecifiers": ["*"], "samplingFrequencyInSeconds": 60}]
#   }'



# # Get DCR resource ID
# DCR_RESOURCE_ID=$(az monitor data-collection rule show \
#   --resource-group WebApp \
#   --name UbuntuVM-DCR \
#   --query "id" \
#   --output tsv)

# # Associate the DCR with the VM
# az monitor data-collection rule association create \
#   --name "UbuntuVM-DCR-Association" \
#   --resource "$VM_RESOURCE_ID" \
#   --rule-id "$DCR_RESOURCE_ID"

# az monitor data-collection rule association show \
#   --resource-group "WebApp" \
#   --resource "$(az vm show --resource-group $resourceGroupName --name $vmName --query 'id' -o tsv)" \
#   --name "UbuntuVM-DCR-Association"


# az vm extension image list-versions \
#   --name AzureMonitorLinuxAgent \
#   --publisher Microsoft.Azure.Monitor \
#   --location "Australia Central" \
#   --output table
# Set the Azure Monitor Linux Agent extension
# az vm extension set \
#   --name AzureMonitorLinuxAgent \
#   --publisher Microsoft.Azure.Monitor \
#   --ids "$VM_RESOURCE_ID" \
#   --enable-auto-upgrade true

# az monitor diagnostic-settings create \
#   --resource "/subscriptions/8b54ea3d-2a10-44ff-9038-fcb1ecd8df39/resourceGroups/WebApp/providers/Microsoft.Compute/virtualMachines/UbuntuVM" \
#   --name "UbuntuVM-diagnostic-setting" \
#   --workspace "/subscriptions/8b54ea3d-2a10-44ff-9038-fcb1ecd8df39/resourceGroups/WebApp/providers/Microsoft.OperationalInsights/workspaces/WebApp-workspace" \
#   --logs '[{"category": "PerformanceCounters", "enabled": true}, {"category": "Syslog", "enabled": true}]' \
#   --metrics '[{"category": "AllMetrics", "enabled": true, "retentionPolicy": {"enabled": true, "days": 30}}]'



# az monitor data-collection rule create \
#   --resource-group WebApp \
#   --name UbuntuVM-DCR \
#   --location "Australia Central" \
#   --data-flows '[{"streams": ["Microsoft-Syslog"], "destinations": ["logAnalyticsDest"]}]' \
#   --destinations 'log-analytics=[{"name": "logAnalyticsDest", "workspaceResourceId": "/subscriptions/8b54ea3d-2a10-44ff-9038-fcb1ecd8df39/resourceGroups/WebApp/providers/Microsoft.OperationalInsights/workspaces/WebApp-workspace"}]'

# # Install Azure Monitor Agent on the VM
# az vm extension set \
#   --resource-group WebApp \
#   --vm-name UbuntuVM \
#   --name AzureMonitorLinuxAgent \
#   --publisher Microsoft.Azure.Monitor \
#   --version 1.0

# # Associate DCR to the VM
# az monitor data-collection rule association create \
#   --name "UbuntuVM-DCR-Association" \
#   --resource "/subscriptions/8b54ea3d-2a10-44ff-9038-fcb1ecd8df39/resourceGroups/WebApp/providers/Microsoft.Compute/virtualMachines/UbuntuVM" \
#   --rule-id "/subscriptions/8b54ea3d-2a10-44ff-9038-fcb1ecd8df39/resourceGroups/WebApp/providers/Microsoft.Insights/dataCollectionRules/UbuntuVM-DCR"



# 3. Entra ID
# az account set --subscription 8b54ea3d-2a10-44ff-9038-fcb1ecd8df39
# WORKSPACE_ID=$(az monitor log-analytics workspace show \
#   --resource-group WebApp \
#   --workspace-name WebApp-workspace \
#   --query customerId \
#   --output tsv)
# az monitor diagnostic-settings create \
#   --name "AADDiagnosticSetting" \
#   --resource "/providers/microsoft.aadiam/organizations/78b7869e-3bc0-4ad1-87cf-91b692c23ff8" \
#   --resource-id "/providers/Microsoft.aadiam/directoryInsights" \
#   --logs '[{"category": "AuditLogs", "enabled": true}, {"category": "SignInLogs", "enabled": true}, {"category": "NonInteractiveUserSignInLogs", "enabled": true}, {"category": "ServicePrincipalSignInLogs", "enabled": true}, {"category": "ManagedIdentitySignInLogs", "enabled": true}, {"category": "ProvisioningLogs", "enabled": true}]' \
#   --workspace "$WORKSPACE_ID"



# 4. all resource groups



# az monitor diagnostic-settings create --resource {ID} -n {name} --workspace --logs "[{category:WorkflowRuntime,enabled:true,retention-policy:{enabled:false,days:0}}]"