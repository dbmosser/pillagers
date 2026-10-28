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

# NO POP UP AFTER THE EXTRACTION SINK (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
['keydown','mousedown','touchstart'].forEach(function(n){ window.addEventListener(n,function(e){ if(e&&e.repeat) return; if(G&&G.rise&&!G.mapFirst) G.rise=null; },true); });
'@ @'
// v35.xx (cw-xsink), HIS NOTE (2026-10-27): "when player extracts into the ground, player pops back up and is shown fully visible for a moment before the 'extracted' screen comes
// up.  this should not happen". The boarding hold sinks him (ascentSink) only while a ring's pull runs in a live raid, and the frame the pull completes ends the raid (G.over),
// or in the 2 player DEMO benches him with the ring's pull cleared, so every frame after it drew him whole, standing on the ring. Once an extraction has taken him he is not
// drawn in the world he left: G.over is extract, or the DEMO has him out (specOut) after his own extraction (G.arcX, or the host out for the run while player 2 plays on).
// His aim line goes with him, and the other window stops drawing him too (netUpHid). A death, an abandon and a bench nobody extracted from are unchanged. Drawing only:
// no seeded draw, and the raid ends and pays as before.
function ascOut(p){
  var g=G;
  if(!g||g.sim||!p||p!==g.player) return false;
  if(g.over==='extract') return true;
  return !!(g.arcade&&p.specOut&&(g.arcX||(typeof ARCADE==='object'&&ARCADE&&ARCADE.xOut==='h')));
}
['keydown','mousedown','touchstart'].forEach(function(n){ window.addEventListener(n,function(e){ if(e&&e.repeat) return; if(G&&G.rise&&!G.mapFirst) G.rise=null; },true); });
'@

SubRx @'
DR.push({k:p.y-drawLift((G&&G.map&&G.map.liftAt)?G.map.liftAt(p.x,p.y):0),pl:1});
'@ @'
if(!ascOut(p)) DR.push({k:p.y-drawLift((G&&G.map&&G.map.liftAt)?G.map.liftAt(p.x,p.y):0),pl:1});   // v35.xx (cw-xsink): an extraction that took him leaves no body on the ring
'@

SubRx @'
if(w&&w.id&&w.id!=='fists'&&p.hp>0&&!p.downed&&!(G.deathBeat>0)&&!(p.roll>0)&&!(G.handsT>0)&&!p.hand&&!(G.punchT>0)){
'@ @'
if(w&&w.id&&w.id!=='fists'&&p.hp>0&&!p.downed&&!(G.deathBeat>0)&&!(p.roll>0)&&!(G.handsT>0)&&!p.hand&&!(G.punchT>0)&&!ascOut(p)){   // v35.xx (cw-xsink): no aim line from a pillager an extraction took
'@

SubRx @'
hd:(G.handsT>0||p.hand)?1:0};
'@ @'
hd:(G.handsT>0||p.hand)?1:0,xo:ascOut(p)?1:0};
'@

SubRx @'
  if(up) g.pb=m.pb?1:0;
'@ @'
  if(up) g.xo=m.xo?1:0;   // v35.xx (cw-xsink): an extraction took him (the DEMO host out for the run); a word without it (an older window) reads as not out
  if(up) g.pb=m.pb?1:0;
'@

SubRx @'
    if(up&&g.pb) out.pb=1;
'@ @'
    if(up&&g.xo) out.xo=1;   // v35.xx (cw-xsink): passed on as it came
    if(up&&g.pb) out.pb=1;
'@

SubRx @'
function netUpGone(g){ return !!g&&!!NET.upOut&&!!NET.upOut[g.seat]&&NET.upOut[g.seat]===(g.sd>>>0); }
'@ @'
function netUpGone(g){ return !!g&&!!NET.upOut&&!!NET.upOut[g.seat]&&NET.upOut[g.seat]===(g.sd>>>0); }
// v35.xx (cw-xsink), his note 2026-10-27 (ascOut): a teammate an extraction took is not drawn here either: his word says he is out (xo, the DEMO host out for the run),
// his extraction out word came on this raid (a late position word must not stand him back up on the ring for NET_HUB_STALE), or player 2 extracted in a DEMO run that
// goes on. Drawing only: he still counts as up top everywhere netUpShown is read.
function netUpHid(g){ return !!g&&(g.xo===1||(netUpGone(g)&&!!NET.upHow&&NET.upHow[g.seat]==='extract')||(typeof G!=='undefined'&&!!G&&!!G.arcade&&NET.role==='host'&&typeof ARCADE==='object'&&!!ARCADE&&ARCADE.xOut==='p')); }
'@

SubRx @'
if(netUpShown(g)){ DR.push({k:g.y
'@ @'
if(netUpShown(g)&&!netUpHid(g)){ DR.push({k:g.y
'@

SubRx @'
      g=NET.up[i]; if(!netUpShown(g)) continue;
'@ @'
      g=NET.up[i]; if(!netUpShown(g)||netUpHid(g)) continue;   // v35.xx (cw-xsink): no name plate over a teammate an extraction took
'@

SubRx @'
g=NET.up[i]; if(!netUpShown(g)||g.dn||g.hd||g.roll>0||!g.wep||g.wep.id==='fists') continue;
'@ @'
g=NET.up[i]; if(!netUpShown(g)||netUpHid(g)||g.dn||g.hd||g.roll>0||!g.wep||g.wep.id==='fists') continue;
'@

SubRx @'
var VER='35.36';
'@ @'
var VER='35.37';
'@

$pat = "(?m)^  now:'v35\.36:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v35.37: an extraction that sank him never draws him whole again Check 35.37 fails on v35.36',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
