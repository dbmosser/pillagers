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

if ($s.Contains("  {v:'35.91',what:")) { throw "check 35.91 is in the fixture already" }

SubRx @'
  {v:'35.90',what:
'@ @'
  {v:'35.91',what:'frag, smoke and decoy bank once off cover; marker, two-leg flight, landing and host copies agree; tripwires stay straight',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: no raid fixture';
     var g,p,oldSegs,oldGrid,oldMW=mouseWorld,oldSay=say,oldSend=netSend,NK={},k,bad=[],said=[],sent=[],target;
     function near(a,b){ return Math.abs(a-b)<0.001; }
     function wall(x1,y1,x2,y2){ return {x1:x1,y1:y1,x2:x2,y2:y2}; }
     function geometry(segs,grid){ g.map.segs=segs; g.grid=grid?buildSegGrid(segs,2000,2000):null; }
     function clear(){ g.throws=[]; g.frags=[]; g.smokes=[]; g.decoys=[]; g.shells=[]; said=[]; }
     function aim(x,y){ target={x:x,y:y}; }
     for(k in NET) NK[k]=NET[k];
     try{
       NET.on=false; NET.peers=[];
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: no live raid';
       p=g.player; p.x=500; p.y=500; p.iv=999; g.ents=[];
       oldSegs=g.map.segs; oldGrid=g.grid; keys={}; mouse.down=false;
       mouseWorld=function(){ return target; }; say=function(m){ said.push(m); };
       var face=wall(580,250,580,900),u=Math.SQRT1_2,wt=80/u,left=(250-wt)*0.5;
       aim(500+250*u,500+250*u); geometry([face],false);
       var A=throwAim(p,'frag');
       if(A.bx==null||A.by==null) return 'no bounce point at the first wall';
       if(!near(A.bx,580)||!near(A.by,580)||!near(A.tx,574-u*left)||!near(A.ty,580+u*left)) bad.push('the 45 degree reflection has the wrong landing');
       if(!(A.tx<580&&A.ty>580)) bad.push('the bank did not return to the thrower side of the face');
       var B;
       geometry([face],true); B=throwAim(p,'frag');
       if(!near(B.tx,A.tx)||!near(B.ty,A.ty)) bad.push('indexed and linear face rays disagree');
       geometry([wall(580,900,580,250)],false); B=throwAim(p,'frag');
       if(!near(B.tx,A.tx)||!near(B.ty,A.ty)) bad.push('reversing the segment changes its reflection');
       geometry([face],false);
       for(var i=0;i<3;i++){
         k=['frag','smoke','decoy'][i]; clear(); p.cooking=true; p.cookKind=k; p.cookT=0;
         var m=throwMarker(p); throwFrom(k,0); var th=g.throws[g.throws.length-1];
         if(!near(th.bx,A.bx)||!near(th.by,A.by)||!near(th.tx,m.tx)||!near(th.ty,m.ty)||!near(m.bx,A.bx)) bad.push(k+' marker and thrown path differ');
         var a=Math.hypot(th.bx-th.sx,th.by-th.sy),b=Math.hypot(th.tx-th.bx,th.ty-th.by);
         if(!near(th.dur,Math.max(.25,(a+b)/430))) bad.push(k+' duration misses a leg');
         updateThrowables(th.dur*(a/(a+b)));
         if(!near(th.x,th.bx)||!near(th.y,th.by)) bad.push(k+' flight cut the corner');
         updateThrowables(th.dur*b/(a+b)*0.5);
         if(!near(th.x,(th.bx+th.tx)/2)||!near(th.y,(th.by+th.ty)/2)) bad.push(k+' second leg is not moving by length');
         while(g.throws.length) updateThrowables(0.01);
         var list=k==='frag'?g.frags:(k==='smoke'?g.smokes:g.decoys),land=list[list.length-1];
         if(!land||!near(land.x,A.tx)||!near(land.y,A.ty)) bad.push(k+' effect missed the final point');
       }
       clear(); p.cooking=false;
       geometry([face,wall(450,610,600,610)],false); B=throwAim(p,'frag');
       var w2=30/u,leg=Math.max(w2*.6,w2-12);
       if(!near(B.bx,580)||!near(B.tx,574-u*leg)||!near(B.ty,580+u*leg)) bad.push('the second wall did not stop the rebound short');
       geometry([face],false); B=throwAim(p,'trip');
       if(B.bx!=null||!near(B.rngT,wt-12)) bad.push('tripwire wall stop changed');
       aim(500+(wt+10)*u,500+(wt+10)*u); B=throwAim(p,'frag');
       if(B.bx!=null||!near(B.rngT,wt-12)) bad.push('a rebound with under 8 units of flight should stop');
       geometry([],false); aim(620,540); B=throwAim(p,'frag');
       if(B.bx!=null||!near(B.tx,620)||!near(B.ty,540)) bad.push('open throw did not land at the mouse');
       geometry([face],false); aim(500+250*u,500+250*u); clear(); throwFrom('frag',0);
       if(!said.length) bad.push('nearby final frag landing gave no cover warning');
       // v28.xx (cw-cx-throwbank): a long path can still bank back inside the smoke warning distance.
       geometry([wall(620,250,620,900)],false); aim(770,500); clear(); throwFrom('smoke',0);
       if(!said.length) bad.push('cover warning used path length instead of final distance');
       // v28.xx (cw-cx-throwbank): use the real reliable send/take path in both directions, with separate effect arrays.
       geometry([face],false); aim(500+250*u,500+250*u);
       var host={state:'in',seat:0},guest={state:'in',seat:1};
       netSend=function(peer,m){ sent.push(JSON.parse(JSON.stringify(m))); return true; };
       NET.on=true; NET.upSeed=g.seed>>>0; NET.specG=null; NET.up=[];
       for(var seat=0;seat<2;seat++) for(i=0;i<3;i++){
         clear(); sent=[]; k=['frag','smoke','decoy'][i];
         NET.role=seat?'join':'host'; NET.seat=seat; NET.peers=[seat?host:guest];
         throwFrom(k,0); while(g.throws.length) updateThrowables(0.01);
         var msg=sent.filter(function(m){ return m.t==='thr'&&m.k===k; })[0];
         if(!msg){ bad.push('seat '+seat+' did not send '+k+' landing'); continue; }
         if(Math.abs(msg.x-A.tx)>0.5||Math.abs(msg.y-A.ty)>0.5) bad.push('the wire word missed the final bank point');
         clear(); NET.role=seat?'host':'join'; NET.seat=seat?0:1; NET.peers=[seat?guest:host];
         var r=netThrTake(seat?guest:host,msg),copy=(k==='frag'?g.frags:(k==='smoke'?g.smokes:g.decoys))[0];
         if(r!=='thr:'+k||!copy||copy.x!==msg.x||copy.y!==msg.y) bad.push('the other window missed seat '+seat+' '+k);
       }
       return bad.length?bad.join('; '):null;
     } finally {
       mouseWorld=oldMW; say=oldSay; netSend=oldSend;
       for(k in NET) if(!Object.prototype.hasOwnProperty.call(NK,k)) delete NET[k];
       for(k in NK) NET[k]=NK[k];
       if(g&&oldSegs){ g.map.segs=oldSegs; g.grid=oldGrid; g.throws=[]; g.frags=[]; g.smokes=[]; g.decoys=[]; }
       try{ __endRaid('abandon'); }catch(_e){} __topClear();
     }
   }},
  {v:'35.90',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
