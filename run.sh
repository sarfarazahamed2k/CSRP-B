#!/bin/bash

# Load environment variables from the .env file
if [ -f .env ]; then
    source .env
else
    echo ".env file not found!"
    exit 1
fi

# Function to login to a specific account
login_to_azure() {
    local tenant_id=$1
    # echo "Logging in to tenant $tenant_id..."
    az login --tenant $tenant_id

    if [ $? -eq 0 ]; then
        echo "Login successful for tenant $tenant_id"
    else
        echo "Login failed for tenant $tenant_id"
        exit 1
    fi
}

# Function to switch to a specific account
switch_azure_account() {
    local subscription_id=$1
    echo "Switching to subscription $subscription_id..."
    az account set --subscription $subscription_id > /dev/null 2>&1

    if [ $? -eq 0 ]; then
        echo "Switched to subscription $subscription_id"
    else
        echo "Failed to switch to subscription $subscription_id"
        exit 1
    fi
}

# Export the functions
export -f login_to_azure
export -f switch_azure_account

echo "Logging into both accounts..."

# Login to the first tenant
echo "Login to Personal Account - Safari"
login_to_azure $T1_ID

# Login to the second tenant
echo "Login to Student Account - Chrome"
login_to_azure $T2_ID

echo "Both accounts logged in successfully."

switch_azure_account $S2_ID

cd on-premise
./Deploy-Infrastructure.sh
./Deploy-Domain.sh

cd Scenario-1
./Scenario-1.sh

cd ../Scenario-2
./Scenario-2.sh

cd ../Scenario-4
./Scenario-4.sh

cd ..

switch_azure_account $S1_ID

cd ../cloud
./MicrosoftEntraConnectUser.sh

# Ask for user input
read -p "Microsoft Entra Connect user is created. Do you want to proceed? (Y/N): " user_input

# Convert input to uppercase for comparison
user_input=$(echo "$user_input" | tr '[:lower:]' '[:upper:]')

# Check if the input is "Y"
if [ "$user_input" != "Y" ]; then
    exit 0
fi

sleep 60

cd Scenario-1
./Scenario-1.sh

cd ../Scenario-2
./Scenario-2.sh

cd ../Scenario-3
./Scenario-3.sh

cd ../Scenario-4
./Scenario-4.sh

cd ../CyberDeception
./Decoy-Users.sh
./InfiniteRecursion.sh
./Deploy-Files.sh

cd ../Blue
./start-Sentinel.sh

# Ask for user input
read -p "Azure Sentinel workspace is created. Do you want to proceed? (Y/N): " user_input

# Convert input to uppercase for comparison
user_input=$(echo "$user_input" | tr '[:lower:]' '[:upper:]')

# Check if the input is "Y"
if [ "$user_input" != "Y" ]; then
    exit 0
fi

./start-Defender.sh
./start-Monitor.sh

cd ..

switch_azure_account $S2_ID

cd ../on-premise/CyberDeception
./Decoy-Users.sh
./Deploy-Files.sh

cd ../Blue
./Deploy-Wazuh.sh
./Deploy-Velociraptor.sh
./Setup-OpenEDRAgent.sh
./start_capture_all_vms.sh
