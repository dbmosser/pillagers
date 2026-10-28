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

# ANSWER LINE UNDER YOUR FEET (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function feedCalm(){
'@ @'
// v35.xx (cw-answerline), HIS ASK (2026-10-27 ~21:40): "Everything about this game needs to be AAA and right now all the messaging on the hud is a clusterfuck", built
// to the research of that night (reports/Player alerts and HUD messaging.md, Centre, job 7). THE ANSWER TO SOMETHING YOU TRIED THAT DID NOT WORK SITS UNDER YOUR FEET.
// A P4 line (msgReach e: health full, no ammo, locked, bandages stop at 85, too tired to roll...) was a line in the left feed, out at the edge where the eye seldom
// goes. It is now one small line about 70 px under the character, at least 20 px tall, on a plate, for 2 s, and only one at a time (a new answer replaces it).
// ONCE PER PRESS: the same line said again while it shows does not restart it, and said again within 0.35 s of the last time (a key held down repeats) it does not
// come back after it has gone; let go and press again and it shows again. There is no soft "no" sound in the game to give it, so it stays silent (the research asked
// for one only if it existed). BACKPACK FULL is a pickup row and stays in the pickup stack exactly as before; contract item nearby (close to looting, his call),
// a pad unplugged and the saved run report notes stay in the feed; so do answers on the hub floor, under a pause or with the backpack open, and a line
// whose lane is named outright (o.reach, which only the checks use to stage a feed line).
var ANSLIFE=2, ANSGAP=0.35, ANSOFF=70;
var ANSFEED=/^(CONTRACT ITEM NEARBY|CONTROLLER DISCONNECTED|WALL GLITCH SAVED TO RUN REPORT|ERROR SAVED TO YOUR RUN REPORT|FEEDBACK (SAVED|COPIED|NOT SAVED)|PICK OTHER INITIALS)$/;
var ANSBOX={on:0,x:0,y:0,w:0,h:0,px:0,t:''};
function ansOn(m){ return !!(G&&!G.hubFloor&&!G.paused&&!G.over&&!G.bagOpen&&!G.mapOpen&&G.player&&!ANSFEED.test(String(m).toUpperCase().replace(/[.\s]+$/,''))); }
function ansSay(m,o){
  var s=String(m), now=statusNow(), A=G.ans, seen=(G.ansSeen=G.ansSeen||{}), last=seen[s];
  seen[s]=now;
  if(A&&A.m===s&&now-A.at<ANSLIFE) return A;                     // said again while it shows: one line, its time is not refreshed
  if(last!==undefined&&now-last<ANSGAP) return A;                 // the key is still held: it does not come back
  G.ans={m:s,sub:(o&&o.sub)?String(o.sub):'',at:now};
  return G.ans;
}
function ansUp(){ var A=G&&G.ans; return (A&&statusNow()-A.at<ANSLIFE)?A:null; }
function ansDraw(){
  var A=ansUp(), p=G&&G.player, ps, hr, f, px, t, tw, al, x, y, bw, bh, k;
  ANSBOX.on=0;
  if(!A||!p||G.mapOpen||G.bagOpen||G.over) return false;
  ps=w2s(p.x,0,p.y); if(!ps) return false;
  hr=Math.max(1,hudRes()); f=hudFS(TYPE.head); px=msgPx(f);
  if(px<20*hr){ px=20*hr; f=f.replace(/[\d.]+px/,px.toFixed(1)+'px'); }
  k=statusNow()-A.at; al=clamp(k/0.12,0,1)*clamp((ANSLIFE-k)/0.3,0,1);
  if(!(al>0.01)) return false;
  t=A.m+(A.sub?'  \u00b7  '+A.sub:'');
  ctx.save();
  try{
    ctx.font=f; ctx.textAlign='center'; ctx.globalAlpha=al;
    tw=ctx.measureText(TX(t)).width; bw=Math.round(tw+LH(16)*hr); bh=Math.round(px*1.45);
    x=Math.round(ps.x); y=Math.round(ps.y+ANSOFF*hr);
    if(y>H-LH(150)*hr) y=Math.round(ps.y-LH(100)*hr);   // the character low on the screen (a short window): over the head, never on the belt
    x=clamp(x,bw/2+LH(8)*hr,W-bw/2-LH(8)*hr); y=clamp(y,bh,H-LH(150)*hr);
    hudPlate(Math.round(x-bw/2),Math.round(y-bh/2),bw,bh,null,HUDC.plate);
    ctx.fillStyle=HUDC.text;
    hudText(t,x,Math.round(y+px*0.36));
    ANSBOX.on=1; ANSBOX.x=x-bw/2; ANSBOX.y=y-bh/2; ANSBOX.w=bw; ANSBOX.h=bh; ANSBOX.px=px; ANSBOX.t=t;
  } finally { ctx.restore(); }
  return true;
}
function feedCalm(){
'@

SubRx @'
    var _rc=msgReach(m,k,o); if(!_rc) return;
'@ @'
    var _rc=msgReach(m,k,o); if(!_rc) return;
    if(_rc==='e'&&!(o&&o.reach!==undefined)&&ansOn(m)){ ansSay(m,o); return; }   // v35.xx (cw-answerline): a try that did not work answers under your feet, not in the feed (a line given o.reach outright keeps its lane)
'@

SubRx @'
  try{ feedDraw(); }catch(_fdw){}   // v27.24 (feed1): the feed, bottom left (over the map too)
'@ @'
  try{ feedDraw(); }catch(_fdw){}   // v27.24 (feed1): the feed, bottom left (over the map too)
  try{ ansDraw(); }catch(_ansd){}   // v35.xx (cw-answerline): the answer line under the character
'@

SubRx @'
var VER='35.51';
'@ @'
var VER='35.52';
'@

$pat = "(?m)^  now:'v35\.51:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v35.52: when something you try does not work, the answer shows small under your feet for 2 s Check 35.52 fails on v35.51',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
