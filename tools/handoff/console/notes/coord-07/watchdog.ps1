# coord-07 RAM watchdog: every 5 s, if free RAM falls under 2 GB, stop the Chrome on debug port 9371 only and log it.
param([string]$Log='C:\claudecode\dark raiders\tools\handoff\console\notes\coord-07\watchdog.txt',[int]$MaxMin=120)
$t0=Get-Date
while(((Get-Date)-$t0).TotalMinutes -lt $MaxMin){
  if(Test-Path 'C:\claudecode\dark raiders\tools\handoff\console\notes\coord-07\watchdog.stop'){ break }
  $f=[math]::Round((Get-CimInstance Win32_OperatingSystem).FreePhysicalMemory/1MB,2)
  Add-Content $Log ((Get-Date -Format 'HH:mm:ss')+' free '+$f+' GB')
  if($f -lt 2){
    Get-CimInstance Win32_Process -Filter "Name='chrome.exe'" | Where-Object { $_.CommandLine -match 'remote-debugging-port=9371(\s|$)' } | ForEach-Object { Stop-Process -Id $_.ProcessId -Force }
    Add-Content $Log ((Get-Date -Format 'HH:mm:ss')+' LOW RAM: stopped chrome 9371')
    break
  }
  Start-Sleep -Seconds 5
}
