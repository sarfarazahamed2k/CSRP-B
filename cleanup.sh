switch_azure_account $S2_ID

cd on-premise

./Delete-AzureResources.sh

switch_azure_account $S1_ID

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
