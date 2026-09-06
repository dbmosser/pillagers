$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
# After renum1195: the first moved draft (1195, the pause note) quotes the
# header of the check before it, which is now the v11.94 wording check and
# not the name box; and the second-down draft (now 1208) anchors on the
# self-revive line that v11.94 rewords to "one per raid". Idempotent.
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
RepRx 'f1195.ps1' "  {v:'11.94',what:'ENTER in the title name box commits the name, and the start button commits whatever is typed there (2026-09-06 first-ten-minutes audit)'," "  {v:'11.94',what:'the Crier names itself when its alarm goes out, the Pillbox says destroyed when it dies, and the self-revive says one per raid (his three wording notes of 2026-09-06)'," 2
RepRx 'p1208.ps1' "You get one a raid." "You get one per raid." 3
RepRx 'd1208.txt' "get back up. You get one a raid." "get back up. You get one per raid." 1
RepRx 'd1208.txt' "spent. One a raid." "spent. One per raid." 1
