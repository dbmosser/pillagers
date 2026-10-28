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

# QUIET HUD PANELS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  if(!trDemo()) n=4;
'@ @'
  // v35.xx (cw-quiethud), HIS ORDER (2026-10-27): "build the quiet hud, all 5 changes" (change 2, one money number). The wallet rows (cash, xp, stash
  // and backpack) are not drawn in a raid any more: the backpack value is on the ammo card, the forge and the pedlar show the balance on their own
  // screens, and the run info panel moves up into the corner. The Undercroft and the menus keep the page text.
'@

SubRx @'
  if(!(g.n>0)||!G||!G.player) return 0;
  TRG.t=(typeof performance!=='undefined')?performance.now():Date.now();
'@ @'
  if(!G||!G.player) return 0;
  TRG.t=(typeof performance!=='undefined')?performance.now():Date.now();   // v35.xx (cw-quiethud): stamped with no rows too, so the page copy of the wallet stays clipped away in a raid
  if(!(g.n>0)) return 0;
'@

SubRx @'
  if(!trDemo()){ trRow(i++,'cash','$'+TRV.c); /* v33.xx (cw-cornercompact2): the critic found the money figure with no label read as part of the xp pair; a short word names it */ trRow(i++,'xp',TRV.x); trRow(i++,'stash','$'+TRV.sv); trRow(i++,'backpack','$'+TRV.bv); }
'@ @'
  // v35.xx (cw-quiethud): no wallet rows in a raid (change 2); the notes row stays
'@

