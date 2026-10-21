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

# PILLAGERS BACK TO THEIR OLD SIZE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var FIG_SCALE=1.25, FIG_UP=19,
'@ @'
var FIG_SCALE=1, FIG_UP=12, /* v28.xx (cw-figback), HIS ORDER (2026-10-20): "player is too big, needs to go back to previous size" and "revert to old player size or maybe even smaller, should be scaled properly compared to bodies on ground, trees, deer". 1.25 back to 1 (the size before v32.64); his head, pack and vest picks stay. FIG_UP 19 to 12 so the plates sit over the smaller head. */
'@

SubRx @'
fs=(typeof FIG_SCALE==='number'&&bld!==null)?FIG_SCALE:1, fk=(fs===1)?[1,1]:figBuildK(bld||'lean'),
'@ @'
fs=(typeof FIG_SCALE==='number'&&bld!==null)?FIG_SCALE:1, fk=(bld===null)?[1,1]:figBuildK(bld||'lean'),   // v28.xx (cw-figback): the build height still applies at scale 1
'@

SubRx @'
var VER='33.21';
'@ @'
var VER='33.22';
'@

$pat = "(?m)^  now:'v33\.21:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v33.22: Pillagers, mates and bots are drawn at their old size again. Check 33.22 fails on v33.21',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
