# Waits for new run reports in exports\ (his local play: both co-op windows post to the collector on :8799) and exits
# printing their names, so a background run wakes the session to read them. Exits after -MaxMin anyway (a heartbeat).
#   powershell -File tools\watch-exports.ps1 -MaxMin 30
param([int]$MaxMin=30,[string]$Root='C:\claudecode\dark raiders')
$dir=Join-Path $Root 'exports'
$seen=@{}; Get-ChildItem -LiteralPath $dir -Filter 'run-*.txt' | ForEach-Object { $seen[$_.Name]=1 }
$end=(Get-Date).AddMinutes($MaxMin)
while((Get-Date) -lt $end){
  Start-Sleep 15
  $new=@(Get-ChildItem -LiteralPath $dir -Filter 'run-*.txt' | Where-Object { -not $seen.ContainsKey($_.Name) })
  if($new.Count){ Start-Sleep 5; $new | ForEach-Object { 'NEW ' + $_.FullName }; exit 0 }
}
'no new report in ' + $MaxMin + ' minutes'
