# Variables
$domainName = "csrp.local"
$userPassword = ConvertTo-SecureString "UserPassword@123" -AsPlainText -Force
$userName = "JohnStrand"
$userDisplayName = "John Strand"
$userOU = "CN=Users,DC=csrp,DC=local"
$adminUserDisplayName = "Administrator"
$adminUserName = "Administrator"
$adminUserPassword = ConvertTo-SecureString "P@ssw0rd@123!" -AsPlainText -Force
$entraConnectUserName = "EntraConnectUser"
$entraConnectUserDisplayName = "Microsoft Entra Connect User"
$entraConnectUserPassword = ConvertTo-SecureString "ConnectUser@123" -AsPlainText -Force
# Define the user and domain
$ADUser = "csrp\EntraConnectUser"
$DomainPath = "DC=csrp,DC=local"
$UsersContainer = "CN=Users,$DomainPath"


# Import the Active Directory module
Import-Module ActiveDirectory

# Create a new user
New-ADUser -Name $userDisplayName -SamAccountName $userName -UserPrincipalName "$userName@$domainName" -Path $userOU -AccountPassword $userPassword -Enabled $true

# Create a new administrator user
New-ADUser -Name $adminUserDisplayName -SamAccountName $adminUserName -UserPrincipalName "$adminUserName@$domainName" -Path $userOU -AccountPassword $adminUserPassword -Enabled $true

# Create a new Microsoft Entra Connect User
New-ADUser -Name $entraConnectUserDisplayName -SamAccountName $entraConnectUserName -UserPrincipalName "$entraConnectUserName@$domainName" -Path $userOU -AccountPassword $entraConnectUserPassword -Enabled $true

# Add the new user to the "Enterprise Admins" group
Add-ADGroupMember -Identity "Enterprise Admins" -Members $adminUserName

# Grant "Replicate Directory Changes" and "Replicate Directory Changes All" at the domain root
Write-Host "Granting Replicate Directory Changes and Replicate Directory Changes All..."

$rootDSE = Get-ADRootDSE
$domainDN = $rootDSE.DefaultNamingContext

# Convert the domain name to LDAP format for ACLs
$domainObj = [ADSI]"LDAP://$domainDN"
$acl = $domainObj.psbase.ObjectSecurity

# Create a new ACE (Access Control Entry) for "Replicate Directory Changes"
$identity = New-Object System.Security.Principal.NTAccount($ADUser)
$guidReplicateDC = [guid]"1131F6AA-9C07-11D1-F79F-00C04FC2DCD2"  # Replicating Directory Changes
$guidReplicateDCA = [guid]"1131F6AD-9C07-11D1-F79F-00C04FC2DCD2"  # Replicating Directory Changes All
$inherit = [System.DirectoryServices.ActiveDirectorySecurityInheritance]::None

# Add "Replicate Directory Changes" permission
$ace = New-Object System.DirectoryServices.ActiveDirectoryAccessRule($identity, "ExtendedRight", "Allow", $guidReplicateDC, $inherit)
$acl.AddAccessRule($ace)

# Add "Replicate Directory Changes All" permission
$ace2 = New-Object System.DirectoryServices.ActiveDirectoryAccessRule($identity, "ExtendedRight", "Allow", $guidReplicateDCA, $inherit)
$acl.AddAccessRule($ace2)

# Apply the changes
$domainObj.psbase.ObjectSecurity = $acl
$domainObj.psbase.CommitChanges()

Write-Host "Replicate Directory Changes permissions granted."

# Grant permissions for User, iNetOrgPerson, Group, and Contact
Write-Host "Granting Read/Write all properties for User, iNetOrgPerson, Group, and Contact..."

# Grant read/write permissions for User
$UserObj = [ADSI]"LDAP://$UsersContainer"
$acl = $UserObj.psbase.ObjectSecurity

$aceUser = New-Object System.DirectoryServices.ActiveDirectoryAccessRule($identity, "WriteProperty", "Allow", [guid]::Empty, $inherit)
$acl.AddAccessRule($aceUser)

# Grant read/write permissions for iNetOrgPerson
$aceInetOrgPerson = New-Object System.DirectoryServices.ActiveDirectoryAccessRule($identity, "WriteProperty", "Allow", [guid]::Empty, $inherit)
$acl.AddAccessRule($aceInetOrgPerson)

# Grant read/write permissions for Group
$aceGroup = New-Object System.DirectoryServices.ActiveDirectoryAccessRule($identity, "WriteProperty", "Allow", [guid]::Empty, $inherit)
$acl.AddAccessRule($aceGroup)

# Grant read/write permissions for Contact
$aceContact = New-Object System.DirectoryServices.ActiveDirectoryAccessRule($identity, "WriteProperty", "Allow", [guid]::Empty, $inherit)
$acl.AddAccessRule($aceContact)

# Apply changes
$UserObj.psbase.ObjectSecurity = $acl
$UserObj.psbase.CommitChanges()

Write-Host "Read/Write permissions for User, iNetOrgPerson, Group, and Contact granted."

# Grant Reset Password permission
Write-Host "Granting Reset Password permission..."

$guidResetPassword = [guid]"00299570-246d-11d0-a768-00aa006e0529"  # Reset Password
$aceResetPassword = New-Object System.DirectoryServices.ActiveDirectoryAccessRule($identity, "ExtendedRight", "Allow", $guidResetPassword, $inherit)
$acl.AddAccessRule($aceResetPassword)

# Apply changes
$UserObj.psbase.ObjectSecurity = $acl
$UserObj.psbase.CommitChanges()

Write-Host "Reset Password permission granted."



# Restart the server to complete the setup of users
Restart-Computer -Force