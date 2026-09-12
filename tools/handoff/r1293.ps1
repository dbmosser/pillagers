$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# MY SLIP, CAUGHT BY CHECK 12.48. The v12.93 release-notes entry I wrote names the
# extraction as a vehicle, using the exact word he retired on 2026-09-02, in a line
# on the what-is-new card that he reads. The check exists because I made this same
# mistake on 2026-09-08, and this is it working.
#
# The word goes; the sentence says extraction, which is what the thing is called.
SubRx @'
while the arrow beside them pointed at the ship you already had.
'@ @'
while the arrow beside them pointed at the extraction you already had.
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
