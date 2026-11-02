# gate-job.ps1 : ONE REMOTE GATE JOB on the spare PC (11-02, his order "use the JTPC for pillagers html testing"). spare-runner.ps1 starts it for
# a job the shipper put on the gate-jobs branch (tools/handoff/gate-remote.sh). It runs the Chrome stages of a ship from its own copy of the repo
# at the job's exact base commit, so a full test run or a robot in the runner's copy is left alone:
#   preflight: the build patch, the check patch, the free code checker, the parse check, the new check twice on the drafted build, the control
#              on the build before, the newest 80 older checks.
#   ship:      all of that (no code checker), then the drafted build as ship.sh start makes it: the seed 4242 fingerprint and the new check on it.
#   shots:     the pictures of the base build (tools/uishots.ps1).
# It decides nothing that counts: it writes what each stage printed, word for word, plus hashes of what it used, to result.txt. The shipper reads
# the same lines with the same tests as a local gate, and refuses a result that names anything but its own draft and base.
# It stops at the first stage that does not hold, as the local gate does. Anything that goes wrong outside a stage says infra=1 and result=FAIL.
# Its parts: Chrome 9347, camera 9348, test server 8823 (127.0.0.1 and ::1 only). Never 8802. Stopped with the other test parts when someone
# comes to the PC (spare-runner.ps1 Stop-Work); the runner then runs the job again from the start. ASCII only.
param([string]$Job,[string]$Copy='C:\PillagersSpare\gate\game',[string]$Main='C:\claudecode\dark raiders',[int]$Port=8823,[int]$Cdp=9347,[int]$Cam=9348)
$ErrorActionPreference='Continue'
if($env:COMPUTERNAME -eq 'JUL26' -or $env:COMPUTERNAME -eq 'VM_Oct2026'){ Write-Output 'refusing: gate jobs run on the spare PC only'; exit 2 }
$env:GATE_JOB='1'   # tools/uishots.ps1 takes its pictures here instead of sending them back to the spare PC
$Enc=New-Object Text.UTF8Encoding $false
$Git=(Get-Command git -ErrorAction SilentlyContinue).Source; if(-not $Git){ $Git='C:\Program Files\Git\cmd\git.exe' }
$Node=(Get-Command node -ErrorAction SilentlyContinue).Source; if(-not $Node){ $Node='C:\Program Files\nodejs\node.exe' }
$J=@{}; foreach($l in [IO.File]::ReadAllLines($Job+'\job.txt')){ $i=$l.IndexOf('='); if($i -gt 0){ $J[$l.Substring(0,$i)]=$l.Substring($i+1).Trim() } }
$kind=[string]$J['kind']; $tag=[string]$J['tag']; $V=[string]$J['v']; $base=[string]$J['base']
$Lines=New-Object Collections.ArrayList
$script:result='FAIL'; $script:reason=''; $script:infra=0; $script:gameSha=''; $script:fixSha=''; $script:draftSha=''; $script:pSha=''; $script:fSha=''; $script:headSeen=''
$t0=[DateTimeOffset]::UtcNow.ToUnixTimeSeconds()

function Stage([string]$s){ [IO.File]::WriteAllText($Job+'\stage.txt',$s,$Enc) }
function Add-Lines([object]$o){ foreach($x in @($o)){ if($null -ne $x){ $t=([string]$x).TrimEnd(); if($t.Length -gt 2000){ $t=$t.Substring(0,2000) }; [void]$Lines.Add($t) } } }
function G(){ $o = & $Git @args 2>&1; $script:gx=$LASTEXITCODE; return (($o | ForEach-Object { "$_" }) -join "`n").Trim() }
function Run-Ps([string]$file,[string[]]$a){ $o = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $file @a 2>&1; return @($o | ForEach-Object { "$_" }) }
# the same hash as gate-remote.sh: no carriage returns (git may give either line ending), and for the game no line with the build stamp, which
# ship.sh writes after the patch
function NH([string]$f,[switch]$Game){
  $l=[Text.Encoding]::GetEncoding(28591); $t=$l.GetString([IO.File]::ReadAllBytes($f)).Replace("`r",'')
  if($Game){ $t=[regex]::Replace($t,"(?m)^var (VER_AT|WHATSNEW_AT)='[^\n]*(\n|\z)",'') }
  $sha=[Security.Cryptography.SHA256]::Create(); $h=$sha.ComputeHash($l.GetBytes($t)); $sha.Dispose()
  return (-join ($h | ForEach-Object { $_.ToString('x2') }))
}
function Up([int]$p,[string]$f){ try{ $rq=[Net.WebRequest]::Create('http://127.0.0.1:'+$p+'/'+$f); $rq.Method='HEAD'; $rq.Timeout=4000; $rs=$rq.GetResponse(); $rs.Close(); return $true }catch{ return $false } }
function Fail-Stage([string]$why){ $script:result='FAIL'; $script:reason=$why }

