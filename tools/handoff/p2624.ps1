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

# PICK AN ITEM, THEN PULL THE TRIGGER (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function wheelPick(k){
  var it=ITEMS[k], ti;
  if(!it||!G||G.sim) return false;
  if(it.use==='throw'){ ti=THROWKEYS.indexOf(k); if(ti<0) return false; G.tsel=ti; say((it.name+' ready').toUpperCase()); return true; }
  if(it.use==='heal'||it.use==='stim'){ G.msel=k; say((it.name+' ready').toUpperCase()); return true; }
  if(it.use==='armor') return quickPlate();
  return false;
}
'@ @'
// v26.xx (wheel3), HIS ORDER 2026-10-14: "You go to the wheel, you select one. Then you pull the trigger, and that lets you use the item. Then your gun
// comes back (have to come off trigger and then click it again to start firing). To get another one time use item, you have to go back to the wheel."
// A pick takes the item OUT (p.hand): the gun is put away, so it cannot fire, and the item needs a short pull-out first (a grenade 0.35 s, a heal or
// a plate 0.3, a stim 0.25). Then a fresh pull of the trigger uses it: a grenade or smoke is cooked while the trigger is held and thrown on release
// (the existing startCook / releaseCook), a tripwire is placed the same way, a bandage or medkit starts its wind-up (the heal ceilings are unchanged:
// a bandage stops at 85), a stim injects, a plate slots. The use takes ONE item, and then the gun comes back on its own with its own draw time
// (wheel1). The trigger has to be let go and pulled again before the gun fires. Another item means another trip to the wheel. A refused use
// (health full, armour full) puts the item away and brings the gun back. Pressing a gun key, or opening the wheel again, puts the item away with no
// use. The hand only exists in a live raid, never in the bot sim, and each window has its own.
function handTake(k){
  var p=G&&G.player, it=ITEMS[k], len;
  if(!p||!it||G.sim||wheelHave(k)<=0||p.cooking||p.downed||p.dying) return false;
  len=(it.use==='throw')?0.35:(it.use==='stim'?0.25:0.30);
  p.hand={k:k,t:len,len:len,armed:0,used:0,prev:!!mouse.down};
  p.reloading=0;
  if(!G.sim) say((it.name+' out').toUpperCase());
  return true;
}
function handEnd(p){
  p.hand=null;
  if(p.wep&&p.wep.mag!==0){ p.drawLen=drawTime(p.wep); p.drawT=p.drawLen; }
  p.trigYield=1;
}
function handCancel(p){ if(p&&p.hand) handEnd(p); }
function wheelHeal(k){
  var p=G.player, it=ITEMS[k], reach=healReach(p), ta, bi;
  if(it.use==='stim'){ bi=G.bag.indexOf('stim'); if(bi<0) return false; return useStim(bi)!==false; }
  if(NET.on&&typeof netAidTarget==='function'){ ta=netAidTarget(p); if(ta>=0){ netAidStart(ta,k); return true; } }
  if(reach>=p.maxhp){ say((p.healQ>0)?'ALREADY HEALING':'HEALTH FULL'); return false; }
  if(reach>=healCeil(it)){
    if(k==='bandage') say('BANDAGES STOP AT '+Math.round(healCeil(ITEMS.bandage)),'info',{sub:'You need a Medkit.'});
    else say((it.name+' stops at '+Math.round(healCeil(it))).toUpperCase());
    return false;
  }
  if(p.prep){ say('ALREADY APPLYING','info',{sub:String(ITEMS[p.prep.key]?ITEMS[p.prep.key].name:'Medical').toUpperCase()}); return false; }
  bi=G.bag.indexOf(k);
  if(bi<0) return false;
  G.bag.splice(bi,1); if(!startPrep('heal',k)) blip('pick');
  G.tel.heals++;
  spark(p.x,p.y,'#6fe0a0',10,90);
  return true;
}
// The trigger, with the item out. True when the use began.
function handUse(p,h){
  var k=h.k, it=ITEMS[k], n0=wheelHave(k), pa0=!!p.prepA;
  if(it.use==='throw'){ G.tsel=THROWKEYS.indexOf(k); return !!startCook(); }
  if(it.use==='heal'||it.use==='stim') return wheelHeal(k);
  if(it.use==='armor'){ useArmor(); return wheelHave(k)<n0||(!pa0&&!!p.prepA); }
  return false;
}
function handTick(p,dt){
  var h=p.hand;
  if(!h) return;
  if(G.sim||G.over||p.downed||p.dying||p.specOut){ p.hand=null; return; }
  if(h.t>0) h.t=Math.max(0,h.t-dt);
  if(mouse.down&&!h.prev&&!G.wheel) h.armed=1;
  if(!mouse.down) h.armed=0;
  h.prev=!!mouse.down;
  if(h.used){ if(!p.cooking) handEnd(p); return; }
  if(h.t>0||!h.armed||G.wheel||p.roll>0||G.paused) return;
  if(wheelHave(h.k)<=0){ handCancel(p); return; }
  h.armed=0;
  if(!handUse(p,h)){ handCancel(p); return; }
  h.used=1;
  if(ITEMS[h.k].use!=='throw') handEnd(p);
}
function wheelPick(k){
  if(!G||G.sim) return false;
  return handTake(k);
}
// The item in hand, over the belt: its picture and name, the pull-out filling, then the trigger and what it does.
function drawHand(){
  var p=G&&G.player, h=p&&p.hand, it, bw, bh, x, y, c0, fl, st, vb;
  if(!h||!ITEMS[h.k]||G.wheel) return;
  it=ITEMS[h.k]; c0=(G.hotCells&&G.hotCells[0])?G.hotCells[0].y:H-LH(130);
  bw=LH(250); bh=LH(46); x=Math.round(W/2-bw/2); y=Math.round(c0-bh-LH(26));
  ctx.save();
  hudPlate(x,y,bw,bh,UIC.acc,HUDC.plate);
  drawIconSprite(ctx,h.k,x+LH(30),y+bh/2,LH(34));
  ctx.textAlign='left'; ctx.font=FS(TYPE.head); ctx.fillStyle=UIC.tx_1; hudText(String(it.name).toUpperCase(),x+LH(54),y+LH(19));
  fl=(h.len>0)?1-h.t/h.len:1;
  if(h.t>0){
    ctx.font=FS(TYPE.micro); ctx.fillStyle=UIC.tx_2; hudText('READYING',x+LH(54),y+LH(36));
    ctx.fillStyle='rgba(255,255,255,.12)'; ctx.fillRect(x+LH(12),y+bh-LH(5),bw-LH(24),LH(3));
    ctx.fillStyle=UIC.acc; ctx.fillRect(x+LH(12),y+bh-LH(5),(bw-LH(24))*fl,LH(3));
  } else {
    st=(it.use==='throw')?(h.k==='trip'?'PLACE':'THROW'):(it.use==='armor'?'SLOT':(it.use==='stim'?'INJECT':'APPLY'));
    ctx.font=FS(TYPE.micro); vb=padOn()?'RT':'LMB';
    hudKey(vb,x+LH(52),y+LH(38),LH(8),LH(34));
    ctx.textAlign='left'; ctx.fillStyle=UIC.acc; hudText(st,x+LH(52)+LH(42),y+LH(36));
  }
  ctx.restore();
}
'@

