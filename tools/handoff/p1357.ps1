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

# END-OF-RAID AUDIT OF 2026-09-14, finding 5 (minor): THE CARD XP COULD BE ONE OFF FROM THE
# XP BANKED. The outcome card builds its XP from a record carrying the raw distance walked,
# while the banked record rounds the distance first, and the XP formula rounds distance over
# its step again, so at a rounding edge the card printed one XP less than the profile
# banked. The card record now rounds the distance the same way the banked record does.
SubRx @'
caches:T.cachesOpened||0,dist:T.distance||0,
'@ @'
caches:T.cachesOpened||0,dist:Math.round(T.distance||0),   // v13.57: rounded as the banked record rounds it
'@
SubRx @'
var VER='13.56';
'@ @'
var VER='13.57';
'@

$pat = "(?m)^  now:'v13\.56:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v13.57: THE XP ON THE CARD IS THE XP BANKED, AT EVERY DISTANCE. End-of-raid audit of 2026-09-14, finding 5: the outcome card built its XP from the raw distance walked while the banked record rounds the distance first, and the XP formula rounds distance over its step again, so at a rounding edge the card printed one XP less than the profile banked. The card record now rounds the distance as the banked record does. Check 13.57 finds a distance where raw and rounded give different XP, extracts at it, and requires the XP on the card to equal the XP banked, with a round distance as the control; it fails on v13.56',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
