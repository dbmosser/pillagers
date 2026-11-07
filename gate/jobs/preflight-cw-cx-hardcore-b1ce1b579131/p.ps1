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

# OPTIONAL HARDCORE SAVES AND GRAVEYARD (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
        <button class="deploy ghost" id="newgame" style="padding:7px 16px">CREATE A NEW SAVE</button>
'@ @'
        <button class="deploy ghost" id="newgame" style="padding:7px 16px">CREATE A NEW SAVE</button>
        <!-- v34.xx (cw-hardcore), v28.xx (cw-cx-hardcore): his optional hardcore save, chosen only at creation. -->
        <label id="hcchoice" style="display:inline-flex;align-items:center;gap:8px;font-size:16px">hardcore <button type="button" id="hctoggle" class="ui-toggle" role="switch" aria-label="hardcore" aria-checked="false"></button></label>
        <button type="button" id="hcgraves" class="deploy ghost" style="display:none" onclick="hcGraveOpen()">graveyard</button>
'@

SubRx @'
<div class="modal" id="cheatmodal">
'@ @'
<!-- v34.xx (cw-hardcore), v28.xx (cw-cx-hardcore): a leaderboard for fallen hardcore careers. -->
<style>
#root #hcgrave{inset:5%;padding:24px;background:var(--ui-panel);border:1px solid var(--ui-line-hi);border-radius:var(--rad);z-index:160;box-sizing:border-box}
#root #hcgrave header{display:flex;align-items:center;justify-content:space-between;gap:24px;margin-bottom:24px}
#root #hcgrave h3{margin:0;font-size:32px;color:var(--tx-1)}
#root #hcgrave header p{margin:8px 0 0;color:var(--tx-2);font-size:16px}
#root #hcgravelist{flex:1;min-height:0;overflow:auto;display:flex;flex-direction:column;gap:16px}
#root .hcgrave-row{display:grid;grid-template-columns:48px 176px 112px minmax(0,1fr);gap:24px;align-items:center;padding:24px;background:var(--ui-raised);border:1px solid var(--ui-line);border-radius:var(--rad)}
#root .hcgrave-rank{font-size:32px;color:var(--tx-2)}
#root .hcgrave-score b{display:block;font-size:40px;line-height:1.1;color:var(--tx-1);font-variant-numeric:tabular-nums}
#root .hcgrave-score span,#root .hcgrave-stats,#root .hcgrave-end{font-size:16px;line-height:1.6;color:var(--tx-2)}
#root .hcgrave-row:first-child{border-left:3px solid var(--acc)}
#root .hcgrave-row:first-child .hcgrave-score b{color:var(--acc)}
#root .hcgrave-name{font-size:24px;margin:0 0 8px;color:var(--tx-1)}
#root .hcgrave-row canvas{width:112px;height:112px}
#root #hcgraveclose{min-width:112px;min-height:48px}
@media(max-width:900px){#root .hcgrave-row{grid-template-columns:32px 132px 80px minmax(0,1fr);gap:12px;padding:16px}#root .hcgrave-score b{font-size:32px}#root .hcgrave-row canvas{width:80px;height:96px}}
</style>
<div class="modal" id="hcgrave" role="dialog" aria-modal="true" aria-labelledby="hcgravetitle">
  <header><div><h3 id="hcgravetitle">graveyard</h3><p>hardcore careers / stash value at death</p></div><button type="button" id="hcgraveclose" class="deploy ghost" onclick="hcGraveClose()">close <span class="ui-key">esc</span></button></header>
  <div id="hcgravelist"></div>
</div>
<div class="modal" id="cheatmodal">
'@

SubRx @'
var NEWNAME_KEY='salvagerun:newname';
'@ @'
// v34.xx (cw-hardcore), v28.xx (cw-cx-hardcore), his 10-25 order: "hardcore save = pillager completely dies".
var HC_KEY='salvagerun:graveyard', HC_REMOVED=false;
function hcGraves(){
  try{ var a=JSON.parse(localStorage.getItem(HC_KEY)||'[]'); return Array.isArray(a)?a.filter(function(r){return r&&typeof r==='object';}):[]; }catch(_hcg){ return []; }
}
function hcArchived(key,raw){
  if(!/^salvagerun:profile:[2-8]$/.test(key)) return false;
  var p; try{p=typeof raw==='string'?JSON.parse(raw):raw;}catch(_hca){return false;}
  return !!(p&&p.hardcore===1&&p.hcBorn&&hcGraves().some(function(r){return r.slot===key&&r.born===p.hcBorn;}));
}
function hcKeep(on,slot){
  var k='salvagerun:newhardcore:'+slotPtrKey();
  try{ localStorage.removeItem(k); if(on&&!NETP2&&!NETSLOT&&/^[2-8]$/.test(String(slot))) localStorage.setItem(k,JSON.stringify({s:String(slot),t:Date.now()})); }catch(_hck){}
}
function hcTake(){
  var k='salvagerun:newhardcore:'+slotPtrKey(),o;
  try{o=JSON.parse(localStorage.getItem(k)||'null');localStorage.removeItem(k);}catch(_hct){return false;}
  if(!o||NETP2||NETSLOT||String(o.s)!==String(SLOT)||!/^[2-8]$/.test(String(SLOT))||Math.abs(Date.now()-o.t)>120000||(P.runs|0)>0||P.hardcore) return false;
  P.hardcore=1;P.hcBorn=Date.now();saveProfile();return true;
}
function hcCapture(how){
  if(how!=='dead'||!G||!G.career||G.sim||G.arcade||(ARCADE&&ARCADE.on)||!P||P.hardcore!==1||!/^salvagerun:profile:[2-8]$/.test(SKEY)) return null;
  var q=pilNow(),look={},s,at=Date.now(),T=G.tel||{};
  for(s in COSKEY) look[COSKEY[s]]=P[COSKEY[s]];
  return {slot:SKEY,born:P.hcBorn,at:at,name:String((q&&q.name)||P.pname||'pillager').toLowerCase(),look:look,
    value:trStash(),level:(q&&q.lvl)||P.xpLevel||1,runs:P.runs||0,extractions:P.ext||0,kills:0,best:P.best||0,
    days:Math.max(0,Math.floor((at-(+P.hcBorn||at))/86400000)),by:String((T.lastHitName&&T.deathKiller!=='timer')?T.lastHitName:(T.deathKiller||'unknown')).toLowerCase().replace(/raider|pillager bot/g,'pillager'),
    clock:Math.max(0,Math.floor(runElapsed())),period:isDay()?'day':'night'};
}
function hcFinish(done){
  var r=P&&P.hcDeath, a, keys, i, k;
  if(!r||P.hardcore!==1||r.slot!==SKEY||!/^salvagerun:profile:[2-8]$/.test(SKEY)) return false;
  try{
    a=hcGraves();
    if(!a.some(function(x){return x.slot===r.slot&&x.born===r.born;})){a.push(r);localStorage.setItem(HC_KEY,JSON.stringify(a));}
    // v28.xx (cw-cx-hardcore): the grave record rejects an old second copy still in flight when this tab closes.
    HC_REMOVED=true;
    keys=[SKEY,SKEY+':prerestore',SKEY+':precrash'];
    dailySaveKeys(true).forEach(function(d){if(d.indexOf(SKEY+':daily:')===0)keys.push(d);});
    for(i=0;i<keys.length;i++)localStorage.removeItem(keys[i]);
    localStorage.setItem('salvagerun:activeSlot','1');
    if(NETP2)localStorage.setItem(p2PtrKey(),'1');
    SLOT='1';saveCopyDel(SKEY,done);return true;
  }catch(_hcf){HC_REMOVED=true;storeWarn();return false;}
}
function hcGraveClose(){ document.getElementById('hcgrave').classList.remove('on');var b=document.getElementById('hcgraves');if(b)b.focus(); }
function hcGraveOpen(){
  var host=document.getElementById('hcgravelist'),a=hcGraves().map(function(r,i){return {r:r,i:i};});
  a.sort(function(x,y){return (+y.r.value||0)-(+x.r.value||0)||(+x.r.at||0)-(+y.r.at||0)||x.i-y.i;});
  host.textContent='';
  function text(parent,tag,cls,value){var e=document.createElement(tag);e.className=cls;e.textContent=value;parent.appendChild(e);return e;}
  function money(n){return '$'+Math.max(0,Math.round(+n||0)).toLocaleString();}
  a.forEach(function(o,i){
    var r=o.r,row=text(host,'div','hcgrave-row',''),score,detail,cv2,x2,keep={},s,w0=wc,own0=cosOwned;
    row.setAttribute('data-hc-name',String(r.name||'pillager').toLowerCase());row.setAttribute('data-hc-value',+r.value||0);
    text(row,'div','hcgrave-rank',String(i+1));score=text(row,'div','hcgrave-score','');text(score,'b','',money(r.value));text(score,'span','','stash at death');
    cv2=document.createElement('canvas');cv2.width=256;cv2.height=256;cv2.setAttribute('aria-label',String(r.name||'pillager').toLowerCase());row.appendChild(cv2);x2=cv2.getContext('2d');
    try{for(s in COSKEY){var ck=COSKEY[s];keep[ck]=P[ck];if(r.look&&r.look[ck]!==undefined)P[ck]=r.look[ck];}wc=x2;cosOwned=function(){return true;};cosPreviewPaint(x2,2.1,106);}finally{wc=w0;cosOwned=own0;for(s in keep){if(keep[s]===undefined)delete P[s];else P[s]=keep[s];}}
    detail=text(row,'div','','');text(detail,'h4','hcgrave-name',String(r.name||'pillager').toLowerCase());
    text(detail,'div','hcgrave-stats','level '+(+r.level||1)+' / '+(+r.runs||0)+' runs / '+(+r.extractions||0)+' extractions / '+(+r.kills||0)+' kills');
    text(detail,'div','hcgrave-stats','best haul '+money(r.best)+' / '+(+r.days||0)+' days alive');
    var sec=Math.max(0,Math.floor(+r.clock||0));
    text(detail,'div','hcgrave-end','killed by '+String(r.by||'unknown').toLowerCase()+' / '+(r.period==='night'?'night':'day')+' / '+Math.floor(sec/60)+':'+('0'+sec%60).slice(-2)+' in');
  });
  document.getElementById('hcgrave').classList.add('on');document.getElementById('hcgraveclose').focus();
}
document.addEventListener('keydown',function(e){if(e.key==='Escape'&&document.getElementById('hcgrave').classList.contains('on')){e.preventDefault();e.stopImmediatePropagation();hcGraveClose();}},true);
var NEWNAME_KEY='salvagerun:newname';
'@

SubRx @'
function saveProfile(){ if(typeof NET===
'@ @'
function saveProfile(){ if(HC_REMOVED) return; if(typeof NET===
'@

SubRx @'
function storeSet(v){
'@ @'
function storeSet(v){
  if(HC_REMOVED||hcArchived(SKEY,v)) return; // v28.xx (cw-cx-hardcore): a fallen save cannot be written again.
'@

SubRx @'
function saveCopyPut(key,raw,cb){
'@ @'
function saveCopyPut(key,raw,cb){
  if(hcArchived(key,raw)){if(cb)cb(false);return;} // v28.xx (cw-cx-hardcore): no resurrection from the second store.
'@

SubRx @'
    try{ var tx=db.transaction('profile','readwrite'); tx.objectStore('profile').put({raw:raw,t:Date.now()},key);
'@ @'
    if(hcArchived(key,raw)){db.close();if(cb)cb(false);return;} // v28.xx (cw-cx-hardcore): recheck after the asynchronous open.
    try{ var tx=db.transaction('profile','readwrite'); tx.objectStore('profile').put({raw:raw,t:Date.now()},key);
'@

SubRx @'
        if(SAVE_COPY_KEY.test(k)&&saveCopyValid(v)){
'@ @'
        if(SAVE_COPY_KEY.test(k)&&saveCopyValid(v)&&!hcArchived(k,v)){ // v28.xx (cw-cx-hardcore): archived careers stay gone.
'@

SubRx @'
      if(found===null) return fin(fb());
'@ @'
      if(found===null||hcArchived(SKEY,found)) return fin(fb()); // v28.xx (cw-cx-hardcore): a grave written during the read wins.
'@

SubRx @'
function applyLoadedProfile(r){
'@ @'
function applyLoadedProfile(r){
      if(r&&hcArchived(SKEY,r.value)) r=null; // v28.xx (cw-cx-hardcore): reject an archived raw backup.
'@

SubRx @'
  G.over=how;
'@ @'
  P.hcDeath=hcCapture(how); // v28.xx (cw-cx-hardcore): stash and living look before settlement.
  G.over=how;
'@

SubRx @'
    pilRaidEnd(how,how==='extract'?(_secV||0):0,{v:_plV,k:_plK});
'@ @'
    if(P.hcDeath){P.hcDeath.runs=P.runs||0;P.hcDeath.extractions=P.ext||0;P.hcDeath.best=P.best||0;for(var _hkk in P.kills)P.hcDeath.kills+=(+P.kills[_hkk]||0);} // v28.xx (cw-cx-hardcore): final career totals, before lineage settlement.
    pilRaidEnd(how,how==='extract'?(_secV||0):0,{v:_plV,k:_plK});
'@

SubRx @'
  document.getElementById('oc_manifest').innerHTML=(how==='extract')?
'@ @'
  if(P.hcDeath) lines.push('<div class="hcfallen" style="font-size:20px;color:var(--tx-1);margin:12px 0">hardcore \u00b7 fallen for good</div>'); // v28.xx (cw-cx-hardcore)
  document.getElementById('oc_manifest').innerHTML=(how==='extract')?
'@

SubRx @'
  ocCommit();
  document.getElementById('outcome').classList.remove('on');
'@ @'
  ocCommit();
  if(P.hcDeath){if(!hcFinish(function(){careerNewReload();}))return;document.getElementById('outcome').classList.remove('on');G=null;keys={};return;} // v28.xx (cw-cx-hardcore): archive only on closing the card; finish deleting the second copy before navigating.
  document.getElementById('outcome').classList.remove('on');
'@

SubRx @'
  PLOADED=true;
'@ @'
  PLOADED=true;
  if(P.hcDeath&&hcFinish(function(){careerNewReload();}))return; // v28.xx (cw-cx-hardcore): closing the browser on KIA cannot undo a death.
  hcTake();
'@

SubRx @'
xp:d.xp||0};   // v37.xx (cw-m2retire)
'@ @'
xp:d.xp||0,hardcore:d.hardcore===1};   // v28.xx (cw-cx-hardcore), v37.xx (cw-m2retire)
'@

SubRx @'
      var h='';
      for(var sn=1;sn<=8;sn++){
'@ @'
      var _hc=document.getElementById('hcchoice');if(_hc)_hc.style.display=(_p2w||NETSLOT)?'none':'inline-flex';
      var _gb=document.getElementById('hcgraves');if(_gb)_gb.style.display=hcGraves().length?'':'none';
      var h='';
      for(var sn=1;sn<=8;sn++){
'@

SubRx @'
(inf?(inf.runs+' raid'
'@ @'
(inf&&inf.hardcore?'<span class="ui-chip danger">hardcore</span> ':'')+(inf?(inf.runs+' raid'
'@

SubRx @'
    if(ng) ng.onclick=function(){
      for(var sn=1;sn<=8;sn++){
'@ @'
    var hct=document.getElementById('hctoggle');if(hct)hct.onclick=function(){var on=this.getAttribute('aria-checked')!=='true';this.setAttribute('aria-checked',String(on));this.classList.toggle('on',on);}; // v28.xx (cw-cx-hardcore)
    if(ng) ng.onclick=function(){
      var hc=!!(hct&&hct.getAttribute('aria-checked')==='true'&&!NETP2&&!NETSLOT);
      for(var sn=hc?2:1;sn<=8;sn++){
'@

SubRx @'
          careerNewReload(); return;
'@ @'
          hcKeep(hc,key);if(hct){hct.setAttribute('aria-checked','false');hct.classList.remove('on');} // v28.xx (cw-cx-hardcore): one creation only.
          careerNewReload(); return;
'@

SubRx @'
      <div style="display:flex;gap:8px;margin-top:10px;align-items:center">
        <input id="pnamein"
'@ @'
      <div style="display:flex;flex-wrap:wrap;gap:8px;margin-top:10px;align-items:center">
        <input id="pnamein"
'@

SubRx @'
var VER='37.48';
'@ @'
var VER='37.49';
'@

$pat = "(?m)^  now:'v37\.48:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v37.49: Choose hardcore only when creating a new save in slots 2 through 8. Death archives the career, removes its backups and returns to the save list. Graveyard ranks stash value at death. Check 37.49 fails on v37.48',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
