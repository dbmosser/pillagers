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

if ($s.Contains("  {v:'34.95',what:")) { throw "check 34.95 is in the fixture already" }

SubRx @'
  {v:'34.94',what:
'@ @'
  {v:'34.95',what:'cw-joinburn, robot report noend: player 2 asking to join a two player run once the clock is out (the site burning, or the clock resting at 0) waits for the next run instead of rebuilding the raid with a fresh 10 minute clock; with time left, a join on another map still rebuilds and keeps the clock',
   run:function(){
     if(!(window.__state&&window.__runPrep&&window.__endRaid&&window.__loop)) return 'SKIP: this fixture cannot run a raid';
     if(typeof arcadeDeploy!=='function'||typeof arcadeLeave!=='function'||typeof arcadeJoinAsk!=='function'||typeof raidClockOn!=='function'||typeof ARCADE!=='object'||typeof NET!=='object') return 'SKIP: no arcade here';
     var bad=[], g, r, k, nsv=null, nsp=netSamePost, posted=[], rs=say, ownS=false, src0, tried0, ownAtt=false;
     function fresh(){
       ARCADE.ini=null; ARCADE.over=null; NET.on=false;
       if(!arcadeDeploy({mapIx:0,seed:4242})||!__state()||!__state().arcade) return null;
       try{ attStop(); }catch(_as){}
       keys={}; ARCADE.holdT=0; ARCADE.waveT=0; ARCADE.ownAt=Date.now(); ARCADE.over=null; ARCADE.ini=null; ARCADE.role='host';
       NET.on=true; NET.role='host'; NET.upWord={seed:((__state().seed>>>0)+1)>>>0};
       posted.length=0;
       return __state();
     }
     function arcnew(){ for(var q=0;q<posted.length;q++) if(posted[q]&&posted[q].t==='arcnew') return true; return false; }
     function out(tag,nuke){
       g=fresh();
       if(!g){ bad.push(tag+': no arcade drop'); return; }
       g.timeLeft=0; g.nuking=nuke; g.nukeT=0;
       r=arcadeJoinAsk();
       if(__state()!==g) bad.push(tag+': a join rebuilt the raid (the new clock reads '+(__state()&&__state().timeLeft)+' s)');
       if(r!=='wait') bad.push(tag+': the join answered '+r+', not wait');
       if(nuke&&!g.nuking) bad.push(tag+': the burn stopped');
       if(!(g.timeLeft<=0)) bad.push(tag+': the clock went back to '+g.timeLeft+' s');
       if(arcnew()) bad.push(tag+': the host told player 2 a new raid is coming');
     }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       if(ARCADE.on) return 'SKIP: the arcade is on after __topClear';
       if(__state()) return 'SKIP: a raid is still up after __topClear';
       if(NET.on) return 'SKIP: a party link is up in the fixture';
       say=function(){}; ownS=true;
       nsv={}; for(k in NET) if(Object.prototype.hasOwnProperty.call(NET,k)) nsv[k]=NET[k];
       NET.bc={postMessage:function(m){},close:function(){}}; NET.pair='tp';
       netSamePost=function(m){ posted.push(m); return true; };
       src0=ATT.src; tried0=ATT.tried; ATT.src=null; ATT.tried=true; ownAtt=true;
       // ONE (control): 300 s left, player 2 on another map: the raid is rebuilt and keeps its 300 s
       g=fresh();
       if(!g) return 'SKIP: arcadeDeploy built no arcade raid';
       if(ARCADE.role!=='host') return 'SKIP: this window is not the arcade host';
       if(!raidClockOn()) return 'SKIP: the arcade raid has no clock';
       g.timeLeft=300; g.nuking=0;
       r=arcadeJoinAsk();
       if(r!=='new') bad.push('ONE: with 300 s left a join on another map answered '+r+', not a rebuild (new)');
       else if(__state()===g||!__state()||!__state().arcade) bad.push('ONE: with 300 s left the raid was not rebuilt');
       else if(!(Math.abs(__state().timeLeft-300)<1)) bad.push('ONE: the rebuilt raid has '+__state().timeLeft+' s, not the 300 it had');
       if(!arcnew()) bad.push('ONE: the rebuild never told player 2 a new raid is coming');
       // TWO: the site is burning at the end of the clock
       out('TWO (burning)',1);
       // THREE: the clock rests at 0 (the host boarding) and the burn has not started
       out('THREE (clock at 0)',0);
       return bad.length?bad.join('; '):null;
     }catch(x){ return 'threw: '+(x&&x.message||x); }
     finally{
       try{ netSamePost=nsp; }catch(_n0){}
       if(ownS) say=rs;
       try{ NET.on=false; NET.role=''; }catch(_o){}
       try{ if(typeof ARCADE==='object'){ ARCADE.endSend=null; ARCADE.endRun=''; ARCADE.ini=null; ARCADE.over=null; } }catch(_z){}
       try{ if(typeof ARCADE==='object'&&ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       try{ if(nsv){ for(k in NET) if(Object.prototype.hasOwnProperty.call(NET,k)&&!Object.prototype.hasOwnProperty.call(nsv,k)) delete NET[k]; for(k in nsv) NET[k]=nsv[k]; } }catch(_n){}
       try{ if(ownAtt){ ATT.src=src0; ATT.tried=tried0; } }catch(_a){}
       try{ if(typeof ARCADE==='object'){ ARCADE.mine=0; ARCADE.mate=0; ARCADE.mateK=0; ARCADE.mateX=0; ARCADE.kills=0; ARCADE.ext=0; ARCADE.deaths=0; ARCADE.holdT=0; ARCADE.waveT=0; ARCADE.ownAt=0; ARCADE.idleSaid=0; ARCADE.wantIn=0; ARCADE.late=0; ARCADE.hiRun=''; ARCADE.hiSaid=0; } }catch(_m){}
       try{ var oc=document.querySelector('#attract .arcover'); if(oc) oc.style.display='none'; }catch(_oc){}
       keys={}; __topClear();
     } }},
  {v:'34.94',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
