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

if ($s.Contains("  {v:'22.33',what:")) { throw "check 22.33 is in the fixture already" }

SubRx @'
  {v:'22.32',what:
'@ @'
  {v:'22.33',what:'the clock in the alert lane: crossing thirty seconds shows THIRTY SECONDS as the alert with a hint of 48 characters or fewer that never says way out, a line said 0.3 s later does not take it off the screen, and on a controller on a landed extraction the hint names [X]',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__loop&&window.__frame)) return 'SKIP: this fixture cannot deploy, step or draw';
     if(window.__vpAlive&&!__vpAlive()) return 'SKIP: the pane has no layout, so the frame loop cannot draw';
     if(typeof outHint!=='function'||typeof raidClockOn!=='function'||typeof padOn!=='function') return 'SKIP: no hint, clock or pad test here';
     var bad=[], g, p, i, j, t0, f=0, realSay=say, oFT=ctx.fillText, oPad=padOn, ev=[], TS=['THIRTY','SECONDS'].join(' '), WO='way '+'out', ZX=['zq','x'].join(' '), z=null, zk=null, h, drawn=false, a;
     function unspy(){ delete ctx.fillText; if(ctx.fillText!==oFT) ctx.fillText=oFT; }
     function step(){ __loop(t0+(++f)*50); }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       try{ __pinDPR(1); }catch(_d){}
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: staging: no raid';
       if(!raidClockOn()||!(g.raidLen>0)) return 'SKIP: the raid clock is off here';
       p=g.player; keys={}; g.mapOpen=false; g.bagOpen=false; g.ents.length=0; g.waveT=-1e9; p.iv=99;
       g.msgT=0; g.msg=''; g.msgQ=[]; g.msgQM=[]; g.feed=[]; g.alert=null; g.alertQ=[];
       say=function(m){ var s=String(m); if(s.indexOf('zq')===0||s.indexOf('THIRTY')===0) return realSay.apply(this,arguments); };
       t0=Math.max(performance.now(),(typeof lastTs==='number'&&isFinite(lastTs))?lastTs:0);
       g.timeLeft=30.02; g.warnPrev=30.03; g.lastWarn=31;
       step();
       if(!(g.timeLeft<30)) return 'SKIP: the live frame did not run the raid clock here ('+g.timeLeft+')';
       a=g.alert;
       if(!(a&&a.m===TS)) bad.push('crossing thirty seconds did not put THIRTY SECONDS in the alert lane (alert '+JSON.stringify(a&&a.m)+', feed '+JSON.stringify(g.msg)+')');
       else {
         if(!a.sub) bad.push('THIRTY SECONDS carries no hint');
         else if(a.sub.length>48) bad.push('the hint is '+a.sub.length+' characters, over 48: '+JSON.stringify(a.sub));
         if(String(a.sub||'').indexOf(WO)>=0) bad.push('the hint still says '+WO+': '+JSON.stringify(a.sub));
       }
       for(i=0;i<5;i++) step();
       say(ZX);
       step(); step();
       ev=[]; ctx.fillText=function(t){ ev.push(String(t)); return oFT.apply(this,arguments); };
       try{ __frame(0.016); } finally { unspy(); }
       for(j=0;j<ev.length;j++) if(ev[j]===TS) drawn=true;
       if(!drawn) bad.push('0.4 s after a line said 0.3 s after it, THIRTY SECONDS is not drawn as a headline');
       // on a controller, standing in a landed extraction, the hint names the pad button
       for(i=0;i<g.zones.length;i++) if(g.zones[i].open!==false){ z=g.zones[i]; break; }
       if(!z) bad.push('SKIP: no open extraction to stand in');
       else {
         zk={x:p.x,y:p.y,b:z.beaconT,h:z.hold,hm:z.holdMax,ac:g.active,gb:g.beaconT};
         p.x=z.x; p.y=z.y; z.beaconT=0; z.hold=12; z.holdMax=30; g.active=z;
         padOn=function(){ return true; };
         try{ h=outHint(1); } finally { padOn=oPad; }
         if(String(h).indexOf('[X]')<0) bad.push('on a controller on a landed extraction the hint does not name [X]: '+JSON.stringify(h));
         if(String(h).length>48) bad.push('the landed hint is over 48 characters: '+JSON.stringify(h));
       }
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       unspy(); say=realSay; padOn=oPad; keys={};
       try{ if(z&&zk){ p.x=zk.x; p.y=zk.y; z.beaconT=zk.b; z.hold=zk.h; z.holdMax=zk.hm; g.active=zk.ac; g.beaconT=zk.gb; } }catch(_z){}
       try{ var g2=__state(); if(g2){ g2.msgT=0; g2.msg=''; g2.feed=[]; g2.msgQ=[]; g2.msgQM=[]; g2.alert=null; g2.alertQ=[]; } if(g2&&!g2.over){ g2.player.downed=false; g2.player.iv=0; __endRaid('abandon'); } }catch(_e){}
       __topClear();
     }
     for(i=0;i<bad.length;i++) if(bad[i].indexOf('SKIP: ')===0&&bad.length===1) return bad[0];
     return bad.length?bad.join('; '):null; }},
  {v:'22.32',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
