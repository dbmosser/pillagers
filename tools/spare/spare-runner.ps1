# spare-runner.ps1 : THE SPARE PC RUNNER (2026-10-20). His spare PC (RTX 2080, AMD X3D, 16 GB; his words: "16gb ram, it can stay on and
# connected") becomes the TEST AND ROBOT machine, so the VM's memory goes to the helpers. It never ships, commits to the game or edits the
# game: its game copy (C:\claudecode\dark raiders, the same path as the VM so every test script works unchanged) refuses every push, and
# only the separate results copy (C:\PillagersSpare\results) pushes, and only to the spare-results branch on GitHub.
# What it does, every 5 minutes, with no Claude and no AI at all:
#   1. When no full test run is going: takes the newest game from GitHub master (a plain detached checkout of origin/master; this copy
#      has no work of its own), and when the game file changed since the last run it builds the test copy (tools\mkfixture.ps1) and
#      starts the full test run (tools\handoff\shipkit\corpq.sh, Chrome 9344), the same run the VM does, writing
#      C:\PillagersSpare\out\corpus\corpus-MMDD-HHMM.txt and a .head file naming the commit.
#   2. Keeps two crash robots going (tools\fuzz.ps1 on 9331 and 9332, 60 minute blocks, 3 of 4 raids the real 2-player demo) on the
#      full test run's copy of the game (tools\fxcorpus.html), so one exact version gets both, which is what the VM's stable picker needs.
#   3. Every 30 minutes, and at once when a full test run ends: copies the finished runs, the robot log and its problem records and a
#      status file into results\spare\HOSTNAME\ and pushes them to spare-results. The VM takes them in (tools\spare\spare-import.mjs).
# Its own test server (tools\spare\serve.mjs) listens on this PC only (127.0.0.1 and ::1, port 8806), so Windows asks no firewall
# question; this file never runs a firewall, Defender, UAC, power-plan or Windows Update command. While it runs it asks Windows to stay
# awake (the same request a video player makes); that ends when it stops.
# It refuses to run on the main PC (JUL26) or the VM, or without the marker file that spare-setup.ps1 writes.
# Start: wscript tools\spare\spare-start.vbs (the task made by spare-setup.ps1 does it at sign-in and every 15 minutes; a copy whose
# heartbeat is under 10 minutes old makes a new one exit). When master brings a new copy of this file, it restarts itself.
# Log: C:\PillagersSpare\runner.log. Status: C:\PillagersSpare\status.txt. ASCII only (PowerShell 5.1 reads .ps1 as ANSI).
param([switch]$Once,[int]$FuzzMinutes=60,[int]$PublishMin=30)
$ErrorActionPreference='Continue'
$R='C:\claudecode\dark raiders'; $T=$R+'\tools'; $W='C:\PillagersSpare'
$Res=$W+'\results'; $Out=$W+'\out'; $FzOut=$Out+'\fuzz'; $CorpDir=$Out+'\corpus'
$Log=$W+'\runner.log'; $StateF=$W+'\state.txt'; $Hb=$W+'\runner.heartbeat'; $StatusF=$W+'\status.txt'
$Bash='C:\Program Files\Git\bin\bash.exe'; $Branch='spare-results'; $HostN=$env:COMPUTERNAME
$Enc=New-Object Text.UTF8Encoding $false

if($HostN -in 'JUL26','VM_Oct2026'){ Write-Output 'refusing: this is the main PC or the VM, not the spare PC'; exit 2 }
if(-not (Test-Path -LiteralPath ($R+'\.spare-pc'))){ Write-Output 'refusing: no spare PC marker (run tools\spare\spare-setup.ps1 first)'; exit 2 }
New-Item -ItemType Directory -Force -Path $W,$Out,$FzOut,$CorpDir | Out-Null
if(-not $Once -and (Test-Path -LiteralPath $Hb)){
  if(((Get-Date)-(Get-Item -LiteralPath $Hb).LastWriteTime).TotalSeconds -lt 600){ exit 0 }   # another copy is alive
}
$Git=(Get-Command git -ErrorAction SilentlyContinue).Source; if(-not $Git){ $Git='C:\Program Files\Git\cmd\git.exe' }
$Node=(Get-Command node -ErrorAction SilentlyContinue).Source; if(-not $Node){ $Node='C:\Program Files\nodejs\node.exe' }

