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

# THE ITEM WHEEL (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
// v26.02 (beltkeys): the gun F brings up next, as a pure pick, so the belt can draw the F keycap on it. cur is the key of the gun in hand.
'@ @'
// v26.xx (wheel2), HIS ORDER 2026-10-14: "add a wheel for heals and grenades. You go to the wheel, you select one." HOLD Q opens an item wheel in
// the middle of the screen: one segment for each TYPE he carries (a grenade, a smoke, a decoy, a tripwire, a bandage, a medkit, a stim, an
// armour plate), with its picture, its name and how many he has. The game runs on in real time while it is open; he can move but not fire. He
// moves the mouse toward a segment (measured from where the mouse was when the wheel opened, so a tap never picks by accident) and lets go of Q
// to pick it; letting go in the middle, or on nothing, cancels. This build only chooses: a grenade or a heal pick sets what G and H use (the
// next build takes the item out and the trigger uses it), a plate slots. Melee moved to V. The wheel keeps no state in the profile yet and
// draws nothing the world reads.
var WHEEL_ORDER=['frag','smoke','decoy','trip','bandage','medkit','stim','plate'];
function wheelHave(k){
  var it=ITEMS[k], n=0, i;
  if(!it||!G) return 0;
  if(it.use==='throw') return throwHave(k);
  for(i=0;G.bag&&i<G.bag.length;i++) if(G.bag[i]===k) n++;
  return n;
}
function wheelList(){
  var out=[], i, n;
  for(i=0;i<WHEEL_ORDER.length;i++){ n=wheelHave(WHEEL_ORDER[i]); if(n>0) out.push({k:WHEEL_ORDER[i],n:n}); }
  return out;
}
// The segment of m under the direction (dx,dy): 0 at the top, clockwise.
function wheelAt(m,dx,dy){
  var seg=Math.PI*2/m, a=Math.atan2(dy,dx)+Math.PI/2;
  a=((a%(Math.PI*2))+Math.PI*2)%(Math.PI*2);
  return Math.floor((a+seg/2)/seg)%m;
}
function wheelOpen(){
  var p=G&&G.player, list;
  if(!G||G.sim||G.over||G.paused||G.trade||G.hubFloor||G.bagOpen||G.mapOpen||!p||p.downed||p.dying||p.specOut||p.roll>0||p.cooking) return false;
  if(G.wheel) return true;
  list=wheelList();
  if(!list.length){ say('NOTHING TO USE'); return false; }
  G.wheel={t:0,list:list,sel:-1,mx:mouse.x,my:mouse.y,d:0};
  return true;
}
function wheelTick(dt){
  var w=G&&G.wheel, p=G&&G.player, dx, dy, d, m;
  if(!w) return;
  if(G.over||G.paused||G.trade||G.bagOpen||G.mapOpen||!p||p.downed||p.dying||p.specOut||p.cooking){ G.wheel=null; return; }
  if(!w.pad&&!keys['KeyQ']){ wheelRelease(); return; }
  w.t+=dt;
  w.list=wheelList(); m=w.list.length;
  if(!m){ G.wheel=null; return; }
  if(w.pad){ dx=w.vx||0; dy=w.vy||0; d=Math.sqrt(dx*dx+dy*dy); w.sel=(d<0.5)?-1:wheelAt(m,dx,dy); }
  else { dx=mouse.x-w.mx; dy=mouse.y-w.my; d=Math.sqrt(dx*dx+dy*dy); w.sel=(d<LH(28))?-1:wheelAt(m,dx,dy); }
  w.d=d;
  p.trigYield=1;   // the trigger is dead while the wheel is open, and until it is let go and pulled again
}
function wheelRelease(){
  var w=G&&G.wheel;
  if(!w) return false;
  G.wheel=null;
  if(w.sel<0||!w.list||!w.list[w.sel]) return false;
  return wheelPick(w.list[w.sel].k);
}
function wheelPick(k){
  var it=ITEMS[k], ti;
  if(!it||!G||G.sim) return false;
  if(it.use==='throw'){ ti=THROWKEYS.indexOf(k); if(ti<0) return false; G.tsel=ti; say((it.name+' ready').toUpperCase()); return true; }
  if(it.use==='heal'||it.use==='stim'){ G.msel=k; say((it.name+' ready').toUpperCase()); return true; }
  if(it.use==='armor') return quickPlate();
  return false;
}
function drawWheel(){
  var w=G&&G.wheel, p=G&&G.player, m, R, ri, j, seg, ac, a0, a1, gap, ro, k, it, s, cx, cy, fade, rm, ix, iy, sz, rim, nm, on, tx;
  if(!w||!w.list||!w.list.length||!p) return;
  m=w.list.length; R=Math.round(Math.min(LH(176),H*0.31)); ri=Math.round(R*0.42);
  fade=Math.min(1,w.t/0.10);
  cx=W/2; cy=H*0.5;
  try{ s=w2s(p.x,0,p.y); if(isFinite(s.x)&&isFinite(s.y)){ cx=clamp(s.x,R+LH(24),W-R-LH(24)); cy=clamp(s.y-LH(14),R+LH(24),H-R-LH(24)); } }catch(_ws){}
  seg=Math.PI*2/m; gap=(m>1)?0.05:0;
  ctx.save();
  ctx.globalAlpha=fade;
  ctx.fillStyle='rgba(5,7,9,.42)'; ctx.fillRect(0,0,W,H);
  for(j=0;j<m;j++){
    k=w.list[j].k; it=ITEMS[k]; on=(j===w.sel);
    ac=-Math.PI/2+j*seg; a0=ac-seg/2+gap/2; a1=ac+seg/2-gap/2;
    if(m===1){ a0=ac-Math.PI+0.001; a1=ac+Math.PI-0.001; }
    ro=on?R+LH(10):R;
    ctx.beginPath(); ctx.arc(cx,cy,ro,a0,a1); ctx.arc(cx,cy,ri,a1,a0,true); ctx.closePath();
    ctx.fillStyle=on?'rgba(58,46,22,.96)':'rgba(22,25,27,.92)'; ctx.fill();
    ctx.lineWidth=on?LH(2.5):LH(1.5); ctx.strokeStyle=on?UIC.acc:UIC.ui_line_hi; ctx.stroke();
    rim=null; try{ rim=RCOL[dispR(k)]; }catch(_rc){}
    if(rim){ ctx.beginPath(); ctx.arc(cx,cy,ro-LH(3),a0+0.03,a1-0.03); ctx.lineWidth=LH(3); ctx.strokeStyle=rim; ctx.stroke(); }
    rm=(ri+ro)/2; ix=cx+Math.cos(ac)*rm; iy=cy+Math.sin(ac)*rm-LH(7);
    sz=on?LH(58):LH(50);
    ctx.globalAlpha=fade*(w.list[j].n>0?1:0.3);
    drawIconSprite(ctx,k,ix,iy,sz);
    ctx.globalAlpha=fade;
    ctx.textAlign='center';
    ctx.font=FS(TYPE.micro); nm=String(it.name).toUpperCase();
    ctx.fillStyle=on?UIC.tx_1:UIC.tx_2; hudText(nm,ix,iy+sz*0.5+LH(13));
    ctx.font=FS(TYPE.label); tx='x'+w.list[j].n;
    ctx.fillStyle=UIC.acc; hudText(tx,ix+sz*0.5,iy-sz*0.32);
  }
  ctx.beginPath(); ctx.arc(cx,cy,ri-LH(8),0,Math.PI*2); ctx.fillStyle='rgba(11,12,13,.9)'; ctx.fill();
  ctx.lineWidth=LH(1.5); ctx.strokeStyle=UIC.ui_line_hi; ctx.stroke();
  ctx.textAlign='center';
  if(w.sel>=0&&w.list[w.sel]){
    ctx.font=FS(TYPE.head); ctx.fillStyle=UIC.tx_1; hudText(String(ITEMS[w.list[w.sel].k].name).toUpperCase(),cx,cy-LH(1));
    ctx.font=FS(TYPE.micro); ctx.fillStyle=UIC.acc; hudText('RELEASE TO PICK',cx,cy+LH(16));
  } else {
    ctx.font=FS(TYPE.head); ctx.fillStyle=UIC.tx_2; hudText('ITEMS',cx,cy-LH(1));
    ctx.font=FS(TYPE.micro); ctx.fillStyle=UIC.tx_3; hudText('AIM TO CHOOSE',cx,cy+LH(16));
  }
  ctx.textAlign='left';
  ctx.restore();
}
// v26.02 (beltkeys): the gun F brings up next, as a pure pick, so the belt can draw the F keycap on it. cur is the key of the gun in hand.
'@

