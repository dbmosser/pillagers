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

# SOUND DUCKING: BLASTS HIT HARDER (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
// ---------------------------------------------------------------- the room
'@ @'
// v23.69, HIS ORDER 2026-10-12 (his #45, punchy arcade sound): DUCKING. A grenade going off beside you landed on top of the
// ambient bed, the machine voices and your own feet at full level, so the one sound that mattered was buried in the rest. The
// way CoD and Fortnite make a blast hit is to pull everything else down for a moment: a blast within 700 drops the bed to 0.35,
// the machines to 0.6 and the footsteps to 0.7, holds half a second and lets them back up over about a second. A hit on you
// pulls the bed down to 0.7. The HUD bus and the stings are never ducked. The levels move only the mix buses of v23.69, so the
// volume rows and the split speakers are untouched; the recovery runs from tickVerb, which runs on the floor and in a raid.
var SND_DUCK={};
function sndDuckApply(cat,tc){
  if(!SND||!SND.bus||!SND.bus[cat]||!AC) return;
  var D=SND_DUCK[cat], v=D?D.lvl:1, gp=SND.bus[cat].gain, t=AC.currentTime;
  try{ gp.cancelScheduledValues(t); gp.setTargetAtTime(v,t,tc); }catch(e){ try{ gp.value=v; }catch(_e){} }
}
function sndDuck(cat,depth,hold){
  if(cat==='ui'||cat==='sting') return;
  var D=SND_DUCK[cat]||(SND_DUCK[cat]={lvl:1,hold:0,rate:0.4});
  if(depth<D.lvl){ D.lvl=depth; D.rate=(1-depth)/1.1; }
  if(hold>D.hold) D.hold=hold;
  sndDuckApply(cat,0.012);
}
function sndMixTick(dt){
  if(!isFinite(dt)||dt<=0) return;
  for(var k in SND_DUCK){
    var D=SND_DUCK[k], r=dt, u;
    if(D.hold>0){ u=Math.min(D.hold,r); D.hold-=u; r-=u; }
    if(r>0&&D.lvl<1){ D.lvl=Math.min(1,D.lvl+r*D.rate); sndDuckApply(k,0.06); }
  }
}
// ---------------------------------------------------------------- the room
'@

SubRx @'
function tickVerb(dt){
  var R=verb(); if(!R) return;
'@ @'
function tickVerb(dt){
  try{ sndMixTick(dt); }catch(_mx){}   // v23.69 (his #45): the ducked buses come back up
  var R=verb(); if(!R) return;
'@

SubRx @'
  var OUT=sndBus(SND_CAT[type]||'world')||bus()||a.destination;   // v23.67 (his #45): onto the bus for its kind of sound
'@ @'
  var OUT=sndBus(SND_CAT[type]||'world')||bus()||a.destination;   // v23.67 (his #45): onto the bus for its kind of sound
  if(type==='boom'&&(d===undefined||d<700)){ sndDuck('amb',0.35,0.5); sndDuck('mach',0.6,0.5); sndDuck('foley',0.7,0.5); }   // v23.69 (his #45): a blast near you pulls the rest down
'@

SubRx @'
function voxGrunt(hard){
  if(G&&G.sim) return;
  var a=ac(); if(!a) return; var out=sndBus('vox'); if(!out) return;
'@ @'
function voxGrunt(hard){
  if(G&&G.sim) return;
  var a=ac(); if(!a) return; var out=sndBus('vox'); if(!out) return;
  sndDuck('amb',0.7,0.25);   // v23.69 (his #45): a hit on you pulls the bed down
'@

SubRx @'
var VER='23.68';
'@ @'
var VER='23.69';
'@

$pat = "(?m)^  now:'v23\.68:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v23.69: A blast near you pulls the rest of the sound down for a moment, so it hits like a blast. Check 23.69 fails on v23.68',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
