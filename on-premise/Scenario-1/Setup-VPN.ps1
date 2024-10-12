# Define the username and password for administrative tasks
$username = "user_administrator"
$password = "Password@123!"

# Convert the password to a secure string
$securePassword = ConvertTo-SecureString $password -AsPlainText -Force

# Create a PSCredential object
$credential = New-Object System.Management.Automation.PSCredential ($username, $securePassword)

# Path to the temporary script file
$scriptPath = "$env:TEMP\ConfigureRRAS.ps1"

# Content of the script to configure RRAS
$scriptContent = @'
# Import the required modules
Import-Module ServerManager

# Install the necessary Windows features for RRAS
Install-WindowsFeature -Name RemoteAccess -IncludeManagementTools
Install-WindowsFeature -Name RSAT-RemoteAccess-PowerShell -IncludeManagementTools
Install-WindowsFeature -Name DirectAccess-VPN -IncludeManagementTools
Install-WindowsFeature -Name Routing -IncludeManagementTools

# Install and configure RRAS for VPN only
Install-RemoteAccess -VpnType Vpn

# Ensure the service is set to start automatically
Set-Service -Name RemoteAccess -StartupType Automatic

# Start RRAS service
Start-Service RemoteAccess

# Configure RRAS for VPN using PowerShell for IKEv2 and MS-CHAPv2
Set-VpnAuthProtocol -UserAuthProtocolAccepted MSChapv2 -PassThru

# Restart RRAS service to apply changes
Restart-Service RemoteAccess
'@

# Write the script content to the file
Set-Content -Path $scriptPath -Value $scriptContent

# Create an argument list for running the script with elevated privileges
$argumentList = "-NoProfile -ExecutionPolicy Bypass -File $scriptPath"

# Run the script with elevated privileges
Start-Process PowerShell -ArgumentList $argumentList -Verb RunAs -Wait

# Optionally, clean up the temporary script file after execution
Remove-Item -Path $scriptPath -Force
