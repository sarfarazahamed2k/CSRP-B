# Define variables
resourceGroupName="on-premise"
winServerVmName="CSRP-DC"
win11VmName="workstation-1"
creds="./creds.txt"

# Paths to the scripts
scriptDecoyUsers="./Decoy-Users.ps1"
scriptFileAudit="./FileAudit.ps1"
scriptInfiniteRecursion="./InfiniteRecursion.ps1"


# Invoke script to configure Domain Controller
az vm run-command invoke --resource-group $resourceGroupName --name $winServerVmName --command-id RunPowerShellScript --scripts @$scriptDecoyUsers

# Wait for the restart to complete before proceeding
sleep 60

# Read the content of the creds.txt file
credsContent=$(<"$creds")

# Prepare the PowerShell script to write the content to the file on the VM
writeCredsScript=$(cat <<EOF
\$credsContent = @'
$credsContent
'@
\$credsPath = 'C:\\Users\\Public\\Desktop\\creds.txt'
Set-Content -Path \$credsPath -Value \$credsContent
EOF
)

# Invoke the script on the win11VmName VM to write creds.txt to the desktop
az vm run-command invoke --resource-group $resourceGroupName --name $win11VmName --command-id RunPowerShellScript --scripts "$writeCredsScript"

# Invoke the script on the win11VmName VM to create a File Audit to creds.txt file
az vm run-command invoke --resource-group $resourceGroupName --name $win11VmName --command-id RunPowerShellScript --scripts @$scriptFileAudit

# Invoke the scriptInfiniteRecursion on the win11VmName VM
az vm run-command invoke --resource-group $resourceGroupName --name $win11VmName --command-id RunPowerShellScript --scripts @$scriptInfiniteRecursion