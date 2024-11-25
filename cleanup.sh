if [ -f /data/.env ]; then
    source /data/.env
else
    echo ".env file not found!"
    exit 1
fi

switch_azure_account $S2_ID

cd on-premise

./Delete-AzureResources.sh

switch_azure_account $S1_ID

cd Blue
./Cleanup-Wazuh-Azure.sh 

cd ..

cd ../cloud

cd Blue

./cleanup-Monitor.sh

cd ../Scenario-1

./Cleanup-Scenario-1.sh

cd ../Scenario-2

./Cleanup-Scenario-2.sh

cd ../Scenario-3

./Cleanup-Scenario-3.sh

cd ../Scenario-4

./Cleanup-Scenario-4.sh

cd ..

./Cleanup-MicrosoftEntraConnectUser.sh

cd ..

# Loop through all groups in Azure AD
for groupId in $(az ad group list --query "[].id" -o tsv); do
  # Get the source property of the group
  groupSource=$(az ad group show --group $groupId --query "onPremisesSyncEnabled" -o tsv)

  # Check if the source is 'Windows Server AD' (onPremisesSyncEnabled is True)
  if [ "$groupSource" == "true" ]; then
    echo "Deleting group with ID: $groupId (Source: Windows Server AD)"
    az ad group delete --group $groupId
  fi
done

cd Red

./cleanup.sh

cd ..