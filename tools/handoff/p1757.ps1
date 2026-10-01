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

# A PING ON THE OVERSEER NAMES IT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function netPingMake(){
'@ @'
// v17.57: what a ping calls the body under it: a pillager or THE OVERSEER by name (a linked window knows the boss by its name
// only), any other body by its kind. The ping said WARDEN on the boss.
function netPingName(hit){ return ((hit.kind==='raider'||hit.boss||hit.name===BOSS_NAME)&&hit.name)?netClean(hit.name,24):String(hit.kind).toUpperCase(); }function netPingMake(){
'@

SubRx @'
  m={t:'png',x:Math.round(hit?hit.x:w.x),y:Math.round(hit?hit.y:w.y),w:hit?((hit.kind==='raider'&&hit.name)?netClean(hit.name,24):String(hit.kind).toUpperCase()):''};
'@ @'
  m={t:'png',x:Math.round(hit?hit.x:w.x),y:Math.round(hit?hit.y:w.y),w:hit?netPingName(hit):''};   // v17.57: the boss by its name
'@

SubRx @'
var VER='17.56';
'@ @'
var VER='17.57';
'@

$pat = "(?m)^  now:'v17\.56:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v17.57: A ping on THE OVERSEER now names it instead of WARDEN. Check 17.57 fails on v17.56',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
