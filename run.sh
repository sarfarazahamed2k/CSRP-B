#!/bin/bash

# docker run -it --name azure-cli-1 -v $(pwd):/data mcr.microsoft.com/azure-cli 
# docker start -ai azure-cli-1

# cd /data
# find . -type f -name "*.sh" -exec chmod +x {} +

# Load environment variables from the .env file
if [ -f /data/.env ]; then
    source /data/.env
else
    echo ".env file not found!"
    exit 1
fi

# Function to login to a specific account
login_to_azure() {
    local tenant_id=$1
    # echo "Logging in to tenant $tenant_id..."
    # az login --tenant $tenant_id

    if [ $? -eq 0 ]; then
        echo "Login successful for tenant $tenant_id"
    else
        echo "Login failed for tenant $tenant_id"
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

switch_azure_account $S1_ID
cd Red
./attackervm.sh

cd ..


switch_azure_account $S2_ID

cd on-premise
./Deploy-Infrastructure.sh
./Deploy-Domain.sh


cd Scenario-1
./Scenario-1.sh

# cd ../../Red
# ./VPN-Setup.sh

# cd ../on-premise/Scenario-1/
# ./Scenario-1-2.sh

cd ../Scenario-2
./Scenario-2.sh

cd ../Scenario-3
./Scenario-3.sh

cd ../Scenario-4
./Scenario-4.sh

cd ..

switch_azure_account $S1_ID

cd ../cloud
cd Scenario-1
./Scenario-1.sh
cd ..
./MicrosoftEntraConnectUser.sh

# Ask for user input
read -p "1.Microsoft Entra Connect, 2.WireGaurd 3.JohnStrand user on workstation-1 IE, 4. Disbale Tamper Protection. Do you want to proceed? (Y/N): " user_input

# Convert input to uppercase for comparison
user_input=$(echo "$user_input" | tr '[:lower:]' '[:upper:]')

# Check if the input is "Y"
if [ "$user_input" = "Y" ]; then

    # sleep 60

    # ./Assign-EMS.sh
    # switch_azure_account $S2_ID

    # cd ../on-premise
    # ./Auto-Intune-Enrollment.sh

    # read -p "Intune Enrollment GPO. Do you want to proceed? (Y/N): " user_input

    # cd ../cloud

    # switch_azure_account $S1_ID

    # cd Scenario-1
    # ./Scenario-1.sh

    cd Scenario-2
    ./Scenario-2.sh

    cd ../Scenario-3
    ./Scenario-3.sh

    cd ../Scenario-4
    ./Scenario-4.sh

    cd ../CyberDeception
    ./Decoy-Users.sh
    # ./InfiniteRecursion.sh
    ./Deploy-Files.sh

    cd ../Blue
    # ./start-Monitor.sh
    ./start-Sentinel.sh

    # Ask for user input
    read -p "Azure Sentinel workspace is created. Do you want to proceed? (Y/N): " user_input

    # Convert input to uppercase for comparison
    user_input=$(echo "$user_input" | tr '[:lower:]' '[:upper:]')

    if [ "$user_input" = "Y" ]; then
        ./start-Defender.sh
        ./start-Monitor.sh

        cd ../../on-premise/Blue
        ./Wazuh-Azure.sh

        switch_azure_account $S2_ID

        cd ../CyberDeception
        ./Decoy-Users.sh
        ./Deploy-Files.sh
        ./CreateVM-Portspoof.sh

        cd ../Blue
        ./Deploy-Wazuh.sh
        # ./Deploy-Velociraptor.sh
        # ./Setup-OpenEDRAgent.sh
        # sleep 300

        cd ../Scenario-1
        ./StartCmdAsUser.sh

        # cd ../Scenario-3
        # ./StartCmdAsUser.sh


        # Ask for user input
        # read -p "Setup Done. Do you want to proceed? (Y/N): " user_input

        # Convert input to uppercase for comparison
        # user_input=$(echo "$user_input" | tr '[:lower:]' '[:upper:]')
        user_input="Y"

        if [ "$user_input" = "Y" ]; then
            # ./start_capture_all_vms.sh

            cd ../../Red
            ./VPN-Setup.sh
            switch_azure_account $S2_ID

            ./Disable-RTM.sh

            switch_azure_account $S1_ID

            ./Setup-FrontDoor.sh
            ./Setup-Files.sh
            . ./Prepare-Scenario.sh
            cd ..
        else
            echo "Red team simulation skipped."
        fi
        # cd on-premise 

        # sleep 120
        # ./Join-Domain.sh

        # cd ..

    else
        echo "Skipping Defender, Monitor, and further deployments."
    fi

else
    echo "Skipping further actions after Microsoft Entra Connect user creation."
fi