function Stamp(){ (Get-Date).ToString('MM-dd HH:mm') }
function Epoch(){ [DateTimeOffset]::UtcNow.ToUnixTimeSeconds() }
function Say([string]$s){ [IO.File]::AppendAllText($Log,(Stamp)+' '+($s -replace '[^\x20-\x7e]','?')+"`r`n",$Enc) }
function GetS([string]$k){
  if(Test-Path -LiteralPath $StateF){ foreach($l in [IO.File]::ReadAllLines($StateF)){ if($l.StartsWith($k+'=')){ return $l.Substring($k.Length+1) } } }
  return ''
}
function PutS([string]$k,[string]$v){
  $L=@(); if(Test-Path -LiteralPath $StateF){ $L=@([IO.File]::ReadAllLines($StateF) | Where-Object { -not $_.StartsWith($k+'=') }) }
  $L+=($k+'='+$v); [IO.File]::WriteAllLines($StateF,[string[]]$L,$Enc)
}
function G(){ $o = & $Git @args 2>&1; $script:gx=$LASTEXITCODE; return (($o | ForEach-Object { "$_" }) -join "`n").Trim() }
function Short([string]$s){ $s=($s -replace '\s+',' ').Trim(); if($s.Length -gt 160){ $s=$s.Substring(0,160) }; return $s }
function Running([string]$rx){
  @(Get-CimInstance Win32_Process -ErrorAction SilentlyContinue | Where-Object { $_.ProcessId -ne $PID -and $_.CommandLine -and ($_.CommandLine -match $rx) }).Count
}
function Up([int]$p,[string]$f){
  try{ $rq=[Net.WebRequest]::Create('http://127.0.0.1:'+$p+'/'+$f); $rq.Method='HEAD'; $rq.Timeout=4000; $rs=$rq.GetResponse(); $rs.Close(); return $true }catch{ return $false }
}
function GameVer(){
  try{ $m=[regex]::Match([IO.File]::ReadAllText($R+'\dark_raiders.html'),"var VER='([0-9]+\.[0-9]+)';"); if($m.Success){ return $m.Groups[1].Value } }catch{}
  return '?'
}

# keep the PC awake while this runs (ES_CONTINUOUS | ES_SYSTEM_REQUIRED); it ends with this process
try{
  Add-Type -Namespace PillagersSpare -Name Power -MemberDefinition '[DllImport("kernel32.dll")] public static extern uint SetThreadExecutionState(uint f);' -ErrorAction Stop
  [void][PillagersSpare.Power]::SetThreadExecutionState([uint32]2147483649)
}catch{ Say ('could not ask Windows to stay awake: '+(Short "$_")) }

$SelfHash=(Get-FileHash -LiteralPath $PSCommandPath -Algorithm SHA256).Hash
Say ('spare runner started (pid '+$PID+', game v'+(GameVer)+')')

function Ensure-Server(){
  if(Up 8806 'cdp.ps1'){ return }
  if(-not (Test-Path -LiteralPath $Node)){ Say 'PROBLEM: Node is not installed, so the test server cannot start'; return }
  Start-Process -FilePath $Node -ArgumentList @(('"'+$T+'\spare\serve.mjs"'),'--root',('"'+$T+'"'),'--port','8806') -WindowStyle Hidden | Out-Null
  for($i=0;$i -lt 10;$i++){ Start-Sleep 1; if(Up 8806 'cdp.ps1'){ Say 'test server 8806 started'; return } }
  Say 'PROBLEM: the test server on 8806 did not start'
}

function Update-Game(){
  $o=G -C $R fetch -q origin master
  if($script:gx -ne 0){ Say ('GitHub fetch failed: '+(Short $o)); return $false }
  $want=G -C $R rev-parse origin/master; $have=G -C $R rev-parse HEAD
  if($want -and $want -ne $have){
    $o=G -C $R -c advice.detachedHead=false checkout -q -f --detach $want
    if($script:gx -ne 0){ Say ('could not take the new game: '+(Short $o)); return $false }
    Say ('game copy now at '+$want.Substring(0,8)+' (v'+(GameVer)+')')
  }
  return $true
}

