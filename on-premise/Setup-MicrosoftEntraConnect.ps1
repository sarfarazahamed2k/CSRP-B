# Define variables
$installerUrl = "https://download.microsoft.com/download/B/0/0/B00291D0-5A83-4DE7-86F5-980BC00DE05A/AzureADConnect.msi"
$installerPath = "$env:TEMP\AzureADConnect.msi"

# Download Azure AD Connect installer
Write-Output "Downloading Azure AD Connect installer..."
Invoke-WebRequest -Uri $installerUrl -OutFile $installerPath

# Install Azure AD Connect silently
Write-Output "Installing Azure AD Connect..."
Start-Process msiexec.exe -ArgumentList "/i `"$installerPath`" /quiet /norestart" -Wait