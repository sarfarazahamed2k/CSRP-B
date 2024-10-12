Invoke-WebRequest -Uri "https://packages.wazuh.com/4.x/windows/wazuh-agent-4.9.0-1.msi" -OutFile "C:\Users\Public\wazuh-agent-4.9.0-1.msi"

msiexec /i "C:\Users\Public\wazuh-agent-4.9.0-1.msi" /quiet WAZUH_MANAGER="10.0.1.10"

Start-Sleep -Seconds 60

Start-Service -Name Wazuh
