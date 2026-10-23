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
# 10-22 IDLE MODE (his orders "When my main PC isn't being used, it should be used for testing too" and "its resources shouldn't be idle"):
# on the MAIN PC (JUL26) this runner works from its own copy, C:\PillagersIdle\game, never his old C:\claudecode\dark raiders there. It
# starts nothing until no key, mouse or game pad has been used for 15 minutes and 6 GB are free; it stops everything it started within
# seconds of a touch (or under 4 GB free); and a build another PC is testing or has tested stays that PC's: here it gets robots only.
# The VM's nights come first: from 22:40 to 23:10 it holds nothing, and until 06:45 it starts only with 10 GB free (see VMNight below).
param([switch]$Once,[int]$FuzzMinutes=60,[int]$PublishMin=30)
$ErrorActionPreference='Continue'
$Idle=($env:COMPUTERNAME -eq 'JUL26')
if($Idle){ $R='C:\PillagersIdle\game'; $W='C:\PillagersIdle' } else { $R='C:\claudecode\dark raiders'; $W='C:\PillagersSpare' }
$T=$R+'\tools'
$Res=$W+'\results'; $Out=$W+'\out'; $FzOut=$Out+'\fuzz'; $CorpDir=$Out+'\corpus'
$Log=$W+'\runner.log'; $StateF=$W+'\state.txt'; $Hb=$W+'\runner.heartbeat'; $StatusF=$W+'\status.txt'
$Bash='C:\Program Files\Git\bin\bash.exe'; $Branch='spare-results'; $HostN=$env:COMPUTERNAME
$Enc=New-Object Text.UTF8Encoding $false

