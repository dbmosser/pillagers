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

# THE QUIET HUD, ONE PLACE PER LINE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    try{ feedSay(m,k,o); }catch(_fsy){}   // v27.24 (feed1): every line said is in the feed, whatever lane it also takes
    if(k==='pick'){ pickSay(m,o); return; }   // v22.50 (R16): an item picked up is a row in the pickup stack, never a feed row
    if(msgAlertK(k)){ alertSay(m,k,o); return; }   // v22.13 (R08): crit, warn and ext take the alert lane, not a feed row
'@ @'
    // v35.xx (cw-quiettext), HIS ORDER (2026-10-27): "build the quiet hud, all 5 changes". EVERY RAID LINE SHOWS IN ONE PLACE. Since v27.24 every line said went
    // into the left feed AND into its lane, so a warning showed as the top banner and again in the feed, and a remark as a grey row under the clock and again in
    // the feed. An alert (crit, warn, ext) is now the top banner only, one at a time through the alert queue (one that waits too long still drops into the feed,
    // never lost); a pickup line (money in or out, BACKPACK FULL) is the right-side pickup stack only, as looted items already were (cw-hudfix); and every other
    // line (obj, ally, info, chat, sys) is a feed line only: the two grey rows under the clock are retired. The pause answer line and the run log are as they
    // were. This reverses his rs-2 a ruling of 2026-10-24 (keep both alert copies).
    if(msgAlertK(k)){ alertSay(m,k,o); return; }   // v22.13 (R08): crit, warn and ext take the alert lane, not a feed row
    if(k==='pick'){ pickSay(m,o); return; }   // v22.50 (R16): an item picked up is a row in the pickup stack, never a feed row
    try{ feedSay(m,k,o); }catch(_fsy){}   // v27.24 (feed1): every other line said is in the feed
'@

SubRx @'
    // v21.86, the raid text rewrite (R04): TWO ROWS INSTEAD OF ONE OVERWRITE. A second line said while one still showed wrote
    // over it, so two things that happened in the same second left only the last on screen. The line showing now moves down to
    // the second row (G.feed[1], with the time it had left) and the new one takes the top; a third pushes the oldest off. The
    // same line said again (a per-frame caller) only refreshes the top row. G.msg and G.msgT stay the top row, as before.
    // v21.88 (R06): with both rows up, msgVictim decides which row gives way, or that this line waits (see msgProt above).
    // v21.91 (R07): a line already on a row, by its text or by its key (o.key), refreshes that row where it is; the second row
    // keeps its place and its first time. A line said is taken out of the queue if it was also waiting there.
    var f=(G.feed=G.feed||[]), now=G.t||0, key=(o&&o.key)||'', hv=!!(G.msgT>0&&G.msg), same=hv&&((G.msg===m&&!msgDiffKey(G.msgKey,key))||(!!key&&G.msgKey===key)),   // v23.xx (tr9fixk): two keyed lines with one headline are two lines
        r1=(hv&&f[1]&&f[1].T>0&&f[1].m&&(f[1].m!==G.msg||msgDiffKey(f[1].key,G.msgKey)))?f[1]:null, hd, v;   // v23.xx (tr9fixk): two keyed lines with one headline are two lines
    if(!same&&r1&&((r1.m===m&&!msgDiffKey(r1.key,key))||(key&&r1.key===key))){ r1.m=m; r1.k=k; r1.sub=(o&&o.sub)||''; r1.T=3.2; if(G.msgQ&&G.msgQ.length) msgQDrop(m,key); return; }
    if(G.msgQ&&G.msgQ.length) msgQDrop(m,key);
    if(hv&&!same){
      hd={m:G.msg,k:G.msgK||'info',sub:G.msgSub||'',T:G.msgT,at:G.msgAt,key:G.msgKey||''};
      if(r1){
        v=msgVictim([hd,r1],MSGK[k].r,now,!!G.msgDrain);
        if(!v){ msgEnq(m,k,o); return; }
        if(msgProt(v,now)&&v.m!==m) msgEnq(v.m,v.k,(v.sub||v.key)?{sub:v.sub,key:v.key}:null);
        if(v===r1) f[1]=hd;
      } else f[1]=hd;
    }
    if(!same) G.msgAt=now;   // the same line said again keeps its first time, so a per-frame caller never renews its protection
    G.msg=m; G.msgT=3.2; G.msgK=k; G.msgSub=(o&&o.sub)||''; G.msgKey=key;
    f[0]={m:m,k:k,sub:G.msgSub,T:3.2,at:G.msgAt,key:key}; return;
'@ @'
    return;   // v35.xx (cw-quiettext): the line is in the feed; the two grey message rows under the clock (v21.86 R04 to v23.xx tr9fixk) are retired
'@

SubRx @'
  if(!G||G.sim||!G.player||G.msgDrain||(o&&o.fd)) return null;
