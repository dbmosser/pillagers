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

# SEASON ZERO M3: TWO PLAYER GEAR (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function netRevNeed(){ return NET_REV_T*(1-wornM('revive')); }
'@ @'
// v37.xx (cw-m3coop), HIS RULINGS OF 11-01 (season zero m3, plan worn gear): A PARTNER'S GEAR COUNTS ON THE HOST. wornM reads your own body. The host runs how far an enemy
// sees a partner and the partner's search on its boxes, so those two read the partner's sum, sent with his state word (netWornPut) and cleaned on arrival. Every other stat
// (speed, stamina, reload, aim, noise, bandage time, time on the floor, revive, damage taken) already runs in the partner's own window on his own wornM: the host sends the
// raw blow and his damagePlayer cuts it, so the host never cuts it a second time. No word, an older window's word or a bad one reads 0, which every site turns into exactly 1.
function wornMof(p,s){ if(!p||typeof G==='undefined'||!G) return 0; if(p===G.player) return wornM(s); return (p.net&&!G.sim)?netSeatWm(p.seat,s):0; }
function netSeatWm(seat,s){ var g=(typeof NET==='object'&&NET&&NET.up)?NET.up[seat|0]:null; return (g&&g.wm&&typeof G!=='undefined'&&G&&!G.sim)?(+g.wm[s]||0):0; }
function netRevNeed(){ return NET_REV_T*(1-wornM('revive')); }
'@

