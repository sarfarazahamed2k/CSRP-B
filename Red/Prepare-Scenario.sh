#!/bin/bash

# Variables
resourceGroupNameKali="RedTeam"
vmName="KaliVM"

kaliIpAddress=$(az vm list-ip-addresses --resource-group $resourceGroupNameKali --name $vmName --query "[].virtualMachine.network.publicIpAddresses[0].ipAddress" -o tsv)

echo "https://127.0.0.1:3333 - admin - kali-gophish"
echo "Sending Profiles: https://myaccount.google.com/apppasswords" 
echo "smtp.gmail.com:465"
echo ""
echo "Email Template: https://raw.githubusercontent.com/FreeZeroDays/GoPhish-Templates/refs/heads/master/Email_Templates/System_is_Out_of_Date.html"
echo "IT Admin <ITAdmin@sarfarazahamed2018gmail.onmicrosoft.com>"
echo "Login Required"
echo ""
echo "Landing Page: https://raw.githubusercontent.com/FreeZeroDays/GoPhish-Templates/refs/heads/master/Landing_Pages/O-Three-Sixty-Five_Landing_Page.html"
echo "O-Three-Sixty-Five_Landing_Page.html"
echo "https://portal.azure.com/"
echo ""
echo "User & Groups:"
echo "Scenario-2 - Joff - Thyer - JoffThyer@sarfarazahamed2018gmail.onmicrosoft.com"
echo "Scenario-3 - Jeff - McJunkin - JeffMcJunkin@sarfarazahamed2018gmail.onmicrosoft.com"
echo "Scenario-4 - Sarfaraz - Ahamed - SarfarazAhamed@sarfarazahamed2018gmail.onmicrosoft.com"
echo ""
echo "Campaigns"
echo "http://20.28.16.60:8080"


# Prompt the user to select a scenario
echo "Select a scenario to simulate:"
echo "1) Scenario 1"
echo "2) Scenario 2"
echo "3) Scenario 3"
echo "4) Scenario 4"
read -p "Enter the number corresponding to the scenario: " scenarioChoice

# Determine the selected scenario and assign the appropriate script
case $scenarioChoice in
    1)
        echo "No Phishing is performed."
        echo "Open Executive_Compensation_2024.xlsx"
        ;;
    2)
        ./Unassign-M365BB.sh 
        export USER_EMAIL="JoffThyer@sarfarazahamed2018gmail.onmicrosoft.com"
        ./Assign-M365BB.sh 
        echo "https://outlook.office365.com/mail/"
        echo "Username: JoffThyer@sarfarazahamed2018gmail.onmicrosoft.com"
        echo "Password: P@ssw0rd!"
        echo "Open Top_Clients_Contracts.xlsx"
        ;;
    3)
        ./Unassign-M365BB.sh 
        export USER_EMAIL="JeffMcJunkin@sarfarazahamed2018gmail.onmicrosoft.com"
        ./Assign-M365BB.sh 
        echo "https://outlook.office365.com/mail/"
        echo "Username: JeffMcJunkin@sarfarazahamed2018gmail.onmicrosoft.com"
        echo "Password: SecureP@ssw0rd!"
        echo "Open Customer_Accounts_Details.xlsx"
        ;;
    4)
        ./Unassign-M365BB.sh 
        export USER_EMAIL="SarfarazAhamed@sarfarazahamed2018gmail.onmicrosoft.com"
        ./Assign-M365BB.sh
        echo "https://outlook.office365.com/mail/"
        echo "Username: SarfarazAhamed@sarfarazahamed2018gmail.onmicrosoft.com"
        echo "Password: UserPassword@123"
        echo "Open High_Profile_Lawsuit_Details.xlsx"
        ;;
    *)
        echo "Invalid selection. Exiting."
        ;;
esac

echo $kaliIpAddress
