# Variables
$domainName = "csrp.local"
$safeModeAdminPassword = ConvertTo-SecureString "AdminPassword@123" -AsPlainText -Force

# Install AD DS role
Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools

# Promote the server to a Domain Controller
Install-ADDSForest -DomainName $domainName -SafeModeAdministratorPassword $safeModeAdminPassword -InstallDns -Force -NoRebootOnCompletion

# Restart the server to complete the installation
Restart-Computer -Force