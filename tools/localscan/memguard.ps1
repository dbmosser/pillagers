# Runs beside a local model scan: every 2 s it reads available RAM and, below -MinFreeMB, unloads every Ollama model at
# once. His PC hard-froze at 97% RAM (2026-09-28); a model load on Windows with an AMD card stages through system RAM.
#   powershell -File tools\localscan\memguard.ps1 [-MinFreeMB 4000] [-Minutes 180]
param([int]$MinFreeMB=4000,[int]$Minutes=180)
$ol="$env:LOCALAPPDATA\Programs\Ollama\ollama.exe"
$end=(Get-Date).AddMinutes($Minutes); $low=999999; $trips=0
while((Get-Date) -lt $end){
  $a=[math]::Round((Get-Counter '\Memory\Available MBytes').CounterSamples[0].CookedValue)
  if($a -lt $low){ $low=$a }
  if($a -lt $MinFreeMB){
    try{ (Invoke-RestMethod http://127.0.0.1:11434/api/ps -TimeoutSec 3).models | ForEach-Object { & $ol stop $_.name | Out-Null } }catch{}
    $trips++; "TRIPPED at $(Get-Date -Format HH:mm:ss): $a MB available, models unloaded"
    Start-Sleep 20
  }
  Start-Sleep 2
}
"memguard done: lowest available $low MB, tripped $trips times"