if($HostN -eq 'VM_Oct2026'){ Write-Output 'refusing: this is the VM, not a test PC'; exit 2 }
$Mark=$(if($Idle){ '.idle-pc' }else{ '.spare-pc' })
if(-not (Test-Path -LiteralPath ($R+'\'+$Mark))){ Write-Output ('refusing: no '+$Mark+' marker (run tools\spare\spare-setup.ps1 first)'); exit 2 }
# the test scripts (corpq.sh, corpus-slices.sh, fuzz.ps1) take their folders from these; unset, they use the spare PC's paths as before
if($Idle){ $env:PILLAGERS_ROOT=($R -replace '\\','/'); $env:PILLAGERS_SCRATCH=(($W+'\scratch') -replace '\\','/'); New-Item -ItemType Directory -Force -Path ($W+'\scratch') | Out-Null }
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

# keep the PC awake while this runs (ES_CONTINUOUS | ES_SYSTEM_REQUIRED); it ends with this process. Not on the main PC: that is his.
if(-not $Idle){ try{
  Add-Type -Namespace PillagersSpare -Name Power -MemberDefinition '[DllImport("kernel32.dll")] public static extern uint SetThreadExecutionState(uint f);' -ErrorAction Stop
  [void][PillagersSpare.Power]::SetThreadExecutionState([uint32]2147483649)
}catch{ Say ('could not ask Windows to stay awake: '+(Short "$_")) } }

# IDLE MODE: is he here? (his yes of 10-22: it may check how long since he last touched the keyboard, mouse or a pad, only to know whether
# he is away, and stop its own tests when he is back.) It reads the time since the last key or mouse input (GetLastInputInfo) and, for
# pads, whether a button, trigger or stick is past its rest zone at a check (XInput pads 1 to 4; a pad does not move the Windows idle clock
# and the party plays on pads). It records nothing of what was pressed.
$script:padT=Get-Date; $script:working=$false
if($Idle){
  try{ Add-Type -Namespace PillagersIdle -Name Input -ErrorAction Stop -MemberDefinition @'
[StructLayout(LayoutKind.Sequential)] public struct LII { public uint cbSize; public uint dwTime; }
[DllImport("user32.dll")] static extern bool GetLastInputInfo(ref LII p);
[DllImport("xinput1_4.dll")] static extern uint XInputGetState(uint i, byte[] s);
public static double IdleSec(){ LII p = new LII(); p.cbSize = 8; if (!GetLastInputInfo(ref p)) return 0; return unchecked((uint)Environment.TickCount - p.dwTime) / 1000.0; }
public static bool PadInUse(){
  byte[] s = new byte[16];
  for (uint i = 0; i < 4; i++) {
    try { if (XInputGetState(i, s) != 0) continue; } catch { return false; }
    if (BitConverter.ToUInt16(s, 4) != 0 || s[6] > 30 || s[7] > 30) return true;
    for (int k = 8; k < 16; k += 2) { if (Math.Abs((int)BitConverter.ToInt16(s, k)) > 8000) return true; }
  }
  return false;
}
'@ }catch{ Say ('PROBLEM: cannot tell whether he is at the PC, so nothing runs: '+(Short "$_")); exit 1 }
}
function AwaySec(){ if([PillagersIdle.Input]::PadInUse()){ $script:padT=Get-Date }; return [Math]::Min([PillagersIdle.Input]::IdleSec(),((Get-Date)-$script:padT).TotalSeconds) }
function FreeGB(){ $os=Get-CimInstance Win32_OperatingSystem -ErrorAction SilentlyContinue; if(-not $os){ return 0 }; return [Math]::Min($os.FreePhysicalMemory,$os.FreeVirtualMemory)/1MB }
# 10-22 the VM's nights: the main PC's "VM night memory up" task (tools/migrate/host-night-memory.ps1) lends the VM up to 6 GB more at 23:00,
# sized once from what is free right then, and takes it back from 06:00. Measured 10-20 and 10-21: 12.1 and 12.5 GB free at 23:00, VM 10 -> 16.
# So from 22:40 to 23:10 this runner frees what it holds and starts nothing, and until 06:45 it starts only with 10 GB free (the VM did not
# take its share). Once working it goes on down to 4 GB free, the margin that task keeps for this PC.
function HourMin(){ return [int](Get-Date).ToString('HHmm') }
function VMResizeSoon(){ $hm=HourMin; return ($hm -ge 2240 -and $hm -lt 2310) }
function VMNight(){ $hm=HourMin; return ($hm -ge 2240 -or $hm -lt 645) }
# ends only what this runner started: the test scripts run from C:\PillagersIdle, and the test Chromes (debug port and pillagers-cdp profile)
function Stop-Work([string]$why){
  $n=0
  Get-CimInstance Win32_Process -ErrorAction SilentlyContinue | Where-Object { $_.ProcessId -ne $PID -and $_.CommandLine -and (
    ($_.CommandLine -match 'PillagersIdle' -and $_.CommandLine -match 'fuzz\.ps1|corpq\.sh|corpus-slices\.sh') -or
    ($_.Name -eq 'chrome.exe' -and $_.CommandLine -match 'remote-debugging-port=(9344|9331|9332)(\s|$)' -and $_.CommandLine -match 'pillagers-cdp')) } |
    ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue; $n++ }
  $script:working=$false
  if($n){ Say ('stopped '+$n+' test parts ('+$why+')') }
}
# the test scripts this runner's copies started (the same match Stop-Work uses)
function IdleWork(){
  @(Get-CimInstance Win32_Process -ErrorAction SilentlyContinue | Where-Object { $_.ProcessId -ne $PID -and $_.CommandLine -and
    $_.CommandLine -match 'PillagersIdle' -and $_.CommandLine -match 'fuzz\.ps1|corpq\.sh|corpus-slices\.sh' }).Count
}
# the wait between rounds, looking for him every 5 seconds
function Watch([int]$sec){
  $end=(Get-Date).AddSeconds($sec); $k=0
  while((Get-Date) -lt $end){
    Start-Sleep -Seconds 5; $k++
    if((AwaySec) -lt 30){ Stop-Work 'he is back at the PC'; return }
    if(($k % 6) -eq 0){
      if((FreeGB) -lt 4){ Stop-Work 'under 4 GB free'; return }
      if(VMResizeSoon){ Stop-Work 'the VM takes its night memory at 23:00'; return }
    }
  }
}

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

function Build-Fixture(){
  $t0=Get-Date
  $fx=& powershell.exe -NoProfile -ExecutionPolicy Bypass -File ($T+'\mkfixture.ps1') -Root $R 2>&1 | Select-Object -Last 2
  $fi=Get-Item -LiteralPath ($T+'\fixture.html') -ErrorAction SilentlyContinue
  if(-not $fi -or $fi.LastWriteTime -lt $t0 -or $fi.Length -lt 5000000){ Say ('PROBLEM: the test copy did not build: '+(Short ($fx -join ' '))); return $false }
  return $true
}

# IDLE MODE: is this commit already another PC's? Its status says it is testing it now (seen under 3 hours ago), or it sent a finished run of it.
function OtherPC([string]$head){
  [void](G -C $Res fetch -q origin $Branch); if($script:gx -ne 0){ return '' }
  foreach($f in ((G -C $Res ls-tree -r --name-only FETCH_HEAD -- spare) -split "`n")){
    if($f -notmatch '^spare/([A-Za-z0-9_.-]+)/(.+)$' -or $Matches[1] -eq $HostN){ continue }
    $h=$Matches[1]; $p=$Matches[2]
    if($p -eq 'status.txt'){
      $t=G -C $Res show ('FETCH_HEAD:'+$f)
      if($t -match ('(?m)^game='+$head.Substring(0,8)) -and $t -match '(?m)^test_run=running' -and $t -match '(?m)^epoch=(\d+)' -and ((Epoch)-[long]$Matches[1]) -lt 10800){ return ('being tested on '+$h) }
    } elseif($p -match '^corpus/corpus-\d{4}-\d{4}\.txt\.head$'){
      if((G -C $Res show ('FETCH_HEAD:'+$f)).StartsWith($head)){ return ('already tested on '+$h) }
    }
  }
  return ''
}

function Start-Corpus(){
  $blob=G -C $R rev-parse 'HEAD:dark_raiders.html'; $head=G -C $R rev-parse HEAD
  if(-not $blob -or $blob -eq (GetS 'tested_blob')){ return }
  if($Idle){
    if((GetS 'skip_blob') -eq $blob){ return }
    $who=OtherPC $head
    if($who){
      PutS 'skip_blob' $blob; Say ('build '+$head.Substring(0,8)+' (v'+(GameVer)+') is '+$who+': robots only here')
      if((GetS 'fx_blob') -ne $blob -and (Build-Fixture)){ Copy-Item -LiteralPath ($T+'\fixture.html') -Destination ($T+'\fxcorpus.html') -Force; PutS 'fx_blob' $blob }
      return
    }
    # 10-22 review: a full run takes 2.5 to 3.5 hours (corpq.sh), so one started after 19:10 is stopped at 22:40 and spends one of the
    # build's two tries. The robots get the build now; the full run waits for the morning (tries untouched).
    $hm=HourMin
    if($hm -ge 1910 -and $hm -lt 2240){
      if((GetS 'fx_blob') -ne $blob -and (Build-Fixture)){ Copy-Item -LiteralPath ($T+'\fixture.html') -Destination ($T+'\fxcorpus.html') -Force; PutS 'fx_blob' $blob; Say ('build '+$head.Substring(0,8)+' (v'+(GameVer)+'): robots only until the morning, a full run would not end before 22:40') }
      return
    }
    # 10-22 12:03: the first full run here (with two robots) took this PC from 8.4 GB free to under 4 within a minute and was stopped,
    # spending a try. By day this PC has about 8 to 9 GB free while he is away (the VM holds 10), so a full run starts only with 10 GB free;
    # otherwise the robots get the build and no try is spent.
    if((FreeGB) -lt 10){
      if((GetS 'fx_blob') -ne $blob -and (Build-Fixture)){ Copy-Item -LiteralPath ($T+'\fixture.html') -Destination ($T+'\fxcorpus.html') -Force; PutS 'fx_blob' $blob; Say ('build '+$head.Substring(0,8)+' (v'+(GameVer)+'): robots only, a full run needs 10 GB free here') }
      return
    }
  }
  $tries=0; if((GetS 'try_blob') -eq $blob){ $tries=[int]('0'+(GetS 'tries')) }
  if($tries -ge 2){ return }   # this build failed twice to give a full run; wait for the next one
  PutS 'try_blob' $blob; PutS 'tries' ([string]($tries+1))
  if(-not (Build-Fixture)){ return }
  PutS 'fx_blob' $blob   # corpq.sh copies this test copy to fxcorpus.html, which the robots play
  $name='corpus-'+(Get-Date -Format 'MMdd-HHmm')+'.txt'; $outF=$CorpDir+'\'+$name
  [IO.File]::WriteAllText($outF+'.head',$head+"`n",$Enc)
  Start-Process -FilePath $Bash -ArgumentList @('tools/handoff/shipkit/corpq.sh',('"'+($outF -replace '\\','/')+'"')) -WorkingDirectory $R -WindowStyle Hidden | Out-Null
  PutS 'corpus_file' $outF; PutS 'corpus_blob' $blob; PutS 'corpus_t' ([string](Epoch))
  Say ('full test run started on '+$head.Substring(0,8)+' (v'+(GameVer)+') -> '+$name)
}

function Start-Robot([int]$port,[string]$copy,[string]$size=''){
  if(-not (Test-Path -LiteralPath ($T+'\fxcorpus.html'))){ return }
  $env:FUZZ_OUT_DIR=$FzOut; $env:FUZZ_COPY_NAME=$copy
  Start-Process -FilePath powershell.exe -WindowStyle Hidden -ArgumentList @('-NoProfile','-ExecutionPolicy','Bypass','-WindowStyle','Hidden',
    '-File',('"'+$T+'\fuzz.ps1"'),'-Minutes',[string]$FuzzMinutes,'-IgnoreFlag','-Port',[string]$port,'-MinFreeGB',$(if($Idle){ '3' }else{ '2' }),'-Fixture','fxcorpus.html',$(if($size){ '-Size' }else{ '-P2Share' }),$(if($size){ $size }else{ '75' })) | Out-Null
  Remove-Item Env:FUZZ_OUT_DIR,Env:FUZZ_COPY_NAME -ErrorAction SilentlyContinue
  Say ('robot started on '+$port+$(if($size){ ' at '+$size }else{ '' }))
}

# 10-22 his "All this work and you can't tell what it's doing?!": the spare PC went quiet at 09:27 and the VM (behind the main PC's private
# switch) cannot see the home network. The main PC can, so in idle mode its status also says whether the spare PC is on: its name, then a
# ping, then two ports, then whether it answered the network's address lookup (ARP, which its firewall cannot block). At most every 10 minutes.
function SparePC([string]$n='DESKTOP-82BKOP4'){
  if($script:spT -and ((Get-Date)-$script:spT).TotalSeconds -lt 600){ return $script:spV }
  $script:spT=Get-Date; $ip=''
  try { $ip=@([Net.Dns]::GetHostAddresses($n) | Where-Object { $_.AddressFamily -eq 'InterNetwork' })[0].IPAddressToString } catch { }
  if(-not $ip){ $script:spV='off or offline (its name is not on the network), '+(Get-Date).ToString('HH:mm'); return $script:spV }
  $v=''
  if(Test-Connection -ComputerName $ip -Count 1 -Quiet -ErrorAction SilentlyContinue){ $v='on ('+$ip+' answers a ping)' }
  if(-not $v){ foreach($port in 445,135){ $c=New-Object Net.Sockets.TcpClient; try { if($c.ConnectAsync($ip,$port).Wait(1500) -and $c.Connected){ $v='on ('+$ip+' port '+$port+')'; break } } catch { } finally { $c.Dispose() } } }
  if(-not $v -and @(Get-NetNeighbor -IPAddress $ip -ErrorAction SilentlyContinue | Where-Object { [string]$_.State -eq 'Reachable' }).Count){ $v='on ('+$ip+' is on the network but answers nothing else)' }
  if(-not $v){ $v='not answering ('+$ip+')' }
  $script:spV=$v+', '+(Get-Date).ToString('HH:mm'); return $script:spV
}
function Write-Status([string]$corpus,[int]$robots){
  $os=Get-CimInstance Win32_OperatingSystem -ErrorAction SilentlyContinue
  $free=if($os){ [math]::Round($os.FreePhysicalMemory/1MB,1) }else{ '?' }
  # 10-21: each pair in its own brackets. PowerShell's comma binds before +, so the old list was ONE string joined with spaces and the
  # VM's import never found epoch= (it read the spare PC as never seen).
  $L=@(('host='+$HostN),('seen='+(Get-Date).ToString('yyyy-MM-dd HH:mm')),('epoch='+(Epoch)),('game='+(G -C $R rev-parse --short=8 HEAD)+' v'+(GameVer)),
    ('test_run='+$corpus),('robots='+$robots),('ram_free_gb='+$free),('push_ok='+(GetS 'push_ok')),('runner='+$SelfHash.Substring(0,8)),('mode='+$(if($Idle){ 'idle' }else{ 'full' })))
  if($Idle){ $L+=('spare_pc='+(SparePC)) }
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
  # 10-22: two PCs push here now (the spare PC and the main PC's idle runs), each into its own folder, so a refused push is usually the
  # other PC's newer note: take it in with a plain merge (never a rebase or a force) and push once more.
  for($k=0;$k -lt 2;$k++){
    $o=G -C $Res push -q origin ('HEAD:refs/heads/'+$Branch)
    if($script:gx -eq 0 -or $k -eq 1){ break }
    [void](G -C $Res fetch -q origin $Branch)
    $m=G -C $Res merge -q --no-edit FETCH_HEAD
    if($script:gx -ne 0){ [void](G -C $Res merge --abort); $o=$o+' / merge: '+$m; break }
  }
  if($script:gx -ne 0){ PutS 'push_ok' '0'; Say ('PROBLEM: results push failed: '+(Short $o)) } else { PutS 'push_ok' '1'; PutS 'pub_t' ([string](Epoch)) }
}

# 10-22 review: a copy that restarted itself for a new runner from GitHub left its robots (or a test run) going; this copy looks after them,
# so his return, the 4 GB floor and the 22:40 hold still stop them
if($Idle -and (IdleWork) -gt 0){ $script:working=$true; Say 'an earlier copy left test work running: this copy looks after it now' }
while($true){
  [IO.File]::WriteAllText($Hb,[string](Epoch),$Enc)
  if($Idle){
    # IDLE MODE: while he is at the PC (or memory is short) nothing runs; a look every 20 seconds, a status note when that changes
    $away=AwaySec; $fg=FreeGB; $vmn=VMNight
    $ng=$(if(VMResizeSoon){ 999 }elseif($script:working){ 4 }elseif($vmn){ 10 }else{ 6 })
    if($away -lt 900 -or $fg -lt $ng){
      $pw=$(if($away -lt 900){ 'paused: he is using the PC' }elseif($vmn){ 'paused: the VM has the memory at night' }else{ 'paused: under 6 GB free' })
      if($script:working){ Stop-Work $pw }
      $pt=[long]('0'+(GetS 'pub_t'))
      if((GetS 'pause_why') -ne $pw -or ((Epoch)-$pt) -ge ($PublishMin*60)){
        if((GetS 'pause_why') -ne $pw){ PutS 'pause_why' $pw; Say $pw }
        Write-Status $pw 0; Publish 'paused'
      }
      if($Once){ break }
      Start-Sleep -Seconds 20; continue
    }
    if((GetS 'pause_why')){ PutS 'pause_why' ''; Say ('he has been away '+[int]($away/60)+' minutes and '+[Math]::Round($fg,1)+' GB are free: testing') }
    $script:working=$true
  }
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
  # 10-22, his "No we might as well get rolling on it": on the main PC (the party PC, two 4K screens) the second robot plays at 4K, both windows
  # of a 2-player raid included, so its log carries the game's own frame times at the party size (fuzz.ps1 -Size; read by spare-import.mjs).
  if((Running 'fuzz\.ps1.*-Port 9332(\s|$)') -eq 0){ Start-Robot 9332 'fixture-soak-spare2.html' $(if($Idle){ '3840x2160' }else{ '' }) }
  $cs='idle'; if((Running 'corpq\.sh|corpus-slices\.sh') -gt 0){ $cs='running '+(Split-Path (GetS 'corpus_file') -Leaf) }
  Write-Status $cs (Running 'fuzz\.ps1')
  $pt=[long]('0'+(GetS 'pub_t'))
  if($why -or ((Epoch)-$pt) -ge ($PublishMin*60)){ if(-not $why){ $why='update' }; Publish $why }
  if($Once){ break }
  if($Idle){ Watch 300 } else { Start-Sleep -Seconds 300 }
}
