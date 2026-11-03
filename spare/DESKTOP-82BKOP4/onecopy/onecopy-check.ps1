# Checks the one-copy guard: its real lines from the patched runner run in real processes, with a test name for the lock and for the script it may stop, and short waits. Touches no runner.
# Usage: onecopy-check.ps1 -File patched-runner.ps1 -Master master-runner.ps1 -Tmp folder
param([string]$File,[string]$Master,[string]$Tmp)
$wrong=0; $n=0
function Say-It($name,$ok){ $script:n++; if(-not $ok){ $script:wrong++ }; '{0,-66} {1}' -f $name,$(if($ok){ 'ok' }else{ 'WRONG' }) }
$lines=[IO.File]::ReadAllLines($File); $text=[IO.File]::ReadAllText($File); $m=[IO.File]::ReadAllLines($Master)
$e=$null; $t=$null; [void][Management.Automation.Language.Parser]::ParseInput($text,[ref]$t,[ref]$e); Say-It 'the runner parses in PowerShell 5.1' ($e.Count -eq 0)
Say-It 'the runner is ASCII' (-not ($text -cmatch '[^\x00-\x7F]'))
$a=[Array]::FindIndex($lines,[Predicate[string]]{ param($x) $x -ceq 'if(-not $Idle -and -not $Once){' }); $b=$a; while($b -lt $lines.Count -and $lines[$b] -cne '}'){ $b++ }
Say-It 'the guard is found' ($a -gt 0 -and $b -gt $a)
$first=$a-3; $rest=@(); for($i=0;$i -lt $lines.Count;$i++){ if($i -lt $first -or $i -gt $b){ $rest+=$lines[$i] } }
$same=$rest.Count -eq $m.Count; if($same){ for($i=0;$i -lt $m.Count;$i++){ if($m[$i] -cne $rest[$i]){ $same=$false; break } } }
Say-It 'taking out the guard gives master exactly: nothing else changed' $same
$say=[Array]::FindIndex($lines,[Predicate[string]]{ param($x) $x -cmatch '^function Say\(' }); $hb=[Array]::FindIndex($lines,[Predicate[string]]{ param($x) $x -cmatch '^function HbAgeSec\(' })
Say-It 'what the guard calls is defined above it' ($say -ge 0 -and $hb -ge 0 -and $say -lt $a -and $hb -lt $a)
$block=($lines[$a..$b] -join "`n").Replace('Global\PillagersSpareRunner','Local\PillagersOneCopyTest').Replace('WaitOne(60000)','WaitOne(4000)').Replace('spare-runner\.ps1','onecopy-t\.ps1')
Say-It 'the test really swapped the lock, the wait and the name' ($block -notmatch 'SpareRunner|60000|spare-runner')
New-Item -ItemType Directory -Force -Path $Tmp | Out-Null
$S=Join-Path $Tmp 'onecopy-t.ps1'; $Log=Join-Path $Tmp 'log.txt'
$src=@'
param([string]$Tag,[double]$HbSec=0,[switch]$Idle,[switch]$Once,[int]$Hold=600,[switch]$NoHb)
function Say([string]$s){ [IO.File]::AppendAllText($env:OC_LOG,$Tag+' SAY '+$s+"`r`n") }
function HbAgeSec(){ if($NoHb){ throw 'no heartbeat' }; return $HbSec }
'@+"`n"+$block+"`n"+@'
[IO.File]::AppendAllText($env:OC_LOG,$Tag+" RUNS`r`n")
$end=(Get-Date).AddSeconds($Hold); while((Get-Date) -lt $end){ Start-Sleep -Milliseconds 200 }
[IO.File]::AppendAllText($env:OC_LOG,$Tag+" ENDS`r`n")
'@
[IO.File]::WriteAllText($S,$src); $env:OC_LOG=$Log
function Go($tag,[string[]]$more=@()){ Start-Process powershell.exe -PassThru -WindowStyle Hidden -ArgumentList (@('-NoProfile','-ExecutionPolicy','Bypass','-File',('"'+$S+'"'),'-Tag',$tag)+$more) }
function Has($s){ try{ return ([IO.File]::ReadAllText($Log)) -cmatch $s }catch{ return $false } }
function WaitFor($s,$sec=40){ $e=(Get-Date).AddSeconds($sec); while((Get-Date) -lt $e){ if(Has $s){ return $true }; Start-Sleep -Milliseconds 200 }; return $false }
function WaitExit($p,$sec=40){ return $p.WaitForExit($sec*1000) }
function Reset(){ Get-CimInstance Win32_Process -Filter "Name='powershell.exe'" | Where-Object { $_.CommandLine -match 'onecopy-t\.ps1' } | ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }; Start-Sleep -Milliseconds 400; [IO.File]::WriteAllText($Log,'') }