function Get-Copy(){
  if(-not (Test-Path -LiteralPath ($Copy+'\.git'))){
    New-Item -ItemType Directory -Force -Path (Split-Path $Copy) | Out-Null
    [void](G -C $Main worktree prune); [void](G -C $Main fetch -q origin master)
    $o=G -C $Main worktree add -f --detach $Copy origin/master; if($script:gx -ne 0){ throw ('could not make the gate copy: '+$o) }
  }
  $o=G -C $Copy fetch -q origin master; if($script:gx -ne 0){ throw ('GitHub fetch failed: '+$o) }
  [void](G -C $Copy cat-file -e ($base+'^{commit}')); if($script:gx -ne 0){ throw ('base '+$base+' is not on GitHub master') }
  $o=G -C $Copy -c advice.detachedHead=false checkout -q -f --detach $base; if($script:gx -ne 0){ throw ('checkout failed: '+$o) }
  $script:headSeen=G -C $Copy rev-parse HEAD
  if($script:headSeen -ne $base){ throw ('the gate copy is at '+$script:headSeen+', not '+$base) }
}
function Ensure-Server(){
  if(Up $Port 'parsecheck.html'){ return }
  Start-Process -FilePath $Node -ArgumentList @(('"'+$Main+'\tools\spare\serve.mjs"'),'--root',('"'+$Copy+'\tools"'),'--port',[string]$Port) -WindowStyle Hidden | Out-Null
  for($i=0;$i -lt 15;$i++){ Start-Sleep 1; if(Up $Port 'parsecheck.html'){ return } }
  throw ('the test server on '+$Port+' did not start')
}
function Ensure-Chrome(){
  try{ Invoke-RestMethod ('http://127.0.0.1:'+$Cdp+'/json/version') -TimeoutSec 3 | Out-Null; return }catch{}
  [void](Run-Ps ($Main+'\tools\cdp.ps1') @('-Start','-Port',[string]$Cdp,'-Profile',($env:TEMP+'\pillagers-cdp'+$Cdp)))
  Start-Sleep 3
  try{ Invoke-RestMethod ('http://127.0.0.1:'+$Cdp+'/json/version') -TimeoutSec 5 | Out-Null }catch{ throw ('the gate Chrome on '+$Cdp+' did not start') }
}
function Run-Lint([string]$file){
  $ld=$Copy+'\tools\lint'
  if(-not (Test-Path -LiteralPath ($ld+'\node_modules'))){ Push-Location $ld; try{ & npm.cmd ci --no-audit --no-fund 2>&1 | Out-Null }finally{ Pop-Location } }
  $o=@(& $Node ($ld+'\lint.mjs') --file $file --gate 2>&1 | ForEach-Object { "$_" })
  Add-Lines ($o | Select-Object -First 8)
  return (@($o | Where-Object { $_ -match '^lint: PASS' }).Count -gt 0)
}

