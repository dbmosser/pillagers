$f = 'C:\claudecode\dark raiders\tools\handoff\f1022.ps1'
$real = @'
  {v:'10.21',what:'FACE is a ninth rack: six faces drawn on the sprite and the figure, with a swatch, and the pillagers wear them',
'@
$t = [IO.File]::ReadAllText($f)
$wrong = "  {v:'10.21',what:'FACE is a ninth rack: six faces drawn on the sprite and the figure, with a slot and a swatch',"
$c = ([regex]::Matches($t, [regex]::Escape($wrong))).Count
$t = $t.Replace($wrong, $real.TrimEnd())
[IO.File]::WriteAllText($f, $t, (New-Object Text.UTF8Encoding $false))
Write-Output "anchor replaced $c times"
