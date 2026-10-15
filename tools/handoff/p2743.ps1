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

# THE CLOUD REVIEW: FIRES, CRATES, BOUNTY, CONVOY, KEYS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
        if(!spotFree(G.map,x,y,40)||!navReachable(G.map,x,y)||shutRoomAt(G.map,x,y)||flowZoneNear(x,y,420)) continue;
'@ @'
        if(!spotFree(G.map,x,y,40)||!navReachable(G.map,x,y)||shutRoomAt(G.map,x,y)||flowZoneNear(x,y,420)||shAt(x,y,80)) continue;
'@

SubRx @'
    function ok(x,y){ return x>300&&y>300&&x<WORLD_W-300&&y<WORLD_H-300&&spotFree(G.map,x,y,40)&&navReachable(G.map,x,y)&&!shutRoomAt(G.map,x,y)&&!flowZoneNear(x,y,300); }
'@ @'
    function ok(x,y){ return x>300&&y>300&&x<WORLD_W-300&&y<WORLD_H-300&&spotFree(G.map,x,y,40)&&navReachable(G.map,x,y)&&!shutRoomAt(G.map,x,y)&&!flowZoneNear(x,y,300)&&!shAt(x,y,80); }
'@

SubRx @'
        if(x>300&&y>300&&x<WORLD_W-300&&y<WORLD_H-300&&spotFree(G.map,x,y,40)&&navReachable(G.map,x,y)&&!shutRoomAt(G.map,x,y)&&!flowZoneNear(x,y,350)) S={x:x,y:y};
'@ @'
        if(x>300&&y>300&&x<WORLD_W-300&&y<WORLD_H-300&&spotFree(G.map,x,y,40)&&navReachable(G.map,x,y)&&!shutRoomAt(G.map,x,y)&&!flowZoneNear(x,y,350)&&!shAt(x,y,80)) S={x:x,y:y};
'@