function Gate-Flow(){
  $pf=$Job+'\p.ps1'; $ff=$Job+'\f.ps1'; $df=$Job+'\draft.json'
  $script:pSha=NH $pf; $script:fSha=NH $ff; $script:draftSha=NH $df
  foreach($x in @(@('p_sha',$script:pSha),@('f_sha',$script:fSha),@('draft_sha',$script:draftSha))){ if($J[$x[0]] -ne $x[1]){ throw ('the job files do not match their record: '+$x[0]) } }
  Stage 'build'
  [IO.File]::Copy($pf,($Copy+'\tools\handoff\p'+$tag+'.ps1'),$true); [IO.File]::Copy($ff,($Copy+'\tools\handoff\f'+$tag+'.ps1'),$true)
  $dr=Run-Ps ($Main+'\tools\handoff\dryrun-pf.ps1') @('-Tag',$tag,'-Root',$Copy)
  Add-Lines ($dr | Where-Object { $_ -match ('^(p|f)'+[regex]::Escape($tag)+' -> ') } | ForEach-Object { if($_.Length -gt 400){ $_.Substring(0,400) }else{ $_ } })
  if(@($dr | Where-Object { $_ -match ('^p'+[regex]::Escape($tag)+' -> OK') }).Count -eq 0){ Fail-Stage 'the build patch did not apply'; return }
  if(@($dr | Where-Object { $_ -match ('^f'+[regex]::Escape($tag)+' -> OK') }).Count -eq 0){ Fail-Stage 'the check patch did not apply'; return }
  $sp=Join-Path $env:TEMP ('pillagers-dry\pf'+$tag)
  $script:gameSha=NH ($sp+'\dark_raiders.html') -Game; $script:fixSha=NH ($sp+'\mkfixture.ps1')
  if($J['game_sha'] -ne $script:gameSha){ Fail-Stage 'the drafted game here is not the drafted game on the shipper'; return }
  if($J['fix_sha'] -ne $script:fixSha){ Fail-Stage 'the drafted fixture here is not the drafted fixture on the shipper'; return }
  if(-not (Test-Path -LiteralPath ($Copy+'\tools\fxdry'+$tag+'.html')) -or -not (Test-Path -LiteralPath ($Copy+'\tools\fxctl'+$tag+'.html'))){ throw 'the test copies did not build' }
  if($kind -eq 'preflight'){ Stage 'code checker'; if(-not (Run-Lint ($sp+'\dark_raiders.html'))){ Fail-Stage 'code checker'; return } }
  Ensure-Server; Ensure-Chrome
  Stage 'gate'
  $gt=Run-Ps ($Main+'\tools\gate.ps1') @('-NN',$tag,'-V',$V,'-Cdp',[string]$Cdp,'-Port',[string]$Port); Add-Lines $gt
  if(@($gt | Where-Object { $_ -match '^parse: PASS' }).Count -eq 0){ Fail-Stage 'parse check'; return }
  if(@($gt | Where-Object { $_ -like ('dry fxdry'+$tag+' check '+$V+': PASS / PASS*') }).Count -eq 0){ Fail-Stage 'the new check does not pass twice on the drafted build'; return }
  $c=@($gt | Where-Object { $_ -like ('control fxctl'+$tag+' check '+$V+':*') })
  if($c.Count -eq 0){ Fail-Stage 'no control result'; return }
  if($c[0] -match ('check '+[regex]::Escape($V)+': (PASS|SKIP)') -or $c[0] -match 'NO CHECK|TIMEOUT'){ Fail-Stage 'the control did not fail'; return }
  Stage 'older checks'
  $rc=Run-Ps ($Main+'\tools\handoff\recent.ps1') @('-NN',$tag,'-Cdp',[string]$Cdp); Add-Lines $rc
  if(@($rc | Where-Object { $_ -match '^recent: 0 new' }).Count -eq 0){ Fail-Stage 'an older check fails on the drafted build'; return }
  if($kind -eq 'ship'){
    Stage 'fingerprint'
    # what ship.sh start makes: the patched build with its stamp, and its test copy under the name the gate opens
    $st=Run-Ps ($Main+'\tools\handoff\stamp-verat.ps1') @('-Game',($sp+'\dark_raiders.html'),'-Prev',($sp+'\base.html')); Add-Lines ($st | Select-Object -Last 1)
    Remove-Item -LiteralPath ($Copy+'\tools\fixture.html') -Force -ErrorAction SilentlyContinue
    $fxo=Run-Ps ($sp+'\mkfixture.ps1') @('-Src',($sp+'\dark_raiders.html'),'-Dst',($Copy+'\tools\fixture.html'))
    $fi=Get-Item -LiteralPath ($Copy+'\tools\fixture.html') -ErrorAction SilentlyContinue
    if(-not $fi -or $fi.Length -lt 5000000){ throw ('the shipped test copy did not build: '+(($fxo | Select-Object -Last 2) -join ' ')) }
    $fx=Run-Ps ($Main+'\tools\gate.ps1') @('-Fix','-V',$V,'-Cdp',[string]$Cdp,'-Port',[string]$Port); Add-Lines $fx
    if(@($fx | Where-Object { $_ -like ('fixture.html check '+$V+': PASS / PASS*') }).Count -eq 0){ Fail-Stage 'the new check fails on the shipped fixture'; return }
    if(@($fx | Where-Object { $_ -like '*"pass":true*' }).Count -eq 0){ Fail-Stage 'verifySafe did not pass'; return }
    if(@($fx | Where-Object { $_ -like '*"ents":{"0":85,"1":374}*' }).Count -eq 0){ Fail-Stage 'entity fingerprint moved'; return }
    if(@($fx | Where-Object { $_ -like '*"containers":{"0":165,"1":593}*' }).Count -eq 0){ Fail-Stage 'container fingerprint moved'; return }
  }
  $script:result='PASS'
}
function Shots-Flow(){
  Stage 'build'
  Remove-Item -LiteralPath ($Copy+'\tools\fixture.html') -Force -ErrorAction SilentlyContinue
  $fxo=Run-Ps ($Copy+'\tools\mkfixture.ps1') @('-Root',$Copy)
  $fi=Get-Item -LiteralPath ($Copy+'\tools\fixture.html') -ErrorAction SilentlyContinue
  if(-not $fi -or $fi.Length -lt 5000000){ throw ('the test copy did not build: '+(($fxo | Select-Object -Last 2) -join ' ')) }
  Ensure-Server
  Stage 'pictures'
  $rec=$Copy+'\tools\handoff\shots\ui-screens-js.json'; if(Test-Path -LiteralPath ($Job+'\recipes.json')){ $rec=$Job+'\recipes.json' }
  $a=@('-Screens',[string]$J['screens'],'-Res',[string]$J['res'],'-Out',($Job+'\shots'),'-Port',[string]$Cam,'-Url',('http://localhost:'+$Port+'/fixture.html'),'-Recipes',$rec)
  if($J['nolint'] -eq '1'){ $a+='-NoLint' }
  if(Test-Path -LiteralPath ($Job+'\lint.js')){ $a+='-LintJs'; $a+=($Job+'\lint.js') }
  if($J['lintopts']){ $a+='-LintOpts'; $a+=[string]$J['lintopts'] }
  Add-Lines (Run-Ps ($Main+'\tools\uishots.ps1') $a)
  if(-not (Test-Path -LiteralPath ($Job+'\shots\report.json'))){ Fail-Stage 'the pictures were not taken'; return }
  $script:result='PASS'
}