'@ @'
  if(!G||G.sim||!G.player||G.msgDrain) return null;   // v35.xx (cw-quiettext): o.fd no longer keeps a line out: with the grey rows retired the feed is the one place it shows (the golden down callout)
'@

SubRx @'
function alertToFeed(e){ var o=e.o||{}; say(e.m,'obj',(o.sub||o.key)?{sub:o.sub||'',key:o.key||'',fd:1}:{fd:1}); }   // v27.24 (feed1): fd, it was written into the feed when it was said
'@ @'
function alertToFeed(e){ var o=e.o||{}; say(e.m,'obj',{sub:o.sub||'',key:o.key||'',fk:feedKindOf(e.m,e.k,null)}); }   // v35.xx (cw-quiettext): an alert that waited too long is written into the feed now, in its own colour (it is no longer written there when said)
'@

SubRx @'
function feedRows(){
  var r=[], f;
  if(!G||!(G.msgT>0)||!G.msg) return r;
  r.push({m:G.msg,k:G.msgK||'info',sub:G.msgSub||'',T:G.msgT});
  f=G.feed&&G.feed[1];
  if(f&&f.T>0&&f.m&&(f.m!==G.msg||msgDiffKey(f.key,G.msgKey))) r.push(f);   // v23.xx (tr9fixk): two keyed lines with one headline are two lines
  return r;
}
'@ @'
function feedRows(){ return []; }   // v35.xx (cw-quiettext): the two grey message rows under the clock are retired; say() puts every line that is not an alert in the left feed only
'@

SubRx @'
  var _cr=!!G.pCrouch, _nearD=1e9;
  if(_cr) for(var _ci=0;_ci<G.ents.length;_ci++){
    var _ce=G.ents[_ci];
    // v15.42, hud audit finding: CROUCHED BESIDE YOUR HIRE OR A DOWNED PILLAGER, THE READOUT SAYS HIDDEN. The nearest body here
    // skipped only the Peddler and a survivor, so your own hire counted as someone standing too close to hide from. He starts on
    // FOLLOW and walks back whenever he is more than 120 away, inside the 170 of the crouch rule, so crouched in a quiet spot with
    // every hostile far off the plate read PARTLY HIDDEN, TOO CLOSE in amber while nothing could find him: updateEnts never lets a
    // hire into the branch that turns a body that sees him on him, and its crouch rule already hides him from everything past 170.
    // A pillager lying downed did the same, though the downed branch there skips his sight entirely, and a finished one did for
    // its last frame. All three are skipped now, so TOO CLOSE names only a body that can give him away. The crouch rule, the 170,
    // every word on the plate and every number are unchanged.
    if(_ce.dead||_ce.merc||_ce.downed||_ce.finished||_ce.kind==='peddler'||_ce.kind==='stray') continue;
    var _cd=dist(_ce,G.player); if(_cd<_nearD) _nearD=_cd;
  }
  var _chid=(CFG.crouchHide===undefined?170:CFG.crouchHide);
  if(G.pBush||_cr){
    var cc=G.pConceal===undefined?1:G.pConceal;
    var clab=cc<=0.15?'HIDDEN':(cc<=0.30?'WELL HIDDEN':(cc<=0.45?'CONCEALED':(cc<1?'PARTLY HIDDEN':'CRASHING THROUGH')));
    var ccol=cc<=0.30?'#7fc4a0':(cc<1?'#ffc04a':'#ff5a4a');
    // Crouched outranks the bush wording, because the rule is stronger and total.
    // STATE FIRST, REASON SECOND, always. Same five words whatever is hiding you.
    if(G.pBush&&!_cr) clab=clab+'  \u00b7  IN COVER';
    if(_cr&&_chid>0){
      if(_nearD>_chid){ clab='HIDDEN  \u00b7  CROUCHED'; ccol='#7fc4a0'; }
      else { clab='PARTLY HIDDEN  \u00b7  TOO CLOSE'; ccol='#ffc04a'; }
    } else if(_cr){ clab='PARTLY HIDDEN  \u00b7  CROUCHED'; ccol='#ffc04a'; }
    ctx.font=hudFS(TYPE.label);   // v28.xx (cw-hudquiet), the critic: the hidden chip was louder (22 px amber) than the info plates; it is label size now. v19.22: grows with the screen, as the weapon panel under it does
    // HIS NOTE, 2026-08-24: "CONCEALED on the right lower corner is blocked by
    // the key legend". It was drawn bottom LEFT at x=14, which is exactly the
    // column the legend panel occupies, and the legend bottoms out at
    // H - max(LH(52),96) while this sat at by - LH(62), so the two overlap for
    // any legend tall enough to reach down. The legend is on by default, so that
    // was the normal state of the screen. Moved to the right column, stacked
    // above the inventory cue, where nothing else is drawn.
    var cw2=ctx.measureText(clab).width;
    ctx.textAlign='right';
    ctx.fillStyle='rgba(6,9,13,.72)';
    var _gGrow=Math.round((34+LH(80))*((HUDZ.gear||1)-1));
    // v18.49, FROM THE CODE COMB (2026-10-06): THE HIDDEN CHIP SITS ABOVE THE WEAPON PANEL AT EVERY SIZE. The weapon panel (v18.38) grows
    // with the corner's scale, and at 1440p and 4K it was painted over this chip. The chip's bottom is kept above the panel's real top
    // on screen, and the chip is a HUD panel like the rest.
    var _zg=(HUDZ.gear||1)*hudRes()*hudUserZ('gear'), _og=hudOff('gear'), _ptop=H+((by-LH(90))-H)*_zg+(_og.dy||0), _cyb=Math.min(by-LH(86)-_gGrow,_ptop-LH(6));
    var _cr2=Math.max(1,hudRes());
    if(typeof hudPanel==='function') hudPanel(W-8-cw2-16*_cr2,_cyb-LH(20)*_cr2,cw2+16*_cr2,LH(20)*_cr2,0.88,1); else { ctx.fillRect(W-8-cw2-16*_cr2,_cyb-LH(20)*_cr2,cw2+16*_cr2,LH(20)*_cr2); }
    ctx.fillStyle=ccol; ctx.fillText(clab,W-8-8*_cr2,_cyb-LH(6)*_cr2);   // v19.22: centred in its panel
    ctx.textAlign='left';
  }
