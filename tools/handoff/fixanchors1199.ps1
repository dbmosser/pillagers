$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
# After renum1196 (+4): f1198 carried a placeholder for the v11.97 header,
# and the first moved draft (1199, the pause note) quotes the header of the
# check before it, which is now the v11.98 extraction check. Idempotent.
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
$h97 = "  {v:'11.97',what:'with the backpack closed, the gun in your hands drags off its belt cell into the backpack when released off the belt, and a key holding a gun drags to another key like any item (his notes of 2026-09-06)',"
$h98 = "  {v:'11.98',what:'a boarding hold that began before the window shut still extracts while E is held, and the ship can be called from the edge of the ring (his orders of 2026-09-06)',"
RepRx 'f1198.ps1' "  {v:'11.97',what:'PLACEHOLDER_1197_WHAT'," $h97 2
RepRx 'f1199.ps1' "  {v:'11.98',what:'the Crier names itself when its alarm goes out, the Pillbox says destroyed when it dies, and the self-revive says one per raid (his three wording notes of 2026-09-06)'," $h98 2
