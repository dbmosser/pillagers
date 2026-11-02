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

# THE KILL FEED SHOWS WHAT MADE THE KILL (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'

};
var _uiIconP={};
'@ @'
,
  crowbar:'M5 20L17 8M17 8a3 3 0 1 1 3-3M5 20l-1.5 1.5',   // v37.xx (cw-feedicon): the kill feed pictures for a swing, a blast and the air strike
  blast:'M12 3v5M12 16v5M3 12h5M16 12h5M5.6 5.6l3.5 3.5M14.9 14.9l3.5 3.5M5.6 18.4l3.5-3.5M14.9 9.1l3.5-3.5',
  strike:'M12 3v14M7 12l5 5 5-5M5 21h14'
};
var _uiIconP={};
'@

SubRx @'
// by: who did it ('' when nobody known), mine: it was this player, mate: a teammate; vn the victim, verb after it when unattributed
function feedKillLine(by,mine,mate,vn,vcol,verb){
'@ @'
// v37.xx (cw-feedicon), HIS ANSWER g-86 (2026-10-25), "Yes, a small gun or element icon": a kill line shows what made the kill where the arrow was. how: {el} an element (it wins:
// a burn, an arc or an element barrel killed it), {g} a gun id, {k} m (a swing), x (a blast) or a (the air strike); null shows the arrow as before. The element is recorded
// on the killing blow only (blowEl); every other blow site clears it.
var FEEDKIC={m:'crowbar',x:'blast',a:'strike'};
function feedHow(e){
  var g;
  if(!e) return null;
  if(e.blowEl&&ELEM[e.blowEl]) return {el:e.blowEl};
  if(e.blow==='g'){ g=String(e.blowG||''); return (g&&g!=='fists'&&WEAPONS[g])?{g:g}:null; }
  if(e.blow==='x'||e.blow==='a'||(e.blow==='m'&&e.blowG!=='fists')) return {k:e.blow};
  return null;
}
function feedHowStr(h){ return !h?'':(h.el?'e:'+h.el:(h.k?'k:'+h.k:(h.g?String(h.g).slice(0,12):''))); }
function feedHowOf(s){
  s=String(s||'');
  if(s.indexOf('e:')===0) return ELEM[s.slice(2)]?{el:s.slice(2)}:null;
  if(s.indexOf('k:')===0) return (/^[mxa]$/).test(s.slice(2))?{k:s.slice(2)}:null;
  return (s&&s!=='fists'&&WEAPONS[s])?{g:s}:null;
}
function feedHowW(h,fp){ return h?Math.round(fp*(h.g?2.4:1.3)):0; }
function feedHowDraw(h,x,cy,w,fp){
  var s, r;
  if(!h) return;
  if(h.g){ gunIcon(ctx,h.g,x+w/2,cy,Math.round(w)); return; }
  if(h.el&&ELEM[h.el]){
    r=Math.max(3,fp*0.4);
    ctx.fillStyle=ELEM[h.el].c; ctx.beginPath(); ctx.arc(x+w/2,cy,r,0,6.2832); ctx.fill();
    ctx.strokeStyle='rgba(6,9,13,.85)'; ctx.lineWidth=Math.max(1,fp*0.08); ctx.stroke();
    return;
  }
  if(FEEDKIC[h.k]){ s=Math.round(fp*1.1); feedGlyph(FEEDKIC[h.k],x+(w-s)/2,cy,s,HUDC.text); }
}
// by: who did it ('' when nobody known), mine: it was this player, mate: a teammate; vn the victim, verb after it when unattributed; how: what made the kill (feedHow), a merged repeat keeps the newest
function feedKillLine(by,mine,mate,vn,vcol,verb,how){
'@

SubRx @'
  segs=by?[{t:by,c:mine?HUDC.text:HUDC.ally},{t:'  >  ',c:HUDC.dim},{t:vn,c:vcol}]:
'@ @'
  segs=by?[{t:by,c:mine?HUDC.text:HUDC.ally}].concat(how?[{t:'  ',c:HUDC.dim},{t:'',ic:how,c:HUDC.dim},{t:'  ',c:HUDC.dim}]:[{t:'  >  ',c:HUDC.dim}],[{t:vn,c:vcol}]):
'@

SubRx @'
Ln.mine=mine; Ln.col=acc; Ln.vn=vn; Ln.mf=''; Ln.last=now; return Ln; }
'@ @'
Ln.mine=mine; Ln.col=acc; Ln.vn=vn; Ln.how=how||null; Ln.mf=''; Ln.last=now; return Ln; }
'@

SubRx @'
    if((by||'')===(Ln.by||'')){ Ln.n++; Ln.at=now; Ln.last=now; Ln.mf=''; return Ln; }
