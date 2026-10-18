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

if ($s.Contains("  {v:'29.60',what:")) { throw "check 29.60 is in the fixture already" }

SubRx @'
  {v:'29.59',what:
'@ @'
  {v:'29.60',what:'the UI motion layer opens and closes a window on a steppable clock (240 ms ease-out with a 16 px rise, 140 ms close, 35 ms stagger of at most 8 items, 200 ms tab slide) and a press or a close mid-move retargets within one frame, with no jump over 12 percent',
   run:function(){
     if(typeof UIM!=='object'||!UIM||typeof UIM.step!=='function') return 'the menus have no motion layer (no UIM): they open and shut without easing';
     var m=document.getElementById('partymodal'), was, bad=[], i, k, kids, t0, mx, prev, cur, pg, btn;
     if(!m) return 'SKIP: no party window';
     function op(){ return parseFloat(getComputedStyle(m).opacity); }
     function yy(){ var s=m.__uim; return s?s.y:0; }
     function near(v,w,tol,lab){ if(!(Math.abs(v-w)<=tol)) bad.push(lab+' was '+(+v).toFixed(3)+', want '+w); }
     function fresh(){ m.classList.remove('on'); UIM.chg(m); UIM.clearAll(); m.classList.add('on'); UIM.chg(m); }
     was=m.classList.contains('on');
     try{
       __topClear(); __runPrep();
       UIM.manual=true; UIM.logOn=true; UIM.log.length=0;
       fresh();
       near(op(),0,0.02,'opacity at 0 ms'); near((16-yy())/16,0,0.02,'rise at 0 ms');
       kids=UIM.kids(m);
       if(kids.length<3) bad.push('only '+kids.length+' items to stagger');
       t0=m.__uim?m.__uim.f.a.t0:0; mx=0;
       for(i=0;i<Math.min(kids.length,8);i++){ k=kids[i].__uim; if(!k||!k.f.a){ bad.push('item '+i+' has no entrance'); continue; } near(k.f.a.t0-t0,i*35,17,'item '+i+' start gap'); mx=Math.max(mx,k.f.a.t0+k.f.a.d-t0); }
       if(kids.length>8&&kids[8].__uim) bad.push('the ninth item is staggered too');
       if(mx>=500) bad.push('the whole entrance runs '+mx+' ms');
       UIM.step(50);  near(op(),0.50,0.08,'opacity at 50 ms'); near((16-yy())/16,0.50,0.08,'rise at 50 ms');
       UIM.step(50);  near(op(),0.80,0.08,'opacity at 100 ms');
       UIM.step(100); near(op(),0.99,0.08,'opacity at 200 ms');
       UIM.step(400);
       if(m.__uim||m.style.opacity!==''||m.style.translate!=='') bad.push('the open leaves its values on the window after 600 ms');
       // close: 140 ms ease-in, still on screen at once, gone within 150 ms
       m.classList.remove('on'); UIM.chg(m);
       if(getComputedStyle(m).display==='none') bad.push('a close cuts the window off at once, with no fade');
       UIM.step(70); near(op(),0.75,0.12,'opacity 70 ms into a close');
       UIM.step(80);
       if(getComputedStyle(m).display!=='none') bad.push('the window is still showing 150 ms after a close');
       if(m.style.display!==''||m.__uim) bad.push('a close leaves its override on the window');
       // a close 30 ms into an open: starts within one frame, no jump
       fresh(); UIM.step(30); prev=op();
       m.classList.remove('on'); UIM.chg(m);
       near(op(),prev,0.02,'the press itself moved the opacity');
       mx=0;
       for(i=0;i<12;i++){ prev=op(); UIM.step(16); cur=op(); if(i>0&&getComputedStyle(m).display==='none') break; mx=Math.max(mx,Math.abs(cur-prev)); if(i===0&&!(cur<prev)) bad.push('the close did not start within one frame of the press'); }
       if(mx>0.12) bad.push('a per-frame jump of '+mx.toFixed(3)+' when a close hit an open');
       // an open 60 ms into a close: goes back up from where it is
       fresh(); UIM.step(300); m.classList.remove('on'); UIM.chg(m); UIM.step(60); prev=op();
       m.classList.add('on'); UIM.chg(m); near(op(),prev,0.02,'the reopen jumped');
       mx=0;
       for(i=0;i<30;i++){ prev=op(); UIM.step(16); cur=op(); mx=Math.max(mx,Math.abs(cur-prev)); if(i===0&&!(cur>=prev)) bad.push('the reopen did not turn within one frame'); }
       if(mx>0.12) bad.push('a per-frame jump of '+mx.toFixed(3)+' when an open hit a close');
       near(op(),1,0.01,'opacity after a reopen');
       // confirm pulse and deny shake on a button inside the window
       fresh(); UIM.step(400);
       btn=document.getElementById('closeparty');
       if(!btn) bad.push('SKIP pulse: no close button');
       else {
         UIM.press(btn,'ok'); UIM.step(60); near(parseFloat(btn.style.scale)||1,1.06,0.006,'the confirm pulse at 60 ms');
         UIM.step(60); near(parseFloat(btn.style.scale)||1,1,0.001,'the confirm pulse at 120 ms');
         UIM.press(btn,'deny'); mx=0; for(i=0;i<25;i++){ UIM.step(4); mx=Math.max(mx,Math.abs(parseFloat(btn.style.translate)||0)); }
         if(mx<3.5||mx>6.01) bad.push('the deny shake peaks at '+mx.toFixed(2)+' px, not 6');
         UIM.step(8); if(btn.style.translate!=='') bad.push('the shake is still moving after 100 ms');
         fresh(); UIM.step(30); UIM.press(btn,'ok'); UIM.step(16);
         near((parseFloat(btn.style.scale)||1)-1,0.0245,0.012,'a press 30 ms into an open pulses at once');
       }
       // tab change on a page: 200 ms, 24 px slide
       pg=document.createElement('div'); pg.textContent='x'; document.body.appendChild(pg);
       UIM.tab(pg,1); near(parseFloat(getComputedStyle(pg).opacity),0,0.02,'a tab starts clear');
       UIM.step(50); near(parseFloat(getComputedStyle(pg).opacity),0.5,0.08,'tab opacity at 50 ms'); near(parseFloat(pg.style.translate)||0,12,2.2,'tab slide at 50 ms');
       UIM.step(200); if(pg.__uim) bad.push('the tab leaves its values after 250 ms');
       if(!UIM.log.length) bad.push('the per-frame log is empty');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       try{ UIM.manual=false; UIM.logOn=false; if(pg&&pg.parentNode) pg.parentNode.removeChild(pg); if(!was){ m.classList.remove('on'); UIM.chg(m); } UIM.clearAll(); if(was&&!m.classList.contains('on')) m.classList.add('on'); }catch(_f){}
       try{ __topClear(); }catch(_t){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'29.60',what:'the focus ring eases to its target (30 percent at 16 ms, 80 at 66, 95 at 120), the focused cell grows to 1.05, one move logs exactly one tick, and a focus outside the menus hides the ring',
   run:function(){
     if(typeof UIM!=='object'||!UIM||typeof UIM.step!=='function') return 'no motion layer (no UIM): the highlight jumps';
     var m=document.getElementById('partymodal'), was, bad=[], b1, b2, b3, ticks=[], os, x0, xf, f0, D;
     if(!m) return 'SKIP: no party window';
     function mk(par,l,t,w,h){ var b=document.createElement('button'); b.textContent='X'; b.style.cssText='position:fixed;display:block;box-sizing:border-box;padding:0;left:'+l+'px;top:'+t+'px;width:'+w+'px;height:'+h+'px'; par.appendChild(b); return b; }
     function near(v,w,tol,lab){ if(!(Math.abs(v-w)<=tol)) bad.push(lab+' was '+(+v).toFixed(3)+', want '+w); }
     function rc(){ var r=UIM.ring.getBoundingClientRect(); return r.left+r.width/2; }
     was=m.classList.contains('on'); f0=(typeof PAD!=='undefined'&&PAD)?PAD.focus:null; os=sndUi;
     try{
       __topClear(); __runPrep();
       UIM.manual=true;
       m.classList.remove('on'); UIM.chg(m); UIM.clearAll(); m.classList.add('on'); UIM.chg(m); UIM.step(400);
       b1=mk(m,100,100,80,40); b2=mk(m,500,300,120,60); b3=mk(document.body,900,500,80,40);
       sndUi=function(k){ ticks.push(k); return true; };
       padSetFocus(b1); UIM.step(16); UIM.step(400);
       if(!UIM.ring||UIM.ring.style.display==='none') bad.push('no focus ring on a button in the window');
       else {
         ticks.length=0; padSetFocus(b2);
         if(ticks.length!==1||ticks[0]!=='move') bad.push('one focus change logged '+ticks.length+' ticks ('+ticks.join(',')+')');
         padSetFocus(b2); if(ticks.length!==1) bad.push('the same cell focused again ticked');
         x0=rc(); xf=b2.getBoundingClientRect(); xf=xf.left+xf.width/2; D=xf-x0;
         UIM.step(16); near((rc()-x0)/D,0.33,0.08,'ring progress at 16 ms');
         UIM.step(50); near((rc()-x0)/D,0.81,0.08,'ring progress at 66 ms');
         UIM.step(54); near((rc()-x0)/D,0.95,0.05,'ring progress at 120 ms');
         UIM.step(300);
         near(parseFloat(b2.style.scale)||1,1.05,0.002,'the focused cell scale');
         if(b1.__uim) bad.push('the cell that lost focus keeps its scale');
         near(UIM.ring.getBoundingClientRect().width,b2.getBoundingClientRect().width+12,3,'the ring width at rest');
       }
       padSetFocus(b3); UIM.step(16);
       if(UIM.ring&&UIM.ring.style.display!=='none') bad.push('the ring stays up on a focus outside the menus');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       try{ sndUi=os; UIM.manual=false; [b1,b2,b3].forEach(function(b){ if(b&&b.parentNode) b.parentNode.removeChild(b); }); var pf=document.querySelectorAll('.padfocus'); for(var j=0;j<pf.length;j++) pf[j].classList.remove('padfocus'); if(!was){ m.classList.remove('on'); UIM.chg(m); } UIM.clearAll(); if(was&&!m.classList.contains('on')) m.classList.add('on'); if(typeof PAD!=='undefined'&&PAD) PAD.focus=f0; }catch(_f){}
       try{ __topClear(); }catch(_t){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'29.60',what:'one UI sound per event kind: the focus tick has 3 or more pitches within 3 percent and at most one per 40 ms, confirm, back, deny, open and close are five different sounds, and sndUi asks the picker',
   run:function(){
     if(typeof uiSndPick!=='function') return 'no sound picker (no uiSndPick): the which-sound decision cannot be tested';
     var bad=[], ps={}, st=-1, t=10, i, r, sig={}, ks=['ok','back','deny','open','close'], P={}, nn;
     for(i=0;i<20;i++){ r=uiSndPick('move',t+i*0.05,st,i); if(!r){ bad.push('tick '+i+' was refused 50 ms after the last'); continue; } st=t+i*0.05; ps[r.pitch.toFixed(3)]=1; if(r.pitch<0.9699||r.pitch>1.0301) bad.push('a tick pitch of '+r.pitch); }
     nn=Object.keys(ps).length; if(nn<3) bad.push('20 ticks use '+nn+' pitches, not 3 or more');
     if(uiSndPick('move',10.02,10,0)!==null) bad.push('a second tick 20 ms after the first plays');
     if(uiSndPick('move',10.039,10,0)!==null) bad.push('a second tick 39 ms after the first plays');
     if(uiSndPick('move',10.041,10,0)===null) bad.push('a tick 41 ms after the last is refused');
     if(uiSndPick('ok',10.035,10,0)===null) bad.push('a confirm 35 ms after another sound is refused');
     if(uiSndPick('nothing',50,-1,0)!==null) bad.push('an unknown kind makes a sound');
     ks.forEach(function(k){ var q=uiSndPick(k,100,-1,0); if(!q){ bad.push(k+' makes no sound'); return; } P[k]=q; var s=[q.ty,Math.round(q.f1),Math.round(q.f2),q.d].join('/'); if(sig[s]) bad.push(k+' sounds the same as '+sig[s]); sig[s]=k; });
     if(P.ok&&P.back){ if(!(P.back.d<P.ok.d)) bad.push('back is not shorter than confirm'); if(!(P.back.v<P.ok.v)) bad.push('back is not lighter than confirm'); }
     if(P.ok&&P.deny&&!(P.deny.f1<P.ok.f1&&P.deny.f2<=100)) bad.push('deny is not a dull low thud');
     if(String(sndUi).indexOf('uiSndPick(')<0) bad.push('sndUi does not use the picker');
     return bad.length?bad.join('; '):null; }},
  {v:'29.59',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
