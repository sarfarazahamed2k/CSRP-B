# Variables
$domainName = "csrp.local"
$userPassword = ConvertTo-SecureString "UserPassword@123" -AsPlainText -Force
$userName = "SarfarazAhamedAdmin"
$userDisplayName = "Sarfaraz Ahamed Admin"
$userOU = "CN=Users,DC=csrp,DC=local"
$userName2 = "RalphMay"
$userDisplayName2 = "Ralph May"

# Import the Active Directory module
Import-Module ActiveDirectory

# Create a new user
New-ADUser -Name $userDisplayName -SamAccountName $userName -UserPrincipalName "$userName@$domainName" -Path $userOU -AccountPassword $userPassword -Enabled $true

# Add the new user to the "Domain Admins" group
Add-ADGroupMember -Identity "Domain Admins" -Members $userName

# Set the description for the new user
Set-ADUser -Identity $userName -Description "Admin account for Sarfaraz Ahamed - UserPassword@123"

# Disable logon hours by setting all bytes to 0
$Hours = New-Object byte[] 21

# Create a hash table to store the attributes to be replaced
$ReplaceHashTable = New-Object Hashtable
$ReplaceHashTable.Add("logonHours", $Hours)

# Update the user attributes in Active Directory
Set-ADUser -Identity $userName -Replace $ReplaceHashTable

# Create the second user
New-ADUser -Name $userDisplayName2 -SamAccountName $userName2 -UserPrincipalName "$userName2@$domainName" -Path $userOU -AccountPassword $userPassword -Enabled $true

# Restart the server to complete the setup of users
Restart-Computer -Force