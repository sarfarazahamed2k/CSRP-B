#!/bin/bash

# Define variables
userName="AzureConnect"
userDisplayName="Azure Connect"
userPassword="P@ssw0rd!"
domain="sarfarazahamed2018gmail.onmicrosoft.com"
roleId="62e90394-69f5-4237-9190-012177145e10"

# Create a new user and capture the userId
userId=$(az ad user create --display-name "$userDisplayName" \
                           --password "$userPassword" \
                           --user-principal-name "$userName@$domain" \
                           --mail-nickname "$userName" \
                           --query 'id' \
                           --output tsv)

# Assign the user to the Global Administrator role
az rest --method POST --uri 'https://graph.microsoft.com/beta/roleManagement/directory/roleAssignments' \
                      --body "{'principalId': '$userId', 'roleDefinitionId': '$roleId', 'directoryScopeId': '/'}"

# Output the username and password
echo ""
echo '# Define variables' && \
echo '$installerUrl = "https://download.microsoft.com/download/B/0/0/B00291D0-5A83-4DE7-86F5-980BC00DE05A/AzureADConnect.msi"' && \
echo '$installerPath = "$env:TEMP\AzureADConnect.msi"' && \
echo '' && \
echo '# Download Azure AD Connect installer' && \
echo 'Write-Output "Downloading Azure AD Connect installer..."' && \
echo 'Invoke-WebRequest -Uri $installerUrl -OutFile $installerPath' && \
echo '' && \
echo '# Install Azure AD Connect silently' && \
echo 'Write-Output "Installing Azure AD Connect..."' && \
echo 'Start-Process msiexec.exe -ArgumentList "/i `"$installerPath`" /norestart" -Wait'

echo ""
echo "on-premise Active Directory Creds:"
echo "Username: csrp\Administrator"
echo "Password: P@ssw0rd@123!"

echo ""
echo "Azure Entra ID Creds:"
echo "Username: $userName@$domain"
echo "Password: $userPassword"

echo ""
echo "on-premise Active Directory Creds:"
echo "Username: csrp\EntraConnectUser"
echo "Password: ConnectUser@123"