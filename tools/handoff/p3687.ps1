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

# THE FIRST DEMO FIGHT COMES ABOUT 15 TO 20 SECONDS IN (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var ARCADE_WAVE={near:1400,minR:770,maxR:1060,tries:40};

'@ @'
var ARCADE_WAVE={near:1400,minR:770,maxR:1060,tries:40};
// v36.87 (cw-firstfight), HIS ANSWER 2.62 b (round 2): "the first fight comes after about 15 to 20 seconds: a short walk, then the first machines notice you".
// Measured on 40 demo seeds with a player standing at the start: the first pack came at 22 s and landed 770 to 1,060 away, and the median first contact was
// about 89 s (19 of 40 seeds met nothing in 100 s). Now the FIRST pack of a DEMO run (no wave yet) comes after ARCADE_FIRST.iv seconds and lands
// ARCADE_FIRST.minR to maxR away, so a short walk meets it. Every later pack is as before, and a career raid never takes this path.
var ARCADE_FIRST={iv:11,minR:480,maxR:640};
function arcadeFirstOn(WS){ return !!(G&&G.arcade&&!G.career&&WS&&!(WS.waveN|0)); }
function arcadeSiegeNear(men){   // a called ring within 1,000 of someone playing: that one still holds the pack
  var i, j, z;
  for(i=0;i<(G.zones||[]).length;i++){ z=G.zones[i]; if(!z||z.beaconT===null||z.beaconT===undefined) continue; for(j=0;j<men.length;j++) if(dist(z,men[j])<1000) return true; }
  return false;
}

'@

SubRx @'
  for(j=0;j<men.length;j++) if(dist({x:x,y:y},men[j])<700) return false;

'@ @'
  for(j=0;j<men.length;j++) if(dist({x:x,y:y},men[j])<Math.min(700,lo+1)) return false;   // v36.87 (cw-firstfight): the first demo pack lands nearer than 700; every other pack has lo of 769 or more, so this stays 700

'@

SubRx @'
function arcadeWaveSpot(men,q){
  var k, a, r, x, y;
  for(k=0;k<ARCADE_WAVE.tries;k++){
    a=Math.random()*Math.PI*2; r=ARCADE_WAVE.minR+Math.random()*(ARCADE_WAVE.maxR-ARCADE_WAVE.minR);
    x=q.x+Math.cos(a)*r; y=q.y+Math.sin(a)*r;
    if(arcadeWaveOk(men,q,x,y,ARCADE_WAVE.minR-1,ARCADE_WAVE.maxR+1)) return {x:x,y:y};
  }
  return null;
}

'@ @'
function arcadeWaveSpot(men,q,f){
  var k, a, r, x, y, lo=f?ARCADE_FIRST.minR:ARCADE_WAVE.minR, hi=f?ARCADE_FIRST.maxR:ARCADE_WAVE.maxR;   // v36.87 (cw-firstfight)
  for(k=0;k<ARCADE_WAVE.tries;k++){
    a=Math.random()*Math.PI*2; r=lo+Math.random()*(hi-lo);
    x=q.x+Math.cos(a)*r; y=q.y+Math.sin(a)*r;
    if(arcadeWaveOk(men,q,x,y,lo-1,hi+1)) return {x:x,y:y};
  }
  return null;
}

'@

SubRx @'
function arcadeWaveBody(men,q,c){
  var k, x, y;
  for(k=0;k<6;k++){
    x=c.x+Math.random()*72-36; y=c.y+Math.random()*72-36;
    if(arcadeWaveOk(men,q,x,y,700,1200)) return {x:x,y:y};

'@ @'
function arcadeWaveBody(men,q,c,f){
  var k, x, y;
  for(k=0;k<6;k++){
    x=c.x+Math.random()*72-36; y=c.y+Math.random()*72-36;
    if(arcadeWaveOk(men,q,x,y,f?ARCADE_FIRST.minR-80:700,f?ARCADE_FIRST.maxR+160:1200)) return {x:x,y:y};

'@

SubRx @'
  if(rush){ iv*=0.8; cap+=2; pack++; }

'@ @'
  if(rush){ iv*=0.8; cap+=2; pack++; }
  var first=arcadeFirstOn(WS); if(first) iv=ARCADE_FIRST.iv;   // v36.87 (cw-firstfight): the first demo pack comes early and near

'@

SubRx @'
  if(!c){ amb=0; c=arcadeWaveSpot(men,q); }

'@ @'
  if(!c){ amb=0; c=arcadeWaveSpot(men,q,first); }

'@

SubRx @'
    s=arcadeWaveBody(men,q,c); kd=kinds
'@ @'
    s=arcadeWaveBody(men,q,c,first); kd=kinds
'@

SubRx @'
  if(siegeCalled()) return 0;

'@ @'
  if(siegeCalled()&&!(first&&!arcadeSiegeNear(arcadeWaveMen()))) return 0;   // v36.87 (cw-firstfight): a ring an AI pillager called far away no longer holds the first demo pack back

'@

SubRx @'
  if(live>=cap){ WS.waveT=iv-1; return 0; }
'@ @'
  if(live>=cap&&!first){ WS.waveT=iv-1; return 0; }
'@

SubRx @'
  n=Math.min(amb?pack+2:pack,cap-live);
'@ @'
  n=first?pack:Math.min(amb?pack+2:pack,cap-live);
'@

SubRx @'
var VER='36.86';
'@ @'
var VER='36.87';
'@

$pat = "(?m)^  now:'v36\.86:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v36.87: In the demo the first pack of machines now comes in a few seconds and lands close, so the first fight starts about 15 to 20 seconds in. Check 36.87 fails on v36.86',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
