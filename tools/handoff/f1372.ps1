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

SubRx @'
  {v:'13.71',what:
'@ @'
  {v:'13.72',what:'on a controller X walks away from the stall and it stays shut: X held through three real frames beside the Peddler leaves the stall closed on every one, while the keyboard E still opens it (hire and peddler audit 2026-09-14, finding 4)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     if(typeof pollPad!=='function'||typeof mkPeddler!=='function'||typeof updatePlayer!=='function') return 'SKIP: no pad poll or Peddler in this build';
     var NG=navigator.getGamepads;
     if(typeof NG!=='function') return 'SKIP: this browser has no pad interface to fake';
     var bad=[], stubbed=false;
     try{ navigator.getGamepads=function(){ return []; }; stubbed=(navigator.getGamepads!==NG); }catch(_s){}
     if(!stubbed){ try{ navigator.getGamepads=NG; }catch(_r0){} return 'SKIP: this browser will not let the pad be faked'; }
     function padWith(down){
       var bts=[],i;
       for(i=0;i<16;i++) bts.push({pressed:(i===down),value:(i===down)?1:0,touched:(i===down)});
       var fake={connected:true,id:'probe pad',index:0,mapping:'standard',timestamp:1,axes:[0,0,0,0],buttons:bts};
       navigator.getGamepads=function(){ return [fake]; };
     }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(), p=g.player;
       if(!g||!p) return 'SKIP: no live raid';
       g.ents.length=0; g.containers.length=0; p.downed=false; p.iv=99;
       var pd=mkPeddler(p.x+40,p.y,g.map);
       if(g.ents.indexOf(pd)<0) g.ents.push(pd);
       padWith(-1); pollPad();
       var K=__keysRef(); for(var k0 in K) K[k0]=false;
       // THE FINDING: the stall open, X pressed and held through three frames.
       g.trade=pd; g.pedLock=0; g.pedSel=0;
       padWith(2);
       var open=[];
       for(var f=0;f<3;f++){ pollPad(); updatePlayer(0.016); open.push(!!g.trade); }
       if(open.indexOf(true)>=0) bad.push('X held on the open stall shut it and then it was open again (frames: '+open.join(',')+')');
       // CONTROL: X let go, the keyboard E beside him opens the stall on the real path.
       padWith(-1); pollPad(); pollPad();
       g.trade=null; g.pedLock=0;
       K['KeyE']=true; updatePlayer(0.016); K['KeyE']=false;
       if(!g.trade) bad.push('control: E beside the Peddler did not open the stall, so this check cannot see it open');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ navigator.getGamepads=function(){ return []; }; pollPad(); }catch(_p0){}
       try{ navigator.getGamepads=NG; }catch(_p){}
       try{ var g3=__state(); if(g3){ g3.trade=null; if(g3.player){ g3.player.iv=0; g3.player.downed=false; } if(!g3.over) __endRaid('abandon'); } }catch(_e){}
       try{ var K3=__keysRef(); for(var k3 in K3) K3[k3]=false; }catch(_k){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'13.71',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
