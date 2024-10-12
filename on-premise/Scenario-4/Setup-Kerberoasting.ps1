# Variables
$domainName = "csrp.local"
$mssqlUserPassword = ConvertTo-SecureString "Password@1" -AsPlainText -Force
$mssqlUserName = "MSSQLSvc"
$mssqlUserDisplayName = "MSSQL Service Account"
$userOU = "CN=Users,DC=csrp,DC=local"
$mssqlSPN = "MSSQLSvc/$domainName"

# Import the Active Directory module
Import-Module ActiveDirectory

# Create a new MSSQL service user
New-ADUser -Name $mssqlUserDisplayName -SamAccountName $mssqlUserName -UserPrincipalName "$mssqlUserName@$domainName" -Path $userOU -AccountPassword $mssqlUserPassword -Enabled $true

# Set the SPN for the MSSQL service user
setspn -A $mssqlSPN $mssqlUserName

# Confirm the SPN was set
setspn -L $mssqlUserName

# Add the new MSSQL service user to the "Domain Admins" group
Add-ADGroupMember -Identity "Domain Admins" -Members $mssqlUserName

# Restart the server to complete the setup of users
Restart-Computer -Force
