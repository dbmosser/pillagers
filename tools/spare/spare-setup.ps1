# spare-setup.ps1 : makes his SPARE PC the Pillagers test and robot machine, once (2026-10-20, his answer "16gb ram, it can stay on and
# connected"). He runs it in a normal (not administrator) PowerShell window on the spare PC, from the game copy he cloned there:
#   powershell -ExecutionPolicy Bypass -File "C:\claudecode\dark raiders\tools\spare\spare-setup.ps1"            set up (safe to run again)
#   ... -Status                                                                                               what it is doing now
#   ... -Remove                                                                                               stop it and remove its task
# What it does: refuses on the main PC (JUL26) and the VM; checks Git, Node and Chrome are installed (prints the line to install each one
# that is missing); marks this game copy as the spare PC's (the .spare-pc file) and makes it refuse every push; makes the results copy
# C:\PillagersSpare\results on the spare-results branch, which may push only that branch; pushes a first note, which is when GitHub asks
# him to sign in once (in his browser); makes the task "Pillagers spare runner" (at sign-in and every 15 minutes, as him, no
# administrator) or, if Windows refuses that, a Startup shortcut; and starts tools\spare\spare-runner.ps1.
# It never runs a firewall, Defender, UAC, power-plan or Windows Update command, never asks for or stores a password or key itself (the
# GitHub sign-in is Git's own window), and never touches port 8802. ASCII only.
# 10-22 THE MAIN PC (his orders "When my main PC isn't being used, it should be used for testing too", "its resources shouldn't be idle",
# and his yes to it checking how long since he last touched the keyboard, mouse or a pad): on JUL26 the same setup makes a SEPARATE copy,
# C:\PillagersIdle\game (it clones it; his old C:\claudecode\dark raiders there is never touched), marked .idle-pc, with its results copy in
# C:\PillagersIdle\results and the task "Main PC idle tests" (no "Pillagers" in the name, so tools\migrate\host-stop.ps1 never matches it).
# The runner then tests only while he is away (tools\spare\spare-runner.ps1, IDLE MODE). One line on the main PC does it all:
#   git clone https://github.com/dbmosser/pillagers.git C:\PillagersIdle\game; powershell -ExecutionPolicy Bypass -File C:\PillagersIdle\game\tools\spare\spare-setup.ps1
param([switch]$Status,[switch]$Remove)
$ErrorActionPreference='Continue'
$Main=($env:COMPUTERNAME -eq 'JUL26')
if($Main){ $R='C:\PillagersIdle\game'; $W='C:\PillagersIdle'; $TaskName='Main PC idle tests'; $Mark='.idle-pc'; $Who='main PC idle tests' }
else { $R='C:\claudecode\dark raiders'; $W='C:\PillagersSpare'; $TaskName='Pillagers spare runner'; $Mark='.spare-pc'; $Who='spare PC' }
$Res=$W+'\results'
$Url='https://github.com/dbmosser/pillagers.git'; $Branch='spare-results'
$Vbs=$R+'\tools\spare\spare-start.vbs'; $Lnk=[Environment]::GetFolderPath('Startup')+'\'+$TaskName+'.lnk'
$Enc=New-Object Text.UTF8Encoding $false

function Say([string]$s){ Write-Host $s }
function Finish([bool]$ok,[string]$s){
  if($ok){ Write-Host ('DONE  '+$s) -ForegroundColor Green; exit 0 } else { Write-Host ('STOP  '+$s) -ForegroundColor Yellow; exit 1 }
}
function G(){ $o = & $script:Git @args 2>&1; $script:gx=$LASTEXITCODE; return (($o | ForEach-Object { "$_" }) -join "`n").Trim() }
function RunnerProcs(){
  @(Get-CimInstance Win32_Process -ErrorAction SilentlyContinue | Where-Object { $_.ProcessId -ne $PID -and $_.CommandLine -and (
    ($_.CommandLine -match 'spare-runner\.ps1') -or ($_.CommandLine -match 'spare\\serve\.mjs') -or ($_.CommandLine -match 'corpq\.sh|corpus-slices\.sh') -or
    ($_.CommandLine -match 'fuzz\.ps1.*-Port 933[12](\s|$)') -or ($_.Name -eq 'chrome.exe' -and $_.CommandLine -match 'remote-debugging-port=(9344|9331|9332)(\s|$)')) })
}

if($env:COMPUTERNAME -eq 'VM_Oct2026'){ Finish $false 'This is the VM, not a test PC. Nothing was changed.' }

