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

# PLAYER 2 SEES AND FEELS THE FIRES (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function fireTick(dt){
  var S=flowS(), F, i, f, t=G.t||0, p=G.player, e, a, r, any=0, pl, hit, d;
  if(!S.fplan) firePlan(S);
  for(i=0;i<S.fplan.length;i++) if(!S.fplan[i].on&&t>=S.fplan[i].at){ S.fplan[i].on=1; fireAdd(S.fplan[i].x,S.fplan[i].y,FIRE.r,FIRE.life,'fuel',FIRE.warn); }
'@ @'
function fireTick(dt){
  var S=flowS(), F, i, f, t=G.t||0, p=G.player, e, a, r, any=0, pl, hit, d, peer=flowPeer();
  if(!peer){   // v27.04 (coop1): a linked player 2 window plans and lights nothing, the fires are the host's (flowNetTake)
    if(!S.fplan) firePlan(S);
    for(i=0;i<S.fplan.length;i++) if(!S.fplan[i].on&&t>=S.fplan[i].at){ S.fplan[i].on=1; fireAdd(S.fplan[i].x,S.fplan[i].y,FIRE.r,FIRE.life,'fuel',FIRE.warn); }
  }
'@

SubRx @'
  for(i=0;i<G.ents.length;i++){
    e=G.ents[i];
    if(!e||!(e.hp>0)||e.kind==='snitch') continue;
    fireKeep(e,e.r||12);
'@ @'
  if(peer) return;   // v27.04 (coop1): the host moves and burns the machines; their bodies come over in the body words
  for(i=0;i<G.ents.length;i++){
    e=G.ents[i];
    if(!e||!(e.hp>0)||e.kind==='snitch') continue;
    fireKeep(e,e.r||12);
'@

SubRx @'
  if(G.hotZone) m.hz=[Math.round(G.hotZone.x),Math.round(G.hotZone.y),G.hotZone.moves|0];   // v20.39 (H59): the hot ground, for the party
'@ @'
  if(G.hotZone) m.hz=[Math.round(G.hotZone.x),Math.round(G.hotZone.y),G.hotZone.moves|0];   // v20.39 (H59): the hot ground, for the party
  try{ m.fl=flowNetOut(); }catch(_fno){}   // v27.04 (coop1): and the raid flow (the fires now, the events and the rest in the builds after), for a linked window
'@

SubRx @'
  return 'wd';
}
'@ @'
  try{ if(m.fl) flowNetTake(m.fl); }catch(_fnt){}   // v27.04 (coop1): the host raid flow, kept as the host has it
  return 'wd';
}
'@

SubRx @'
// FLOW-MODULE-END (the next flow builds add their code above this line)
'@ @'
// v27.04 (coop1), HIS ORDER (2026-10-14), the two player first: the raid flow batch shipped for the host or a solo player only, and it must work for both players. THE
// FLOW COMES TO PLAYER 2, THE FIRES FIRST. A linked player 2 window ran its own fire plan beside the host, and the debris fires the host lit were never in it, so the two
// screens showed different fires and the discs the host kept its machines out of were not discs player 2 was kept out of. The host now puts the flow in the world word it
// already sends twice a second (netWorldSend, the field fl: for the fires, per fire the id, the place, the size, the clock, the warm up, the life and where it came from;
// the later flow builds add their keys to the same field, so there is no new word and no new channel). The linked window (flowPeer: a party raid on the host seed) takes it
// (flowNetTake) instead of planning: it lights nothing of its own, keeps the fires the host has, runs their clocks between words, and puts player 2 back on the edge of
// a lit fire and burns him there as it does the host player (fireTick). The machines stay the host: their bodies come over in the body words and the host burns them.
function flowPeer(){ return !!(typeof NET==='object'&&NET&&NET.on&&NET.role==='join'&&typeof netEntsPeer==='function'&&netEntsPeer()); }
function flowNetOut(){
  var S=G&&G.flow, F, i, f, a=[];
  if(!S||!(G.arcade||G.career)||G.sim||G.over) return null;
  F=S.fires||[];
  for(i=0;i<F.length&&i<8;i++){ f=F[i]; a.push([f.id|0,Math.round(f.x),Math.round(f.y),Math.round(f.r),+(+f.t).toFixed(1),+(+f.warn).toFixed(1),+(+f.life).toFixed(1),(f.src==='fuel')?0:1]); }
  return {f:a};
}
function flowNetTake(fl){
  if(!fl||typeof fl!=='object'||!flowOn()||!flowPeer()) return 0;
  if(fl.f&&typeof fl.f.length==='number') fireNetTake(fl.f);
  return 1;
}
function fireNetTake(rows){
  var S=flowS(), F=fireS(), i, j, r, f, seen={};
  for(i=0;i<rows.length&&i<8;i++){
    r=rows[i];
    if(!r||typeof r.length!=='number'||r.length<8) continue;
    if(!isFinite(+r[1])||!isFinite(+r[2])||!(+r[3]>0)||!isFinite(+r[4])||!isFinite(+r[5])||!(+r[6]>0)) continue;
    f=null; for(j=0;j<F.length;j++) if(F[j].id===(r[0]|0)){ f=F[j]; break; }
    if(!f){ f={x:0,y:0,r:FIRE.r,t:0,life:FIRE.life,warn:FIRE.warn,src:'fuel',id:r[0]|0,bt:0,told:0}; F.push(f); }
    f.x=+r[1]; f.y=+r[2]; f.r=+r[3]; f.t=+r[4]; f.warn=+r[5]; f.life=+r[6]; f.src=r[7]?'debris':'fuel';
    seen[f.id]=1; S.fireN=Math.max(S.fireN|0,f.id);
  }
  for(j=F.length-1;j>=0;j--) if(!seen[F[j].id]) F.splice(j,1);
  return F.length;
}
// FLOW-MODULE-END (the next flow builds add their code above this line)
'@

SubRx @'
var VER='27.03';
'@ @'
var VER='27.04';
'@

$pat = "(?m)^  now:'v27\.03:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v27.04: Player 2 now sees the same fires as player 1 and cannot walk through them. Check 27.04 fails on v27.03',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
