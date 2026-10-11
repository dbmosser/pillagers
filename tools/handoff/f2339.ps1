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

if ($s.Contains("  {v:'23.39',what:")) { throw "check 23.39 is in the fixture already" }

SubRx @'
  {v:'23.38',what:
'@ @'
  {v:'23.39',what:'arcade16, his order 2026-10-11: idle return and end run, 90 s idle says STILL PLAYING?, 125 s says RUN ENDS IN 25, a player 1 idle 150 s while player 2 plays is benched under the attract, the pause box offers END RUN in place of Settings and Abandon run, 150 s idle with nobody playing ends the run back to the attract with the RUN OVER card and nothing counted, END RUN does the same, and a normal raid gets none of it',
   run:function(){
     var bad=[], g=null, g2=null, rs=say, own=false, lines=[], runs0, ru0=null, ownRu=false, nOn0, nUp0, ownNet=false, d, c, now, r, ae, ab, ps, ap, tx;
     function said(s){ var j; for(j=0;j<lines.length;j++) if(lines[j].indexOf(s)===0) return true; return false; }
     function el(id){ return document.getElementById(id); }
     function shown(e){ return !!e&&e.style.display!=='none'; }
     try{
       __topClear(); __runPrep();
       if(typeof arcadeIdleTick!=='function'||typeof ARCADE!=='object') return 'no arcadeIdleTick in this build';
       if(ARCADE.on) return 'SKIP: the arcade is on after __topClear';
       if(!arcadeDeploy({mapIx:0,seed:4242})) return 'SKIP: arcadeDeploy built no arcade raid';
       g=__state(); keys={}; ARCADE.holdT=0; ARCADE.waveT=0;
       ru0=RUMBLE.usedAt; RUMBLE.usedAt=-1e9; ownRu=true;
       say=function(m,k,o){ lines.push(String(m)+'|'+String(k||'')+'|'+String((o&&o.sub)||'')); }; own=true;
       runs0=P.runs; now=Date.now();
       if(!(now-(+ARCADE.ownAt||0)<10000)) bad.push('a fresh arcade drop did not stamp activity ('+ARCADE.ownAt+')');
       ARCADE.mateAt=0;
       ARCADE.ownAt=now-91000; r=arcadeIdleTick(now);
       if(__state()!==g||g.over) bad.push('91 s idle ended the raid');
       if(!said('STILL PLAYING?|warn|PRESS ANY BUTTON')) bad.push('91 s idle did not say STILL PLAYING? in the warn lane ('+lines.join(' / ')+')');
       ARCADE.ownAt=now-125000; r=arcadeIdleTick(now);
       if(__state()!==g) bad.push('125 s idle ended the raid');
       if(!said('RUN ENDS IN 25|warn')) bad.push('125 s idle did not say RUN ENDS IN 25 ('+lines.slice(-3).join(' / ')+')');
       ARCADE.ownAt=now; r=arcadeIdleTick(now);
       if(r!==''||__state()!==g) bad.push('activity did not clear the idle ('+r+')');
       nOn0=NET.on; nUp0=NET.up; ownNet=true;
       NET.on=true; NET.up=[{seat:(NET.seat|0)+1,x:g.player.x+80,y:g.player.y,dn:0}];
       ARCADE.mateAt=now; ARCADE.ownAt=now-151000;
       r=arcadeIdleTick(now);
       NET.on=nOn0; NET.up=nUp0; ownNet=false;
       if(r!=='bench') bad.push('player 1 idle 150 s while player 2 plays gave '+(r||'nothing')+', not bench');
       if(__state()!==g) bad.push('the bench ended the raid');
       else if(!g.player.specOut) bad.push('the idle player 1 is not benched (specOut)');
       ap=attEl().querySelector('.attpress');
       if(attEl().style.display!=='block') bad.push('the benched player 1 has no attract');
       if(!ap||ap.textContent!=='PLAYER 1: PRESS ANY BUTTON') bad.push('the bench attract reads '+(ap?ap.textContent:'nothing'));
       g.player.specOut=0; try{ attStop(); }catch(_as){}
       ARCADE.mateAt=0; ARCADE.ownAt=Date.now();
       togglePauseBox(true);
       ae=el('arcendbtn'); ab=el('abandonbtn'); ps=el('pausesetbtn');
       if(!shown(ae)) bad.push('the arcade pause box has no END RUN');
       if(shown(ab)) bad.push('the arcade pause box still offers Abandon run');
       if(shown(ps)) bad.push('the arcade pause box still offers Settings');
       togglePauseBox(false);
       lines=[];
       ARCADE.ownAt=Date.now()-151000; ARCADE.mateAt=0;
       r=arcadeIdleTick(Date.now());
       if(r!=='end') bad.push('150 s idle with nobody playing gave '+(r||'nothing')+', not end');
       if(__state()) bad.push('150 s idle left the raid up');
       if(!ARCADE.on) bad.push('the run end left the arcade');
       d=attEl();
       if(d.style.display!=='block') bad.push('the run end did not bring back the attract');
       c=d.querySelector('.arcover'); tx=c?c.textContent:'';
       if(!c||c.style.display==='none') bad.push('no RUN OVER card on the attract');
       else if(tx.indexOf('RUN '+'OVER')<0||tx.indexOf('TEAM '+'SCORE')<0||tx.indexOf('P1 ')<0) bad.push('the RUN OVER card reads '+tx);
       if(P.runs!==runs0) bad.push('the run end counted a run ('+runs0+' to '+P.runs+')');
       if(el('outcome')&&el('outcome').classList.contains('on')) bad.push('the run end shows the outcome card');
       if(!arcadeDeploy({mapIx:0,seed:4242})) bad.push('no second arcade drop');
       else {
         if(c&&c.style.display!=='none') bad.push('a fresh drop left the RUN OVER card up');
         togglePauseBox(true);
         el('arcendbtn').click();
         if(__state()) bad.push('END RUN left the raid up');
         if(!ARCADE.on) bad.push('END RUN left the arcade');
         if(!ARCADE.over||ARCADE.over.why!=='menu') bad.push('END RUN did not end the run ('+(ARCADE.over?ARCADE.over.why:'no card')+')');
         if(typeof pauseOpen!=='undefined'&&pauseOpen) bad.push('END RUN left the pause box open');
       }
       say=rs; own=false;
       try{ if(ARCADE.on) arcadeLeave(); }catch(_l1){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e1){}
       __topClear(); __runPrep();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g2=__state();
       if(!g2) return bad.length?bad.join('; '):'SKIP: __deploy built no raid';
       if(g2.arcade) bad.push('a normal raid is flagged arcade');
       togglePauseBox(true);
       if(shown(el('arcendbtn'))) bad.push('a normal pause box offers END RUN');
       if(!shown(el('abandonbtn'))) bad.push('a normal pause box lost Abandon run');
       if(!shown(el('pausesetbtn'))) bad.push('a normal pause box lost Settings');
       togglePauseBox(false);
       ARCADE.ownAt=Date.now()-500000;
       r=arcadeIdleTick(Date.now());
       if(r!==''||__state()!==g2||g2.over) bad.push('the idle tick touched a normal raid ('+r+')');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       if(own) say=rs;
       if(ownNet){ try{ NET.on=nOn0; NET.up=nUp0; }catch(_n){} }
       if(ownRu){ try{ RUMBLE.usedAt=ru0; }catch(_r){} }
       try{ if(typeof pauseOpen!=='undefined'&&pauseOpen) togglePauseBox(false); }catch(_p){}
       keys={};
       try{ if(typeof ARCADE==='object'&&ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       try{ if(typeof ARCADE==='object'){ ARCADE.over=null; ARCADE.mine=0; ARCADE.holdT=0; ARCADE.waveT=0; ARCADE.ownAt=0; ARCADE.mateAt=0; ARCADE.idleSaid=0; } }catch(_m){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'23.38',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