if($Status){
  if(Test-Path -LiteralPath ($W+'\status.txt')){ Get-Content -LiteralPath ($W+'\status.txt') | ForEach-Object { Say ('  '+$_) } } else { Say '  no status yet' }
  $tk=Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
  Say ('  task: '+$(if($tk){ $tk.State }elseif(Test-Path -LiteralPath $Lnk){ 'Startup shortcut' }else{ 'none' }))
  Say ('  running parts: '+(RunnerProcs).Count)
  if(Test-Path -LiteralPath ($W+'\runner.log')){ Say '  last log lines:'; Get-Content -LiteralPath ($W+'\runner.log') -Tail 6 | ForEach-Object { Say ('    '+$_) } }
  exit 0
}

if($Remove){
  Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false -ErrorAction SilentlyContinue
  Remove-Item -LiteralPath $Lnk -Force -ErrorAction SilentlyContinue
  RunnerProcs | ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }
  Remove-Item -LiteralPath ($W+'\runner.heartbeat') -Force -ErrorAction SilentlyContinue
  Finish $true ('The '+$Who+' runner is stopped and will not start again. Its folders are kept ('+$W+').')
}

# 1 the programs it needs
$script:Git=(Get-Command git -ErrorAction SilentlyContinue).Source; if(-not $script:Git -and (Test-Path 'C:\Program Files\Git\cmd\git.exe')){ $script:Git='C:\Program Files\Git\cmd\git.exe' }
$node=(Get-Command node -ErrorAction SilentlyContinue).Source; if(-not $node -and (Test-Path 'C:\Program Files\nodejs\node.exe')){ $node='C:\Program Files\nodejs\node.exe' }
$miss=@()
if(-not $script:Git -or -not (Test-Path 'C:\Program Files\Git\bin\bash.exe')){ $miss+='winget install --id Git.Git -e' }
if(-not $node){ $miss+='winget install --id OpenJS.NodeJS.LTS -e' }
if(-not (Test-Path 'C:\Program Files\Google\Chrome\Application\chrome.exe')){ $miss+='winget install --id Google.Chrome -e' }
if($miss.Count){
  Say 'First install these. Paste each line, press Enter, wait for it to finish. Then close this window, open a new one and run this setup again:'
  $miss | ForEach-Object { Say ('  '+$_) }
  Finish $false 'some programs are missing'
}
Say '1. Git, Node and Chrome are installed.'

