# soak-run.ps1 : 10-31 (CEO and the main PC's Claude): the two-window soak (tools\handoff\soakloop.ps1) on the main PC, started by the
# idle runner (tools\spare\spare-runner.ps1) once per new build while he is away. It has its own headless Chrome (CDP 9335, temp profile
# pillagers-soak, downloads go into the runner's soak-downloads folder, never his Downloads) and its own test server (tools\spare\serve.mjs
# on 8809 serving the runner copy's tools folder; never 8802). The fixture already points the report receiver (8799) at a black hole.
# Both are ended by PID at the end, and any Chrome part of the pillagers-soak profile after that. Calls no AI. ASCII only (PS 5.1).
# Result: -Out gets one line per run ("run k {...}" or "run k NOT FINISHED"), then DONE; NOT STARTED when Chrome never answered.
param([string]$Root='C:\PillagersIdle\game',[string]$Out='C:\PillagersIdle\soak-last.txt',[int]$Runs=6,[int]$Soak=120)
$ErrorActionPreference='Continue'
$T=$Root+'\tools'; $W=Split-Path $Out -Parent; $Enc=New-Object Text.UTF8Encoding $false
$prof=Join-Path $env:TEMP 'pillagers-soak'; $dl=Join-Path $W 'soak-downloads'
New-Item -ItemType Directory -Force -Path ($prof+'\Default'),$dl | Out-Null
foreach($lf in 'SingletonLock','SingletonCookie','SingletonSocket','lockfile'){ Remove-Item -LiteralPath (Join-Path $prof $lf) -Force -ErrorAction SilentlyContinue }
$pj='{"download":{"default_directory":"'+($dl -replace '\\','\\')+'","prompt_for_download":false,"directory_upgrade":true},"profile":{"default_content_setting_values":{"automatic_downloads":2}}}'
[IO.File]::WriteAllText($prof+'\Default\Preferences',$pj,$Enc)
[IO.File]::WriteAllText($Out,'',$Enc)
function Note([string]$s){ [IO.File]::AppendAllText($Out,$s+"`r`n",$Enc) }
$chrome=@(($env:ProgramFiles+'\Google\Chrome\Application\chrome.exe'),(${env:ProgramFiles(x86)}+'\Google\Chrome\Application\chrome.exe'),($env:LOCALAPPDATA+'\Google\Chrome\Application\chrome.exe')) | Where-Object { $_ -and (Test-Path -LiteralPath $_) } | Select-Object -First 1
if(-not $chrome){ Note 'NOT STARTED: no Chrome'; exit 2 }
$node=(Get-Command node -ErrorAction SilentlyContinue).Source; if(-not $node){ $node='C:\Program Files\nodejs\node.exe' }
$srv=Start-Process -FilePath $node -ArgumentList @(('"'+$T+'\spare\serve.mjs"'),'--root',('"'+$T+'"'),'--port','8809') -WindowStyle Hidden -PassThru
$ch=Start-Process -FilePath $chrome -PassThru -ArgumentList @('--headless=new','--remote-debugging-port=9335',('--user-data-dir="'+$prof+'"'),'--window-size=1920,1080','--force-device-scale-factor=1',
  '--no-first-run','--no-default-browser-check','--disable-background-timer-throttling','--disable-renderer-backgrounding','about:blank')
try{
  $ok=$false; for($i=0;$i -lt 30;$i++){ Start-Sleep 1; try{ Invoke-RestMethod http://127.0.0.1:9335/json/version -TimeoutSec 2 | Out-Null; $ok=$true; break }catch{} }
  if(-not $ok){ Note 'NOT STARTED: the test Chrome did not answer on 9335'; exit 2 }
  & powershell.exe -NoProfile -ExecutionPolicy Bypass -File ($T+'\handoff\soakloop.ps1') -Runs $Runs -Soak $Soak -Cdp 9335 -Port 8809 -Root $Root | ForEach-Object { Note ([string]$_) }
  Note 'DONE'
} finally {
  foreach($p in @($ch,$srv)){ if($p){ Stop-Process -Id $p.Id -Force -ErrorAction SilentlyContinue } }
  Get-CimInstance Win32_Process -Filter "Name='chrome.exe'" -ErrorAction SilentlyContinue | Where-Object { $_.CommandLine -match 'pillagers-soak' } | ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }
}