function Start-Corpus(){
  $blob=G -C $R rev-parse 'HEAD:dark_raiders.html'; $head=G -C $R rev-parse HEAD
  if(-not $blob -or $blob -eq (GetS 'tested_blob')){ return }
  $tries=0; if((GetS 'try_blob') -eq $blob){ $tries=[int]('0'+(GetS 'tries')) }
  if($tries -ge 2){ return }   # this build failed twice to give a full run; wait for the next one
  PutS 'try_blob' $blob; PutS 'tries' ([string]($tries+1))
  $t0=Get-Date
  $fx=& powershell.exe -NoProfile -ExecutionPolicy Bypass -File ($T+'\mkfixture.ps1') 2>&1 | Select-Object -Last 2
  $fi=Get-Item -LiteralPath ($T+'\fixture.html') -ErrorAction SilentlyContinue
  if(-not $fi -or $fi.LastWriteTime -lt $t0 -or $fi.Length -lt 5000000){ Say ('PROBLEM: the test copy did not build: '+(Short ($fx -join ' '))); return }
  $name='corpus-'+(Get-Date -Format 'MMdd-HHmm')+'.txt'; $outF=$CorpDir+'\'+$name
  [IO.File]::WriteAllText($outF+'.head',$head+"`n",$Enc)
  Start-Process -FilePath $Bash -ArgumentList @('tools/handoff/shipkit/corpq.sh',('"'+($outF -replace '\\','/')+'"')) -WorkingDirectory $R -WindowStyle Hidden | Out-Null
  PutS 'corpus_file' $outF; PutS 'corpus_blob' $blob; PutS 'corpus_t' ([string](Epoch))
  Say ('full test run started on '+$head.Substring(0,8)+' (v'+(GameVer)+') -> '+$name)
}

function Start-Robot([int]$port,[string]$copy){
  if(-not (Test-Path -LiteralPath ($T+'\fxcorpus.html'))){ return }
  $env:FUZZ_OUT_DIR=$FzOut; $env:FUZZ_COPY_NAME=$copy
  Start-Process -FilePath powershell.exe -WindowStyle Hidden -ArgumentList @('-NoProfile','-ExecutionPolicy','Bypass','-WindowStyle','Hidden',
    '-File',('"'+$T+'\fuzz.ps1"'),'-Minutes',[string]$FuzzMinutes,'-IgnoreFlag','-Port',[string]$port,'-MinFreeGB','2','-Fixture','fxcorpus.html') | Out-Null
  Remove-Item Env:FUZZ_OUT_DIR,Env:FUZZ_COPY_NAME -ErrorAction SilentlyContinue
  Say ('robot started on '+$port)
}

function Write-Status([string]$corpus,[int]$robots){
  $os=Get-CimInstance Win32_OperatingSystem -ErrorAction SilentlyContinue
  $free=if($os){ [math]::Round($os.FreePhysicalMemory/1MB,1) }else{ '?' }
  # 10-21: each pair in its own brackets. PowerShell's comma binds before +, so the old list was ONE string joined with spaces and the
  # VM's import never found epoch= (it read the spare PC as never seen).
  $L=@(('host='+$HostN),('seen='+(Get-Date).ToString('yyyy-MM-dd HH:mm')),('epoch='+(Epoch)),('game='+(G -C $R rev-parse --short=8 HEAD)+' v'+(GameVer)),
    ('test_run='+$corpus),('robots='+$robots),('ram_free_gb='+$free),('push_ok='+(GetS 'push_ok')),('runner='+$SelfHash.Substring(0,8)))
  [IO.File]::WriteAllLines($StatusF,[string[]]$L,$Enc)
}

