$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
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

if ($s.Contains("  {v:'16.80',what:")) { throw "check 16.80 is in the fixture already" }

SubRx @'
  {v:'16.79',what:
'@ @'
  {v:'16.80',what:'the controller follows its window whether or not that window is in front: a window whose pad timestamp moves plays it with focus false and hands the other window its pad, a window whose pad stands still plays only a state handed over, a state handed over 0.4 s ago still plays (a slow host frame no longer drops it) while one 0.8 s old lets go, and after 1.5 s with neither the window that had a pad says CONTROLLER PAUSED on the HUD, under the message scale, and where to click, never a window that had none; outside a same machine mode the first pad is read as before',
   run:function(){
     if(typeof NET==='undefined'||!NET||typeof netPadTick!=='function'||typeof netSameOnMsg!=='function'||typeof pollPad!=='function'||typeof PAD==='undefined'||!PAD||typeof padRelease!=='function'||typeof padOpenModal!=='function'||typeof netReset!=='function') return 'SKIP: this build has no controller hand-over between two windows on one PC';
     if(typeof netPadLive!=='function'||typeof netPadHud!=='function'||typeof NET_PAD_LIVE!=='number'||typeof NET_PAD_DEAD!=='number') return 'this build reads the controller by focus alone: a window Chrome still feeds plays nothing once it is not in front, a slow host frame drops the state handed over, and nothing tells player 2 when both windows are out';
     if(typeof G!=='undefined'&&G&&!G.over) return 'SKIP: a raid is running, and the hand-over is measured on the Undercroft floor';
     if(!window.__hubEnter||!window.__topClear) return 'SKIP: this fixture cannot reach the Undercroft floor';
     if(NET.same||NET.on) return 'SKIP: a party is on in this copy, and the check stands in for the player 2 window';
     var bad=[], NG=navigator.getGamepads, stubbed=false, hf={v:false}, hadHF=Object.prototype.hasOwnProperty.call(document,'hasFocus'), oHF=document.hasFocus, hfStub=false, PAIR='zqxpadlive1', ts=1000, k0=null, rng0=null, line='';
     var _s2=(typeof say2==='function')?say2:null;
     var oZ=(typeof hudZoomIn==='function')?hudZoomIn:null, zc=0;
     var keepPad={on:PAD.on,announced:PAD.announced,prev:(PAD.prev||[]).slice(),ax:PAD.ax,mx:PAD.mx,my:PAD.my};
     var keepNet={padIx:NET.padIx,padOther:NET.padOther,padTs:NET.padTs,padLiveAt:NET.padLiveAt,padOkAt:NET.padOkAt,padHad:NET.padHad};
     var ch={posted:[],onmessage:null,postMessage:function(m){ this.posted.push(m); },close:function(){}};
     function posts(t){ var o=[], q; for(q=0;q<ch.posted.length;q++) if(ch.posted[q]&&ch.posted[q].t===t) o.push(ch.posted[q]); return o; }
     function last(t){ var o=posts(t); return o.length?o[o.length-1]:null; }
     function pad(ix,down,stamp){ var bts=[], q, d; for(q=0;q<17;q++){ d=down.indexOf(q)>=0; bts.push({pressed:d,value:d?1:0,touched:d}); } return {connected:true,id:'probe pad '+ix,index:ix,mapping:'standard',timestamp:stamp,axes:[0,0,0,0],buttons:bts}; }
     function pads(list){ navigator.getGamepads=function(){ return list; }; }
     function both(stamp){ pads([pad(0,[3],stamp),pad(1,[0],stamp)]); }
     function fwd(ix,own,down){ var p=[], v=[], q; for(q=0;q<17;q++){ p.push(down.indexOf(q)>=0?1:0); v.push(down.indexOf(q)>=0?1:0); } return {t:'pad',pair:PAIR,ix:ix,own:own,p:p,v:v,a:[0,0,0,0]}; }
     function closeAll(){ [].forEach.call(document.querySelectorAll('.modal.on'),function(m){ m.classList.remove('on'); }); }
     function frame(){ pollPad(); }
     function st(){ return 'on '+PAD.on+', F '+!!keys.KeyF+', R '+!!keys.KeyR; }
     try{
       __topClear();
       try{ __hubEnter(); }catch(_h){}
       closeAll();
       try{ var pbx=document.getElementById('pausebox'); if(pbx&&pbx.classList.contains('on')){ try{ togglePauseBox(false); }catch(_tp){} if(pbx.classList.contains('on')){ pbx.classList.remove('on'); pauseOpen=false; } } }catch(_pb){}
       if(typeof state==='undefined'||state!=='hub'||!HB||!HB.player) return 'SKIP: the Undercroft floor is not up here';
       if(padOpenModal()) return 'SKIP: a panel is open over the floor, so the reader would work the panel and not the floor';
       try{ navigator.getGamepads=function(){ return []; }; stubbed=(navigator.getGamepads!==NG); }catch(_s){}
       if(!stubbed){ try{ navigator.getGamepads=NG; }catch(_r0){} return 'SKIP: this browser will not let the pad be faked'; }
       try{ document.hasFocus=function(){ return hf.v; }; hfStub=(document.hasFocus()===false); }catch(_hf){ hfStub=false; }
       if(!hfStub) return 'SKIP: this browser will not let the focus be faked';
       if(_s2) say2=function(){};
       k0=keys; keys={};
       PAD.announced=true; PAD.on=false; PAD.prev=[];
       rng0=RNGS;
       NET.same='p2'; NET.pair=PAIR; NET.mode='coop'; NET.bc=ch; NET.padIx=-1; NET.padOther=-1; NET.padFwd=null;
       NET.padTs=null; NET.padLiveAt=undefined; NET.padOkAt=undefined; NET.padHad=false;
       // ONE: not in front, fed a pad whose timestamp moves: played, and the second pad is handed to the host.
       both(ts); frame();
       both(ts+=8); frame();
       if(!PAD.on||!PAD.prev[3]||!keys.KeyF) bad.push('player 2 not in front, fed a pad whose timestamp moves, does not play it ('+st()+')');
       if(!last('pad')||last('pad').ix!==1||last('pad').own!==-1) bad.push('player 2 fed live data did not hand the host the second pad ('+JSON.stringify(last('pad'))+')');
       // TWO: the timestamps stand still and nothing is handed over: once the live hold runs out, its frozen read is not played.
       both(ts); frame();
       NET.padLiveAt-=(NET_PAD_LIVE+1); ch.posted=[]; frame();
       if(PAD.on||keys.KeyF) bad.push('player 2 whose pad timestamp stands still, with nothing handed over, still plays its own frozen read ('+st()+')');
       if(posts('pad').length) bad.push('player 2 with a frozen read still handed the host a state');
       // THREE: the state handed over rides out a slow host frame: 0.4 s old plays, 0.8 s old lets go.
       if(netSameOnMsg(fwd(0,-1,[2]))!=='pad'||!NET.padFwd) bad.push('a state the host handed over was refused');
       else {
         NET.padFwd.at-=0.4; frame();
         if(!PAD.on||!keys.KeyR) bad.push('a state handed over 0.4 s ago is not played, so a slow frame on the host drops the controller ('+st()+')');
         NET.padFwd.at-=0.4; frame();
         if(PAD.on||keys.KeyR) bad.push('a state handed over 0.8 s ago is still played ('+st()+')');
       }
       // FOUR: the HUD word. Fresh: nothing. Neither live data nor a state handed over for over 1.5 s: CONTROLLER PAUSED and
       // where to click, drawn under the message scale so it never sits across the message plate. A window that never
       // played a pad says nothing.
       var need=['CONTROLLER','PAUSED'].join(' ');
       line=String(netPadHud()||'');
       if(line) bad.push('the HUD says the controller paused right after it let go ('+line+')');
       if(NET.padOkAt===undefined) bad.push('the window does not note when it last had a controller');
       else {
         NET.padOkAt-=(NET_PAD_DEAD+0.1);
         if(oZ){ zc=0; hudZoomIn=function(k,ax,ay){ if(k==='msg') zc++; return oZ(k,ax,ay); }; }
         line=String(netPadHud()||'');
         if(oZ){ hudZoomIn=oZ; if(!zc) bad.push('the pause word is not drawn under the message scale, so on a screen above 1080p or with the message plate grown the message sits across it'); }
         if(line.toUpperCase().indexOf(need)<0||line.toLowerCase().indexOf('click')<0||line.toLowerCase().indexOf('window')<0) bad.push('player 2 with neither live data nor a state handed over for over 1.5 s is not told on the HUD to click a game window ('+(line||'nothing')+')');
         NET.padHad=false;
         line=String(netPadHud()||'');
         if(line) bad.push('a window that never played a controller says it paused ('+line+')');
       }
       // FIVE, CONTROL: outside a same machine mode the first connected pad is read as before, focus or none.
       NET.same=''; NET.pair=''; NET.padFwd=null;
       both(ts+=8); frame();
       if(!PAD.on||!keys.KeyF) bad.push('control: outside a same machine mode the first connected pad is not read as before ('+st()+')');
       if(RNGS!==rng0) bad.push('the seeded stream moved from '+rng0+' to '+RNGS+' through the hand-over');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ if(oZ) hudZoomIn=oZ; }catch(_hz){}
       try{ NET.bc=null; NET.same=''; NET.pair=''; NET.mode=''; NET.padFwd=null; }catch(_n){}
       try{ netReset(); }catch(_nr){}
       try{ NET.padIx=keepNet.padIx; NET.padOther=keepNet.padOther; NET.padTs=keepNet.padTs; NET.padLiveAt=keepNet.padLiveAt; NET.padOkAt=keepNet.padOkAt; NET.padHad=keepNet.padHad; }catch(_n2){}
       try{ if(hfStub){ if(hadHF) document.hasFocus=oHF; else delete document.hasFocus; } }catch(_h2){}
       try{ if(stubbed){ navigator.getGamepads=function(){ return []; }; pollPad(); } }catch(_p0){}
       try{ padRelease(); }catch(_pr){}
       try{ navigator.getGamepads=NG; }catch(_p){}
       if(k0) keys=k0;
       try{ PAD.on=keepPad.on; PAD.announced=keepPad.announced; PAD.prev=keepPad.prev; PAD.ax=keepPad.ax; PAD.mx=keepPad.mx; PAD.my=keepPad.my; PAD.held={}; }catch(_pd){}
       if(_s2) say2=_s2;
       try{ __topClear(); }catch(_tc){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'16.79',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
