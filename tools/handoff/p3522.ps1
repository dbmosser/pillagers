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

# RECOVERING IN SUPERHOT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function statusLive(p){
'@ @'
// v35.xx (cw-restfreeze): seconds on the real clock, which keeps running while Superhot or a pause holds the raid clock still.
function statusNow(){ return ((typeof performance!=='undefined'&&performance.now)?performance.now():Date.now())/1000; }
function statusLive(p){
'@

SubRx @'
      top=healCeil(ITEMS.bandage);
      // v21.65, HIS NOTE (2026-10-09)
'@ @'
      top=healCeil(ITEMS.bandage);
      // v35.xx (cw-restfreeze), HIS NOTE (2026-10-27, build 35.19, Superhot on): "status nofifications are still broken, it says i'm
      // recovering to 85 when I'm not". Every test below reads the raid clock, and Superhot stops that clock whenever no input is live,
      // so standing still kept RECOVERING lit for as long as he waited while his health stood still. The raid clock now also has to have
      // moved within the last half second of real time; the moment he acts again, time and the regen run on and the icon comes back.
      var rn=statusNow(); if(E.gt!==G.t){ E.gt=G.t; E.gtR=rn; }
      // v21.65, HIS NOTE (2026-10-09)
'@

SubRx @'
&&!(p.hp<(p.regenUpHp||0)-0.05)){ E.on=true; if(E.vk!==top)
'@ @'
&&!(p.hp<(p.regenUpHp||0)-0.05)&&typeof E.gtR==='number'&&rn-E.gtR<0.5){ E.on=true; if(E.vk!==top)
'@

SubRx @'
var VER='35.21';
'@ @'
var VER='35.22';
'@

$pat = "(?m)^  now:'v35\.21:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v35.22: recovering goes dark while superhot holds time still Check 35.22 fails on v35.21',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
