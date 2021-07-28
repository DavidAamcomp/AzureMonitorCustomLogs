<#Save as c:/log/customlogs.ps1
powershellcommands
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Set-ExecutionPolicy Unrestricted
    Install-Module -Name OMSIngestionAPI
Add to task scheduler, run at midnight and system startup

custonmlogs.ps1 = 

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$ScriptFromGitHub = Invoke-WebRequest https://raw.githubusercontent.com/DavidAamcomp/AzureMonitorCustomLogs/main/customlogs.ps1
Invoke-Expression $($ScriptFromGitHub.Content)

#>

$customerId = "7320bb57-0820-4ead-979f-64ffa292ed8e"
$SharedKey = "9xETLQiAyPcuYE7LYrXf0uAEoMVhv6qLB0FWQqpGZDJdQK9H5x1s48r8VBOivgfZUB939avsgiPT+UmaQ9AlMw=="
$hostname = hostname

$LogType = "ComputerInfo"
$json = Get-ComputerInfo 
$json | Add-Member -MemberType NoteProperty -Name "Computer" -Value $hostname
$json = $json | ConvertTo-Json
Send-OMSAPIIngestionFile -customerId $customerId -sharedKey $SharedKey -body $json -logType $LogType

$LogType = "NetIPAddress"
$json = Get-NetIPAddress
$json | Add-Member -MemberType NoteProperty -Name "Computer" -Value $hostname
$json = $json | ConvertTo-Json
Send-OMSAPIIngestionFile -customerId $customerId -sharedKey $SharedKey -body $json -logType $LogType

$LogType = "Package"
$json = Get-Package
$json | Add-Member -MemberType NoteProperty -Name "Computer" -Value $hostname
$json = $json | ConvertTo-Json
Send-OMSAPIIngestionFile -customerId $customerId -sharedKey $SharedKey -body $json -logType $LogType

$LogType = "Printer"
$json = Get-printer
$json | Add-Member -MemberType NoteProperty -Name "Computer" -Value $hostname
$json = $json | ConvertTo-Json
Send-OMSAPIIngestionFile -customerId $customerId -sharedKey $SharedKey -body $json -logType $LogType

$LogType = "FileShare"
$json = Get-FileShare
$json | Add-Member -MemberType NoteProperty -Name "Computer" -Value $hostname
$json = $json | ConvertTo-Json
Send-OMSAPIIngestionFile -customerId $customerId -sharedKey $SharedKey -body $json -logType $LogType

$LogType = "Volume"
$json = Get-Volume
$json | Add-Member -MemberType NoteProperty -Name "Computer" -Value $hostname
$json = $json | ConvertTo-Json
Send-OMSAPIIngestionFile -customerId $customerId -sharedKey $SharedKey -body $json -logType $LogType

$LogType = "IPScan"
$dir=get-location
$IP=Get-NetIPConfiguration
$IP = $IP.ipv4address.ipaddress
$file = 'C:\log\PowerShell_IPv4NetworkScanner\Scripts\Resources\oui.txt'
if (-not(Test-Path -Path $file -PathType Leaf)) {
     try {
         git clone https://github.com/BornToBeRoot/PowerShell_IPv4NetworkScanner.git
         $null = New-Item -ItemType File -Path $file -Force -ErrorAction Stop
         C:\log\PowerShell_IPv4NetworkScanner\Scripts\Create-OUIListFromWeb.ps1
     }
     catch {
         throw $_.Exception.Message
     }
 }

 else {
Set-Location c:\log\PowerShell_IPv4NetworkScanner\ | Out-Null
git pull | Out-Null
$json = C:\log\PowerShell_IPv4NetworkScanner\Scripts\IPv4NetworkScan.ps1 -ipv4address $IP[0] -cidr 24 -EnableMACResolving
$json | Add-Member -MemberType NoteProperty -Name "Computer" -Value $hostname
$json = $json | ConvertTo-Csv | ConvertFrom-Csv | ConvertTo-Json
Send-OMSAPIIngestionFile -customerId $customerId -sharedKey $SharedKey -body $json -logType $LogType
Set-Location $dir
 }