SubRx @'
function netPnPut(msg,n){
'@ @'
// v37.xx (cw-m3coop): THE PARTNER'S GEAR ON THE WIRE, with his state word up top: wm, his summed stats (p.wm: his gear and his pillager's traits), and wg, what he wears as
// kind.rarity for his row. Sent when it changes and every tenth word, like his look. Off the wire only WORN_STATS keys are kept, each a number held between minus its base
// and its cap; a stat that is not a number makes the whole word nothing. wg keeps only known kinds with rarity 0 to 3, nine at most, rarest first.
function netWmClean(w){
  var out={}, s, v, any=0;
  if(!w||typeof w!=='object'||Array.isArray(w)) return null;
  for(s in WORN_STATS){
    if(!Object.prototype.hasOwnProperty.call(WORN_STATS,s)||!Object.prototype.hasOwnProperty.call(w,s)) continue;
    v=w[s]; if(typeof v!=='number'||!isFinite(v)) return null;
    v=Math.max(-WORN_STATS[s].base,Math.min(WORN_STATS[s].cap,v)); if(v){ out[s]=v; any=1; }
  }
  return any?out:null;
}
function netWgClean(a){
  var out=[], i, q, r;
  if(!Array.isArray(a)) return out;
  for(i=0;i<a.length&&i<40&&out.length<WORN_SLOTS.length;i++){
    q=(typeof a[i]==='string'&&a[i].length<=12)?a[i].split('.'):null; if(!q||q.length!==2) continue;
    r=+q[1]; if(!Object.prototype.hasOwnProperty.call(WORN_KINDS,q[0])||!(r>=0&&r<=3)||r%1||q[1]==='') continue;
    out.push({k:q[0],r:r});
  }
  out.sort(function(x,y){ return y.r-x.r; });
  return out;
}
function netWornWord(){
  var p=(typeof G!=='undefined'&&G)?G.player:null, m={}, l=[], s, i, pc, W=null;
  if(p&&p.wm&&!G.sim) for(s in WORN_STATS) if(Object.prototype.hasOwnProperty.call(WORN_STATS,s)&&+p.wm[s]) m[s]=+(+p.wm[s]).toFixed(4);
  if(P&&P.worn&&typeof P.worn==='object'&&!(G&&G.sim)&&!(typeof ARCADE==='object'&&ARCADE&&ARCADE.on)) W=P.worn;
  if(W) for(i=0;i<WORN_SLOTS.length;i++){ pc=W[WORN_SLOTS[i]]; if(pc&&WORN_KINDS[pc.k]) l.push(pc.k+'.'+Math.max(0,Math.min(3,pc.r|0))); }
  return {m:m,g:l};
}
function netWornPut(msg,n){ var w=netWornWord(), s=JSON.stringify(w); if(s!==NET.wmSent||n%10===0){ msg.wm=w.m; msg.wg=w.g; NET.wmSent=s; } }
function netPnPut(msg,n){
'@

SubRx @'
  if(up) g.pb=m.pb?1:0;
'@ @'
  if(up&&m.wm!==undefined){ g.wm=netWmClean(m.wm); g.wg=netWgClean(m.wg); }   // v37.xx (cw-m3coop): his gear sum and list; a word without them (an older window, or the nine between sends) leaves what was last said, and none ever said reads as nothing
  if(up) g.pb=m.pb?1:0;
'@

SubRx @'
    if(up&&g.pb) out.pb=1;
'@ @'
    if(up&&m.wm!==undefined){ out.wm=g.wm||{}; out.wg=(g.wg||[]).map(function(q){ return q.k+'.'+q.r; }); }   // v37.xx (cw-m3coop): passed on, cleaned
    if(up&&g.pb) out.pb=1;
'@

SubRx @'
  if(ls!==NET.lkSent||NET.upN%10===0){ msg.lk=lk; NET.lkSent=ls; }
'@ @'
  if(ls!==NET.lkSent||NET.upN%10===0){ msg.lk=lk; NET.lkSent=ls; }
  netWornPut(msg,NET.upN);   // v37.xx (cw-m3coop): his gear sum and what he wears
'@

SubRx @'
if(NET.role==='host') netSrchTick((G.paused&&!netPauseLive())?0:dt); else if(NET.role==='join') netSrchSync();
'@ @'
if(NET.role==='host') netSrchTick((G.paused&&!netPauseLive())?0:dt); else if(NET.role==='join') netSrchSync(); try{ wgGiveTick(); }catch(_wgt){}   /* v37.xx (cw-m3coop): a gear hand-off runs out or is sent again */
'@

SubRx @'
var _wmh=(p===G.player)?1-wornM('hide'):1,
'@ @'
var _wmh=1-wornMof(p,'hide'),   /* v37.xx (cw-m3coop): a partner's own hard to spot, from his word */
'@

SubRx @'
ct.prog=(ct.prog||0)+dt/r.slow*(G.arcade?ARCADE_SRCH:1)*(duoAt(ct,+s)?DUO_SRCH:1);
'@ @'
ct.prog=(ct.prog||0)+dt/r.slow/(1-netSeatWm(+s,'search'))*(G.arcade?ARCADE_SRCH:1)*(duoAt(ct,+s)?DUO_SRCH:1);   /* v37.xx (cw-m3coop): his search gear, from his word */
'@

SubRx @'
if(s.ok) near.prog=Math.min(near.time||1,(near.prog||0)+dt/buzzSlow()*(G.arcade?ARCADE_SRCH:1)*(duoAt(near,NET.seat)?DUO_SRCH:1));
'@ @'
if(s.ok) near.prog=Math.min(near.time||1,(near.prog||0)+dt/buzzSlow()/(1-wornM('search'))*(G.arcade?ARCADE_SRCH:1)*(duoAt(near,NET.seat)?DUO_SRCH:1));   /* v37.xx (cw-m3coop): his search gear, as the host now runs it */
'@

SubRx @'
  wornBoxRoll(ct);   // v37.xx (cw-m3drops): the host rolls with its own seed and its own best gear; the same key means the same piece on both PCs
'@ @'
  wornBoxRoll(ct);   // v37.xx (cw-m3drops): the host rolls with its own seed and its own best gear; the same key means the same piece on both PCs
  // v37.xx (cw-m3coop): power for a partner's pull is the host's wornDropPw FOR NOW (the same key must mean the same piece on both PCs); the key goes to whoever pulled it and each PC banks only its own bag into its own P.gear
'@

SubRx @'
function netGiftKey(){
'@ @'
// v37.xx (cw-m3coop), HIS RULINGS OF 11-01 (season zero m3, answer 75: "don't know if we ever figured out trading but yes"): HAND A WORN PIECE TO YOUR PARTNER. With the
// backpack open, a piece in the bag (never one worn) goes to the partner within the revive reach who is not down: T on the keyboard, Y on a pad (Y still drops anything
// else, and a piece with nobody in reach). The gift words carry a gear mark (wg): the partner's window says yes by itself when it can take it, the piece leaves the giver's
// bag only on that yes and lands in the partner's bag by its key (a key spells its piece, 00p-m3a), so both PCs agree or nothing moves. A lost offer or yes leaves it with
// the giver (the ask runs out after WG_GIVE_T); the hand-over is sent again each second until the partner says got, and the partner takes an id only once, so it is
// never doubled. Only gear: every other item keeps the v17.44 offer.
var WG_GIVE_T=4;
function wgGiveOk(){ return typeof G!=='undefined'&&!!G&&!G.over&&!G.sim&&!G.hubFloor&&!!G.player&&typeof NET==='object'&&!!NET&&!!NET.on&&!(typeof ARCADE==='object'&&ARCADE&&ARCADE.on); }
function wgGiveSeat(){ var p=(typeof G!=='undefined'&&G)?G.player:null; if(!wgGiveOk()||!p||p.downed||p.dying) return -1; return netAidTarget(p,true); }
// The backpack footer: the give, only for a piece and only with someone in reach.
function wgGiveHint(it,pad){
  var s;
  if(!it||it.use!=='wornpiece') return '';
  s=wgGiveSeat(); if(s<0) return '';
  return '   '+(pad?'Y':keyName(keysOf('KeyT')))+' give to '+(netSeatName(s)||'partner');
}
function wgGive(k){
  var p=(typeof G!=='undefined'&&G)?G.player:null, s;
  if(!wgGiveOk()) return 'off';
  if(!p||p.downed||p.dying) return 'down';
  if(G.wgOut) return 'busy';
  if(!wornKeyIs(k)||!Array.isArray(G.bag)||G.bag.lastIndexOf(k)<0||!wornItemEnsure(k)) return 'none';
  s=wgGiveSeat();
  if(s<0){ if(!G.sim) say('no partner in reach','info',{key:'wggive'}); return 'far'; }
  G.wgOut={id:String(Date.now()%1e9)+'-'+Math.floor(Math.random()*1e4),k:k,to:s,t:G.t,st:'ask'};
  netGiftSend(s,{op:'offer',id:G.wgOut.id,k:k,wg:1});
  return 'asked';
}
// The selected stack in the backpack: true when it was a piece and the give took the key.
function wgGiveSel(pad){
  var S, st, k;
  if(typeof G==='undefined'||!G||!G.bagOpen||G.bagBelt||!Array.isArray(G.bag)) return false;
  S=bagStacks(); st=S[clamp(G.bagSel|0,0,Math.max(0,S.length-1))];
  if(!st||!st.idxs||!st.idxs.length) return false;
  k=G.bag[st.idxs[st.idxs.length-1]];
  if(!wornKeyIs(k)) return false;
  if(pad&&wgGiveSeat()<0) return false;   // a pad Y with nobody in reach drops it, as before
  wgGive(k);
  return true;
}
function wgGiftTake(fr,m){
  var k=netClean(m.k,40), id=String(m.id||'').slice(0,40), go=(typeof G!=='undefined'&&G)?G.wgOut:null, ix, it, nm=netSeatName(fr)||'partner';
  if(typeof G==='undefined'||!G||G.over||!G.player||G.hubFloor){ if(m.op==='offer') netGiftSend(fr,{op:'no',id:id,wg:1,why:'gone'}); return 'wg:noraid'; }
  if(m.op==='offer'){
    if(!wornKeyIs(k)||!wornItemEnsure(k)){ netGiftSend(fr,{op:'no',id:id,wg:1}); return 'wg:bad'; }
    if(G.player.downed||G.player.dying){ netGiftSend(fr,{op:'no',id:id,wg:1,why:'down'}); return 'wg:down'; }
    netGiftSend(fr,{op:'yes',id:id,wg:1});
    return 'wg:yes';
  }
  if(m.op==='yes'){
    if(!go||go.id!==id||go.to!==fr||go.st!=='ask') return 'wg:stale';
    ix=G.bag.lastIndexOf(go.k);
    if(ix<0){ G.wgOut=null; netGiftSend(fr,{op:'no',id:id,wg:1}); return 'wg:gone'; }
    G.bag.splice(ix,1); go.st='sent'; go.ts=G.t; go.tr=G.t;
    netGiftSend(fr,{op:'give',id:id,k:go.k,wg:1});
    it=ITEMS[go.k]; if(!G.sim) say(it?it.name:go.k,'pick',{item:go.k,tag:'given to '+nm});
    return 'wg:gave';
  }
  if(m.op==='give'){
    if(!G.wgGot) G.wgGot={};
    if(G.wgGot[id]){ netGiftSend(fr,{op:'got',id:id,wg:1}); return 'wg:dup'; }
    if(!wornKeyIs(k)||!wornItemEnsure(k)) return 'wg:bad';
    G.wgGot[id]=1;
    openContainer({x:G.player.x,y:G.player.y},[k]);
    if(!G.sim) pickTag(k,'from '+nm);
    netGiftSend(fr,{op:'got',id:id,wg:1});
    return 'wg:took';
  }
  if(m.op==='got'){ if(go&&go.id===id) G.wgOut=null; return 'wg:done'; }
  if(m.op==='no'){ if(go&&go.id===id&&go.st==='ask'){ G.wgOut=null; if(!G.sim) say(m.why==='down'?(nm+' is down'):'give failed','info',{key:'wggive'}); } return 'wg:no'; }
  return 'bad';
}
// Every raid frame of a linked window: an ask nobody answered runs out (the piece never left); a hand-over not yet got is sent again each second, for 12 seconds.
function wgGiveTick(){
  var go=(typeof G!=='undefined'&&G)?G.wgOut:null;
  if(!go) return 0;
  if(go.st==='ask'){ if(G.t-go.t>WG_GIVE_T){ G.wgOut=null; if(!G.sim) say('give failed','info',{key:'wggive'}); return 1; } return 0; }
  if(G.t-go.ts>WG_GIVE_T*3){ G.wgOut=null; return 1; }
  if(G.t-go.tr>=1){ go.tr=G.t; netGiftSend(go.to,{op:'give',id:go.id,k:go.k,wg:1}); return 2; }
  return 0;
}
function netGiftKey(){
'@

SubRx @'
    if(bagBeltNo('TO OFFER IT')) return true;
'@ @'
    if(wgGiveSel(0)) return true;   // v37.xx (cw-m3coop): a worn piece is handed over, never offered
    if(bagBeltNo('TO OFFER IT')) return true;
'@

SubRx @'
    out={t:'gift',op:m.op,id:m.id,k:m.k,ib:m.ib,to:m.to,from:fr,hub:m.hub?1:0,why:m.why};
'@ @'
    out={t:'gift',op:m.op,id:m.id,k:m.k,ib:m.ib,to:m.to,from:fr,hub:m.hub?1:0,why:m.why}; if(m.wg) out.wg=1;   /* v37.xx (cw-m3coop) */
'@

SubRx @'
  if(m.hub) return netHubGiftTake(peer,m,fr);
'@ @'
  if(m.wg) return wgGiftTake(fr,m);   // v37.xx (cw-m3coop): a worn piece handed over
  if(m.hub) return netHubGiftTake(peer,m,fr);
'@

SubRx @'
if(pressed(3)&&bagNav&&!PAD.prev[3]){ try{ bagDropSel(); }catch(_gk){} }
'@ @'
if(pressed(3)&&bagNav&&!PAD.prev[3]){ try{ if(!wgGiveSel(1)) bagDropSel(); }catch(_gk){} }   /* v37.xx (cw-m3coop): a worn piece with the partner in reach is handed over */
'@

SubRx @'
        +(isGun?'   ENTER equip   SHIFT+ENTER to back':'')
'@ @'
        +(isGun?'   ENTER equip   SHIFT+ENTER to back':'')
        +wgGiveHint(sit,0)   // v37.xx (cw-m3coop)
'@

SubRx @'
:padOn()?padB('DPAD move, past the ends to the hotbar   A pick up or place   B close')
'@ @'
:padOn()?padB('DPAD move, past the ends to the hotbar   A pick up or place'+wgGiveHint(sit,1)+'   B close')
'@

SubRx @'
  _trh=Math.max(1,_tun)*Math.round(56*_thr);
'@ @'
  // v37.xx (cw-m3coop): a row that lists what he wears is 14 taller, so the rows step 70 when one does
  var _tst=56; try{ for(_tj=0;_tj<(NET.up||[]).length;_tj++) if(netUpShown(NET.up[_tj])&&NET.up[_tj].wg&&NET.up[_tj].wg.length) _tst=70; }catch(_tw){}
  _trh=Math.max(1,_tun)*Math.round(_tst*_thr);
'@

SubRx @'
    y=Math.round(H*0.30)+n*56; n++;
'@ @'
    y=Math.round(H*0.30)+n*_tst; n++;
'@

SubRx @'
_ty=_tt+(n-1)*Math.round(56*_thr)+Math.round(15*_thr);
'@ @'
_ty=_tt+(n-1)*Math.round(_tst*_thr)+Math.round(15*_thr);
'@

SubRx @'
NETTEAMBOX={n:n,x:hudIns(),y:_tt,w:Math.round(158*_thr),h:Math.round(n*56*_thr)};
'@ @'
NETTEAMBOX={n:n,x:hudIns(),y:_tt,w:Math.round(158*_thr),h:Math.round(n*_tst*_thr)};
'@

SubRx @'
    hudPanel(x-4,y-15,w+8,48,undefined,1);
'@ @'
    hudPanel(x-4,y-15,w+8,48+((g.wg&&g.wg.length)?14:0),undefined,1);
'@

SubRx @'
    } finally { hudFadeEnd(_hfMate); }
'@ @'
    // v37.xx (cw-m3coop), HIS RULINGS OF 11-01 (season zero m3): the partner sees what you wear, as a list until m6 draws it: a fourth line, each kind in its rarity colour,
    // rarest first, +n when the row is full. Nothing when he wears nothing or his window is older.
    if(g.wg&&g.wg.length){
      var _wx=x, _wi, _wn, _ww, _wpl;
      ctx.font=FS(TYPE.micro); ctx.textAlign='left'; _wpl=ctx.measureText('+9').width;
      for(_wi=0;_wi<g.wg.length;_wi++){
        _wn=WORN_KINDS[g.wg[_wi].k]?WORN_KINDS[g.wg[_wi].k].n:''; _ww=ctx.measureText(_wn).width;
        if(_wx+_ww>x+w-((_wi<g.wg.length-1)?_wpl+6:0)) break;
        ctx.fillStyle=WORN_RARS[g.wg[_wi].r].c; ctx.fillText(_wn,_wx,y+44); _wx+=_ww+6;
      }
      if(_wi<g.wg.length){ ctx.fillStyle=HUDC.dim; ctx.fillText('+'+(g.wg.length-_wi),_wx,y+44); }
    }
    } finally { hudFadeEnd(_hfMate); }
'@

SubRx @'
var VER='37.64';
'@ @'
var VER='37.65';
'@

$pat = "(?m)^  now:'v37\.64:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v37.65: in a two player raid your gear counts for you on the host too: enemies see you from less far with hard to spot, and your search runs at your own speed on the host boxes (damage, speed and the rest already ran in your own window). The teammate row lists what your partner wears, each kind in its rarity colour. With the backpack open, T (Y on a pad) hands a piece from your bag to a partner within revive reach who is not down: it leaves your bag and lands in theirs with a line on each side; a lost word leaves it with you and it is never doubled. Worn pieces stay worn. Solo, the demo and a raid with nothing worn play as before Check 37.65 fails on v37.64',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