'@ @'
    if((by||'')===(Ln.by||'')){ Ln.n++; Ln.at=now; Ln.last=now; Ln.mf=''; if(by&&how){ Ln.how=how; Ln.segs=segs; } return Ln; }
'@

SubRx @'
  if(Ln){ Ln.vn=vn; Ln.by=by; Ln.mine=!!mine; }
'@ @'
  if(Ln){ Ln.vn=vn; Ln.by=by; Ln.mine=!!mine; Ln.how=(by&&how)||null; }
'@

SubRx @'
  return feedKillLine(by,mine,seat>0,vn,(e.kind==='raider')?HUDC.danger:HUDC.warn,killWord(e));
'@ @'
  return feedKillLine(by,mine,seat>0,vn,(e.kind==='raider')?HUDC.danger:HUDC.warn,killWord(e),by?feedHow(e):null);
'@

SubRx @'
for(i=0;i<ln.segs.length;i++){ sg=ln.segs[i]; P.push({t:sg.t,c:sg.c||ln.col}); }
'@ @'
for(i=0;i<ln.segs.length;i++){ sg=ln.segs[i]; P.push({t:sg.t,c:sg.c||ln.col,ic:sg.ic||null}); }
'@

SubRx @'
for(i=0;i<P.length;i++){ P[i].w=ctx.measureText(P[i].t).width; w+=P[i].w; }
'@ @'
for(i=0;i<P.length;i++){ P[i].w=P[i].ic?feedHowW(P[i].ic,msgPx(fL)):ctx.measureText(P[i].t).width; w+=P[i].w; }
'@

SubRx @'
    t=P[i].t; tw=w-P[i].w;
'@ @'
    if(P[i].ic){ w-=P[i].w; P.pop(); continue; }   // v37.xx (cw-feedicon): the picture is never cut; it goes whole when the line is too long
    t=P[i].t; tw=w-P[i].w;
'@

SubRx @'
for(j=0;j<pr.length;j++){ ctx.fillStyle=pr[j].c; ctx.fillText(pr[j].t,tx,yb); tx+=pr[j].w; }
'@ @'
for(j=0;j<pr.length;j++){ if(pr[j].ic) feedHowDraw(pr[j].ic,tx,yt+R.rh/2,pr[j].w,R.fp); else { ctx.fillStyle=pr[j].c; ctx.fillText(pr[j].t,tx,yb); } tx+=pr[j].w; }
'@

SubRx @'
e.hp-=arcadeBmDamage(e,(e.burnDps||0)*t,e.burnBy|0); elemCredit(e,e.burnBy|0); }
'@ @'
e.hp-=arcadeBmDamage(e,(e.burnDps||0)*t,e.burnBy|0); elemCredit(e,e.burnBy|0); if(e.hp<=0) e.blowEl='fire'; }   /* v37.xx (cw-feedicon): the burn took the last health: the feed shows fire */
'@

SubRx @'
best.hp-=arcadeBmDamage(best,a,seat); best.hitT=.16; best.pHitT=.3; best.pHitSeat=seat|0;
'@ @'
best.hp-=arcadeBmDamage(best,a,seat); best.hitT=.16; best.pHitT=.3; best.pHitSeat=seat|0; if(best.hp<=0) best.blowEl='shock';   // v37.xx (cw-feedicon): the arc took the last health
'@

SubRx @'
if(best.hp<=0){ best.byPlayer=(s===0); best.bySeat=(s>0)?s:0; } }
'@ @'
if(best.hp<=0){ best.byPlayer=(s===0); best.bySeat=(s>0)?s:0; best.blowEl='shock'; } }   /* v37.xx (cw-feedicon): the barrel arc took the last health */
'@

SubRx @'

    if(s>=0){ e.pHitT=.3; e.pHitSeat=s; e.blow='x'; e.blowT=G.t; }
'@ @'

    if(s>=0){ e.pHitT=.3; e.pHitSeat=s; e.blow='x'; e.blowT=G.t; e.blowEl=(e.hp<=0)?B.k:''; }   // v37.xx (cw-feedicon): an element barrel that kills shows its element, not the blast
'@

SubRx @'

      if(s>=0){ e.pHitT=.3; e.pHitSeat=s; e.blow='x'; e.blowT=G.t; }
'@ @'

      if(s>=0){ e.pHitT=.3; e.pHitSeat=s; e.blow='x'; e.blowT=G.t; e.blowEl=''; }   // v37.xx (cw-feedicon): the plain barrel is a blast
'@

SubRx @'
if(_fMine){ e.blow='x'; e.blowT=G.t; }
'@ @'
if(_fMine){ e.blow='x'; e.blowT=G.t; e.blowEl=''; }
'@

