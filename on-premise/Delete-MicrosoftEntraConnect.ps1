# Stop the Azure AD Connect synchronization service
Write-Output "Stopping Azure AD Connect synchronization service..."
Stop-Service -Name "ADSync" -Force

# Clean up the registry entries related to Azure AD Connect
Write-Output "Cleaning up registry entries..."
Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Azure AD Connect" -Recurse -Force -ErrorAction SilentlyContinue