SubRx @'
  drawTick(p,dt);   // v26.xx (wheel1): the gun that just came into his hands is not ready yet
'@ @'
  drawTick(p,dt);   // v26.xx (wheel1): the gun that just came into his hands is not ready yet
  handTick(p,dt);   // v26.xx (wheel3): the item in hand, read after the draw clock
'@

SubRx @'
else if(mouse.down&&!p.trigYield&&!p.cooking&&!(p.drawT>0)&&
'@ @'
else if(mouse.down&&!p.trigYield&&!p.cooking&&!p.hand&&!(p.drawT>0)&&
'@

SubRx @'
  if(mouse.down&&!hotGun){
'@ @'
  if(mouse.down&&!hotGun&&!p.hand){
'@

SubRx @'
if(keys['KeyR']&&p.reloading<=0&&p.ammo<p.wep.mag&&p.reserve>0){
'@ @'
if(keys['KeyR']&&p.reloading<=0&&!p.hand&&p.ammo<p.wep.mag&&p.reserve>0){
'@

SubRx @'
  if(mouse.down&&p.reloading<=0&&p.wep.mag>0&&p.ammo<=0&&p.reserve>0&&!p.downed&&p.jam<=0){
'@ @'
  if(mouse.down&&p.reloading<=0&&!p.hand&&p.wep.mag>0&&p.ammo<=0&&p.reserve>0&&!p.downed&&p.jam<=0){
'@

SubRx @'
function setHot(i){
  var sl=hotbarSlots();
'@ @'
function setHot(i){
  if(G&&G.player&&G.player.hand) handCancel(G.player);   // v26.xx (wheel3): a gun key puts the item away with no use
  var sl=hotbarSlots();
'@

SubRx @'
  if(G.wheel) return true;
  list=wheelList();
'@ @'
  if(G.wheel) return true;
  if(p.hand) handCancel(p);   // v26.xx (wheel3): the wheel again puts the item away
  list=wheelList();
'@

SubRx @'
  try{ drawWheel(); }catch(_dwh){}   // v26.xx (wheel2): the item wheel, over the belt
'@ @'
  try{ drawWheel(); }catch(_dwh){}   // v26.xx (wheel2): the item wheel, over the belt
  try{ drawHand(); }catch(_dhd){}   // v26.xx (wheel3): and the item in hand
'@

SubRx @'
var VER='26.23';
'@ @'
var VER='26.24';
'@

$pat = "(?m)^  now:'v26\.23:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v26.24: Pick an item on the wheel, pull the trigger to use one, and your gun comes back by itself. Check 26.24 fails on v26.23',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