SubRx @'
  if(code==='KeyQ'&&G&&!G.over&&!G.paused&&!repeat) meleeStrike();   // v25.xx (keyswap): Q swings the crowbar (it was F)   // v10.64, his note
'@ @'
  if(code==='KeyV'&&G&&!G.over&&!G.paused&&!repeat) meleeStrike();   // v26.xx (wheel2): V swings the crowbar (it was Q; the wheel took Q)   // v25.xx (keyswap): Q swings the crowbar (it was F)   // v10.64, his note
  if(code==='KeyQ'&&G&&!G.over&&!G.paused&&!repeat) wheelOpen();   // v26.xx (wheel2): HOLD Q opens the item wheel
'@

SubRx @'
window.addEventListener('keyup',function(e){ keys[keyRemap(e.code)]=false;
'@ @'
window.addEventListener('keyup',function(e){ keys[keyRemap(e.code)]=false; if(keyRemap(e.code)==='KeyQ'&&typeof G!=='undefined'&&G&&G.wheel&&typeof wheelRelease==='function') wheelRelease(); /* v26.xx (wheel2): and the wheel picks */
'@

SubRx @'
  var _aw=mouseWorld();
  p.face=Math.atan2(_aw.y-p.y,_aw.x-p.x);
'@ @'
  wheelTick(dt);   // v26.xx (wheel2): the item wheel, read every step
  var _aw=mouseWorld();
  p.face=(G.wheel&&G.wheel.face!==undefined)?G.wheel.face:Math.atan2(_aw.y-p.y,_aw.x-p.x);   // v26.xx (wheel2): and the aim stands still while it is open
  if(G.wheel&&G.wheel.face===undefined) G.wheel.face=p.face;
'@

SubRx @'
  drawBelt();
  // Bars, at a size you can read in a firefight.
'@ @'
  drawBelt();
  try{ drawWheel(); }catch(_dwh){}   // v26.xx (wheel2): the item wheel, over the belt
  // Bars, at a size you can read in a firefight.
'@

SubRx @'
  keys={}; try{ HHOLD.arm=0; }catch(_hh){} mouse.down=false; if(G) G.sprinting=false;
'@ @'
  keys={}; try{ HHOLD.arm=0; }catch(_hh){} mouse.down=false; if(G) G.sprinting=false; if(G) G.wheel=null; /* v26.xx (wheel2) */
'@

SubRx @'
['KeyQ','melee (crowbar)'],
'@ @'
['KeyQ','item wheel (hold)'],['KeyV','melee (crowbar)'],
'@

SubRx @'
['FIGHT',['KeyR','KeyQ','KeyF',
'@ @'
['FIGHT',['KeyR','KeyQ','KeyV','KeyF',
'@

SubRx @'
s('KeyQ')+' melee &nbsp; '
'@ @'
s('KeyV')+' melee &nbsp; '+s('KeyQ')+' item wheel (hold) &nbsp; '
'@

SubRx @'
['Q','melee, swing the crowbar'],
'@ @'
['V','melee, swing the crowbar'],['Q','item wheel, hold and aim'],
'@

SubRx @'
['Q','melee'],['F','next gun'],
'@ @'
['V','melee'],['F','next gun'],
'@

SubRx @'
'Q':['KeyQ']
'@ @'
'Q':['KeyQ'],'V':['KeyV']
'@

SubRx @'
var VER='26.22';
'@ @'
var VER='26.23';
'@

$pat = "(?m)^  now:'v26\.22:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v26.23: Hold Q for the item wheel: aim at a grenade or a heal and let go to pick it. Melee is on V now. Check 26.23 fails on v26.22',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
