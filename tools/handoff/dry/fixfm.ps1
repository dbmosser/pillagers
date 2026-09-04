$f = 'C:\claudecode\dark raiders\tools\handoff\p1032.ps1'
$t = [IO.File]::ReadAllText($f)
$old = "v10.31: faceMark, because"
$new = "v10.21: faceMark, because"
$c = ([regex]::Matches($t, [regex]::Escape($old))).Count
$t = $t.Replace($old, $new)
[IO.File]::WriteAllText($f, $t, (New-Object Text.UTF8Encoding $false))
Write-Output "replaced $c"
$rest = [regex]::Matches($t, "10\.31")
Write-Output ("remaining 10.31 mentions: " + $rest.Count)
