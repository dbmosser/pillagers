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

# FINISHER (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function meleeStrike(){
'@ @'
// v26.xx (feel16), HIS ORDER (2026-10-14): "finisher ok". HOLD THE CROWBAR KEY (V) ON A DOWNED PILLAGER AND YOU EXECUTE HIM. A pillager on the floor
// (hurt down, not yet dead) within FIN_REACH of you and in clear sight, held on V for FIN_T seconds, is finished at once: a heavy blow, a kick of
// the screen and FIN_PTS added to the run score (DEMO and CAREER), and the kill pays as any kill of yours does. It beats his one self-revive,
// which is the point of it. A tap on V is still the crowbar swing and nothing else. A downed pillager in reach shows FINISH and the key over him,
// and a ring that fills while you hold. On a linked window the host does the killing (the blow goes as a shot request). Live play only, and no
// seeded draw.
var FIN_T=0.55, FIN_REACH=62, FIN_PTS=100;
function finTarget(p){
  var best=null, bd=1e9, i, e, d;
  if(!G||!p||!G.ents||!G.map) return null;
  for(i=0;i<G.ents.length;i++){
    e=G.ents[i];
    if(e.kind!=='raider'||!e.downed||e.finished||!(e.hp>0)||e.merc||e.friendlyPC) continue;
    d=dist(p,e);
    if(d<FIN_REACH+(e.r||12)&&d<bd&&losClear(p.x,p.y,e.x,e.y,G.map.segs)){ bd=d; best=e; }
  }
  return best;
}
function finishHim(p,e){
  var a=Math.atan2(e.y-p.y,e.x-p.x);
  notoAggress(e);
  if(NET.on&&netEntsPeer()) netShotSend(e,(+e.hp||1)+5,a,null,0,'');
  else { e.hp=0; e.byPlayer=true; e.pHitT=.3; e.pHitSeat=0; }
  try{ meleeImpact(p.x,p.y,e.x,e.y,e.r); meleeFoley('hit',e.x,e.y); G.shake=Math.max(G.shake||0,4.2); bloodFx(e.x,e.y-14,p.x,p.y,40); }catch(_f){}
  if(!scoreBonus(FIN_PTS,e.x,e.y-30,'FINISHER')){ try{ label(e.x,e.y-30,'FINISHER','#ffc04a',0,true); }catch(_l){} }
  if(G.tel) G.tel.finishers=(G.tel.finishers||0)+1;
  return true;
}
function finisherTick(p,dt){
  var e;
  if(!G) return false;
  if(G.sim||G.over||G.paused||!p||p.downed||p.dying||p.roll>0||!keys['KeyV']){ G.finT=0; G.finE=null; return false; }
  e=finTarget(p);
  if(!e){ G.finT=0; G.finE=null; return false; }
  if(G.finE!==e){ G.finE=e; G.finT=0; }
  G.finT+=dt;
  if(G.finT<FIN_T) return false;
  G.finT=0; G.finE=null;
  return finishHim(p,e);
}
function drawFinisher(c,p){
  var e=(p&&!p.downed&&G&&!G.over&&!G.sim)?finTarget(p):null, s, z, r, f;
  if(!e) return false;
  s=w2s(e.x,0,e.y); z=Math.max(1,hudRes()); r=24*z; f=(G.finE===e)?clamp(G.finT/FIN_T,0,1):0;
  c.lineWidth=3*z; c.lineCap='butt';
  c.strokeStyle='rgba(255,192,74,.30)'; c.beginPath(); c.arc(s.x,s.y,r,0,6.2832); c.stroke();
  if(f>0){ c.strokeStyle='rgba(255,192,74,.96)'; c.beginPath(); c.arc(s.x,s.y,r,-1.5708,-1.5708+6.2832*f); c.stroke(); }
  c.font=hudFS(TYPE.micro); c.textAlign='center'; c.fillStyle='rgba(255,192,74,.96)';
  c.fillText(f>0?'FINISHING':'FINISH ['+keyLabel('KeyV','V')+']',s.x,s.y-r-6*z);
  return true;
}
function meleeStrike(){
'@

SubRx @'
  spinTick(p,dt);   // v26.xx (feel13): the Support MG winds up while the trigger is held
'@ @'
  spinTick(p,dt);   // v26.xx (feel13): the Support MG winds up while the trigger is held
  finisherTick(p,dt);   // v26.xx (feel16): hold V on a downed pillager to finish him
'@

SubRx @'
  // reticle at the cursor
'@ @'
  try{ drawFinisher(ctx,p); }catch(_dfn){}   // v26.xx (feel16): FINISH over a downed pillager in reach
  // reticle at the cursor
'@

SubRx @'
var VER='26.63';
'@ @'
var VER='26.64';
'@

$pat = "(?m)^  now:'v26\.63:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v26.64: Hold V on a downed pillager to finish him for a score bonus. Check 26.64 fails on v26.63',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
