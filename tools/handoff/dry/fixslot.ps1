$f = 'C:\claudecode\dark raiders\tools\handoff\p1032.ps1'
$t = [IO.File]::ReadAllText($f)
$old = "'\u25CC');   // v10.31"
$new = "'\u25CC');   // v10.21"
$c = ([regex]::Matches($t, [regex]::Escape($old))).Count
$t = $t.Replace($old, $new)
[IO.File]::WriteAllText($f, $t, (New-Object Text.UTF8Encoding $false))
Write-Output "replaced $c"
