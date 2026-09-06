$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
# The rest of the v11.80 record repair (a1180, the AUDIT row, cm1180); the
# p1180 SubRx block was already brought to what shipped by fixrec1180.ps1.
# Idempotent; line breaks match \r?\n.
$enc = New-Object Text.UTF8Encoding $false
function L { param([string[]]$lines) return ($lines -join "`n") }
function RepRx([string]$path, [string]$old, [string]$new, [int]$n) {
  $s = [IO.File]::ReadAllText($path)
  if ($s.IndexOf($new) -ge 0 -and $s.IndexOf($old) -lt 0) { Write-Output ($path + ': already repaired'); return }
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($s, $pat)).Count
  if ($c -ne $n) { throw ($path + ': anchor matched ' + $c + ' times, wanted ' + $n + ': ' + $old.Substring(0, [Math]::Min(60, $old.Length))) }
  $s = [regex]::Replace($s, $pat, { param($m) $new })
  [IO.File]::WriteAllText($path, $s, $enc)
  Write-Output ($path + ': repaired')
}
$H = 'C:\claudecode\dark raiders\tools\handoff\'
$oldA = 'A death arrives downed and writes 0, so only extractions hummed. Over an ended raid the bed is driven with threat 0, alive false, dread 0.'
$newA = 'A death ends the raid from the death-beat branch, which never reaches the bed drive, so only extractions hummed. Over an ended raid the bed is driven with threat 0, alive false, dread 0, and the 0.12 s cut is written again last.'
RepRx ($H + 'a1180.txt') $oldA $newA 1
RepRx 'C:\claudecode\dark raiders\AUDIT.md' $oldA $newA 1
RepRx ($H + 'cm1180.txt') (L @(
  'meaning not downed, true after an extraction, so the bed was written back',
  'up to its 0.16 floor after the cut and held that level on the Undercroft',
  'floor once the raid was dropped. A death arrives downed and writes 0, so',
  'only completed runs hummed. Over an ended raid the bed is now driven to',
  'silence.')) (L @(
  'meaning not downed, true after an extraction, so the bed was written back',
  'up to its 0.16 floor after the cut and held that level on the Undercroft',
  'floor once the raid was dropped. A death ends the raid from the death-beat',
  'branch, which never reaches the drive, so only completed runs hummed. Over',
  'an ended raid the bed is driven to silence and the cut is written again last.')) 1
