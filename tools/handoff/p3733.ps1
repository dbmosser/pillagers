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

# SEASON ZERO M2: THE BIRTH CARD IN THE UNDERCROFT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  if(!p.pil||typeof p.pil!=='object'||Array.isArray(p.pil)){ g=Math.max(p.pilGen|0,p.hall.length)+1; p.pil=pilMake(p.pname,g); }
'@ @'
  // v37.xx (cw-m2birth): a pillager that ended (it is in the hall) leaves nobody living until the birth card; only a save with no lineage at all gets its first one here.
  if(!p.pil||typeof p.pil!=='object'||Array.isArray(p.pil)){ if(p.hall.length) p.pil=null; else { g=Math.max(p.pilGen|0,p.hall.length)+1; p.pil=pilMake(p.pname,g); } }
'@

SubRx @'
  pilClean(p.pil);
'@ @'
  if(p.pil) pilClean(p.pil);
'@

SubRx @'
  if(typeof p.pilGen!=='number'||!isFinite(p.pilGen)||p.pilGen<p.pil.gen) p.pilGen=p.pil.gen;
'@ @'
  if(typeof p.pilGen!=='number'||!isFinite(p.pilGen)||(p.pil&&p.pilGen<p.pil.gen)) p.pilGen=p.pil?p.pil.gen:p.hall.length;
'@

