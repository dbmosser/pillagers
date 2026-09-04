$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\AUDIT.md'
$lines = [IO.File]::ReadAllLines($p)
# 0-based: 949 is the first v10.69 row, 951 the second. Keep the LATER one, so
# the table stays in ascending order after both v10.68 rows.
if ($lines[949] -notlike '*| v10.69 |*') { throw "line 950 is not a v10.69 row" }
if ($lines[951] -notlike '*| v10.69 |*') { throw "line 952 is not a v10.69 row" }
if ($lines[950] -notlike '*| v10.68 |*') { throw "line 951 is not a v10.68 row" }
$out = New-Object System.Collections.Generic.List[string]
for ($i = 0; $i -lt $lines.Count; $i++) { if ($i -eq 949) { continue }; $out.Add($lines[$i]) }
[IO.File]::WriteAllLines($p, $out, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, dropped the duplicate"
