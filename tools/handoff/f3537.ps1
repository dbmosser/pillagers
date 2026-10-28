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

if ($s.Contains("  {v:'35.37',what:")) { throw "check 35.37 is in the fixture already" }

SubRx @'
  {v:'35.36',what:
'@ @'
  {v:'35.37',what:'cw-xsink, his note 2026-10-27: after the boarding hold has sunk him he is never drawn whole again, neither on the frame that ends the raid nor on the DEMO bench after his extraction, and the other window stops drawing a teammate an extraction took; the rise at the raid start still runs',
   run:function(){
     if(!(window.__deploy&&window.__endRaid&&window.__state&&window.__frame&&window.__loop)||typeof ascentSink!=='function'||typeof drawOp!=='function') return 'SKIP: this fixture cannot stage an extraction';
     var bad=[], g=null, p, z, f, k, od=drawOp, oab=ascentBegin, oae=ascentEnd, inA=0, whole=0, sunk=0, t0=performance.now()+1000, stub=null, net0=null, w, r, nk, oc;
     function cnt(){ whole=0; sunk=0; }
     function ring(g,p,pull){ var z=g.zones[0]; g.rise=null; g.mapFirst=0; g.mapOpen=false; g.bagOpen=false; g.paused=false; g.ents.length=0;
       z.open=true; z.beaconT=null; z.callT=0; z.hold=25; z.boardT=0; z.pullFloor=0; z.pullT=pull; g.active=z;
       p.x=z.x; p.y=z.y; p.downed=false; p.dying=false; p.roll=0; p.moving=false; p.vx=0; p.vy=0; return z; }
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       ascentBegin=function(){ inA++; return oab.apply(this,arguments); };
       ascentEnd=function(){ inA=Math.max(0,inA-1); return oae.apply(this,arguments); };
       drawOp=function(){ var st=arguments[9]; if(st&&st.hero===1){ if(inA>0) sunk++; else whole++; } return od.apply(this,arguments); };
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||!g.zones||!g.zones.length) return 'SKIP: no raid with a ring';
       p=g.player;
       // control: the rise at the raid start is still drawn in the hatch
       if(!g.rise) bad.push('control: a new raid starts with no rise');
       cnt(); __frame(); if(!(sunk>0&&whole===0)) bad.push('control: the rise is not drawn in the hatch ('+sunk+' sunk, '+whole+' whole)');
       // CAREER: on a ring with the ship down, the pull one step from done and X held; the real frame that ends the raid, then the frames under the card
       z=ring(g,p,1.3);
       cnt(); __frame(); if(!(sunk>0&&whole===0)) bad.push('control: the boarding hold is not drawn in the hatch ('+sunk+' sunk, '+whole+' whole)');
       z.pullT=1.3999; keys={}; keys.KeyX=true;
       for(f=0;f<40&&!g.over;f++){ cnt(); __loop(t0+f*16.7); }
       keys={};
       if(g.over!=='extract') bad.push('control: the held pull did not extract ('+g.over+', pull '+z.pullT+')');
       else {
         if(whole) bad.push('the frame that ends the raid draws him whole on the ring ('+whole+' whole)');
         oc=document.getElementById('outcome');
         if(!(oc&&oc.classList.contains('on'))) bad.push('control: no extracted card');
         for(k=0;k<4;k++){ cnt(); if(k<2) __loop(t0+(50+k)*16.7); else __frame(); if(whole){ bad.push('frame '+(k+1)+' after the extraction draws him whole ('+whole+' whole)'); break; } }
       }
       // the other window: a teammate whose word says an extraction took him is not drawn, nor one whose extraction out word came first; the plain word is (control)
       net0={on:NET.on,role:NET.role,seat:NET.seat,up:NET.up,roster:NET.roster,upSeed:NET.upSeed,upOut:NET.upOut,upHow:NET.upHow,peers:NET.peers};
       NET.on=true; NET.role='join'; NET.seat=1; NET.up=[]; NET.roster=[{seat:0,name:'Player 1'},{seat:1,name:'Player 2'}]; NET.upSeed=4242; NET.upOut={}; NET.upHow={}; NET.peers=[];
       w={t:'st',k:'r',s:0,sd:4242,x:Math.round(p.x)+120,y:Math.round(p.y),f:0,m:0,r:0,c:0,sp:0,dn:0,w:'',hp:100,mh:100};
       r=netOnState({state:'in'},w); nk=netUpDraw([]);
       if(nk!==1) bad.push('control: a teammate word is not drawn in the other window ('+r+', '+nk+')');
       w.xo=1; netOnState({state:'in'},w); nk=netUpDraw([]);
       if(nk!==0) bad.push('the other window still draws a teammate whose word says an extraction took him');
       w.xo=0; netOnState({state:'in'},w); NET.upOut[0]=4242; NET.upHow[0]='extract'; nk=netUpDraw([]);
       if(nk!==0) bad.push('a late position word stands a teammate back up after his extraction out word');
       for(k in net0) NET[k]=net0[k];
       net0=null;
       // DEMO: the host extracts while player 2 is still out (his Q65), so he is benched for the run; he must not stand back up on the ring
       __topClear();
       if(typeof arcadeDeploy==='function'&&typeof ARCADE==='object'&&ARCADE&&typeof arcadeMateLive==='function'){
         stub={ml:arcadeMateLive,sc:arcadeScSend,as:arcadeAttShow};
         arcadeMateLive=function(){ return true; }; arcadeScSend=function(){ return 0; }; arcadeAttShow=function(){ return 0; };
         if(!arcadeDeploy({mapIx:0,seed:4242})) bad.push('control: arcadeDeploy built no DEMO raid');
         else {
           g=__state(); p=g.player; ARCADE.solo=0; ARCADE.xOut=0; ARCADE.holdT=0; if(!ARCADE.run) ARCADE.run={id:'txsink'};
           z=ring(g,p,1.3999); p.specOut=0; keys={}; keys.KeyX=true;
           for(f=0;f<40&&!p.specOut&&__state()===g;f++){ cnt(); __loop(t0+(100+f)*16.7); }
           keys={};
           if(!p.specOut||ARCADE.xOut!=='h') bad.push('control: the DEMO host did not extract to the bench (specOut '+p.specOut+', out '+ARCADE.xOut+', pull '+z.pullT+')');
           else {
             if(whole) bad.push('the frame that benches the DEMO host draws him whole ('+whole+' whole)');
             for(k=0;k<4;k++){ cnt(); if(k<2) __loop(t0+(200+k)*16.7); else __frame(); if(whole){ bad.push('frame '+(k+1)+' on the DEMO bench after his extraction draws him whole ('+whole+' whole)'); break; } }
           }
         }
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       drawOp=od; ascentBegin=oab; ascentEnd=oae; keys={};
       if(stub){ arcadeMateLive=stub.ml; arcadeScSend=stub.sc; arcadeAttShow=stub.as; }
       if(net0){ for(k in net0) NET[k]=net0[k]; }
       try{ if(typeof ARCADE==='object'&&ARCADE&&ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'35.36',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