'@ @'
  // v35.xx (cw-quiettext), HIS ORDER (2026-10-27): "build the quiet hud, all 5 changes". The hidden chip at the right (CONCEALED, IN COVER) is an icon in the
  // status column at the left now (STATUSL hide, read through concealState): the same five states, the same reasons and colours, beside the other statuses.
'@

SubRx @'
  {id:'wade',  nm:'WADING',     col:'#6fb6d8', bad:1},
'@ @'
  {id:'wade',  nm:'WADING',     col:'#6fb6d8', bad:1},
  {id:'hide',  nm:'CONCEALED',  col:'#7fc4a0', bad:0},   // v35.xx (cw-quiettext): the hidden chip, moved here from the right; its name and colour follow concealState
'@

SubRx @'
function statusLive(p){
  var L=STATUSL, B=
'@ @'
// v35.xx (cw-quiettext), HIS ORDER (2026-10-27): "build the quiet hud, all 5 changes". What hides this window's player now, or null: {nm,v,col,bad}. The
// words, the colours and the crouch rule are the right-side chip's (v1.97, v15.42) that this replaces: the concealment state first, the reason second.
function concealState(){
  var p=G&&G.player, cr, nearD=1e9, i, e, d, hid, cc, nm, v='', col;
  if(!p||!G.ents||!(G.pBush||G.pCrouch)) return null;
  cr=!!G.pCrouch;
  if(cr) for(i=0;i<G.ents.length;i++){ e=G.ents[i]; if(!e||e.dead||e.merc||e.downed||e.finished||e.kind==='peddler'||e.kind==='stray') continue; d=dist(e,p); if(d<nearD) nearD=d; }
  hid=(CFG.crouchHide===undefined?170:CFG.crouchHide);
  cc=(G.pConceal===undefined)?1:G.pConceal;
  nm=cc<=0.15?'HIDDEN':(cc<=0.30?'WELL HIDDEN':(cc<=0.45?'CONCEALED':(cc<1?'PARTLY HIDDEN':'CRASHING THROUGH')));
  col=cc<=0.30?'#7fc4a0':(cc<1?'#ffc04a':'#ff5a4a');
  if(G.pBush&&!cr) v='in cover';
  if(cr&&hid>0){ if(nearD>hid){ nm='HIDDEN'; v='crouched'; col='#7fc4a0'; } else { nm='PARTLY HIDDEN'; v='too close'; col='#ffc04a'; } }
  else if(cr){ nm='PARTLY HIDDEN'; v='crouched'; col='#ffc04a'; }
  return {nm:nm,v:v,col:col,bad:(col==='#ff5a4a')?1:0};
}
function statusLive(p){
  var L=STATUSL, B=
'@

SubRx @'
    } else if(B){
'@ @'
    } else if(E.id==='hide'){
      // v35.xx (cw-quiettext): the words and colour of the right-side chip it replaces; a name that changes is measured again
      var cs=concealState();
      if(cs){ E.on=true; E.col=cs.col; E.bad=cs.bad; if(E.nm!==cs.nm){ E.nm=cs.nm; E.nf=''; } if(E.vk!==cs.v){ E.vk=cs.v; E.v=cs.v; } }
    } else if(B){
'@

SubRx @'
  } else if(id==='drunk'){
'@ @'
  } else if(id==='hide'){
    // v35.xx (cw-quiettext): an eye struck through, for hidden
    ctx.lineWidth=u*0.24; ctx.lineCap='round'; ctx.lineJoin='round';
    ctx.moveTo(cx-u,cy); ctx.quadraticCurveTo(cx,cy-u*1.1,cx+u,cy); ctx.quadraticCurveTo(cx,cy+u*1.1,cx-u,cy); ctx.stroke();
    ctx.beginPath(); ctx.arc(cx,cy,u*0.3,0,6.2832); ctx.fill();
    ctx.beginPath(); ctx.moveTo(cx-u*0.92,cy+u*0.92); ctx.lineTo(cx+u*0.92,cy-u*0.92);
    ctx.strokeStyle='#0b0f14'; ctx.lineWidth=u*0.56; ctx.stroke();
    ctx.strokeStyle=col; ctx.lineWidth=u*0.22; ctx.stroke();
    ctx.lineCap='butt'; ctx.lineJoin='miter';
  } else if(id==='drunk'){
'@

SubRx @'
  for(i=0;i<G.zones.length;i++){
    var zz2=G.zones[i],za=!!zz2.open;
'@ @'
  var _zEdge=null;   // v35.xx (cw-quiettext): the ring badge held at the screen edge this frame, drawn under the extract distance after this loop
  for(i=0;i<G.zones.length;i++){
    var zz2=G.zones[i],za=!!zz2.open;
'@

SubRx @'
    if(zcx!==zs.x&&zwid+24*_zr+LH(12)*_zr<W){ _zcl=true; _zaw=LH(12)*_zr; zcx=clamp(zs.x,(zwid+_zaw)/2+12*_zr,W-(zwid+_zaw)/2-12*_zr); }
'@ @'
    if(zcx!==zs.x&&zwid+24*_zr+LH(12)*_zr<W){ _zcl=true; _zaw=LH(12)*_zr; zcx=clamp(zs.x,(zwid+_zaw)/2+12*_zr,W-(zwid+_zaw)/2-12*_zr); }
    if(zcx!==zs.x){ var _zed=dist(p,zz2); if(!_zEdge||(za&&!_zEdge.za)||(za===_zEdge.za&&_zed<_zEdge.d)) _zEdge={lab:zlab,za:za,d:_zed}; continue; }   // v35.xx (cw-quiettext): held at the edge, it goes to the top centre instead
'@

SubRx @'
    // CLOSED FOR THE REMAINDER OF THIS RAID line now.
  }
  ctx.textAlign='left';
  // projected world labels
'@ @'
    // CLOSED FOR THE REMAINDER OF THIS RAID line now.
  }
  // v35.xx (cw-quiettext), HIS ORDER (2026-10-27): "build the quiet hud, all 5 changes". A RING BADGE HELD AT THE SCREEN EDGE IS A LINE UNDER THE EXTRACT DISTANCE.
  // A ring just off the screen had its badge (EXTRACTION C AVAILABLE) pinned to the edge with an arrow, out on its own at the right. It is now one line at the
  // top centre, under the extract distance and its arrow (where the MARKED row was until v22.13), on the same plate in the ring colour: an open ring before a
  // closed one, then the nearest. It steps aside for an alert or the location tag that would reach it. A badge over its ring is drawn there as before.
  if(_zEdge&&typeof _yMk==='number'&&typeof _yArw==='number'){
    ctx.font=_fCmp; ctx.textAlign='center';
    var _zeb=_yArw+(G.arcade?Math.round(8*_tz):0)+5*_tz*(G.arcade?ARCADE_ARW:1), _zey=Math.max(_yMk,Math.round(_zeb+LH(3)*_tz+_hCmp*1.05)), _zew=Math.round(ctx.measureText(_zEdge.lab).width+LH(20)), _zeh=Math.round(_hCmp*1.5), _zet=Math.round(_zey-_hCmp*1.05);
    var _zea=Math.round((LH(96)-LH(10))*(HUDZ.msg||1)*hudRes()*hudUserZ('msg'));
    if(!((ALERTL||locUp())&&_zet+_zeh>_zea)){
      hudPlate(Math.round(W/2-_zew/2),_zet,_zew,_zeh,null,HUDC.plate);
      ctx.fillStyle=_zEdge.za?'#4de3d0':'rgba(168,180,193,.95)';
      hudText(_zEdge.lab,W/2,_zey);
    }
  }
  ctx.textAlign='left';
  // projected world labels
'@

SubRx @'
var VER='35.29';
'@ @'
var VER='35.30';
'@

$pat = "(?m)^  now:'v35\.29:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v35.30: quiet hud: every raid line shows once, warnings at the top and the rest in the left feed; hidden is a status icon; an off-screen extraction shows under the extract distance Check 35.30 fails on v35.29',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
