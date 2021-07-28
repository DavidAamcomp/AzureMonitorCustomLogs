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
Set-Location c:\log\PowerShell_IPv4NetworkScanner\
git pull
$json = C:\log\PowerShell_IPv4NetworkScanner\Scripts\IPv4NetworkScan.ps1 -ipv4address $IP[0] -cidr 24 -EnableMACResolving
$json | Add-Member -MemberType NoteProperty -Name "Computer" -Value $hostname
$json = $json | ConvertTo-Csv | ConvertFrom-Csv | ConvertTo-Json
Send-OMSAPIIngestionFile -customerId $customerId -sharedKey $SharedKey -body $json -logType $LogType
Set-Location $dir
 }
 
$LogType = "SpeedTest" 
$DownloadURL = "https://install.speedtest.net/app/cli/ookla-speedtest-1.0.0-win64.zip"
#location to save on the computer. Path must exist or it will error
$DOwnloadPath = "c:\temp\SpeedTest.Zip"
$ExtractToPath = "c:\temp\SpeedTest"
$SpeedTestEXEPath = "C:\temp\SpeedTest\speedtest.exe"
#Log File Path
$LogPath = 'c:\temp\SpeedTestLog.txt'

#Start Logging to a Text File
$ErrorActionPreference="SilentlyContinue"
#Stop-Transcript | out-null
$ErrorActionPreference = "Continue"
#Start-Transcript -path $LogPath -Append:$false
#check for and delete existing log files

function RunTest()
{
    $test = & $SpeedTestEXEPath --accept-license --format=json
    $test
}

if (Test-Path $SpeedTestEXEPath -PathType leaf)
{
    #Write-Host "SpeedTest EXE Exists, starting test" -ForegroundColor Green
    $json = RunTest
}
else
{
    #Write-Host "SpeedTest EXE Doesn't Exist, starting file download"

    #downloads the file from the URL
    wget $DownloadURL -outfile $DOwnloadPath

    #Unzip the file
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    function Unzip
    {
        param([string]$zipfile, [string]$outpath)

        [System.IO.Compression.ZipFile]::ExtractToDirectory($zipfile, $outpath)
    }

    Unzip $DOwnloadPath $ExtractToPath
    RunTest
}

$json | Add-Member -MemberType NoteProperty -Name "Computer" -Value $hostname
Send-OMSAPIIngestionFile -customerId $customerId -sharedKey $SharedKey -body $json -logType $LogType
