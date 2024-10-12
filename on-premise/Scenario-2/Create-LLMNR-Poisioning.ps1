# Variables for the task
$taskName = "CopyFile"
$adminUserName = "csrp.local\Administrator"
$adminUserPassword = "P@ssw0rd@123!"

# Script content
$scriptContent = @"
# Set the resource name
`$server = 'test.csrp.local'
`$share = 'share'
`$filePath = 'test.txt'
`$localPath = 'C:\temp\test.txt'

# Define the credentials (username and password)
`$username = 'Administrator'
`$password = 'P@ssw0rd@123!'
`$securePassword = ConvertTo-SecureString `$password -AsPlainText -Force
`$credential = New-Object System.Management.Automation.PSCredential(`$username, `$securePassword)

# Error handling
try {
    # Map the SMB share
    New-SmbMapping -RemotePath "\\`$server\`$share" -Credential `$credential -Persistent `$false -ErrorAction Stop

    # Copy the file from the SMB share to the local path
    Copy-Item "\\`$server\`$share\`$filePath" `$localPath -ErrorAction Stop

    # Remove the SMB mapping
    Remove-SmbMapping -RemotePath "\\`$server\`$share" -ErrorAction Stop

    Write-Output "File copied successfully to `$localPath"
} catch {
    Write-Output "Failed"
}
"@

# Create a scheduled task action
$encodedCommand = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($scriptContent))
$action = New-ScheduledTaskAction -Execute 'PowerShell.exe' -Argument "-NoProfile -WindowStyle Hidden -EncodedCommand $encodedCommand"

# Create a trigger to run the task every minute
$trigger = New-ScheduledTaskTrigger -RepetitionInterval (New-TimeSpan -Minutes 1) -At (Get-Date).AddMinutes(1) -Once

# Create task settings
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -DontStopOnIdleEnd

# Register the scheduled task
Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Settings $settings -User $adminUserName -Password $adminUserPassword
