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

# THE WHEEL IS IN HIS ORDER (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var WHEEL_ORDER=['medkit','frag','smoke','decoy','plate','trip','stim','bandage'];
'@ @'
// v26.xx (wheelorder), HIS ORDER 2026-10-14 ("wheel should go in this order instead / medkit, smoke, frag, tripwire, armour, decoy, bandage, stim"):
// the same eight slots in his order, clockwise from the top: TOP the medkit, TOP-RIGHT the smoke, RIGHT the frag, BOTTOM-RIGHT the tripwire, BOTTOM the
// armour plate, BOTTOM-LEFT the decoy, LEFT the bandage, TOP-LEFT the stim. Only the order changed: the mouse and the right stick both read this table.
var WHEEL_ORDER=['medkit','smoke','frag','trip','plate','decoy','bandage','stim'];
'@

SubRx @'
var VER='26.33';
'@ @'
var VER='26.34';
'@

$pat = "(?m)^  now:'v26\.33:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v26.34: The item wheel now runs medkit, smoke, frag, tripwire, armour, decoy, bandage, stim, clockwise from the top. Check 26.34 fails on v26.33',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
