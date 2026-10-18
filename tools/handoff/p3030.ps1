$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $new = $new.Replace("`r`n", "`n")
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# PAUSE CARD LOSES THE PLAIN HINT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
body.padon #root #pausebox::after, #root #pausebox.asking::after{ display:none; }
'@ @'
/* v30.xx (cw-pausehint) critic 49 (pause card, 3 of 5): "the unstyled Esc Resume hint ... or delete the hint, since the X already shows close, and cut the card height". One control per job: the header X closes the card (Esc still works), so the plain text hint is gone and the card is shorter */
#root #pausebox::after, body.padon #root #pausebox::after, #root #pausebox.asking::after{ display:none !important; }
'@

SubRx @'
var VER='30.29';
'@ @'
var VER='30.30';
'@

$pat = "(?m)^  now:'v30\.29:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v30.30: The pause card no longer has a plain Esc Resume line. Check 30.30 fails on v30.29',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
