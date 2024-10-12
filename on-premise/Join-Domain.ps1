# Variables
$domainControllerIp = "10.0.1.4"  # IP address of the Domain Controller
$domainName = "csrp.local"
$domainUser = "workstation-1\user_administrator"
$domainPassword = ConvertTo-SecureString "Password@123!" -AsPlainText -Force
$domainCredential = New-Object System.Management.Automation.PSCredential ($domainUser, $domainPassword)

# Set DNS server to the Domain Controller IP
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses $domainControllerIp

Start-Sleep -Seconds 60

# Join the Windows 11 machine to the domain
Add-Computer -DomainName $domainName -Credential $domainCredential -Restart -Force