SubRx @'
EVENTS.cool={name:'COOLANT RUPTURE',sub:'FOG AND COLD',warn:18,dur:75,r:420,fade:4,col:'#8fd8ff',
  pick:function(ev){
    var p=G.player, S=null;
    evStream(ev,function(){
      var k, a, d, x, y;
      for(k=0;k<80&&!S;k++){
        a=rr()*6.2832; d=450+rr()*550; x=p.x+Math.cos(a)*d; y=p.y+Math.sin(a)*d;
        if(x>400&&y>400&&x<WORLD_W-400&&y<WORLD_H-400&&spotFree(G.map,x,y,40)&&navReachable(G.map,x,y)&&!shutRoomAt(G.map,x,y)&&!flowZoneNear(x,y,450)) S={x:x,y:y};
'@ @'
EVENTS.cool={name:'COOLANT RUPTURE',sub:'FOG AND COLD',warn:18,dur:75,r:420,fade:4,col:'#8fd8ff',
  pick:function(ev){
    var p=G.player, S=null;
    evStream(ev,function(){
      var k, a, d, x, y;
      for(k=0;k<80&&!S;k++){
        a=rr()*6.2832; d=450+rr()*550; x=p.x+Math.cos(a)*d; y=p.y+Math.sin(a)*d;
        if(x>400&&y>400&&x<WORLD_W-400&&y<WORLD_H-400&&spotFree(G.map,x,y,40)&&navReachable(G.map,x,y)&&!shutRoomAt(G.map,x,y)&&!flowZoneNear(x,y,450)&&!shAt(x,y,80)) S={x:x,y:y};
'@

SubRx @'
          if(x>300&&y>300&&x<WORLD_W-300&&y<WORLD_H-300&&spotFree(G.map,x,y,40)&&navReachable(G.map,x,y)&&!shutRoomAt(G.map,x,y)){ wps.push({x:x,y:y}); break; }
'@ @'
          if(x>300&&y>300&&x<WORLD_W-300&&y<WORLD_H-300&&spotFree(G.map,x,y,40)&&navReachable(G.map,x,y)&&!shutRoomAt(G.map,x,y)&&!shAt(x,y,80)){ wps.push({x:x,y:y}); break; }
'@

SubRx @'
function fireKeep(o,rad){
  var F=G.flow.fires, i, f, d, R, a, nx, ny, k, ta;
'@ @'
function fireKeep(o,rad,tg,dt){   // v27.43 (rvw1, cloud review 3): tg is where a body is going and dt the frame, so one that wants to cross the fire slides round its edge instead of grinding on it
  var F=G.flow.fires, i, f, d, R, a, nx, ny, k, ta, sg, cr;
'@

SubRx @'
    a=(d>0.5)?Math.atan2(o.y-f.y,o.x-f.x):((o.id|0)*1.7+0.3);
'@ @'
    a=(d>0.5)?Math.atan2(o.y-f.y,o.x-f.x):((o.id|0)*1.7+0.3);
    if(tg&&dt>0&&d>0.5&&(tg.x-f.x)*(o.x-f.x)+(tg.y-f.y)*(o.y-f.y)<0){   // v27.43 (rvw1): his way lies across the fire: along the edge, the short way round
      cr=(o.x-f.x)*(tg.y-o.y)-(o.y-f.y)*(tg.x-o.x);
      sg=(o.fkS&&Math.abs(cr)<R*60)?o.fkS:((cr>=0)?1:-1); o.fkS=sg;   // and he keeps to the side he chose, so a body straight in line does not dither
      ta=a+sg*Math.min(0.6,150*dt/R);
      nx=f.x+Math.cos(ta)*(R+1); ny=f.y+Math.sin(ta)*(R+1);
      if(nx>20&&ny>20&&nx<WORLD_W-20&&ny<WORLD_H-20&&spotFree(G.map,nx,ny,Math.max(6,rad*0.6))){ o.x=nx; o.y=ny; return true; }
    }
'@

SubRx @'
    fireKeep(e,e.r||12);
'@ @'
    fireKeep(e,e.r||12,fireGoal(e),dt);   // v27.43 (rvw1): and where he is going
'@

SubRx @'
  if(id==='crate6'){ C=G.containers||[]; for(i=0;i<C.length;i++) if(C[i]&&C[i].opened) n++; S.crates=Math.max(S.crates|0,n); return S.crates; }
'@ @'
  if(id==='crate6') return S.crates|0;   // v27.43 (rvw1, cloud review 12): the boxes the party opened (flowCrate), not the ones pillagers and hires emptied
'@

SubRx @'
  ct.opened=true; T.containers++;
'@ @'
  ct.opened=true; T.containers++;
  try{ flowCrate(ct); }catch(_fcr){}   // v27.43 (rvw1): the run goal counts what the party opens
'@

SubRx @'
  ct.opened=true; ct.prog=0; ct.netBy=-1; ct.netOpen=1; ct.netOpenBy=by;
'@ @'
  ct.opened=true; ct.prog=0; ct.netBy=-1; ct.netOpen=1; ct.netOpenBy=by;
  try{ flowCrate(ct); }catch(_fch){}   // v27.43 (rvw1): player 2's box counts for the party too
'@

SubRx @'
function convoyLeave(ev){
  var i, k;
  for(i=0;ev.d.crew&&i<ev.d.crew.length;i++){ k=G.ents.indexOf(ev.d.crew[i]); if(k>=0) G.ents.splice(k,1); }
}
'@ @'
function convoyLeave(ev){
  var i, k, e, kept=0;
  for(i=0;ev.d.crew&&i<ev.d.crew.length;i++){
    e=ev.d.crew[i]; k=G.ents.indexOf(e); if(k<0) continue;
    if(evBodyAway(e)) G.ents.splice(k,1);   // v27.43 (rvw1, cloud review 10): out of the world only where nobody can see it
    else { e.carrier=0; kept++; }           // in view or close: he stays, an ordinary machine now
  }
  return kept;
}
'@

SubRx @'
      ev.d.over=1; convoyLeave(ev);
      try{ say('CONVOY AWAY','info'); }catch(_ca){}
'@ @'
      ev.d.over=1; convoyLeave(ev);
      try{ if(G.ents.indexOf(car)<0) say('CONVOY AWAY','info'); else say('CONVOY ARRIVED','info',{sub:'THEY STAY'}); }catch(_ca){}   // v27.43 (rvw1): AWAY is said only once it is true
'@

SubRx @'
    down=!(e.hp>0)||e.downed||e.finished||G.ents.indexOf(e)<0;
    if(down){
      ev.d.over=1;
      if(e.byPlayer!==false||(e.bySeat|0)>0){ flowChip(BOUNTY.pay,'BOUNTY CLAIMED','BOUNTY PILLAGER'); ev.d.won=1; }   // v27.27 (coop8): player 2's kill claims it too
      else { try{ say('BOUNTY GONE','info',{sub:'NOT YOUR KILL'}); }catch(_bg){} }
      return;
    }
    e.state='chase'; e.alert=3; e.chaseHold=0; e.tx=p.x; e.ty=p.y;
'@ @'
    down=!(e.hp>0)||e.finished||G.ents.indexOf(e)<0;   // v27.43 (rvw1, cloud review 17): a DOWNED hunter can get up, so he is still on the hunt
    if(down){
      ev.d.over=1;
      if(e.hp<=0&&(e.byPlayer===true||(e.bySeat|0)>0)){ flowChip(BOUNTY.pay,'BOUNTY CLAIMED','BOUNTY PILLAGER'); ev.d.won=1; }   // paid for a kill of the party (player 2 too), never for a death nobody caused (fire, debris, a barrel)
      else { try{ say('BOUNTY GONE','info',{sub:(e.hp<=0)?'NOT YOUR KILL':'HE GOT AWAY'}); }catch(_bg){} }
      return;
    }
    if(e.downed) return;
    e.state='chase'; e.alert=3; e.chaseHold=0; e.tx=p.x; e.ty=p.y;
'@

SubRx @'
      k=G.ents.indexOf(e); if(k>=0) G.ents.splice(k,1);
      try{ say('BOUNTY SLIPPED AWAY','info'); }catch(_be){}
'@ @'
      k=G.ents.indexOf(e);
      if(k>=0&&evBodyAway(e)){ G.ents.splice(k,1); try{ say('BOUNTY SLIPPED AWAY','info'); }catch(_be){} }   // v27.43 (rvw1, cloud review 10): out of the world only where nobody can see it
      else if(k>=0){ e.bounty=0; try{ say('BOUNTY OVER','info',{sub:'HE STAYS'}); }catch(_bo){} }
'@

SubRx @'
function airHint(){ return (typeof padOn==='function'&&padOn())?padB('LB + RB'):'PRESS G'; }
'@ @'
function airHint(){ return (typeof padOn==='function'&&padOn())?padB('LB + RB'):('PRESS '+keyLabel('KeyG','G')); }   // v27.43 (rvw1, cloud review 21): the key as it is bound
'@

SubRx @'
    c.font=hudFS(TYPE.micro); c.fillStyle=UIC.tx_2; hudText((padOn()?pbn(7):'LMB')+' CALL     '+(padOn()?padB('LB + RB'):'G')+' CANCEL',s.x,s.y-ar-U(8));
'@ @'
    c.font=hudFS(TYPE.micro); c.fillStyle=UIC.tx_2; hudText((padOn()?pbn(7):'LMB')+' CALL     '+(padOn()?padB('LB + RB'):keyLabel('KeyG','G'))+' CANCEL',s.x,s.y-ar-U(8));
'@

SubRx @'
    if(rdy) hudKey(padOn()?padB('LB+RB'):'G',x+bw-U(padOn()?74:46),y+Math.round(bh*0.7),U(8),U(padOn()?62:32));   // v27.25 (coop7): the chord on a controller
'@ @'
    if(rdy) hudKey(airCapLabel(),x+bw-U((padOn()||airCapLabel().length>1)?74:46),y+Math.round(bh*0.7),U(8),U((padOn()||airCapLabel().length>1)?62:32));   // v27.43 (rvw1, cloud review 21): the key as it is bound
'@

SubRx @'
// FLOW-MODULE-END (the next flow builds add their code above this line)
'@ @'
// v27.43 (rvw1), the CLOUD REVIEW of 2026-10-15 (findings 3, 10, 12, 17, 21), each checked against the code before it was changed.
// 3: the fires pushed a body back onto the edge every frame, so a pillager or a machine chasing him across a fire stood grinding on it (and burned); a body now slides along the edge the short way round toward
//    where it is going (fireGoal). And no raid event, fire or ambush is ever placed in a stronghold (flowZoneNear says so, and every picker asks it).
// 10: the convoy's crew and the bounty pillager were taken out of the world in plain view when the event ended; a body is removed now only where nobody sees it (not seen, and not within 300), otherwise it stays as an
//    ordinary enemy, and CONVOY AWAY / BOUNTY SLIPPED AWAY are said only when they are true (CONVOY ARRIVED, BOUNTY OVER when they stay).
// 12: the 6 CRATES goal counted every box that was opened, by pillagers and hires too; it counts what the party opens (not bodies, not bot wrecks, not dropped litter), player 2's boxes included.
// 17: the bounty was paid on a DOWN (he can get up) and for deaths nobody caused (fire, debris, a barrel); now only a kill by the party pays, and a downed hunter is still on the hunt.
// 21: the air strike prompts named the keyboard key G whatever it was bound to; they name the bound key.
function evBodyAway(e){
  var p=G.player;
  if(!e) return true;
  if(e.seen) return false;
  if(p&&Math.hypot(e.x-p.x,e.y-p.y)<300) return false;
  return true;
}
function fireGoal(e){
  var p=G.player;
  if(e.state==='chase'||e.state==='alarm'||e.state==='hunt') return p?{x:p.x,y:p.y}:null;
  return (isFinite(e.tx)&&isFinite(e.ty))?{x:e.tx,y:e.ty}:null;
}
function airCapLabel(){ return padOn()?padB('LB+RB'):keyLabel('KeyG','G'); }
function flowCrate(ct){
  var S;
  if(!ct||G.sim||!G.player||ct.type==='body'||ct.type==='botwreck'||ct.dropped) return 0;
  S=flowS(); S.crates=(S.crates|0)+1;
  return S.crates;
}
// FLOW-MODULE-END (the next flow builds add their code above this line)
'@

SubRx @'
var VER='27.42';
'@ @'
var VER='27.43';
'@

$pat = "(?m)^  now:'v27\.42:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v27.43: Fires, crates, the bounty, the convoy and the strike key are cleaned up. Check 27.43 fails on v27.42',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
