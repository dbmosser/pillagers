# Checks the robot quiet rule against the real line from the patched runner, with only what the line calls stubbed. Starts no robot and touches nothing outside this script.
# Usage: quiet-check.ps1 -File patched-runner.ps1 -Master master-runner.ps1
param([string]$File,[string]$Master)
$wrong=0; $n=0
function Say-It($name,$ok){ $script:n++; if(-not $ok){ $script:wrong++ }; '{0,-58} {1}' -f $name,$(if($ok){ 'ok' }else{ 'WRONG' }) }
$lines=[IO.File]::ReadAllLines($File); $text=[IO.File]::ReadAllText($File)
$e=$null; $t=$null; [void][Management.Automation.Language.Parser]::ParseInput($text,[ref]$t,[ref]$e); Say-It 'the runner parses in PowerShell 5.1' ($e.Count -eq 0)
Say-It 'the runner is ASCII' (-not ($text -cmatch '[^\x00-\x7F]'))
$m=[IO.File]::ReadAllLines($Master); $changed=0; if($m.Count -eq $lines.Count){ for($i=0;$i -lt $m.Count;$i++){ if($m[$i] -cne $lines[$i]){ $changed++ } } }
Say-It 'same line count as master, exactly 5 lines differ' ($m.Count -eq $lines.Count -and $changed -eq 5)
Say-It 'the two places a gate job ends both mark it' (@($lines | Where-Object { $_ -cmatch "PutS 'gate_pid' ''; Gate-Yield \`$false; (\`$script:gateT=Epoch; )?\`$script:gateEnd=Epoch" }).Count -eq 2)
$l=@($lines | Where-Object { $_ -cmatch "Start-Robot 9331 'fixture-soak-spare1\.html'" }); Say-It 'one robot start line' ($l.Count -eq 1)
Say-It 'no other robot start uses it' (@($lines | Where-Object { $_ -cmatch 'RobotQuietSec' }).Count -eq 2)
# the else of if($Idle): the line must sit under it, so idle mode cannot reach it
$idx=[Array]::IndexOf($lines,$l[0]); $k=$idx; while($k -ge 0 -and $lines[$k] -cnotmatch '^  \} else \{'){ $k-- }; $j=$k; while($j -ge 0 -and $lines[$j] -cnotmatch '^  if\(\$Idle\)\{'){ $j-- }
Say-It 'the line is in the else of if($Idle)' ($k -ge 0 -and $j -ge 0 -and ($idx-$k) -le 2)
$code=[scriptblock]::Create($l[0].Trim())
$script:now=[long]1793700000; $script:started=0; $script:running=0; $script:gid=''; $script:hold=$false; $RobotQuietSec=[long](($lines | Where-Object { $_ -cmatch '\$RobotQuietSec=\d+' } | ForEach-Object { [regex]::Match($_,'\$RobotQuietSec=(\d+)').Groups[1].Value }))
function Epoch(){ return $script:now }
function Running($x){ return $script:running }
function GetS($x){ if($x -ceq 'gate_id'){ return $script:gid }; return '' }
function FocusHold(){ return $script:hold }
function Start-Robot($p,$c){ $script:started++ }
function Case($name,$ago,$run,$gid,$hold,$want){ $script:started=0; $script:running=$run; $script:gid=$gid; $script:hold=$hold; $script:gateEnd=$(if($ago -lt 0){ [long]0 }else{ $script:now-$ago }); & $code; Say-It $name ($script:started -eq $want) }
Say-It 'the quiet time is 300 s' ($RobotQuietSec -eq 300)
Case 'a fresh runner, no gate job yet: starts' ([int]-1) 0 '' $false 1
Case 'a gate job ended 10 s ago: waits' 10 0 '' $false 0
Case 'ended 299 s ago: waits' 299 0 '' $false 0
Case 'ended 300 s ago: starts' 300 0 '' $false 1
Case 'ended an hour ago: starts' 3600 0 '' $false 1
Case 'a gate job is running, the last ended long ago: waits' 3600 0 'x' $false 0
Case 'a robot is already running: no second one' 3600 1 '' $false 0
Case 'someone at the PC (the hold): waits' 3600 0 '' $true 0
"checks $n, wrong $wrong"; if($wrong){ 'RESULT FAIL' }else{ 'RESULT PASS' }
