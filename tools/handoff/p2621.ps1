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

# THE FORGE UPGRADES YOUR GUN TO MK II (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function sealPayout(tier){
'@ @'
// v26.xx (forgest2), HIS ORDERS 2026-10-12 ("a pack-a-punch mechanism to upgrade guns", "in-raid only", "if you extract with an upgraded gun you
// get to keep it") AND HIS QUESTION 2026-10-14: THE BENCH. At the Forge E opens THE FORGE panel; picking MK II turns the gun in your hands into
// its MK II (forgeApply, the model of v24.03) and takes FORGE_COST[0] from the RAID SCORE, the same in the DEMO (ARCADE.mine) and in CAREER
// (G.cs.s), so no caller ever asks which mode it is in. The panel is not a pause (the raid runs on, like the stall); the mouse, the number
// keys and the pad all work; ESC, TAB, B and CLOSE leave it with no charge. Too little score says NEED $2,500 and opens nothing. Done, it
// says GUN UPGRADED, shows the new gun against the old on the pickup card, rings the anvil, throws gold sparks and is HEARD: the upgrade
// pings 700 out, so machines and pillagers in earshot come to look. In two players each window has its own score and its own bench; the
// station stands in the same place in both. Nothing here draws from any stream.
function forgeScore(){ return (G&&G.arcade)?Math.max(0,ARCADE.mine|0):((G&&G.cs)?Math.max(0,G.cs.s|0):0); }
function forgeSpend(n){
  if(!(n>0)||forgeScore()<n) return false;
  if(G.arcade){ ARCADE.mine=(ARCADE.mine|0)-n; try{ arcadeScSend(); }catch(_fs){} } else G.cs.s=(G.cs.s|0)-n;
  return true;
}
function forgeGun(){ var p=G&&G.player, w=p&&p.wep; return (w&&w.id&&w.id!=='fists'&&w.mag>0&&WEAPONS[w.id])?w:null; }
function forgeOpts(){
  var w=forgeGun();
  if(!w) return {err:'NO GUN IN HAND',opts:[]};
  if(w.fk===1||w.fk===2) return {err:'MAX TIER',opts:[]};
  return {err:'',opts:[{k:'mk2',cost:FORGE_COST[0]}]};
}
function forgePromptInfo(){
  var R=forgeOpts(), w=forgeGun(), need, short;
  if(R.err) return {line:R.err,sub:'',short:false};
  need=R.opts[0].cost; short=forgeScore()<need;
  return {line:'['+keyLabel('KeyE','E')+'] UPGRADE \u00b7 '+(w.fk===1?'MK III':'MK II'),sub:short?('NEED '+arcadeCr(need)):arcadeCr(need),short:short};
}
function forgeOpen(){
  var R=forgeOpts(), need;
  if(!G||G.over||G.forgeUI) return false;
  if(R.err){ say(R.err,'info'); try{ sndUi('deny'); }catch(_f0){} return false; }
  need=R.opts[0].cost;
  if(forgeScore()<need){ say('NEED '+arcadeCr(need),'warn'); try{ sndUi('deny'); }catch(_f1){} return false; }
  G.forgeUI={t0:G.t||0,sel:0,n:R.opts.length,cells:[],closeBox:null,mx:NaN,my:NaN};
  G.mapOpen=false; mouse.down=false;
  try{ sndUi('open'); }catch(_f2){}
  return true;
}
function forgeClose(spent){
  if(!G) return false;
  G.forgeUI=null; G.forgeLock=1;
  if(typeof PAD!=='undefined'&&PAD&&PAD.on) PAD.xAfterTrade=1;
  if(!spent){ try{ sndUi('back'); }catch(_fc){} }
  return true;
}
function forgeBuy(ix){
  var U=G&&G.forgeUI, p=G&&G.player, w=forgeGun(), R=forgeOpts(), o=R.opts[ix], nw, col, tag, F=G&&G.forge;
  if(!U||!p||!w||!o||G.over) return false;
  if(!forgeSpend(o.cost)){ say('NEED '+arcadeCr(o.cost),'warn'); try{ sndUi('deny'); }catch(_b0){} return false; }
  nw=forgeApply(w,1);
  p.wep=nw; p.wepIssued=false;
  col=FORGE_GOLD; tag='MK II';
  say('GUN UPGRADED','obj',{sub:String(nw.name).toUpperCase()});
  G.gunCard={gk:nw.id,w:nw,vs:w,route:tag+'  -'+arcadeCr(o.cost),t0:G.t||0};
  blip('forge');
  if(F&&isFinite(F.x)){
    spark(F.x,F.y-26,col,40,420); flash(F.x,F.y-30,130,col,0.5);
    ping(F.x,F.y,700,false,false,'player','fire');
  }
  forgeClose(true);
  return true;
}
function forgeClick(){
  var U=G&&G.forgeUI, i, c, b;
  if(!U) return false;
  b=U.closeBox;
  if(b&&mouse.x>=b.x&&mouse.x<=b.x+b.w&&mouse.y>=b.y&&mouse.y<=b.y+b.h){ forgeClose(); return true; }
  for(i=0;i<(U.cells||[]).length;i++){
    c=U.cells[i];
    if(mouse.x>=c.x&&mouse.x<=c.x+c.w&&mouse.y>=c.y&&mouse.y<=c.y+c.h){ U.sel=c.i; forgeBuy(c.i); return true; }
  }
  return true;
}
// The panel, in his graphite menu style: a chamfered plate with the amber tick, Barlow Condensed caps, a keycap on every key it names.
// Drawn on the HUD canvas at the size the rest of the HUD grows to (hudRes), centred; the cards it draws are also its mouse targets.
function forgeChamfer(x,y,w,h,c){ ctx.beginPath(); ctx.moveTo(x+c,y); ctx.lineTo(x+w,y); ctx.lineTo(x+w,y+h-c); ctx.lineTo(x+w-c,y+h); ctx.lineTo(x,y+h); ctx.lineTo(x,y+c); ctx.closePath(); }
function forgeKeycap(label,x,yb,font){
  var a, sw, of=ctx.font;
  ctx.font=font; a=ctx.measureText('M').actualBoundingBoxAscent||LH(12);
  sw=Math.max(hudRawW(label)+LH(14),a+LH(9));
  hudKey(label,x,yb,a,sw);
  ctx.font=of;
  return sw;
}
function drawForgeUI(){
  var U=G&&G.forgeUI, p=G&&G.player, R, w, rs, u, fT, fH, fL, fM, fG, pT, pH, pL, pM, n, PW, PH, HH, GB, CH, FH, pad, x, y, i, o, nw, os, ns, sel, c, cx, cy, cw, chh, a, yy, rows, k, vr, tx, tw, ckL, xr, ok, lab, kw, hy;
  if(!U||!p||G.over) return;
  R=forgeOpts(); w=forgeGun();
  if(!w||!R.opts.length){ G.forgeUI=null; return; }
  rs=Math.max(1,hudRes()); u=function(px){ return Math.round(LH(px)*rs); };
  fT=hudFS(TYPE.title); fH=hudFS(TYPE.head); fL=hudFS(TYPE.label); fM=hudFS(TYPE.micro); fG=hudFS(TYPE.huge);
  pT=msgPx(fT); pH=msgPx(fH); pL=msgPx(fL); pM=msgPx(fM);
  n=R.opts.length; pad=u(24); HH=u(54); GB=u(92); CH=u(132); FH=u(46);
  PW=u(600); PH=HH+GB+u(8)+CH+u(10)+FH;
  x=Math.round((W-PW)/2); y=Math.round(H*0.47-PH/2);
  if(y<u(8)) y=u(8);
  ctx.save();
  try{
    ctx.textBaseline='alphabetic'; ctx.textAlign='left';
    ctx.fillStyle='rgba(0,0,0,.40)'; ctx.fillRect(x+u(6),y+u(8),PW,PH);
    hudPanel(x,y,PW,PH,0.97);
    // the header: the name, the score, the way out
    ctx.font=fT; ctx.fillStyle=UIC.acc; ctx.fillText('THE FORGE',x+pad,y+Math.round(HH*0.66));
    ok=forgeScore(); xr=x+PW-pad; hy=y+Math.round(HH*0.5);
    ctx.font=fL; lab=padOn()?padB('B'):'ESC';
    a=ctx.measureText('M').actualBoundingBoxAscent||LH(12); kw=Math.max(hudRawW(lab)+LH(14),a+LH(9)); tw=hudRawW('CLOSE');
    ckL=u(8)+kw+u(8)+tw+u(12);
    forgeChamfer(xr-ckL,hy-u(15),ckL,u(30),u(6));
    ctx.fillStyle=(mouse.x>=xr-ckL&&mouse.x<=xr&&mouse.y>=hy-u(15)&&mouse.y<=hy+u(15))?UIC.ui_hover:UIC.ui_raised; ctx.fill();
    ctx.strokeStyle=UIC.ui_line_hi; ctx.lineWidth=1; ctx.stroke();
    U.closeBox={x:xr-ckL,y:hy-u(15),w:ckL,h:u(30)};
    forgeKeycap(lab,xr-ckL+u(8),hy+Math.round(pL*0.35),fL);
    ctx.textAlign='left'; ctx.font=fL; ctx.fillStyle=UIC.tx_2; ctx.fillText('CLOSE',xr-ckL+u(8)+kw+u(8),hy+Math.round(pL*0.35));
    ctx.textAlign='right'; ctx.font=fH; ctx.fillStyle=UIC.tx_1; ctx.fillText(arcadeCr(ok),xr-ckL-u(24),hy+Math.round(pH*0.4));
    ctx.font=fM; ctx.fillStyle=UIC.tx_3; ctx.fillText('RAID SCORE',xr-ckL-u(24),hy-Math.round(pH*0.5));
    ctx.textAlign='left';
    ctx.fillStyle=UIC.ui_line; ctx.fillRect(x+pad,y+HH,PW-pad*2,1);
    // the gun on the bench and the ladder it climbs
    yy=y+HH+Math.round(GB/2);
    try{ gunIcon(ctx,w.id,x+pad+u(52),yy,u(80),w.tint); }catch(_gi){}
    ctx.font=fH; ctx.fillStyle=RCOL[gunRarity(w.id)]||UIC.tx_1; ctx.fillText(String(w.name).toUpperCase(),x+pad+u(116),yy-u(2));
    ctx.font=fM; ctx.fillStyle=UIC.tx_3; ctx.fillText('IN YOUR HANDS',x+pad+u(116),yy-u(2)-pH-u(2));
    rows=['MK I','MK II','MK III']; xr=x+PW-pad;
    for(i=2;i>=0;i--){
      cw=u(62); cx=xr-(2-i)*(cw+u(8))-cw; k=(w.fk||0);
      forgeChamfer(cx,yy-u(15),cw,u(30),u(6));
      if(i===k){ ctx.fillStyle=UIC.acc; ctx.fill(); }
      else { ctx.fillStyle=(i===k+1)?UIC.acc_dim:UIC.ui_raised; ctx.fill(); ctx.strokeStyle=(i===k+1)?UIC.acc:UIC.ui_line; ctx.lineWidth=(i===k+1)?2:1; ctx.stroke(); }
      ctx.font=fL; ctx.textAlign='center'; ctx.fillStyle=(i===k)?UIC.acc_ink:((i===k+1)?UIC.acc:UIC.tx_3);
      ctx.fillText(rows[i],cx+cw/2,yy+Math.round(pL*0.35)); ctx.textAlign='left';
    }
    // the choices
    U.cells=[];
    cy=y+HH+GB+u(8); cx=x+pad; cw=PW-pad*2; chh=CH;
    for(i=0;i<n;i++){
      o=R.opts[i]; sel=((U.sel|0)===i);
      c={x:cx,y:cy,w:cw,h:chh,i:i}; U.cells.push(c);
      if(isFinite(mouse.x)&&(mouse.x!==U.mx||mouse.y!==U.my)){ if(mouse.x>=c.x&&mouse.x<=c.x+c.w&&mouse.y>=c.y&&mouse.y<=c.y+c.h) U.sel=i; }
      sel=((U.sel|0)===i);
      forgeChamfer(c.x,c.y,c.w,c.h,u(10));
      ctx.fillStyle=sel?UIC.ui_hover:UIC.ui_raised; ctx.fill();
      ctx.strokeStyle=sel?UIC.acc:UIC.ui_line; ctx.lineWidth=sel?2:1; ctx.stroke();
      ctx.fillStyle=FORGE_GOLD; ctx.fillRect(c.x+u(10),c.y,u(48),u(3));
      if(o.k==='mk2'){
        nw=forgeApply(w,1); os=gunStats(w); ns=gunStats(nw);
        ctx.font=fG; ctx.fillStyle=FORGE_GOLD; ctx.fillText('MK II',c.x+u(22),c.y+u(58));
        ctx.font=fM; ctx.fillStyle=UIC.tx_3; ctx.fillText('GUN UPGRADE',c.x+u(24),c.y+u(78));
        vr=[['DAMAGE',os.dmg,ns.dmg],['MAGAZINE',w.mag,nw.mag],['RELOAD',(w.reload/1000).toFixed(2)+'S',(nw.reload/1000).toFixed(2)+'S']];
        tx=c.x+u(176);
        for(k=0;k<3;k++){
          yy=c.y+u(38)+k*u(30);
          ctx.font=fM; ctx.fillStyle=UIC.tx_3; ctx.textAlign='left'; ctx.fillText(vr[k][0],tx,yy);
          ctx.font=fL; ctx.fillStyle=UIC.tx_2; ctx.textAlign='right'; ctx.fillText(String(vr[k][1]),tx+u(122),yy);
          ctx.strokeStyle=UIC.acc; ctx.lineWidth=Math.max(1.5,u(2)); ctx.beginPath(); ctx.moveTo(tx+u(134),yy-u(9)); ctx.lineTo(tx+u(141),yy-u(4)); ctx.lineTo(tx+u(134),yy+u(1)); ctx.stroke();
          ctx.fillStyle=UIC.tx_1; ctx.textAlign='left'; ctx.fillText(String(vr[k][2]),tx+u(152),yy);
        }
        ctx.textAlign='right'; ctx.font=fG; ctx.fillStyle=(forgeScore()<o.cost)?UIC.danger:UIC.acc;
        ctx.fillText(arcadeCr(o.cost),c.x+c.w-u(22),c.y+u(58));
        ctx.font=fM; ctx.fillStyle=UIC.tx_3; ctx.fillText('COST',c.x+c.w-u(22),c.y+u(28));
        ctx.textAlign='left';
        forgeKeycap(padOn()?padB('A'):'1',c.x+c.w-u(22)-u(30),c.y+chh-u(14),fL);
        ctx.font=fL; ctx.fillStyle=UIC.tx_1; ctx.textAlign='right'; ctx.fillText('UPGRADE',c.x+c.w-u(22)-u(40),c.y+chh-u(14)); ctx.textAlign='left';
      }
      cx+=cw+u(12);
    }
    U.mx=mouse.x; U.my=mouse.y;
    // the keys it names
    yy=y+PH-Math.round(FH/2)+Math.round(pL*0.35); xr=x+pad;
    ctx.font=fL;
    function hint(key,txt){ var kw=forgeKeycap(key,xr,yy,fL); ctx.font=fL; ctx.fillStyle=UIC.tx_2; ctx.textAlign='left'; ctx.fillText(txt,xr+kw+u(8),yy); xr+=kw+u(8)+hudRawW(txt)+u(26); }
    if(padOn()){ hint(padB('A'),'UPGRADE'); hint(padB('B'),'CLOSE'); }
    else { hint('1','UPGRADE'); hint(keyLabel('KeyE','E'),'CONFIRM'); hint('ESC','CLOSE'); }
  } finally { ctx.restore(); }
}
function sealPayout(tier){
'@

SubRx @'
  if(G.nearPad) return 'ring';
'@ @'
  if(G.nearForge&&!G.forgeBlocked) return 'forge';   // v26.xx (forgest2): a crate or a pile underfoot still wins E, as at the stall
  if(G.nearPad) return 'ring';
'@

SubRx @'
    G.nearPed=null; G.pedBlocked=0;
'@ @'
    G.nearPed=null; G.pedBlocked=0;
    G.nearForge=null; G.forgeUI=null;   // v26.xx (forgest2): and the bench shuts
'@

SubRx @'
// THE WALL-CLIP TRIPWIRE, v4.06.
'@ @'
  // v26.xx (forgest2), HIS QUESTION 2026-10-14 (where is the Forge): THE FORGE IN REACH. Within 70 of the station with a clear line, standing,
  // E opens THE FORGE panel (a crate or pile within 46 keeps the key, a Peddler in reach takes it first, as the stall does). The open panel
  // is not a pause: the clocks run on (the same two calls the stall makes) and it shuts when he is taken down or walks 95 away.
  if(G.forge&&!G.sim){
    var fgd=dist(p,G.forge);
    G.nearForge=(!p.downed&&fgd<FORGE_REACH&&losClear(p.x,p.y,G.forge.x,G.forge.y,G.vseg))?G.forge:null;
    G.forgeBlocked=crateUnderfoot?1:0;
    if(G.forgeUI&&(p.downed||fgd>95)) forgeClose(false);
    if(G.nearForge&&!G.forgeUI&&keys['KeyE']&&!G.forgeLock&&!G.forgeBlocked&&promptPick(p)==='forge'){ G.forgeLock=1; forgeOpen(); }
    if(!keys['KeyE']) G.forgeLock=0;
    if(G.forgeUI){ tickRegen(dt); tryExtractTick(dt); return; }
  }
// THE WALL-CLIP TRIPWIRE, v4.06.
'@

SubRx @'
// v6.41, his note: M is a toggle, not a hold.
'@ @'
  // v26.xx (forgest2): THE OPEN FORGE PANEL OWNS THE KEYS. 1 to 4 picks and buys, E or ENTER buys the marked choice (not in its first
  // fifth of a second, so a double tap of E cannot spend), ESC, TAB, B, I and M leave with no charge; the belt, the throw, the heal and
  // the melee keys do nothing behind it, as at the stall.
  if(G&&!G.over&&G.forgeUI&&!G.trade){
    if(ev) ev.preventDefault();
    if(code==='Escape'||code==='Tab'||code==='KeyB'||code==='KeyI'||code==='KeyM'){ if(!repeat) forgeClose(false); return; }
    if(code==='KeyE'||code==='Enter'||code==='NumpadEnter'){ if(!repeat&&(G.t||0)-(G.forgeUI.t0||0)>=0.2) forgeBuy(G.forgeUI.sel|0); return; }
    if(code.indexOf('Digit')===0){
      if(!repeat){ var fdn=parseInt(code.slice(5),10); if(fdn>=1&&fdn<=(G.forgeUI.n|0)){ G.forgeUI.sel=fdn-1; forgeBuy(fdn-1); } }
      return;
    }
    if(code==='KeyG'||code==='Space'||code==='KeyQ'||code==='KeyC'||code==='KeyH'||code==='KeyF'||code==='KeyU'||code==='KeyJ') return;
  }
// v6.41, his note: M is a toggle, not a hold.
'@

SubRx @'
  if(e.button===0&&G&&!G.over&&G.trade) return;
'@ @'
  if(e.button===0&&G&&!G.over&&G.forgeUI){ forgeClick(); return; }   // v26.xx (forgest2): a click on the Forge panel picks, and never fires behind it
  if(e.button===0&&G&&!G.over&&G.trade) return;
'@

SubRx @'
  // Ownership, not assignment. Writing these unconditionally meant that merely
'@ @'
  // v26.xx (forgest2): THE FORGE PANEL ON A PAD. D-pad or the left stick across picks, A or X buys the marked choice, B leaves with no
  // charge, Menu pauses; nothing else acts behind it (padRelease first, so nothing fires), and an X held from the open is spent.
  if(G.forgeUI&&!G.over){
    padRelease();
    var _fU=G.forgeUI, _fn=Math.max(1,_fU.n|0), _fdx=0, _fq=padAxis(ax[0]||0), _fq2=(_fq<-0.5)?-1:((_fq>0.5)?1:0);
    if((pressed(14)&&!PAD.prev[14])||(pressed(12)&&!PAD.prev[12])) _fdx=-1;
    else if((pressed(15)&&!PAD.prev[15])||(pressed(13)&&!PAD.prev[13])) _fdx=1;
    else if(_fq2&&_fq2!==PAD.fgStick) _fdx=_fq2;
    PAD.fgStick=_fq2;
    if(_fdx){ _fU.sel=((_fU.sel|0)+_fdx+_fn)%_fn; try{ sndUi('move'); }catch(_fm){} }
    if((pressed(0)&&!PAD.prev[0])||(pressed(2)&&!PAD.prev[2])) forgeBuy(_fU.sel|0);
    else if(pressed(1)&&!PAD.prev[1]) forgeClose(false);
    if(pressed(9)&&!PAD.prev[9]){ raidKey('KeyP',false,null); keys['KeyP']=false; }
    for(var _fb=0;_fb<bt.length;_fb++) PAD.prev[_fb]=pressed(_fb);
    return;
  }
  // Ownership, not assignment. Writing these unconditionally meant that merely
'@

SubRx @'
PAD.xMode=(G.nearContainer||G.nearPad||G.nearDown||G.nearDoor||G.nearPed||
'@ @'
PAD.xMode=(G.nearContainer||G.nearPad||G.nearDown||G.nearDoor||G.nearPed||G.nearForge||
'@

SubRx @'
  // v9.61: THE VERB THE SECOND CENTRE BLOCK USED TO OWN. Worked out here so the
'@ @'
  // v26.xx (forgest2), HIS QUESTION 2026-10-14: THE FORGE PROMPT. At the station the one E prompt reads [E] UPGRADE with the gun's next MK and
  // its price under it (NEED $2,500 in danger red when short); with nothing to upgrade it says why in caps (NO GUN IN HAND, MAX TIER).
  if(!G.over&&G.nearForge&&!G.forgeUI&&!p.downed&&_pk==='forge'){
    var _fi=forgePromptInfo(), _fpp=w2s(p.x,66,p.y), _hsFG=hudAtIn(_fpp.x,_fpp.y);
    hudPrompt(_fi.line,_fpp.x,_fpp.y,{sub:_fi.sub,subCol:_fi.short?UIC.danger:UIC.acc,accent:_fi.short?UIC.danger:FORGE_GOLD});
    ctx.textAlign='left';
    if(_hsFG) ctx.restore();
  }
  // v9.61: THE VERB THE SECOND CENTRE BLOCK USED TO OWN. Worked out here so the
'@

SubRx @'
if(G.trade) drawTrade();
'@ @'
if(G.trade) drawTrade();
  try{ if(G.forgeUI) drawForgeUI(); }catch(_dfu){}   // v26.xx (forgest2): THE FORGE panel
'@

SubRx @'
    if(G.trade){ G.trade=null; G.pedLock=1; return true; }
'@ @'
    if(G.trade){ G.trade=null; G.pedLock=1; return true; }
    if(G.forgeUI){ forgeClose(false); return true; }   // v26.xx (forgest2)
'@

SubRx @'
  } else if(type==='elFire'){
'@ @'
  } else if(type==='forge'){
    // v26.xx (forgest2): the Forge: a low hammer thump, a metal ring over a second, and a short hiss of quench
    var fgo=a.createOscillator(), fgg=a.createGain();
    fgo.type='sine'; fgo.frequency.setValueAtTime(130,t); fgo.frequency.exponentialRampToValueAtTime(46,t+.22);
    fgg.gain.setValueAtTime(.26*vol,t); fgg.gain.exponentialRampToValueAtTime(.001,t+.28);
    fgo.connect(fgg); fgg.connect(OUT); fgo.start(t); fgo.stop(t+.3);
    [880,1318,2093].forEach(function(F,ix){
      var fro=a.createOscillator(), frg=a.createGain(), t0=t+.02+ix*.011;
      fro.type='triangle'; fro.frequency.setValueAtTime(F,t0);
      frg.gain.setValueAtTime(.001,t0); frg.gain.linearRampToValueAtTime([.09,.05,.025][ix]*vol,t0+.004); frg.gain.exponentialRampToValueAtTime(.001,t0+.9-ix*.18);
      fro.connect(frg); frg.connect(OUT); fro.start(t0); fro.stop(t0+.95);
    });
    var fhl=Math.floor(a.sampleRate*0.38), fhb=a.createBuffer(1,fhl,a.sampleRate), fhc=fhb.getChannelData(0);
    for(var fhi=0;fhi<fhl;fhi++) fhc[fhi]=(Math.random()*2-1)*Math.pow(1-fhi/fhl,1.6);
    var fhs=a.createBufferSource(); fhs.buffer=fhb;
    var fhf=a.createBiquadFilter(); fhf.type='highpass'; fhf.frequency.value=4200;
    var fhg=a.createGain(); fhg.gain.value=.07*vol;
    fhs.connect(fhf); fhf.connect(fhg); fhg.connect(OUT); fhs.start(t+.08);
  } else if(type==='elFire'){
'@

SubRx @'
var VER='26.20';
'@ @'
var VER='26.21';
'@

$pat = "(?m)^  now:'v26\.20:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v26.21: At THE FORGE press E to upgrade your gun to MK II for 2,500 score. The MK III and the elements come next. Check 26.21 fails on v26.20',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
