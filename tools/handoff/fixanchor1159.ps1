# renumberHUD.ps1 bumped the version inside f1159's INSERTION ANCHOR, so it now
# names a check that will never exist: "11.58" paired with the LIGHTNING
# INCOMING what-line, which is really 11.57. f1159 inserts its check before the
# entry for the build immediately ahead of it, and after 1158 ships that entry
# is the Undercroft HUD check. Point the anchor at that.
$f = 'C:\claudecode\dark raiders\tools\handoff\f1159.ps1'
$old = "  {v:'11.58',what:'the storm warning ring says LIGHTNING INCOMING with the seconds left, and the world draw puts it at the circle (his note of 2026-09-05)',"
$new = "  {v:'11.58',what:'the Undercroft floor HUD survives the frame it is painted in: the heading and the station prompt are on the HUD canvas after real frames, and the belt is still drawn under them',"
$t = [IO.File]::ReadAllText($f)
$c = ([regex]::Matches($t, [regex]::Escape($old))).Count
if ($c -ne 2) { Write-Output "FAILED: anchor matched $c times, expected 2"; exit 1 }
$t = $t.Replace($old, $new)
[IO.File]::WriteAllText($f, $t, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, anchor repointed at the v11.58 HUD check ($c occurrences)"
