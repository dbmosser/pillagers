$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# v12.91 CHECK, inserted before the v12.90 entry.
#
# IT FAKES THE HARDWARE, NOT THE STATE, and it has to. Setting PAD.mx by hand is
# useless: pollPad runs every frame before the raid update, and with no gamepad
# present its first act is to set PAD.on false and PAD.mx and PAD.my to zero and
# return. Anything poked into PAD is gone before updatePlayer reads it. So
# navigator.getGamepads is stubbed to hand back one connected pad with the axes
# this check wants, and the whole real chain runs: pollPad reads the axes, applies
# its own deadzone and normalisation, sets PAD, and the crawl reads it.
#
# IT CALIBRATES ITSELF AGAINST THE KEYBOARD instead of asserting a distance. A
# downed body can be lying against a wall, and then a direction moves nothing for a
# perfectly good reason; a check that demanded movement in a fixed direction would
# be measuring the map. Every direction is crawled twice, once on the keys and once
# on the stick, and the stick is judged only where the keys proved the way is open.
#
# THAT PAIRING IS ALSO THE SPEED CONTROL. The fix goes in before the magnitude
# normalisation, so the stick must cover the same ground and not more: a stick that
# crawled faster would be a balance change nobody asked for.
#
# ONLY __loop RUNS THE PLAYER. __sim has no player movement and __rawStep is the
# bot, so the frames here are real ones.
SubRx @'
  {v:'12.90',what:'the feeling tag for the tactical belt
'@ @'
  {v:'12.91',what:'a downed player can crawl on the stick as well as the keys, covering the same ground and no more, which is the one action the downed overlay asks for and the one a controller could not perform (audit finding 11, 2026-09-11)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__loop&&window.__keysRef))
       return 'SKIP: this fixture cannot drive a live frame';
     var NG=navigator.getGamepads;
     if(typeof NG!=='function') return 'SKIP: this browser has no pad interface to fake';
     var bad=[], stubbed=false;
     try{
       navigator.getGamepads=function(){ return []; };
       stubbed=(navigator.getGamepads!==NG);
     }catch(_s){}
     if(!stubbed){ try{ navigator.getGamepads=NG; }catch(_r0){} return 'SKIP: this browser will not let the pad be faked'; }
     var T0=performance.now();
     function pad(ax0,ax1,on){
       if(!on){ navigator.getGamepads=function(){ return []; }; return; }
       var fake={connected:true,id:'probe pad',index:0,mapping:'standard',timestamp:1,
                 axes:[ax0,ax1,0,0],buttons:[]};
       navigator.getGamepads=function(){ return [fake]; };
     }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state();
       if(!g||!g.player) return 'SKIP: the raid did not start';
       var start={x:g.player.x,y:g.player.y};
       // dx,dy is the direction. onStick sends it through the fake pad; otherwise
       // through the keys with a pad present but at rest, which is also the control
       // that reading the stick has not taken the keyboard away.
       function crawl(dx,dy,onStick){
         var p2=__state().player, K=__keysRef(), kk;
         for(kk in K) K[kk]=false;
         p2.x=start.x; p2.y=start.y; p2.prep=null; p2.prepA=null;
         p2.hp=0; p2.downed=true; p2.downT=60;
         if(onStick){ pad(dx,dy,true); }
         else {
           pad(0,0,true);
           if(dx>0) K['KeyD']=true; else if(dx<0) K['KeyA']=true;
           if(dy>0) K['KeyS']=true; else if(dy<0) K['KeyW']=true;
         }
         for(var f=0;f<30;f++){ T0+=16.7; __loop(T0); }
         var d=Math.sqrt((p2.x-start.x)*(p2.x-start.x)+(p2.y-start.y)*(p2.y-start.y));
         for(kk in K) K[kk]=false;
         pad(0,0,false);
         return d;
       }
       var dirs=[[1,0],[-1,0],[0,1],[0,-1]], open=0, i;
       for(i=0;i<dirs.length;i++){
         // THE KEYS, WITH A PAD CONNECTED AND THE STICK AT REST. This says whether
         // the way is open at all, and doubles as the control that the override did
         // not take the keyboard from a pad player.
         var kd=crawl(dirs[i][0],dirs[i][1],false);
         if(kd<5) continue;
         open++;
         var pd=crawl(dirs[i][0],dirs[i][1],true);
         if(pd<kd*0.6)
           bad.push('pushing the stick while downed moved him '+Math.round(pd)+' units where the keys moved him '+Math.round(kd)+', so the one action the downed screen asks for is dead on a controller: he turns on the spot and bleeds out where he fell');
         else if(pd>kd*1.4)
           bad.push('the stick crawls '+Math.round(pd)+' units where the keys crawl '+Math.round(kd)+', so a controller crawls faster than a keyboard, which is a balance change nobody asked for');
       }
       if(!open)
         return 'SKIP: with a pad connected the keys crawled nowhere in any of the four directions, so either the body is boxed in at this landing or the keyboard itself is broken and that is not this row to report';
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ navigator.getGamepads=function(){ return []; }; if(typeof pollPad==='function') pollPad(); }catch(_p0){}
       try{ navigator.getGamepads=NG; }catch(_p){}
       try{ var K3=__keysRef(); for(var k3 in K3) K3[k3]=false; }catch(_k){}
       try{ var g3=__state(); if(g3&&g3.player){ g3.player.downed=false; g3.player.downT=0; }
            if(g3&&!g3.over){ __endRaid('abandon'); } }catch(_e){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'12.90',what:'the feeling tag for the tactical belt
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