SubRx @'
function pilBirth(p,a){
'@ @'
function pilBirth(p,a,nm){
'@

SubRx @'
  if(typeof a==='string'&&a){ r.name=a.slice(0,24); r.num=pilNum(p,r.name); }
'@ @'
  if(typeof a==='string'&&a){ r.name=a.slice(0,24); r.num=pilNum(p,r.name); }
  if(typeof nm==='string'&&nm&&nm!==r.name){ r.name=nm.slice(0,24); r.num=pilNum(p,r.name); }   // v37.xx (cw-m2birth): the name he typed on the birth card
'@

SubRx @'
  pilBirth(P);
  if(r) P.pilNote={t:String(r.name).toLowerCase()+' is gone  pillager '+P.pilGen,shown:0};
'@ @'
  pilHeirs(P);   // v37.xx (cw-m2birth), his rulings of 11-01: no birth here any more; the card in the Undercroft births one of these
  if(r) P.pilNote={t:String(r.name).toLowerCase()+' is gone  pillager '+pilNext(P),shown:0};
'@

SubRx @'
      if(P.freeKit&&!g.sim){ P.dropKit=[]; g.freeKit=1; P.freeKit=0; }
'@ @'
      if(P.freeKit&&!g.sim){ P.dropKit=[]; g.freeKit=1; P.freeKit=0; g.freeKitK=freeKitNow(); if(g.freeKitK) P.birthKit=null; }   // v37.xx (cw-m2birth): a starter kit he paid for goes up here and only here
'@

SubRx @'
      for(var _fk=0;_fk<FREEKIT.length;_fk++){
'@ @'
      var _fkL=g.freeKitK?g.freeKitK.items:FREEKIT, _fkG=g.freeKitK?g.freeKitK.gun:FREEKIT_GUN;   // v37.xx (cw-m2birth)
      for(var _fk=0;_fk<_fkL.length;_fk++){
'@

SubRx @'
        var _fi=ITEMS[FREEKIT[_fk]]; if(!_fi) continue;
'@ @'
        var _fi=ITEMS[_fkL[_fk]]; if(!_fi) continue;
'@

SubRx @'
        if(_fi.use==='throw'){ if(g.pouch[FREEKIT[_fk]]!==undefined) g.pouch[FREEKIT[_fk]]++; }
'@ @'
        if(_fi.use==='throw'){ if(g.pouch[_fkL[_fk]]!==undefined) g.pouch[_fkL[_fk]]++; }
'@

SubRx @'
        else g.bag.push(FREEKIT[_fk]);
'@ @'
        else g.bag.push(_fkL[_fk]);
'@

SubRx @'
      if(WEAPONS[FREEKIT_GUN]){
'@ @'
      if(WEAPONS[_fkG]){
'@

SubRx @'
        arSetHeldGun(g.player,WEAPONS[FREEKIT_GUN]);
'@ @'
        arSetHeldGun(g.player,WEAPONS[_fkG]);
'@

SubRx @'
          if(_d3h[0]||((G.freeKit||G.spawnGun)&&_d3g===FREEKIT_GUN&&!_d3h[1])) continue;
'@ @'
          if(_d3h[0]||((G.freeKit||G.spawnGun)&&_d3g===kitGunNow()&&!_d3h[1])) continue;
'@

SubRx @'
        if((G.freeKit||G.spawnGun)&&_d3w<0&&_d3g===FREEKIT_GUN) continue;
'@ @'
        if((G.freeKit||G.spawnGun)&&_d3w<0&&_d3g===kitGunNow()) continue;
'@

SubRx @'
    var _keq=kept.filter(function(w){ return !((G.freeKit||G.spawnGun)&&w.id===FREEKIT_GUN&&
'@ @'
    var _keq=kept.filter(function(w){ return !((G.freeKit||G.spawnGun)&&w.id===kitGunNow()&&
'@

SubRx @'
      var _egFree=!!((G.freeKit||G.spawnGun)&&!_egArm&&gone[j].id===FREEKIT_GUN);
'@ @'
      var _egFree=!!((G.freeKit||G.spawnGun)&&!_egArm&&gone[j].id===kitGunNow());
'@

SubRx @'
    if(!G.sim){ P.kitBeforeFree=null; P.hotBeforeFree=null; P.gunBeforeFree=null; dropDeadKeys(); saveProfile(); }
'@ @'
    if(!G.sim&&G.freeKitK){ P.birthKit=G.freeKitK.id; P.freeKit=1; P.kitPick='free'; }   // v37.xx (cw-m2birth): he paid for it and went nowhere, so it is still his
    if(!G.sim){ P.kitBeforeFree=null; P.hotBeforeFree=null; P.gunBeforeFree=null; dropDeadKeys(); saveProfile(); }
'@

SubRx @'
var FREEKIT_GUN='pistol';
'@ @'
var FREEKIT_GUN='pistol';
// v37.xx (cw-m2birth), HIS RULINGS OF 11-01, open question 2 default: starter kits at each birth, paid in $: nothing (free), basic $300 (a plain gun and bandages), privileged $1,500 (a
// better gun, a medkit and, until m3 gear drops exist, an armor plate). A kit goes up the way the freebie does: nothing lands in the stash, the raid hands it out, an extract keeps it,
// a death takes it. So a kit can never be bought and sold back at home for more than it cost. P.birthKit is the kit paid for and not yet taken up.
var BIRTH_KITS={
  none:{id:'none',n:'nothing',c:0,t:'your own pack',items:[],gun:null},
  basic:{id:'basic',n:'basic',c:300,t:'compact smg, 3 bandages',s:'compact smg \u00b7 3 bandages',items:['bandage','bandage','bandage'],gun:'smg'},
  priv:{id:'priv',n:'privileged',c:1500,t:'burst carbine, medkit, armor plate',s:'burst carbine \u00b7 2 items',items:['medkit','plate'],gun:'carbine'}
};
var BIRTH_KIT_ORDER=['none','basic','priv'];
function freeKitNow(){ var K=(typeof P==='object'&&P&&P.birthKit)?BIRTH_KITS[P.birthKit]:null; return (K&&K.gun)?K:null; }
function kitGunNow(){ return (G&&G.freeKitK&&G.freeKitK.gun)||FREEKIT_GUN; }
'@

SubRx @'
  return 'A Scav Pistol, two Bandages, one Frag Charge and one Armour Plate.';
'@ @'
  if(freeKitNow()) return freeKitNow().t;   // v37.xx (cw-m2birth)
  return 'A Scav Pistol, two Bandages, one Frag Charge and one Armour Plate.';
'@

SubRx @'
    '<b>FREEBIE KIT</b>'+
'@ @'
    '<b>'+(freeKitNow()?freeKitNow().n+' kit':'FREEBIE KIT')+'</b>'+
'@

SubRx @'
      var _fkg=WEAPONS[FREEKIT_GUN];
'@ @'
      if(freeKitNow()){ sw.innerHTML='<span style="color:var(--amber)">'+freeKitNow().n+' kit</span>  &middot;  '+escHtml(freeKitNow().t); return; }   // v37.xx (cw-m2birth)
      var _fkg=WEAPONS[FREEKIT_GUN];
'@

SubRx @'
  bs=host.querySelectorAll('.kitb');
'@ @'
  bs=host.querySelectorAll('.kitb');
  // v37.xx (cw-m2birth): with a starter kit paid for, the freebie tile is that kit
  (function(){ var K=freeKitNow(), b=host.querySelector('.kitb[data-kit="free"]'), sp=b?b.querySelectorAll('span'):[]; KIT_INFO.free=K?[K.n+' kit',K.s]:['FREEBIE KIT','SCAV PISTOL \u00b7 4 ITEMS']; if(sp.length>1){ sp[0].textContent=KIT_INFO.free[0]; sp[1].textContent=KIT_INFO.free[1]; } })();
'@

SubRx @'
  if(netGuestHeld()) return false;   // v15.91: before the kit is committed or a window shut, so a guest held at the lift loses nothing
'@ @'
  if(netGuestHeld()) return false;   // v15.91: before the kit is committed or a window shut, so a guest held at the lift loses nothing
  if(birthNeed()){ birthOpen(); return false; }   // v37.xx (cw-m2birth): nothing ascends with no living pillager
'@

SubRx @'
function(){ if(netGuestHeld()) return; liftResetDay(); commitKit(); ac(); startRaid(); }
'@ @'
function(){ if(netGuestHeld()) return; if(birthNeed()){ birthOpen(); return; } liftResetDay(); commitKit(); ac(); startRaid(); }
'@

SubRx @'
  snap=netUpSnapP();
'@ @'
  if(!m.arc) try{ birthAuto(); }catch(eB){}   // v37.xx (cw-m2birth): the host went up while the card was open, so heir one goes up with him
  snap=netUpSnapP();
'@

SubRx @'
  if(document.querySelector('.modal.on')) return;   // he is reading one already
'@ @'
  if(birthNeed()){ birthOpen(); return; }   // v37.xx (cw-m2birth): no living pillager, so the birth card comes first; closing it comes back here
  if(document.querySelector('.modal.on')) return;   // he is reading one already
'@

SubRx @'
  if(PADNAME||!input||input.id!=='pnamein')return false;
'@ @'
  if(PADNAME||!input||(input.id!=='pnamein'&&input.id!=='birthname'))return false;
'@

SubRx @'
  if(!document.getElementById('title').classList.contains('on')){padNameClose(false);return false;}
'@ @'
  if(!document.getElementById('title').classList.contains('on')&&!birthOn()){padNameClose(false);return false;}
'@

SubRx @'
el.id!=='pnamein'&&!/^(button|submit
'@ @'
el.id!=='pnamein'&&el.id!=='birthname'&&!/^(button|submit
'@

SubRx @'
else if(PAD.focus.id==='pnamein') padNameStart(PAD.focus);
'@ @'
else if(PAD.focus.id==='pnamein'||PAD.focus.id==='birthname') padNameStart(PAD.focus);
'@

SubRx @'
    if(md===IMENU){ closeItemMenu(); padSetFocus(null); PAD.focus=null; return true; }
'@ @'
    if(md.id==='birthmodal'){ birthFinish(false); padSetFocus(null); PAD.focus=null; return true; }   // v37.xx (cw-m2birth): a trait name must never pass for the way out
    if(md===IMENU){ closeItemMenu(); padSetFocus(null); PAD.focus=null; return true; }
'@

SubRx @'
function drawAvatarCanvas(){
'@ @'
function drawAvatarCanvas(cv){
'@

SubRx @'
  var c=document.getElementById('avcv'); if(!c||typeof drawOp!=='function') return;
'@ @'
  var c=cv||document.getElementById('avcv'); if(!c||typeof drawOp!=='function') return;   // v37.xx (cw-m2birth): the birth card draws the same figure
'@

SubRx @'
closecodex',trophymodal:'closetrophy'};
'@ @'
closecodex',trophymodal:'closetrophy',birthmodal:'closebirth'};
'@

SubRx @'
<div class="modal" id="welcomemodal">
'@ @'
<!-- v37.xx (cw-m2birth): the birth card, picture a of tools/handoff/console/notes/progression/birth-pick-1101.html -->
<div class="modal" id="birthmodal">
  <h3><span id="birthhead">your next pillager</span></h3>
  <div id="birthwrap">
    <div id="birthheirs"></div>
    <div id="birthmid">
      <div id="birthfig"><canvas id="birthcv" width="200" height="236"></canvas><button id="birthlook">edit look</button></div>
      <div id="birthside">
        <div class="bhlab">name</div>
        <input id="birthname" maxlength="16" autocomplete="off" spellcheck="false" aria-label="name">
        <div class="bhlab">starter kit</div>
        <div id="birthkits"></div>
      </div>
    </div>
  </div>
  <div style="display:flex;gap:8px;margin-top:10px">
    <button id="birthgo" class="deploy" style="padding:8px 22px">ascend</button>
    <button id="closebirth" data-esc="1" style="padding:8px 22px;margin-left:auto">close</button>
  </div>
</div>
<div class="modal" id="welcomemodal">
'@

SubRx @'
document.getElementById('closeappear').onclick=function(){
'@ @'
// v37.xx (cw-m2birth), HIS RULINGS OF 11-01, plan m2: THE BIRTH MOMENT. After a death nobody is living and P.heirs holds the roll. The first arrival in the Undercroft opens this card:
// three heirs, a typed name (lower case, the limit the title's name box has), today's look editor (random once per birth, his edits kept, SURPRISE ME lives there) and the starter kit.
// One default button: what is lit goes, and nothing touched is heir one, the random look and no kit. CLOSE, ESC and B birth what is lit too, so the card cannot be lost; a reload
// with nobody living opens it again. An old save has a living pillager and never sees it; nor does the demo or the player 2 window, which keeps today's rules until m3f.
careerStyle('birthcss',
  '#root #birthmodal{align-items:center}'+
  '#root #birthmodal #birthwrap{width:100%;max-width:1200px;display:flex;flex-direction:column;gap:16px;margin:0 auto}'+
  '#root #birthmodal #birthheirs{display:grid;grid-template-columns:repeat(3,minmax(0,1fr));gap:16px}'+
  '#root #birthmodal .bhcard{display:flex;flex-direction:column;align-items:flex-start;justify-content:flex-start;gap:4px;min-height:136px;padding:16px 24px;background:var(--ui-panel);border:2px solid var(--ui-line-hi);border-radius:var(--rad);color:var(--tx-1);text-align:left;text-transform:none}'+
  '#root #birthmodal .bhcard.on{border-color:var(--acc);background:var(--ui-raised)}'+
  '#root #birthmodal .bhcard b{font:700 var(--fs-title)/1.15 var(--f-cond);color:var(--tx-1)}'+
  '#root #birthmodal .bhcard i{font:600 var(--fs-body)/1.3 var(--f-cond);font-style:normal}'+
  '#root #birthmodal #birthmid{display:grid;grid-template-columns:232px minmax(0,1fr);gap:16px}'+
  '#root #birthmodal #birthfig{display:flex;flex-direction:column;align-items:center;gap:8px;padding:8px 16px 16px;background:var(--ui-panel);border:1px solid var(--ui-line-hi);border-radius:var(--rad)}'+
  '#root #birthmodal #birthcv{width:200px;height:236px;flex:none}'+
  '#root #birthmodal #birthlook{width:100%;min-height:48px;font:600 var(--fs-body)/1 var(--f-cond)}'+
  '#root #birthmodal #birthside{display:flex;flex-direction:column;gap:8px;min-width:0}'+
  '#root #birthmodal .bhlab{font:600 var(--fs-label)/1.2 var(--f-cond);color:var(--tx-2)}'+
  '#root #birthmodal #birthname{box-sizing:border-box;width:100%;height:56px;padding:0 16px;background:var(--ui-panel);border:1px solid var(--ui-line-hi);border-radius:var(--rad);color:var(--tx-1);font:700 var(--fs-title)/1 var(--f-cond);text-transform:none}'+
  '#root #birthmodal #birthkits{display:flex;flex-direction:column;gap:8px}'+
  '#root #birthmodal .bkit{display:grid;grid-template-columns:160px minmax(0,1fr) auto;align-items:center;gap:16px;min-height:56px;padding:8px 16px;background:var(--ui-panel);border:2px solid var(--ui-line-hi);border-radius:var(--rad);color:var(--tx-1);text-align:left;text-transform:none}'+
  '#root #birthmodal .bkit.on{border-color:var(--acc);background:var(--ui-raised)}'+
  '#root #birthmodal .bkit:disabled{opacity:.45}'+
  '#root #birthmodal .bkit b{font:700 var(--fs-body)/1.2 var(--f-cond);color:inherit}'+
  '#root #birthmodal .bkit span{font:500 var(--fs-body)/1.2 var(--f-cond);color:var(--tx-2);white-space:nowrap;overflow:hidden;text-overflow:ellipsis}'+
  '#root #birthmodal #birthgo{min-height:56px;font:700 var(--fs-body)/1 var(--f-cond)}');
var BIRTH=null;
function birthOn(){ var m=document.getElementById('birthmodal'); return !!(m&&m.classList.contains('on')); }
function birthNeed(){
  if(!P||(typeof ARCADE==='object'&&ARCADE&&ARCADE.on)||(typeof NETP2!=='undefined'&&NETP2)) return false;
  return !acctEnsure(P);
}
function birthState(){ var g=pilNext(P); if(!BIRTH||BIRTH.g!==g) BIRTH={g:g,i:0,name:'',kit:'none',look:0}; return BIRTH; }
function birthKitCost(id){ var K=BIRTH_KITS[id]; if(!K) return 0; return P.birthKit===id?0:K.c; }   // a kit paid for and never taken up is not paid for twice
function birthKitOk(id){ return birthKitCost(id)<=(+P.credits||0); }
function birthShown(){ var B=birthState(), h=pilHeirs(P)[B.i]; return (B.name&&B.name!==h.name)?pilName({name:B.name,num:pilNum(P,B.name)}):pilName(h); }
function birthDraw(){
  var B=birthState(), L=pilHeirs(P), h='', i, j, T, K, c, nm=document.getElementById('birthname');
  document.getElementById('birthhead').textContent='your '+pilOrd(B.g)+' pillager';
  for(i=0;i<L.length;i++){
    T=pilTraitList(L[i]);
    h+='<button class="bhcard'+(i===B.i?' on':'')+'" data-heir="'+i+'"><b>'+escHtml(i===B.i?birthShown():pilName(L[i]))+'</b>';
    for(j=0;j<T.length;j++) h+='<i style="color:var('+(pilTraitGood(T[j])?'--ok':'--danger')+')">'+T[j].n+'</i>';
    h+='</button>';
  }
  document.getElementById('birthheirs').innerHTML=h;
  h='';
  for(i=0;i<BIRTH_KIT_ORDER.length;i++){
    K=BIRTH_KITS[BIRTH_KIT_ORDER[i]]; c=birthKitCost(K.id);
    h+='<button class="bkit'+(K.id===B.kit?' on':'')+'" data-bkit="'+K.id+'"'+(birthKitOk(K.id)?'':' disabled')+'><b>'+K.n+'</b><span>'+K.t+'</span><b>'+(K.c?(c?'$'+c.toLocaleString():'paid'):'free')+'</b></button>';
  }
  document.getElementById('birthkits').innerHTML=h;
  if(nm&&document.activeElement!==nm) nm.value=B.name||L[B.i].name;
  document.getElementById('birthgo').textContent='ascend as '+birthShown();
  try{ drawAvatarCanvas(document.getElementById('birthcv')); }catch(_bd){}
}
function birthOpen(){
  var B;
  if(!birthNeed()) return false;
  B=birthState(); pilHeirs(P);
  if(P.birthLook!==B.g){ P.birthLook=B.g; try{ lookRandom(); }catch(_bl){} }   // random once per birth, so a reload or the editor keeps what he made
  try{ saveProfile(); }catch(_bs){}
  birthDraw(); openModal('birthmodal');
  try{ if(padOn()) padSetFocus(document.getElementById('birthgo')); }catch(_bp){}
  return true;
}
// THE ONE DOOR: heir i, the typed name and a kit he can pay for. Returns the pillager, or null with nothing changed.
function birthBorn(i,name,kit){
  var K=BIRTH_KITS[kit]||BIRTH_KITS.none, c, r;
  if(!birthNeed()) return null;
  c=birthKitCost(K.id);
  if(c>(+P.credits||0)) return null;
  r=pilBirth(P,Math.max(0,Math.min(2,i|0)),String(name||'').toLowerCase().trim().slice(0,16));
  if(K.gun){ P.credits-=c; P.birthKit=K.id; kitApply('free'); P.kitPick='free'; }   // spending: lifetime earnings are not touched
  BIRTH=null;
  try{ saveProfile(); }catch(_bb){}
  return r;
}
function birthFinish(go){
  var B=birthState(), r=birthBorn(B.i,B.name,B.kit)||birthBorn(B.i,B.name,'none');
  document.getElementById('birthmodal').classList.remove('on');
  try{ sndUi('ok'); }catch(_bo){}
  try{ renderHub(); }catch(_bh){}
  if(go){   // the lift's own door: every route up ends on the map page
    var S=(HB&&HB.stations)||[], i, d=null;
    for(i=0;i<S.length;i++) if(S[i].acts&&S[i].acts.KeyE&&S[i].acts.KeyE[0]==='go up'){ d=S[i].acts.KeyE[1]; break; }
    if(d) d(); else { renderSector(); openModal('sectormodal'); }
  } else firstRunNext();
  return r;
}
function birthAuto(){
  var B, r;
  if(!birthNeed()) return null;
  B=birthState(); r=birthBorn(B.i,B.name,'none');
  document.getElementById('birthmodal').classList.remove('on');
  return r;
}
document.getElementById('birthheirs').onclick=function(ev){
  var b=ev.target.closest('[data-heir]'); if(!b) return;
  birthState().i=Math.max(0,Math.min(2,+b.getAttribute('data-heir')||0));
  try{ sndUi('click'); }catch(_bu){}
  birthDraw();
};
document.getElementById('birthkits').onclick=function(ev){
  var b=ev.target.closest('[data-bkit]'), id; if(!b) return;
  id=b.getAttribute('data-bkit');
  if(!BIRTH_KITS[id]||!birthKitOk(id)){ try{ sfx('clank'); }catch(_bc){} return; }
  birthState().kit=id;
  try{ sndUi('click'); }catch(_bu){}
  birthDraw();
};
document.getElementById('birthname').oninput=function(){
  var v=String(this.value||'').toLowerCase().slice(0,16);
  if(this.value!==v) this.value=v;
  birthState().name=v.trim();
  birthDraw();
};
document.getElementById('birthlook').onclick=function(){
  birthState().look=1; P._avSlot=null;
  renderAvatar('appavatar','appavatarpicker'); openModal('appearmodal');
};
document.getElementById('birthgo').onclick=function(){ birthFinish(true); };
document.getElementById('closebirth').onclick=function(){ birthFinish(false); };
// The keyboard: left and right walk the heirs, up and down the kits he can pay for, enter is the default button. ESC is the window's own CLOSE.
window.addEventListener('keydown',function(e){
  var ae, B, c=e.code, L, ix;
  if(!birthOn()||e.repeat) return;
  ae=document.activeElement;
  if(c==='Enter'||c==='NumpadEnter'){
    if(ae&&ae.id==='birthname'){ ae.blur(); birthDraw(); e.preventDefault(); e.stopPropagation(); return; }
    if(ae&&ae.tagName==='BUTTON'&&document.getElementById('birthmodal').contains(ae)) return;
    e.preventDefault(); e.stopPropagation(); birthFinish(true); return;
  }
  if(ae&&ae.id==='birthname') return;
  B=birthState();
  if(c==='ArrowLeft'||c==='ArrowRight'){ B.i=(B.i+(c==='ArrowLeft'?2:1))%3; }
  else if(c==='ArrowUp'||c==='ArrowDown'){
    L=BIRTH_KIT_ORDER.filter(birthKitOk); ix=L.indexOf(B.kit);
    B.kit=L[(ix+(c==='ArrowUp'?L.length-1:1))%L.length];
  } else return;
  e.preventDefault(); e.stopPropagation();
  try{ sndUi('move'); }catch(_bk){}
  birthDraw();
},true);
document.getElementById('closeappear').onclick=function(){
  if(BIRTH&&BIRTH.look){ BIRTH.look=0; document.getElementById('appearmodal').classList.remove('on'); birthOpen(); return; }   // v37.xx (cw-m2birth): back to the birth card, his edits kept
'@

SubRx @'
var VER='37.32';
'@ @'
var VER='37.33';
'@

$pat = "(?m)^  now:'v37\.32:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v37.33: after a death nobody is living and three heirs wait. The first arrival in the Undercroft opens the birth card: three heir cards with traits in green and red, a typed name, the figure with edit look (random once per birth, edits kept), and the starter kit row with prices, a kit he cannot pay for greyed. One button, ascend as name, births what is lit and opens the map page; close, esc and B birth what is lit and stay on the floor. A kit goes up the way the freebie does and costs its price in cash, never touching lifetime earnings. Nothing can ascend with nobody living. An old save, the demo and the player 2 window never see the card Check 37.33 fails on v37.32',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