# 2 this game copy becomes the spare PC's (never pushes)
if($Main -and -not (Test-Path -LiteralPath $R)){ Say ('   making the main PC''s own test copy in '+$R+' (a few minutes)'); [void](G clone -q $Url $R) }
if(-not (Test-Path -LiteralPath ($R+'\.git'))){ Finish $false ('There is no game copy at '+$R+'. Run the clone line from the steps first.') }
$origin=G -C $R remote get-url origin
if($origin -notmatch '^https://github\.com/dbmosser/pillagers(\.git)?/?$'){ Finish $false ('The copy at '+$R+' is not the Pillagers GitHub copy ('+$origin+'). Nothing was changed.') }
if(-not (Test-Path -LiteralPath ($R+'\'+$Mark))){
  [void](G -C $R fetch -q origin master)
  $dirty=G -C $R status --porcelain --untracked-files=no
  $ahead=G -C $R log --oneline origin/master..HEAD
  if($dirty -or $ahead){ Finish $false ('The copy at '+$R+' has work of its own, so it may be someone''s working copy. Nothing was changed.') }
  [IO.File]::WriteAllText($R+'\'+$Mark,($Who+' game copy: '+$env:COMPUTERNAME+', set up '+(Get-Date).ToString('yyyy-MM-dd HH:mm')+"`n"),$Enc)
}
[IO.File]::WriteAllText($R+'\.git\hooks\pre-push',"#!/bin/sh`necho 'this test game copy never pushes (tools/spare/spare-runner.ps1)' >&2`nexit 1`n",$Enc)
Say ('2. The game copy is marked as the '+$Who+' copy and can never push.')

# 3 the results copy (spare-results only)
New-Item -ItemType Directory -Force -Path $Res | Out-Null
if(-not (Test-Path -LiteralPath ($Res+'\.git'))){ [void](G -C $Res init -q); [void](G -C $Res remote add origin $Url) }
[void](G -C $Res config core.autocrlf false); [void](G -C $Res config user.name 'Pillagers spare PC'); [void](G -C $Res config user.email 'spare-pc@pillagers.invalid')
$cur=G -C $Res rev-parse --abbrev-ref HEAD
if($cur -ne $Branch){
  $has=G -C $Res ls-remote --heads origin $Branch
  if($script:gx -ne 0){ Finish $false ('GitHub did not answer: '+$has) }
  if($has){ [void](G -C $Res fetch -q origin $Branch); [void](G -C $Res checkout -q -B $Branch FETCH_HEAD) }
  else { [void](G -C $Res symbolic-ref HEAD ('refs/heads/'+$Branch)) }   # a new, empty branch (the results never share history with the game)
}
[IO.File]::WriteAllText($Res+'\.git\hooks\pre-push',("#!/bin/sh`nwhile read lref lsha rref rsha; do`n  [ `"`$rref`" = `"refs/heads/$Branch`" ] || { echo 'the spare PC results copy pushes only $Branch' >&2; exit 1; }`ndone`nexit 0`n"),$Enc)
$d=$Res+'\spare\'+$env:COMPUTERNAME; New-Item -ItemType Directory -Force -Path $d | Out-Null
[IO.File]::WriteAllLines($d+'\status.txt',[string[]]@('host='+$env:COMPUTERNAME,'seen='+(Get-Date).ToString('yyyy-MM-dd HH:mm'),
  'epoch='+[DateTimeOffset]::UtcNow.ToUnixTimeSeconds(),'test_run=set up, the runner is starting','robots=0',('mode='+$(if($Main){ 'idle' }else{ 'full' }))),$Enc)
[void](G -C $Res add -A -f -- spare)
[void](G -C $Res diff --cached --quiet); if($script:gx -ne 0){ [void](G -C $Res commit -q -m ('spare: '+$env:COMPUTERNAME+' set up')) }
Say '3. Sending a first note to GitHub. If a GitHub sign-in window opens, sign in there and allow it.'
$o=G -C $Res push -q origin ('HEAD:refs/heads/'+$Branch)
if($script:gx -ne 0){ Finish $false ('GitHub did not take the note (the sign-in may not have finished). Run this setup again. ('+(($o -replace '\s+',' ').Trim())+')') }
Say '   GitHub took it.'

# 4 start at every sign-in and every 15 minutes
$how=''
try{
  $me=$env:USERDOMAIN+'\'+$env:USERNAME
  $a=New-ScheduledTaskAction -Execute 'wscript.exe' -Argument ('"'+$Vbs+'"')
  $t1=New-ScheduledTaskTrigger -AtLogOn -User $me
  $t2=New-ScheduledTaskTrigger -Once -At (Get-Date).AddMinutes(2) -RepetitionInterval (New-TimeSpan -Minutes 15)
  $s=New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -MultipleInstances IgnoreNew -ExecutionTimeLimit (New-TimeSpan -Seconds 0)
  $p=New-ScheduledTaskPrincipal -UserId $me -LogonType Interactive -RunLevel Limited
  Register-ScheduledTask -TaskName $TaskName -Action $a -Trigger $t1,$t2 -Settings $s -Principal $p -Force -ErrorAction Stop | Out-Null
  $how='a Windows task, at sign-in and every 15 minutes'
}catch{
  $sh=New-Object -ComObject WScript.Shell; $sc=$sh.CreateShortcut($Lnk); $sc.TargetPath='wscript.exe'; $sc.Arguments='"'+$Vbs+'"'; $sc.WindowStyle=7; $sc.Save()
  $how='a Startup shortcut, at sign-in (Windows would not make the task: '+(("$_" -replace '\s+',' ').Trim())+')'
}
Say ('4. It starts by itself: '+$how+'.')

# 5 start it now (unless a copy already runs) and wait for its first line
$ok=@(RunnerProcs | Where-Object { $_.CommandLine -match 'spare-runner\.ps1' }).Count -gt 0
if(-not $ok){
  Remove-Item -LiteralPath ($W+'\runner.heartbeat') -Force -ErrorAction SilentlyContinue   # no runner is alive, so an old heartbeat is stale
  $n0=0; if(Test-Path -LiteralPath ($W+'\runner.log')){ $n0=@(Get-Content -LiteralPath ($W+'\runner.log')).Count }
  Start-Process -FilePath wscript.exe -ArgumentList ('"'+$Vbs+'"') | Out-Null
  for($i=0;$i -lt 30;$i++){ Start-Sleep 2
    if((Test-Path -LiteralPath ($W+'\runner.log')) -and (@(Get-Content -LiteralPath ($W+'\runner.log') | Select-Object -Skip $n0) -match 'spare runner started')){ $ok=$true; break } }
}
if(-not $ok){ Finish $false 'The runner did not start. Run this setup again with -Status and send me what it says.' }
if($Main){ Finish $true 'The main PC now tests new builds whenever nobody has touched it for 15 minutes, and stops within seconds when you do.' }
Finish $true 'The spare PC now tests every new Pillagers build by itself. Leave it on and signed in; if it restarts, just sign in.'
