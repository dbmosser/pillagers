# v11.54 follow-up, applied to the live game after ship.sh start had run p1154:
# a comment inside drawHUD (the v9.xx bag-close note) still names the old badge
# phrase, and check 11.54's control reads drawHUD's source for that phrase.
# The comment is reworded; p1154.ps1 carries the same edit.
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
$t = [IO.File]::ReadAllText($p)
$old = "// It clears the world's own EXTRACTION - OPEN badge as well, which sits at"
$new = "// It clears the world's own extraction point badge as well, which sits at"
$c = ([regex]::Matches($t, [regex]::Escape($old))).Count
if ($c -ne 1) { Write-Output "FAILED: matched $c"; exit 1 }
$t = $t.Replace($old, $new)
[IO.File]::WriteAllText($p, $t, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, 1 edit applied"
