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

if ($s.Contains("  {v:'27.04',what:")) { throw "check 27.04 is in the fixture already" }

SubRx @'
  {v:'27.03',what:
'@ @'
  {v:'27.04',what:'coop1, the two player first: a linked player 2 window takes the host fires from the world word instead of planning its own, and feels them: the host word carries the fire, player 2 has it where the host does, is kept out of it and burned at its edge, plans none of his own, and the word that follows the fire going out puts it out',
   run:function(){
     if(!(window.__state&&window.__endRaid&&window.__runPrep)) return 'SKIP: no raid here';
     if(typeof arcadeDeploy!=='function'||typeof ARCADE!=='object'||typeof netWorldSend!=='function'||typeof netOnMsg!=='function'||typeof fireAdd!=='function') return 'SKIP: no arcade or party in this fixture';
     var bad=[], g=null, p=null, NK={}, k, oSF=netSendFast, oS=netSend, sent=[], w=null, w2=null, f=null, i, j, ok, free, x0=0, y0=0, hp0, oIv, oSh, oAr, d, F, h={seat:0,state:'in'}, staged=false;
     function word(){ var q, r=null; for(q=sent.length-1;q>=0;q--) if(sent[q].t==='wd'){ r=sent[q]; break; } return r; }
     try{
       __topClear(); __runPrep();
       if(ARCADE.on) return 'SKIP: the arcade is on after __topClear';
       if(!arcadeDeploy({mapIx:0,seed:4242})) return 'SKIP: arcadeDeploy built no arcade raid';
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       p=g.player; keys={}; oSh=p.arcSh; oAr=p.armor; oIv=p.iv; p.arcSh=0; p.armor=0; p.iv=0;
       ok=0;
       for(i=-400;i<=400&&!ok;i+=40) for(j=-400;j<=400;j+=40){
         x0=p.x+i; y0=p.y+j;
         if(Math.hypot(i,j)<250||!spotFree(g.map,x0,y0,30)||!navReachable(g.map,x0,y0)) continue;
         free=1; for(k=0;k<8;k++) if(!spotFree(g.map,x0+Math.cos(k*0.7854)*(FIRE.r+30),y0+Math.sin(k*0.7854)*(FIRE.r+30),8)) free=0;
         if(free){ ok=1; break; }
       }
       if(!ok) return 'SKIP: staging: no open ground near the drop for a test fire';
       for(k in NET) NK[k]=NET[k];
       staged=true;
       NET.on=true; NET.max=4; NET.role='host'; NET.seat=0; NET.specG=null; NET.up=[]; NET.upSeed=g.seed>>>0; NET.peers=[{seat:1,state:'in'}];
       netSendFast=function(q,m){ sent.push(JSON.parse(JSON.stringify(m))); return true; };
       netSend=function(q,m){ return true; };
       // ONE: the host lights a fire and its world word carries it
       f=fireAdd(x0,y0,FIRE.r,FIRE.life,'test',0);
       netWorldSend();
       w=word();
       if(!w) bad.push('ONE: the host sent no world word');
       else if(!w.fl||!w.fl.f||w.fl.f.length!==1) bad.push('ONE: the host world word does not carry the fire (fl '+JSON.stringify(w.fl)+')');
       // TWO: player 2 window has no fire of its own, takes the word, and has the fire where the host does
       g.flow.fires=[]; delete g.flow.fplan;
       NET.role='join'; NET.seat=1; NET.peers=[h];
       if(typeof netEntsPeer==='function'&&!netEntsPeer()) bad.push('TWO: staging: the window is not a linked window');
       if(w) netOnMsg(h,JSON.stringify(w));
       F=g.flow.fires;
       if(!F||F.length!==1) bad.push('TWO: player 2 has '+(F?F.length:'no')+' fires after the host word, not 1');
       else if(Math.hypot(F[0].x-x0,F[0].y-y0)>1.5||Math.abs(F[0].r-FIRE.r)>0.6) bad.push('TWO: the fire player 2 has is at '+Math.round(F[0].x)+','+Math.round(F[0].y)+' size '+Math.round(F[0].r)+', not where the host has it');
       // THREE: player 2 feels it: put back on the edge of the lit fire and burned there
       if(F&&F.length){
         p.x=x0+30; p.y=y0+5; hp0=p.hp;
         for(i=0;i<12;i++) flowTick(0.1);
         d=Math.hypot(p.x-x0,p.y-y0);
         if(d<FIRE.r+(p.r||11)-0.5) bad.push('THREE: player 2 stands '+Math.round(d)+' from the middle of a fire of '+FIRE.r);
         if(!(p.hp<hp0)) bad.push('THREE: player 2 took no burn at the edge of the fire for 1.2 s (hp '+hp0+' to '+p.hp+')');
       }
       // FOUR: and player 2 window plans no fires of its own
       if(g.flow.fplan&&g.flow.fplan.length) bad.push('FOUR: the linked window planned '+g.flow.fplan.length+' fires of its own');
       // FIVE: the host fire is spent: the next word has none, and player 2 has none either
       sent.length=0; NET.role='host'; NET.seat=0; NET.peers=[{seat:1,state:'in'}];
       g.flow.fires=[]; netWorldSend(); w2=word();
       if(!w2||!w2.fl||!w2.fl.f||w2.fl.f.length!==0) bad.push('FIVE: the host word after the fire went out still lists a fire');
       g.flow.fires=[{x:x0,y:y0,r:FIRE.r,t:1,life:FIRE.life,warn:0,src:'fuel',id:99,bt:0,told:1}];
       NET.role='join'; NET.seat=1; NET.peers=[h];
       if(w2) netOnMsg(h,JSON.stringify(w2));
       if(g.flow.fires.length) bad.push('FIVE: player 2 kept a fire the host had put out');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       netSendFast=oSF; netSend=oS;
       if(staged){ for(k in NET) if(!(k in NK)) delete NET[k]; for(k in NK) NET[k]=NK[k]; }
       keys={};
       try{ if(p){ p.arcSh=oSh; p.armor=oAr; p.iv=oIv; } }catch(_q){}
       try{ if(typeof ARCADE==='object'&&ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       try{ if(typeof ARCADE==='object'){ ARCADE.mine=0; ARCADE.waveT=0; ARCADE.holdT=0; } }catch(_h){}
       __topClear();
     }
     return bad.length?bad.slice(0,8).join('; '):null; }},
  {v:'27.03',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
