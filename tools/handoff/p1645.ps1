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

# SETTINGS IN A RAID (his order: reachable in a raid, changing the game in real time).

SubRx @'
      if(b) b.onclick=function(){ cycleGameOpt(k); renderSettings(); };
'@ @'
      if(b) b.onclick=function(){ var _rs0=CFG.raidSec; cycleGameOpt(k); gameOptRaidNow(_rs0); renderSettings(); };   // v16.45: a raid in hand changes at once
'@

SubRx @'
      '<div class="hint">'+_gr.hint+(_gs?'':' Set by hand in the tuning console; click to put a word back on it.')+'</div></div>'+
'@ @'
      '<div class="hint">'+_gr.hint+(_gs?'':' Set by hand in the tuning console; click to put a word back on it.')+((G&&!G.over&&!G.sim&&(_gr.k==='raiders'||_gr.k==='robots'))?' In a raid this takes effect from the next raid.':'')+'</div></div>'+
'@

SubRx @'
    <button id="resumebtn" style="padding:8px 22px">Resume run</button>
'@ @'
    <button id="resumebtn" style="padding:8px 22px">Resume run</button>
    <button id="pausesetbtn" style="padding:8px 22px">Settings</button>
'@

SubRx @'
function abandonRepCost(el){ return Math.min(400,100+Math.round(el/10)); }
'@ @'
function abandonRepCost(el){ return Math.min(400,100+Math.round(el/10)); }
// v16.45, HIS ORDER: SETTINGS IN A RAID, CHANGING THE GAME IN REAL TIME. The pause box opens the same Settings window over the
// raid. Damage, loot value, extraction heat, Superhot and kid mode are read as they happen, so they change at once; the raid
// length moves the clock now, keeping the time already played (on a teammate window the host clock rules); the pillager and
// machine counts are the map as it was built and say they take effect from the next raid.
document.getElementById('pausesetbtn').onclick=function(){ openSettings(); };
function gameOptRaidNow(rs0){
  var el, nl;
  if(typeof G==='undefined'||!G||G.over||G.sim||!(G.raidLen>0)||!(rs0>0)||CFG.raidSec===rs0||!(CFG.raidSec>0)) return false;
  if(typeof NET==='object'&&NET&&NET.on&&NET.role==='join'&&netEntsPeer()) return false;
  el=elapsed();
  nl=Math.round(G.raidLen*CFG.raidSec/rs0);
  G.raidLen=nl; G.timeLeft=Math.max(30,nl-el);
  say('Raid clock changed: '+fmtMS(G.timeLeft)+' left.');
  return true;
}
'@

SubRx @'
var VER='16.44';
'@ @'
var VER='16.45';
'@

$pat = "(?m)^  now:'v16\.44:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v16.45: SETTINGS IN A RAID. His order: the Settings menu should be reachable in a raid and change the game in real time. The pause box has a Settings button that opens the same window over the raid. Damage, loot value, extraction heat, Superhot and kid mode already apply as they happen; the raid length now moves the clock at once, keeping the time played. The pillager and machine counts say they take effect from the next raid. Check 16.45 fails on v16.44',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
