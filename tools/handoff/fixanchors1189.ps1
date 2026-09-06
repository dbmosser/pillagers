$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
# After the two renumbers, two check anchors quoted the wrong neighbour: the
# f-file of a moved draft quotes the header line of the check before it, and
# a build inserted in between changes which check that is. And p1199 expected
# a WHATSNEW_VER bump that the first-ten-minutes builds before it do not all
# make. Idempotent.
$enc = New-Object Text.UTF8Encoding $false
function RepRx([string]$file, [string]$old, [string]$new, [int]$n) {
  $path = 'C:\claudecode\dark raiders\tools\handoff\' + $file
  $s = [IO.File]::ReadAllText($path)
  if ($s.IndexOf($new) -ge 0 -and $s.IndexOf($old) -lt 0) { Write-Output ($file + ': already repaired'); return }
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($s, $pat)).Count
  if ($c -ne $n) { throw ($file + ': anchor matched ' + $c + ' times, wanted ' + $n + ': ' + $old.Substring(0, [Math]::Min(60, $old.Length))) }
  $s = [regex]::Replace($s, $pat, { param($m) $new })
  [IO.File]::WriteAllText($path, $s, $enc)
  Write-Output ($file + ': repaired')
}
# f1189 (fulgurite) sits after the v11.88 conditions check, not the survivor one.
RepRx 'f1189.ps1' "  {v:'11.88',what:'a helped survivor walks to the nearest open extraction on his own instead of following you, and leaves when he reaches the ring (his note of 2026-09-06)'," "  {v:'11.88',what:'the raid conditions panel no longer prints the kill-nothing and three-minute contract verdicts, and still prints the no-heals one (his order of 2026-09-06)'," 2
# f1199 (character screen keys) sits after the v11.98 notes-line check, not the belt one.
RepRx 'f1199.ps1' "  {v:'11.98',what:'a belt key holding a gun from the backpack equips it into your hands, and a derived belt cell (Medical, plate, grenade) can be dragged to another key (his note of 2026-09-06)'," "  {v:'11.98',what:'the notes-logged line in the raid HUD is drawn below the corner credits and XP readout, not through it (2026-09-06 first-ten-minutes audit)'," 2
# p1199: the card version stands at 11.96 when it runs (11.97 and 11.98 add no card line).
RepRx 'p1199.ps1' "var WHATSNEW_VER='11.98';" "var WHATSNEW_VER='11.96';" 1