SubRx @'
function hudOff(id){
  var o=(P&&P.hud&&P.hud[id])||{};
  return {dx:o.dx||0,dy:o.dy||0,c:!!o.c&&id!=='body'};
'@ @'
// v35.xx (cw-quiethud), HIS ORDER (2026-10-27): "build the quiet hud, all 5 changes" (change 3, things at rest hide). THE RUN INFO PANEL FOLDS TO ONE LINE
// AT REST, its count (contracts 1/3, the demo goals 0/3). When a contract or a goal moves (riNote, from the panel) it opens for RI_OPEN_MS and folds
// again; its arrow opens it for good (P.hud.cond.o) and folds it again. Real time, so a slowed raid clock does not hold it open. A new raid starts folded.
var RIF={g:null,sig:'',until:0}, RI_OPEN_MS=4000;
function riNow(){ return (typeof performance!=='undefined')?performance.now():Date.now(); }
function riNote(sig){
  if(RIF.g!==G){ RIF.g=G; RIF.sig=sig; RIF.until=0; return; }
  if(sig!==RIF.sig){ RIF.sig=sig; RIF.until=riNow()+RI_OPEN_MS; }
}
function riOpen(){ return !!((P&&P.hud&&P.hud.cond&&P.hud.cond.o)||(G&&RIF.g===G&&riNow()<RIF.until)); }
function hudOff(id){
  var o=(P&&P.hud&&P.hud[id])||{};
  return {dx:o.dx||0,dy:o.dy||0,c:(id==='cond')?!riOpen():(!!o.c&&id!=='body')};   // v35.xx (cw-quiethud): run info is folded unless it is open for a moment or for good
'@

SubRx @'
          P.hud[hk].c=!P.hud[hk].c; saveProfile(); blip('pick');
'@ @'
          if(hk==='cond'){ P.hud.cond.o=riOpen()?0:1; RIF.until=0; }   // v35.xx (cw-quiethud): the run info arrow opens it for good from folded, and folds it from open
          else P.hud[hk].c=!P.hud[hk].c;
          saveProfile(); blip('pick');
'@

SubRx @'
    var _ps=playerStatus();
'@ @'
    // v35.xx (cw-quiethud), HIS ORDER (2026-10-27): "build the quiet hud, all 5 changes" (change 3, things at rest hide). The posture word shows only
    // when it matters, crouched or down; standing, jogging and the rest are at rest and draw nothing (the reticle, the use bar and the search bar
    // carry the actions). The pillager board keeps its own status words.
    var _ps=p.downed?'DOWN':(G.pCrouch?'CROUCHED':'');
    if(!_ps) return;
'@

SubRx @'
  if(_lowDim) ctx.globalAlpha=0.45;
'@ @'
  var _sfa=stamFade(p);   // v35.xx (cw-quiethud), change 3: the stamina bar and its word show only while stamina is not full, fading in and out
  ctx.globalAlpha=(_lowDim?0.45:1)*_sfa;
'@

SubRx @'
  bar(16,by-29,HBW,16,p.stam/100,_stc);
'@ @'
  if(_sfa>0.001) bar(16,by-29,HBW,16,p.stam/100,_stc);
'@

SubRx @'
  ctx.fillText(p.stamLock?'WINDED':'STAMINA',
'@ @'
  ctx.globalAlpha=_sfa; if(_sfa>0.001) ctx.fillText(p.stamLock?'WINDED':'STAMINA',
'@

SubRx @'
function drawHUD(){
'@ @'
// v35.xx (cw-quiethud), HIS ORDER (2026-10-27): "build the quiet hud, all 5 changes" (change 3, things at rest hide). The stamina bar shows only while
// stamina is not full: it fades in over 0.15 s when it starts to drain and out over 0.5 s once it is full again, so it never pops. A new raid starts at
// its resting state with no fade. Real time, so a slowed raid clock does not hold it.
var STAMF={g:null,a:0,t:0};
function stamFade(p){
  var now=(typeof performance!=='undefined')?performance.now():Date.now(), want=(p&&(p.stamLock||p.stam<100))?1:0, d;
  if(STAMF.g!==G){ STAMF.g=G; STAMF.a=want; STAMF.t=now; return want; }
  d=Math.min(0.1,Math.max(0,(now-STAMF.t)/1000)); STAMF.t=now;
  STAMF.a=want?Math.min(1,STAMF.a+d/0.15):Math.max(0,STAMF.a-d/0.5);
  return STAMF.a;
}
function drawHUD(){
'@

SubRx @'
        if(note) _clines.push({v:(lost?'LOST   ':'')+note,vc:lost?UIC.danger:UIC.ok});
'@ @'
        // v35.xx (cw-quiethud), change 3: a conduct line that only says nothing has happened yet is at rest and draws nothing; it comes back the
        // moment it changes (broken, or the elite down), and that opens the panel. The count line says the contract is there.
        var _crest=!lost&&(CC.ck==='clean'||CC.ck==='steady'||(CC.ck==='elite'&&!((T.eliteKills||0)>0)));
        if(note&&!_crest) _clines.push({v:(lost?'LOST   ':'')+note,vc:lost?UIC.danger:UIC.ok});
'@

SubRx @'
    delete HUDBOX.cond;
'@ @'
    // v35.xx (cw-quiethud), change 3: what can move (the contract lines and the goals) opens the panel for a moment when it changes, and the one line
    // the folded panel shows is the count: contracts done of all, and goals done of all.
    var _rsig=(_arc?'':_clines.map(function(q){ return q.v; }).join('|'))+'#', _rcn=0, _rcd=0, _rgn=0, _rgd=0, _rtl=[], _rg, _rc;
    if(G.flow&&G.flow.goals) for(_rg=0;_rg<G.flow.goals.length;_rg++){ _rgn++; if(G.flow.goals[_rg].done) _rgd++; _rsig+=String(G.flow.goals[_rg].v)+'/'+(G.flow.goals[_rg].done?1:0)+';'; }
    if(!_arc&&CFG.condHud!==0&&P.contracts) for(_rc=0;_rc<P.contracts.length;_rc++){ if(!P.contracts[_rc]) continue; _rcn++; if(P.contracts[_rc].prog>=P.contracts[_rc].n) _rcd++; }
    if(_rcn) _rtl.push('contracts '+_rcd+'/'+_rcn);
    if(_rgn) _rtl.push('goals '+_rgd+'/'+_rgn);
    var _rttl=_rtl.length?_rtl.join('   '):'run info';
    riNote(_rsig);
    delete HUDBOX.cond;
'@

SubRx @'
    var bx=W-16-bw, by=LH(30);
'@ @'
    var bx=W-16-bw, by=TRG.y0;   // v35.xx (cw-quiethud), change 2: with the wallet rows gone the panel starts at the top of the corner column, where they were
'@

SubRx @'
ctx.fillStyle=UIC.tx_1; ctx.fillText('RUN INFO',bx+pad,ry);
'@ @'
ctx.fillStyle=UIC.tx_1; ctx.fillText(_rttl,bx+pad,ry);   /* v35.xx (cw-quiethud): the title is the count, folded or open */
'@

SubRx @'
    // v13.08, HIS NOTE: not in the Undercroft. The belt strip is drawn on the floor
    // as well as in a raid, and this caption offers two actions that do not exist
    // down there: there is nothing to fire at and nobody to signal. It stays in a
    // raid, where both are real and he uses them.
    if(state!=='hub'){
      ctx.font=beltCapFS(bw); ctx.textAlign='center';   // v18.71: grows with the slots under it; v19.66: and with the screen
      // v19.34, seen on the 4K fog screenshot (2026-10-08): grey words straight on the ground, so on pale ground (fog, sand, a lit
      // floor) they all but vanished. They sit on a soft dark strip now, a little brighter, at the same size and place.
      var _bcT=sl[sel].name+'   [FIRE] use', _bcW=ctx.measureText(_bcT).width, _bcF=parseFloat(((/([\d.]+)px/).exec(String(ctx.font))||[0,11])[1])||11;
      BELTCAP={x:Math.round(W/2-_bcW/2-_bcF*0.6),y:Math.round(hy-LH(6)-_bcF*0.95),w:Math.round(_bcW+_bcF*1.2),h:Math.round(_bcF*1.25)};   // v28.xx (cw-hudcorner): the caption strip as drawn, screen pixels, so the keys chip on its row and the list over it keep off it
      ctx.fillStyle='rgba(17,19,21,.72)'; ctx.fillRect(BELTCAP.x,BELTCAP.y,BELTCAP.w,BELTCAP.h);   // vNN.xx (ui5q1n): graphite, as the HUD plate
      ctx.fillStyle='#b4bfca';
      // vNN.xx, UI REDESIGN ui5q1n (his #50 and #35, from the AAA judge of the raid HUD shot): THE BELT CAPTION DRAWS KEYCAPS. Its keys
      // were bracketed words ([FIRE] use, [V] signal) beside the keycaps of every world prompt (ui7, hudPrompt). As hudPrompt does, the
      // line is still drawn whole through the TX door (his wording and the word editor are untouched), with each bracketed key cut out
      // by a clip, and a keycap (hudKey) drawn in its place. Same words, same place, same size.
      (function(){
        var _y=hy-LH(6), _T=(typeof TX==='function')?TX(_bcT):_bcT, _tw=hudRawW(_T), _x0=W/2-_tw/2, _m=ctx.measureText(_T), _re=/\[[^\]]+\]/g, _k, _ks=[];
        var _a=(_m.actualBoundingBoxAscent>0)?_m.actualBoundingBoxAscent:_bcF*0.72;
        while((_k=_re.exec(_T))) _ks.push({i:_k.index,s:_k[0]});
        if(!_ks.length||typeof hudKey!=='function'){ ctx.fillText(_bcT,W/2,_y); return; }   // v13.52: no pad button reaches V; v18.71: the key as set
        ctx.save(); ctx.beginPath(); ctx.rect(_x0-_bcF,_y-_a-_bcF,_tw+_bcF*2,_a+_bcF*2);
        _ks.forEach(function(q){ q.x=_x0+hudRawW(_T.slice(0,q.i)); q.w=hudRawW(q.s); ctx.rect(q.x,_y-_a-_bcF,q.w,_a+_bcF*2); });
        ctx.clip('evenodd');
        try{ ctx.fillText(_bcT,W/2,_y); } finally { ctx.restore(); }
        _ks.forEach(function(q){ hudKey(q.s.slice(1,-1),q.x,_y,_a,q.w,{fill:'#3b434b',ink:UIC.tx_1}); });   // v28.xx (cw-firechip), the critic (2026-10-20): the fire chip had a lime fill beside the lime selected slot, two lime fills. The belt caption keycaps are a quiet grey chip now; lime stays on the selected slot.
        ctx.textAlign='center';
      })();
      ctx.textAlign='left';
    }
'@ @'
    // v35.xx (cw-quiethud), HIS ORDER (2026-10-27): "build the quiet hud, all 5 changes" (change 4, the gun name once). The caption over the belt (the
    // name of the key in hand and the fire key) is gone: the ammo card names the gun or the item, and an item in hand draws its own fire key line (drawHand).
    BELTCAP=null;
'@

SubRx @'
var VER='35.35';
'@ @'
var VER='35.36';
'@

$pat = "(?m)^  now:'v35\.35:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v35.36: the raid hud is quieter: no money card in the corner, the posture word and the stamina bar show only when they matter, run info folds to its count and opens when a contract moves, and the gun is named only on the ammo card Check 35.36 fails on v35.35',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
