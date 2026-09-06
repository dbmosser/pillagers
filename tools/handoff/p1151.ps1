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

# MY v11.42 BAKE NAMED THE WRONG MAP. The two sector-facts lines he rewrote end
# "in Cold Storage." and "in The Cold Mile.", and both have the SAME digit shape
# (runs, metres, hectares, zones, rooms, percent). The pattern derivation turned
# each into a shape key, the second overwrote the first, and TX then matched
# ANY sector line of that shape by digits, so one map printed the other map's
# name. Those two lines are exact-only from here: their own figures still map,
# a line with other figures is left as the game drew it.
SubRx @'
    if(!TXSHIP.hasOwnProperty(_tk)) continue;
'@ @'
    if(!TXSHIP.hasOwnProperty(_tk)) continue;
    // v11.51: the sector-facts lines stay exact-only. Both maps draw the same
    // digit shape, so matched by shape one map printed the other map's name.
    if(_tk.indexOf('test robot extracts')>=0) continue;
'@

# STAMPS.
SubRx @'
var VER='11.50';
'@ @'
var VER='11.51';
'@
SubRx @'
var WHATSNEW_VER='11.50';
'@ @'
var WHATSNEW_VER='11.51';
'@
SubRx @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
'@ @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
  'THE SECTOR PAGE NAMES THE RIGHT MAP AGAIN. The line of facts under each map could end with the other map name, because the two lines share a digit shape and the reworded text was matched by shape. Each map keeps its own line now.',
'@
$cnt=([regex]::Matches($s,"now:'v11\.50:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v11.50 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v11\.50:[^']*'",{ param($m) "now:'v11.51: my v11.42 bake named the wrong map on the sector page. His two sector-facts lines end in Cold Storage and in The Cold Mile and share one digit shape, so the pattern derivation keyed both to one shape, the second overwrote the first, and TX matched any sector line of that shape by digits: one map printed the other map name. The two lines are exact-only now, skipped by the derivation. From the v11.46 audit, P1, mine.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
