# Enable Object Access auditing (if not already enabled)
auditpol /set /category:"Object Access" /success:enable /failure:enable

# Get ACL for "C:\Users\Public\Desktop\creds.txt" file
$acl = Get-Acl "C:\Users\Public\Desktop\creds.txt"

# Add Logging of all activities
$ar = New-Object System.Security.AccessControl.FileSystemAuditRule("Everyone", "FullControl", "Success, Failure")
$acl.AddAuditRule($ar)

# Apply an audit rule to creds.txt to track who accesses the file
Set-Acl "C:\Users\Public\Desktop\creds.txt" $acl
