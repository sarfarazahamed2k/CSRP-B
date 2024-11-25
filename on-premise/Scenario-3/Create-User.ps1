# Define the user details
$username = "JeffMcJunkin"
$fullname = "Jeff McJunkin"
$defaultPassword = "SecureP@ssw0rd!"  # Set the default password
$userOU = "CN=Users,DC=csrp,DC=local"  # Specify the Organizational Unit (OU) where the user will be created

# Convert the plain text password to a SecureString
$password = ConvertTo-SecureString $defaultPassword -AsPlainText -Force

# Create the Active Directory user account in one line
New-ADUser -Name $fullname -SamAccountName $username -UserPrincipalName "$username@csrp.local" -GivenName "Jeff" -Surname "McJunkin" -DisplayName $fullname -AccountPassword $password -Enabled $true -PasswordNeverExpires $true -Path $userOU -ChangePasswordAtLogon $false