Reset; $p1=Go 'A'; Say-It 'the first copy runs' (WaitFor 'A RUNS')
$p2=Go 'B' @('-HbSec','700'); Say-It 'a slow copy holds it (10+ min with no heartbeat): the new one leaves' (WaitExit $p2)
Say-It '  it never ran' (-not (Has 'B RUNS')); Say-It '  it says so' (Has 'B SAY another copy of this runner is alive, slow for 12 minutes'); Say-It '  the first is still alive' (-not $p1.HasExited)

$p3=Go 'C'; Start-Sleep -Milliseconds 300; Stop-Process -Id $p1.Id -Force; Say-It 'the holder dies with a copy waiting: that copy runs' (WaitFor 'C RUNS')
Reset; $p1=Go 'D'; [void](WaitFor 'D RUNS'); Stop-Process -Id $p1.Id -Force; [void]$p1.WaitForExit(5000); Start-Sleep -Milliseconds 300; $p2=Go 'E'; Say-It 'the last copy died earlier: the next one runs, not held out' (WaitFor 'E RUNS')

Reset; $p1=Go 'F' @('-Hold','1'); [void](WaitFor 'F RUNS'); $p2=Go 'G' @('-NoHb'); Say-It 'a restart: the old copy leaves itself (F ENDS), the new one gets it' ((WaitFor 'F ENDS') -and (WaitFor 'G RUNS'))

Reset; $p1=Go 'H'; [void](WaitFor 'H RUNS'); $p2=Go 'I' @('-HbSec','3700'); Say-It 'stuck (over an hour with no heartbeat): the new one ends it and runs' (WaitFor 'I RUNS'); Say-It '  the stuck copy is gone' ($p1.WaitForExit(10000)); Say-It '  it says so' (Has 'I SAY another copy of this runner has had no heartbeat for 62 minutes')

Reset; $p1=Go 'J'; [void](WaitFor 'J RUNS'); $p2=Go 'K' @('-HbSec','1e9'); Say-It 'a heartbeat from before this boot, a copy alive: it is starting, leave it' (WaitExit $p2); Say-It '  the new one never ran, the first is alive' ((-not (Has 'K RUNS')) -and (-not $p1.HasExited))

Reset; $p1=Go 'L' @('-Idle'); $p2=Go 'M' @('-Idle'); Say-It 'idle mode takes no lock: two copies both run, as today' ((WaitFor 'L RUNS') -and (WaitFor 'M RUNS'))
Reset; $p1=Go 'N'; [void](WaitFor 'N RUNS'); $p2=Go 'O' @('-Once'); Say-It 'a -Once run takes no lock and is not held out' (WaitFor 'O RUNS')
$p3=Go 'P' @('-HbSec','3700'); Say-It '  a stuck-copy clean-up leaves a -Once run alone' ((WaitFor 'P RUNS') -and (-not $p2.HasExited))

Reset; $ev=New-Object Threading.EventWaitHandle($false,[Threading.EventResetMode]::ManualReset,'Local\PillagersOneCopyTest'); $p1=Go 'Q'; $p2=Go 'R'; Say-It 'the lock cannot be opened: both run, as before the guard' ((WaitFor 'Q RUNS') -and (WaitFor 'R RUNS')); $ev.Dispose()

Reset; Remove-Item -LiteralPath $S,$Log -Force -ErrorAction SilentlyContinue; Remove-Item Env:OC_LOG -ErrorAction SilentlyContinue
"checks $n, wrong $wrong"; if($wrong){ 'RESULT FAIL' }else{ 'RESULT PASS' }
