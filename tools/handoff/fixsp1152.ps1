# v11.52 follow-up, applied to the live game after ship.sh start had run p1152:
# the readout's number ran straight into its label in the element's text
# ("98,761XP"), which is bad copy text and tripped the label test in check
# 11.52. Spaces between figure and label; p1152.ps1 carries the same line.
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
$t = [IO.File]::ReadAllText($p)
$old = "  el.innerHTML=c+'<small>CREDITS</small>'+x+'<small>XP</small>';"
$new = "  el.innerHTML=c+' <small>CREDITS</small> '+x+' <small>XP</small>';   // spaces, so the text reads right when copied"
$c = ([regex]::Matches($t, [regex]::Escape($old))).Count
if ($c -ne 1) { Write-Output "FAILED: matched $c"; exit 1 }
$t = $t.Replace($old, $new)
[IO.File]::WriteAllText($p, $t, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, 1 edit applied"
