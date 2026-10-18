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

if ($s.Contains("  {v:'31.27',what:")) { throw "check 31.27 is in the fixture already" }

SubRx @'
  {v:'31.26',what:
'@ @'
  {v:'31.27',what:'cw-endhalf, his Q60 (ending early halves the score, the same as dying): END RUN pressed twice in the real demo pause box halves the score in a one player run and both scores in a two player run, the second window halves its own figures from the very word the host sends and shows ended early -50%, the RUN OVER card and the board row agree, an idle out still pays in full and an extraction still doubles',
   run:function(){
     if(!(window.__state&&window.__runPrep&&window.__endRaid&&window.__loop)) return 'SKIP: this fixture cannot run a raid';
     if(typeof arcadeDeploy!=='function'||typeof arcadeLeave!=='function'||typeof arcadeRunEnd!=='function'||typeof arcadeOnMsg!=='function'||typeof arcadeX2!=='function'||typeof arcadeBoardLoad!=='function'||typeof ARCADE!=='object'||typeof NET!=='object'||typeof togglePauseBox!=='function'||typeof attEl!=='function'||typeof arcadeAttShow!=='function') return 'SKIP: no arcade here';
     var b=document.getElementById('arcendbtn');
     if(!b) return 'SKIP: no END RUN button';
     var bad=[], g, o, r, k, id, rw, txt, msg=null, nsv=null, nsp=netSamePost, posted=[], rs=say, ownS=false, BK=(typeof ARCADE_BOARD_KEY==='string')?ARCADE_BOARD_KEY:'', bk=null, ownBk=false, src0, tried0, ownAtt=false;
     function fresh(){
       ARCADE.ini=null; ARCADE.over=null;
       if(!arcadeDeploy({mapIx:0,seed:4242})||!__state()||!__state().arcade) return false;
       try{ attStop(); }catch(_as){}
       keys={}; ARCADE.holdT=0; ARCADE.waveT=0; ARCADE.ownAt=Date.now(); ARCADE.over=null; ARCADE.ini=null; ARCADE.role='host';
       return true;
     }
     function upNow(){ var s=__state(); return !!(s&&s.arcade&&!s.over); }
     function menuEnd(){ togglePauseBox(true); b.click(); b.click(); }
     function cardText(){ arcadeAttShow(); var c=attEl().querySelector('.arcover'); return (c&&c.style.display!=='none')?String(c.textContent).toLowerCase():''; }
     function row(rn){ var a=arcadeBoardLoad(), q; for(q=0;q<a.length;q++) if(a[q].run===rn) return a[q]; return null; }
     function stage(){
       var gg;
       NET.on=false; NET.role=''; NET.same='p2';
       if(!arcadeDeploy({role:'p2',mapIx:0,seed:4242})||!__state()||!__state().arcade) return null;
       try{ attStop(); }catch(_as){}
       gg=__state(); ARCADE.role='p2'; ARCADE.endRun=''; ARCADE.holdT=0; ARCADE.ownAt=Date.now(); ARCADE.over=null;
       NET.on=true; NET.role='join'; NET.same='p2'; NET.seat=1; NET.upSeed=gg.seed>>>0; NET.up=[]; NET.peers=[]; NET.upOut={};
       ARCADE.mine=1200; ARCADE.kills=5; ARCADE.ext=1; ARCADE.deaths=1; ARCADE.mate=300; ARCADE.mateK=2; ARCADE.mateX=0;
       return gg;
     }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       if(ARCADE.on) return 'SKIP: the arcade is on after __topClear';
       if(__state()) return 'SKIP: a raid is still up after __topClear';
       if(NET.on) return 'SKIP: a party link is up in the fixture';
       if(BK){ try{ bk=localStorage.getItem(BK); ownBk=true; localStorage.removeItem(BK); }catch(_b){} }
       say=function(){}; ownS=true;
       nsv={}; for(k in NET) if(Object.prototype.hasOwnProperty.call(NET,k)) nsv[k]=NET[k];
       NET.bc={postMessage:function(m){},close:function(){}}; NET.pair='tp';
       netSamePost=function(m){ posted.push(m); return true; };
       src0=ATT.src; tried0=ATT.tried; ATT.src=null; ATT.tried=true; ownAtt=true;
       // ONE: one player, END RUN through the real pause box (press, then press again)
       if(!fresh()) return 'SKIP: arcadeDeploy built no arcade raid';
       if(ARCADE.role!=='host') return 'SKIP: this window is not the arcade host';
       id=ARCADE.run&&ARCADE.run.id; ARCADE.mine=12000; ARCADE.mate=0; ARCADE.kills=3;
       menuEnd();
       if(upNow()) return 'SKIP: END RUN pressed twice left the raid up';
       o=ARCADE.over;
       if(!o||o.why!=='menu') return 'SKIP: END RUN did not end the run ('+(o?o.why:'no card')+')';
       if(!o.p1||o.p1.s!==6000||o.team!==6000) bad.push('ONE: END RUN with 12000 ended on '+(o.p1&&o.p1.s)+' (team '+o.team+'), not half, 6000');
       txt=cardText();
       if(!/ended early/.test(txt)||txt.indexOf('-50%')<0) bad.push('ONE: the RUN OVER card never says ended early -50% ('+txt.slice(0,90)+')');
       rw=id?row(id):null;
       if(!rw||rw.s!==6000) bad.push('ONE: the board row holds '+(rw?rw.s:'nothing')+', not the halved 6000');
       // TWO: an idle out is left alone (it still pays in full until he decides, question 78)
       if(!fresh()) bad.push('TWO: no second arcade drop');
       else {
         ARCADE.mine=12000; ARCADE.mate=0; arcadeRunEnd('idle'); o=ARCADE.over;
         if(!o||!o.p1||o.p1.s!==12000) bad.push('TWO: an idle out paid '+(o&&o.p1&&o.p1.s)+', not the full 12000');
         if(cardText().indexOf('-50%')>=0) bad.push('TWO: the card of an idle out says -50%');
       }
       // THREE: an extraction still doubles
       if(!fresh()) bad.push('THREE: no third arcade drop');
       else {
         ARCADE.mine=1500; ARCADE.mate=0; arcadeX2(); arcadeRunEnd('extract'); o=ARCADE.over;
         if(!o||o.why!=='extract'||o.team!==3000) bad.push('THREE: an extraction ended on '+(o&&o.team)+' ('+(o&&o.why)+'), not 1500 x2 = 3000');
         txt=cardText();
         if(txt.indexOf('extracted')<0||txt.indexOf('-50%')>=0) bad.push('THREE: the extraction card reads ['+txt.slice(0,90)+']');
       }
       // FOUR: two players, the host presses END RUN: each player halves, and the word to player 2 says so
       if(!fresh()) bad.push('FOUR: no fourth arcade drop');
       else {
         ARCADE.solo=0; ARCADE.mine=4000; ARCADE.mate=2000; ARCADE.mateK=2; posted.length=0;
         menuEnd();
         o=ARCADE.over;
         if(upNow()||!o||o.why!=='menu') bad.push('FOUR: END RUN did not end the two player run ('+(o?o.why:'no card')+')');
         else {
           if(!o.p1||o.p1.s!==2000||!o.p2||o.p2.s!==1000||o.team!==3000) bad.push('FOUR: player 1 / player 2 / team ended on '+(o.p1&&o.p1.s)+' / '+(o.p2&&o.p2.s)+' / '+o.team+', not 2000 / 1000 / 3000');
           for(k=0;k<posted.length;k++) if(posted[k]&&posted[k].t==='arcend') msg=posted[k];
           if(!msg) bad.push('FOUR: the host told player 2 nothing about the run end');
           else if(!msg.hf||msg.ko||msg.x2) bad.push('FOUR: the run end word is '+JSON.stringify(msg)+', not a half (hf) without ko or x2');
         }
       }
       // FIVE: player 2 takes that very word
       try{ if(ARCADE.on) arcadeLeave(); }catch(_l1){}
       if(msg){
         g=stage();
         if(!g) bad.push('FIVE: arcadeDeploy built no player 2 arcade raid');
         else {
           r=arcadeOnMsg(msg); o=ARCADE.over;
           if(r!=='arcend') bad.push('FIVE: player 2 answered the run end with '+r);
           if(!o) bad.push('FIVE: player 2 built no RUN OVER card from the host END RUN');
           else {
             if(o.team!==750||!o.p2||o.p2.s!==600||!o.p1||o.p1.s!==150) bad.push('FIVE: player 2 ended on team / player 2 / player 1 '+o.team+' / '+(o.p2&&o.p2.s)+' / '+(o.p1&&o.p1.s)+', not 750 / 600 / 150 (halved)');
             if(o.why!=='menu') bad.push('FIVE: player 2 calls the run end '+o.why);
           }
           txt=cardText();
           if(!/ended early/.test(txt)||txt.indexOf('-50%')<0) bad.push('FIVE: the player 2 card never says ended early -50% ('+txt.slice(0,90)+')');
         }
       }
       return bad.length?bad.join('; '):null;
     }catch(x){ return 'threw: '+(x&&x.message||x); }
     finally{
       try{ netSamePost=nsp; }catch(_n0){}
       if(ownS) say=rs;
       try{ NET.on=false; NET.role=''; }catch(_o){}
       try{ if(typeof ARCADE==='object'){ ARCADE.endSend=null; ARCADE.endRun=''; ARCADE.ini=null; ARCADE.over=null; } }catch(_z){}
       try{ if(typeof ARCADE==='object'&&ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       try{ if(typeof togglePauseBox==='function') togglePauseBox(false); }catch(_t){}
       try{ if(typeof arcEndDisarm==='function') arcEndDisarm(); }catch(_d){}
       try{ if(nsv){ for(k in NET) if(Object.prototype.hasOwnProperty.call(NET,k)&&!Object.prototype.hasOwnProperty.call(nsv,k)) delete NET[k]; for(k in nsv) NET[k]=nsv[k]; } }catch(_n){}
       try{ if(ownAtt){ ATT.src=src0; ATT.tried=tried0; } }catch(_a){}
       try{ if(ownBk){ if(bk===null) localStorage.removeItem(BK); else localStorage.setItem(BK,bk); } }catch(_k){}
       try{ if(typeof ARCADE==='object'){ ARCADE.mine=0; ARCADE.mate=0; ARCADE.mateK=0; ARCADE.mateX=0; ARCADE.kills=0; ARCADE.ext=0; ARCADE.deaths=0; ARCADE.holdT=0; ARCADE.waveT=0; ARCADE.ownAt=0; ARCADE.idleSaid=0; ARCADE.wantIn=0; ARCADE.late=0; ARCADE.hiRun=''; ARCADE.hiSaid=0; } }catch(_m){}
       try{ var oc=document.querySelector('#attract .arcover'); if(oc) oc.style.display='none'; }catch(_oc){}
       keys={}; __topClear();
     } }},
  {v:'31.26',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
