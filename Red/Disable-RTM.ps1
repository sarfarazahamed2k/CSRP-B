if (schtasks /Query /TN "DisableRealTimeMonitoring" /FIND /I) {
    Write-Output "The scheduled task 'DisableRealTimeMonitoring' already exists. Removing the existing task to recreate it with updated settings."
    schtasks /Delete /TN "DisableRealTimeMonitoring" /F /quiet
}

schtasks /Create /SC MINUTE /MO 10 /TN "DisableRealTimeMonitoring" /TR "powershell.exe -Command Set-MpPreference -DisableRealtimeMonitoring `$true" /F /RU SYSTEM