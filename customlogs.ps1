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
