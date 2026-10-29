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

if ($s.Contains("  {v:'36.26',what:")) { throw "check 36.26 is in the fixture already" }

SubRx @'
  {v:'36.25',what:
'@ @'
  {v:'36.26',what:'a name tag that lands a rounding hair over the one below no longer freezes the game, a stack that never lets go is capped with one crash note, and a raid heartbeat left by a frozen page becomes a crash note on the next load',
   run:function(){
     if(typeof wlTagPlace!=='function'||typeof WLTEXT!=='object'||typeof WTX!=='object') return 'SKIP: no world tag stack here';
     var bad=[], ob=WLTEXT.boxes, og=WLTEXT.g, oz=WTX.z, ox=WTX.ox, oy=WTX.oy, nc=noteCrash, noted=[], reads=0, gap=4*Math.max(1,hudRes()), Y=0, h=41.4393740425111, k, r, y, cur, n, creep, g=null, s, dep=false;
     function guard(list){ return new Proxy(list,{get:function(t,key){ if(key==='length'){ if(++reads>5000) throw Error('the tag stack never ended'); } return t[key]; }}); }
     try{
       for(k=0;k<20000&&!Y;k++){ y=100+k*0.0137; if((y-gap-h)+h>y-gap) Y=y; }
       if(!Y) return 'SKIP: no rounding case for gap '+gap;
       if(Y+h>H) return 'SKIP: the window is too short';
       noteCrash=function(a,b,c){ noted.push([a,b,c]); };
       WTX.z=1; WTX.ox=0; WTX.oy=0;
       // ONE: his freeze: the second pass puts the tag back on the same spot
       WLTEXT.boxes=guard([{x:0,y:Y,w:300,h:20}]); reads=0;
       try{ r=wlTagPlace(10,Y,50,h); }catch(e1){ return 'ONE: '+e1.message+' (the loop that froze his game)'; }
       if(!(isFinite(r)&&r+h<=Y-gap)) bad.push('ONE: the tag went to '+r+', not clear above '+(Y-gap));
       if(WLTEXT.boxes.length!==2) bad.push('ONE: the placed tag was not reserved');
       if(reads>12) bad.push('ONE: '+reads+' passes for one box');
       // TWO: a box that never lets go is capped, with one note
       if(typeof WLCAP==='object') WLCAP.told=0;
       cur=400; n=0;
       creep={x:0,w:2000,h:1e6,get y(){ n++; var v=cur+gap+h-0.001; if(n%3===0) cur-=0.001; return v; }};
       WLTEXT.boxes=guard([creep]); reads=0;
       try{ r=wlTagPlace(10,400,50,h); }catch(e2){ return 'TWO: '+e2.message+' (no cap)'; }
       if(r!==null) bad.push('TWO: a box that never lets go placed the tag at '+r);
       if(reads>40) bad.push('TWO: the cap let '+reads+' passes run');
       if(noted.length!==1||noted[0][0]!=='hang') bad.push('TWO: the cap noted '+JSON.stringify(noted));
       WLTEXT.boxes=ob; WLTEXT.g=og; WTX.z=oz; WTX.ox=ox; WTX.oy=oy;
       // THREE: the heartbeat
       if(typeof hbTick!=='function'||typeof hbCheck!=='function'||typeof hbClear!=='function') return bad.concat(['THREE: no raid heartbeat']).join('; ');
       window.__hbTest=1; hbClear();
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:['gun_pistol'],safe:null,mapIx:0,seed:4242}); dep=true; g=__state(); if(!g||g.over) return 'no live raid';
       hbClear(); hbTick(); s=localStorage.getItem(HBEAT_KEY);
       if(!s||JSON.parse(s).v!==VER) bad.push('THREE: a live raid wrote no heartbeat');
       noted.length=0; hbCheck();
       if(noted.length!==1||noted[0][0]!=='hang'||!/stopped answering/.test(noted[0][1])) bad.push('THREE: a heartbeat left behind gave '+JSON.stringify(noted));
       if(localStorage.getItem(HBEAT_KEY)) bad.push('THREE: the heartbeat was not wiped after the note');
       hbTick(); hbClear(); noted.length=0; hbCheck();
       if(noted.length) bad.push('THREE: a clean leave still noted a hang');
       return bad.length?bad.join('; '):null;
     }finally{
       WLTEXT.boxes=ob; WLTEXT.g=og; WTX.z=oz; WTX.ox=ox; WTX.oy=oy; noteCrash=nc;
       try{ if(typeof hbClear==='function') hbClear(); }catch(_c){}
       try{ delete window.__hbTest; }catch(_d){}
       if(dep){ try{ __endRaid('abandon'); }catch(_e){} __topClear(); }
     }
   }},
  {v:'36.25',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
