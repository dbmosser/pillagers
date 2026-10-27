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

# RAID HUD FIXES (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    else if(item&&ITEMS[item]){ fk='loot'; col=feedItemCol(item,o&&o.c); cnt=true; key='p:'+item+'|'+tag; }
'@ @'
    else if(item&&ITEMS[item]&&!(/^[+\-](\$|[\d,]+ SP$)/).test(s)){ return null; }   // cw-hudfix, his note 10-27: looted items show only in the right-side stack
    else if(item&&ITEMS[item]){ fk='loot'; col=feedItemCol(item,o&&o.c); cnt=true; key='p:'+item+'|'+tag; }
'@

SubRx @'
while(p.crAcc>=2&&p.hp<_top){ p.crAcc-=2; p.hp=Math.min(_top,p.hp+1);
'@ @'
while(p.crAcc>=2&&p.hp<_top){ p.crAcc-=2; p.hp=Math.min(_top,p.hp+1); p.regenUpT=G.t; p.regenUpW=2.6; p.regenUpHp=p.hp; /* cw-hudfix */
'@

SubRx @'
    p.regenAcc-=CFG.regenSec;
    p.hp=Math.min(_top,p.hp+1);
'@ @'
    p.regenAcc-=CFG.regenSec;
    p.hp=Math.min(_top,p.hp+1); p.regenUpT=G.t; p.regenUpW=CFG.regenSec+0.6; p.regenUpHp=p.hp;   // cw-hudfix
'@

SubRx @'
G.t-p.regenLive<0.5){ E.on=true
'@ @'
G.t-p.regenLive<0.5&&Math.round(p.hp)<top&&typeof p.regenUpT==='number'&&G.t-p.regenUpT<(p.regenUpW||CFG.regenSec+0.6)&&!(p.hp<(p.regenUpHp||0)-0.05)){ E.on=true
'@

SubRx @'
FEEDBOX.on?FEEDBOX:null]
'@ @'
FEEDBOX.on?FEEDBOX:null,(typeof MEDALBOX==='object'&&MEDALBOX&&MEDALBOX.on)?MEDALBOX:null]
'@

SubRx @'
if(B.y+B.h+g*hr<=oy||B.y>=yBot) continue;
'@ @'
if(B.y+B.h+g*hr<=oy||B.y>=yBot) continue;
    if(B===FEEDBOX||B===MEDALBOX){ yBot=Math.min(yBot,B.y-g*hr); continue; }   // cw-hudfix, his note 10-27: the feed and the medal strip only cap the column
'@

SubRx @'
yBot-oy<S*hr*0.6&&_bx.length
'@ @'
yBot-oy<S*hr&&_bx.length
'@

SubRx @'
var VER='35.10';
'@ @'
var VER='35.11';
'@

$pat = "(?m)^  now:'v35\.10:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v35.11: loot leaves the left feed; recovering shows only while health really climbs; status icons stay clear of the feed Check 35.11 fails on v35.10',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
