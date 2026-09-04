$SP = 'C:\claudecode\dark raiders\tools\handoff'
$nowLine = "  now:'v10.31: the Blotter melts. The frame pours downward in strips that sway and stretch on clocks rolled fresh with every dose, and the pouring comes and goes, so no two trips look alike.',"
$whatLine = "  {v:'10.31',what:'the Blotter melts the frame on clocks rolled with the dose, so two doses never warp alike and one dose never holds still',"
$f = Join-Path $SP 'p1032.ps1'; $lines = [IO.File]::ReadAllLines($f); $c = 0
for ($i = 0; $i -lt $lines.Length; $i++) { if ($lines[$i] -match "^  now:'v10\.31: a ninth rack: FACE") { $lines[$i] = $nowLine; $c++ } }
[IO.File]::WriteAllLines($f, $lines, (New-Object Text.UTF8Encoding $false)); Write-Output "p1032 now-line anchors fixed: $c"
$f = Join-Path $SP 'f1032.ps1'; $lines = [IO.File]::ReadAllLines($f); $c = 0
for ($i = 0; $i -lt $lines.Length; $i++) { if ($lines[$i] -match "^  \{v:'10\.31',what:'FACE is a ninth rack") { $lines[$i] = $whatLine; $c++ } }
[IO.File]::WriteAllLines($f, $lines, (New-Object Text.UTF8Encoding $false)); Write-Output "f1032 what-line anchors fixed: $c"
