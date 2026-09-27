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

if ($s.Contains("  {v:'16.76',what:")) { throw "check 16.76 is in the fixture already" }

SubRx @'
  {v:'16.75',what:
'@ @'
  {v:'16.76',what:'in a shared raid the ambient bed is cut on the first frame the world stands still under an open pause box (every player paused), not on a paused frame the world still runs, and it is cut again after a teammate ran the world on and the party paused once more',
   run:function(){
     if(typeof togglePauseBox!=='function'||typeof netPauseLive!=='function'||typeof ambienceOff!=='function'||typeof tickAmbience!=='function'||typeof AMBOFF!=='number'||!window.__deploy||!window.__endRaid||!window.__loop||!window.__runPrep||typeof NET!=='object'||!NET) return 'SKIP: this fixture cannot stage a paused party raid';
     var keep={on:NET.on,role:NET.role,seat:NET.seat,upSeed:NET.upSeed,up:NET.up,peers:NET.peers,roster:NET.roster,fxQ:NET.fxQ,status:NET.status},
         oSend=netSend, oFast=netSendFast, oUp=netUpTick, oFx=netFxStep, oRef=netRefresh, oAmb=tickAmbience, oShown=netUpShown,
         bad=[], k, ambN=0, off0, t0, ts, g, fault=null;
     function frame(){ ts+=16.7; try{ __loop(ts); }catch(e){ fault=String((e&&e.message)||e); } }
     try{
       __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       if(!G||!G.player) return 'SKIP: staging: no raid came up';
       netSend=function(){ return true; }; netSendFast=function(){ return true; }; netUpTick=function(){ return 0; }; netFxStep=function(){ return 0; }; netRefresh=function(){};
       netUpShown=function(x){ return !!x; };
       tickAmbience=function(){ ambN++; return oAmb.apply(this,arguments); };
       NET.on=true; NET.role='host'; NET.seat=0; NET.upSeed=G.seed>>>0; NET.peers=[{state:'in',seat:1}]; NET.roster=[{seat:0,name:'PLAYER 1'},{seat:1,name:'PLAYER 2'}];
       g={seat:1,n:1,age:0,sd:NET.upSeed,x:G.player.x+80,y:G.player.y,tx:G.player.x+80,ty:G.player.y,f:0,tf:0,bob:0,roll:0,mv:0,cr:0,sp:0,dn:0,w:'',pz:0,hp:100,mh:100,ar:0,ac:0,dt:0,sa:1};
       NET.up=[]; NET.up[1]=g;
       ts=performance.now();
       frame(); if(fault) return 'SKIP: staging: a raid frame threw ('+fault+')';
       togglePauseBox(true);
       if(!G.paused) return 'SKIP: staging: the pause box did not pause the raid';
       if(!netPauseLive()) return 'SKIP: staging: with the teammate unpaused the world did not count as running';
       off0=AMBOFF; ambN=0;
       frame(); frame();
       if(fault) return 'SKIP: staging: a paused frame threw ('+fault+')';
       if(!ambN) bad.push('control: paused with the teammate unpaused, the world did not run on and drive the bed');
       if(AMBOFF!==off0) bad.push('the bed was cut on a paused frame the world still ran ('+(AMBOFF-off0)+' cut, and driven back up in the same frame)');
       g.pz=1;
       if(netPauseLive()) return 'SKIP: staging: with every player paused the world still counted as running';
       off0=AMBOFF; ambN=0; t0=G.t;
       frame();
       if(fault) return 'SKIP: staging: a still frame threw ('+fault+')';
       if(G.t!==t0) bad.push('control: with every player paused the world ran ('+(G.t-t0).toFixed(3)+' s)');
       if(ambN) bad.push('control: with the world standing still the bed was still driven');
       if(AMBOFF===off0) bad.push('with every player paused the world stood still and the bed was not cut: it held its last level through the pause');
       g.pz=0; frame(); frame();
       g.pz=1; off0=AMBOFF; frame();
       if(fault) return 'SKIP: staging: a later frame threw ('+fault+')';
       if(AMBOFF===off0) bad.push('after the teammate ran the world on and the party paused again, the bed was not cut a second time');
     } finally {
       netSend=oSend; netSendFast=oFast; netUpTick=oUp; netFxStep=oFx; netRefresh=oRef; tickAmbience=oAmb; netUpShown=oShown;
       for(k in keep) NET[k]=keep[k];
       try{ togglePauseBox(false); }catch(e){}
       try{ __endRaid('abandon'); __topClear(); }catch(e){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'16.75',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
