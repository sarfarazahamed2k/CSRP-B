# Define the user account and the local administrators group
$userName = "csrp\JohnStrand"
$groupName = "Administrators"

# Add the user to the local administrators group
Add-LocalGroupMember -Group $groupName -Member $userName

# Restart the server to complete the setup of users
Restart-Computer -Force