try{
  Stage 'copy'; Get-Copy
  if($kind -eq 'shots'){ Shots-Flow } elseif($kind -eq 'preflight' -or $kind -eq 'ship'){ Gate-Flow } else { throw ('unknown job kind '+$kind) }
}catch{ $script:result='FAIL'; $script:infra=1; $script:reason=([string]$_ -replace '\s+',' ') }
Stage 'closing'
try{ if($kind -ne 'shots'){ [void](Run-Ps ($Main+'\tools\cdp.ps1') @('-Close','-Port',[string]$Cdp)) } }catch{}
foreach($x in @(('tools\fxdry'+$tag+'.html'),('tools\fxctl'+$tag+'.html'),('tools\handoff\p'+$tag+'.ps1'),('tools\handoff\f'+$tag+'.ps1'))){ Remove-Item -LiteralPath ($Copy+'\'+$x) -Force -ErrorAction SilentlyContinue }
Remove-Item -Recurse -Force -LiteralPath (Join-Path $env:TEMP ('pillagers-dry\pf'+$tag)) -ErrorAction SilentlyContinue
$out=New-Object Collections.ArrayList
foreach($k in 'id','kind','key','tag','v','new'){ [void]$out.Add($k+'='+[string]$J[$k]) }
[void]$out.Add('base='+$script:headSeen); [void]$out.Add('host='+$env:COMPUTERNAME)
foreach($p in @(@('draft_sha',$script:draftSha),@('p_sha',$script:pSha),@('f_sha',$script:fSha),@('game_sha',$script:gameSha),@('fix_sha',$script:fixSha))){ [void]$out.Add($p[0]+'='+$p[1]) }
[void]$out.Add('started='+$t0); [void]$out.Add('ended='+[DateTimeOffset]::UtcNow.ToUnixTimeSeconds())
[void]$out.Add('result='+$script:result); [void]$out.Add('infra='+$script:infra); [void]$out.Add('reason='+$script:reason)
[void]$out.Add('--- stages'); foreach($l in $Lines){ [void]$out.Add($l) }; [void]$out.Add('--- end'); [void]$out.Add('done=1')
[IO.File]::WriteAllText($Job+'\result.tmp',(($out.ToArray() -join "`n")+"`n"),$Enc)
Move-Item -LiteralPath ($Job+'\result.tmp') -Destination ($Job+'\result.txt') -Force
exit 0