function Publish([string]$why){
  if(-not (Test-Path -LiteralPath ($Res+'\.git'))){ Say 'PROBLEM: the results copy is missing (run tools\spare\spare-setup.ps1 again)'; return }
  $dst=$Res+'\spare\'+$HostN; New-Item -ItemType Directory -Force -Path ($dst+'\corpus'),($dst+'\fuzz') | Out-Null
  Get-ChildItem -LiteralPath $CorpDir -Filter 'corpus-*.txt' | Sort-Object Name | Select-Object -Last 12 | ForEach-Object {
    if([IO.File]::ReadAllText($_.FullName) -match 'ALL DONE'){
      Copy-Item -LiteralPath $_.FullName -Destination ($dst+'\corpus\'+$_.Name) -Force
      if(Test-Path -LiteralPath ($_.FullName+'.head')){ Copy-Item -LiteralPath ($_.FullName+'.head') -Destination ($dst+'\corpus\'+$_.Name+'.head') -Force }
    }
  }
  if(Test-Path -LiteralPath ($FzOut+'\fuzz.log')){ Copy-Item -LiteralPath ($FzOut+'\fuzz.log') -Destination ($dst+'\fuzz\fuzz.log') -Force }
  Get-ChildItem -LiteralPath $FzOut -Filter 'fuzz-*.jsonl' | Where-Object { $_.LastWriteTime -gt (Get-Date).AddDays(-7) } |
    ForEach-Object { Copy-Item -LiteralPath $_.FullName -Destination ($dst+'\fuzz\'+$_.Name) -Force }
  Copy-Item -LiteralPath $StatusF -Destination ($dst+'\status.txt') -Force
  [void](G -C $Res add -A -f -- spare)
  [void](G -C $Res diff --cached --quiet)
  if($script:gx -eq 0){ return }
  [void](G -C $Res commit -q -m ('spare: '+$HostN+' '+$why+' '+(Stamp)))
  $o=G -C $Res push -q origin ('HEAD:refs/heads/'+$Branch)
  if($script:gx -ne 0){ PutS 'push_ok' '0'; Say ('PROBLEM: results push failed: '+(Short $o)) } else { PutS 'push_ok' '1'; PutS 'pub_t' ([string](Epoch)) }
}

while($true){
  [IO.File]::WriteAllText($Hb,[string](Epoch),$Enc)
  Ensure-Server
  $cr=Running 'corpq\.sh|corpus-slices\.sh'
  $why=''
  if($cr -eq 0){
    $cf=GetS 'corpus_file'
    if($cf -and (GetS 'corpus_done') -ne $cf -and (Test-Path -LiteralPath $cf)){
      PutS 'corpus_done' $cf
      if([IO.File]::ReadAllText($cf) -match 'ALL DONE'){ PutS 'tested_blob' (GetS 'corpus_blob'); Say ('full test run finished: '+(Split-Path $cf -Leaf)); $why='test run done' }
      else { Say ('full test run ended without finishing: '+(Split-Path $cf -Leaf)) }
    }
    if(Update-Game){
      if((Get-FileHash -LiteralPath $PSCommandPath -Algorithm SHA256).Hash -ne $SelfHash){
        if($why){ Write-Status 'idle' (Running 'fuzz\.ps1'); Publish $why }
        Say 'a new copy of this runner came from GitHub: restarting'
        Remove-Item -LiteralPath $Hb -Force -ErrorAction SilentlyContinue
        Start-Process -FilePath wscript.exe -ArgumentList ('"'+$T+'\spare\spare-start.vbs"') | Out-Null
        exit 0
      }
      Start-Corpus
    }
  }
  if((Running 'fuzz\.ps1.*-Port 9331(\s|$)') -eq 0){ Start-Robot 9331 'fixture-soak-spare1.html' }
  if((Running 'fuzz\.ps1.*-Port 9332(\s|$)') -eq 0){ Start-Robot 9332 'fixture-soak-spare2.html' }
  $cs='idle'; if((Running 'corpq\.sh|corpus-slices\.sh') -gt 0){ $cs='running '+(Split-Path (GetS 'corpus_file') -Leaf) }
  Write-Status $cs (Running 'fuzz\.ps1')
  $pt=[long]('0'+(GetS 'pub_t'))
  if($why -or ((Epoch)-$pt) -ge ($PublishMin*60)){ if(-not $why){ $why='update' }; Publish $why }
  if($Once){ break }
  Start-Sleep -Seconds 300
}
