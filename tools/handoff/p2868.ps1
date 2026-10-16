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

# CRAWLERS ARE A FIFTH SLOWER (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function mkCrawler(x,y){
'@ @'
// v28.68 (lean3), HIS ORDER (2026-10-15): "Crawlers are too fast now". A crawler walked and chased at 150 units a second; it is 120 now (a fifth slower).
// Its hit points, bite, reach, senses and every count are unchanged, and the Fast affix still takes a third of whatever the base is.
function mkCrawler(x,y){
'@

SubRx @'
alert:0,spd:150,dmg:13,rng:26,cone:1.5,hitT:0,legs:rnd(0,6.28)
'@ @'
alert:0,spd:120,dmg:13,rng:26,cone:1.5,hitT:0,legs:rnd(0,6.28)
'@

SubRx @'
var VER='28.67';
'@ @'
var VER='28.68';
'@

$pat = "(?m)^  now:'v28\.67:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v28.68: Crawlers are a fifth slower, 120 instead of 150. Check 28.68 fails on v28.67',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