SubRx @'
_me.blow='m'; _me.blowT=G.t;
'@ @'
_me.blow='m'; _me.blowT=G.t; _me.blowEl=''; _me.blowG=wep.crowbar?'':'fists';   /* v37.xx (cw-feedicon): bare hands show no picture */
'@

SubRx @'
en.blow='g'; en.blowT=G.t; en.blowG=b.gid||'';
'@ @'
en.blow='g'; en.blowT=G.t; en.blowG=b.gid||''; en.blowEl='';
'@

SubRx @'
e.blow='a'; e.blowT=G.t;
'@ @'
e.blow='a'; e.blowT=G.t; e.blowEl='';
'@

SubRx @'
function netShotSend(e,dmg,ang,wk,ar,el,sk,hs){
'@ @'
function netShotSend(e,dmg,ang,wk,ar,el,sk,hs,gid){
'@

SubRx @'
if(hs) m.hs=1;
'@ @'
if(hs) m.hs=1; if(sk&&gid) m.g=netClean(String(gid),12); /* v37.xx (cw-feedicon): the gun id, so the host feed can show it */
'@

SubRx @'
netShotSend(en,edmg,Math.atan2(b.vy,b.vx),WK,_nar,b.el,1,b.dmg>=HITSTOP_DMG)
'@ @'
netShotSend(en,edmg,Math.atan2(b.vy,b.vx),WK,_nar,b.el,1,b.dmg>=HITSTOP_DMG,b.gid)
'@

SubRx @'
  if(e.hp<=0){ e.byPlayer=false; e.bySeat=m.nc?0:s; } else if(!e.downed){ e.byPlayer=false; e.bySeat=0; }
'@ @'
  if(m.sk&&typeof m.g==='string'&&m.g){ e.blow='g'; e.blowT=G.t; e.blowG=netClean(m.g,12); } else e.blow='';   // v37.xx (cw-feedicon): the last blow was his round with this gun (or not a round), so the host feed can name it
  e.blowEl='';
  if(e.hp<=0){ e.byPlayer=false; e.bySeat=m.nc?0:s; } else if(!e.downed){ e.byPlayer=false; e.bySeat=0; }
'@

SubRx @'
  netBroadcast({t:'kf',s:s,w:who});
  netFeedPush(s,who);
'@ @'
  var how=feedHow(e);   // v37.xx (cw-feedicon): and what made the kill, as gun id, e:element or k:blow
  netBroadcast({t:'kf',s:s,w:who,h:feedHowStr(how)});
  netFeedPush(s,who,how);
'@

SubRx @'
  netFeedPush(m.s,netClean(m.w,32));
'@ @'
  netFeedPush(m.s,netClean(m.w,32),feedHowOf(netClean(m.h,14)));
'@

SubRx @'
function netFeedPush(s,who){
'@ @'
function netFeedPush(s,who,how){
'@

SubRx @'
String(who),HUDC.warn,''); } }catch(_fkp){}
'@ @'
String(who),HUDC.warn,'',how); } }catch(_fkp){}
'@

SubRx @'
NET.feed.push({txt:nm+' killed '+who,me:(s===NET.seat),at:Date.now()});
'@ @'
NET.feed.push({txt:nm+' killed '+who,me:(s===NET.seat),at:Date.now(),nm:nm,who:String(who),how:how||null});
'@

SubRx @'
    tw=ctx.measureText(f.txt).width;
'@ @'
    tw=ctx.measureText(f.txt).width;
    var _fh=f.how, _fpx=msgPx(ctx.font), _iw=0, _t2w=0;   // v37.xx (cw-feedicon): the picture stands in the place of the word killed
    if(_fh){ _iw=feedHowW(_fh,_fpx); _t2w=ctx.measureText(' '+f.who).width; tw=ctx.measureText(f.nm+' ').width+_iw+_t2w; }
'@

SubRx @'
    ctx.fillStyle=f.me?'#ffc04a':'#bfe0ff'; ctx.fillText(f.txt,x,y);
'@ @'
    ctx.fillStyle=f.me?'#ffc04a':'#bfe0ff';
    if(_fh){ ctx.fillText(' '+f.who,x,y); ctx.fillText(f.nm+' ',x-_t2w-_iw,y); feedHowDraw(_fh,x-_t2w-_iw,y-Math.round(_fpx*0.3),_iw,_fpx); }
    else ctx.fillText(f.txt,x,y);
'@

SubRx @'
var VER='37.27';
'@ @'
var VER='37.28';
'@

$pat = "(?m)^  now:'v37\.27:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v37.28: A kill line shows a gun, element or blow picture instead of the arrow, in the left feed and in the party list. Check 37.28 fails on v37.27',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
