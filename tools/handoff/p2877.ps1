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

# THE LOW ALARM ONLY SOUNDS NEAR YOU AND SAYS WHAT IT IS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function sfx(type,wx,wy,wid){
  if(G&&G.sim) return;

'@ @'
// v28.xx (alarmcap), HIS NOTE (2026-10-16): "theres still an annoying low siren in the background too often and i dont even know what it means".
// The low siren is the 'alarm' cue, and about twenty things raise it: a machine spotting someone, the crawler shout, a mimic, a noisy
// strongbox, the seal. Since machines and pillagers fight each other, machines far away raised it all raid long. It now sounds only within
// ALARM_RANGE of you, at most once every ALARM_CD seconds, and each time it says what it is in the feed: MACHINE ALERT.
var ALARM_CD=4, ALARM_RANGE=700, ALARM_LAST=-99;
function alarmOk(wx,wy){
  var p=G&&G.player;
  if(p&&wx!==undefined&&wx!==null&&Math.hypot(wx-p.x,wy-p.y)>ALARM_RANGE) return false;
  var now=((typeof performance!=='undefined'&&performance.now)?performance.now():Date.now())/1000;
  if(now-ALARM_LAST<ALARM_CD) return false;
  ALARM_LAST=now;
  try{ if(G&&G.player&&!G.over) say('MACHINE ALERT','info'); }catch(_as){}
  return true;
}
function sfx(type,wx,wy,wid){
  if(G&&G.sim) return;
  if(type==='alarm'&&!alarmOk(wx,wy)) return;   // v28.xx (alarmcap)

'@

SubRx @'
var VER='28.76';
'@ @'
var VER='28.77';
'@

$pat = "(?m)^  now:'v28\.76:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v28.77: The low alarm now only sounds when a machine near you is alerted, at most every 4 seconds, and the feed says MACHINE ALERT. Check 28.77 fails on v28.76',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
