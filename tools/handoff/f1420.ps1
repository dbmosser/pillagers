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
  {v:'14.19',what:
'@ @'
  {v:'14.20',what:'the pad lets go when the stall opens: A held to fire through raid frames sets the fire flag and the aim, and on the first frame with the stall open both are off and the pad no longer counts itself as firing (controller audit finding 2)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     if(typeof pollPad!=='function'||typeof mkPeddler!=='function'||typeof raidKey!=='function'||typeof PAD==='undefined'||typeof mouse==='undefined') return 'SKIP: no pad poll or Peddler in this build';
     var NG=navigator.getGamepads;
     if(typeof NG!=='function') return 'SKIP: this browser has no pad interface to fake';
     var bad=[], stubbed=false, _rk=raidKey;
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
       var g=__state(), p=g&&g.player;
       if(!g||!p) return 'SKIP: no live raid';
       g.ents.length=0; g.containers.length=0; p.downed=false; p.iv=99;
       var pd=mkPeddler(p.x+40,p.y,g.map);
       if(g.ents.indexOf(pd)<0) g.ents.push(pd);
       g.trade=null; PAD.xAfterTrade=0;
       padWith(-1); pollPad();
       var K=__keysRef(); for(var k0 in K) K[k0]=false;
       raidKey=function(){};
       // CONTROL: A held in the raid sets the fire flag and the aim through the pad.
       padWith(0); pollPad(); pollPad();
       if(!mouse.down) bad.push('control: A held in the raid did not set the fire flag, so this check cannot see it held');
       if(!p.ads) bad.push('control: A held in the raid did not aim, so this check cannot see the aim let go');
       // THE FIX: the stall opens with A still held.
       g.trade=pd; g.pedLock=0; g.pedSel=0;
       pollPad();
       if(mouse.down) bad.push('with the stall open and A still held, the fire flag stayed on behind the panel');
       if(PAD.firing) bad.push('with the stall open, the pad still counts itself as firing');
       if(p.ads) bad.push('with the stall open, the gun stayed aimed down the sights');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       raidKey=_rk;
       try{ var g2=__state(); if(g2) g2.trade=null; PAD.xAfterTrade=0; }catch(_t){}
       try{ navigator.getGamepads=function(){ return []; }; pollPad(); }catch(_p0){}
       try{ padRelease(); mouse.down=false; }catch(_pr){}
       try{ navigator.getGamepads=NG; }catch(_p){}
       try{ var g3=__state(); if(g3){ if(g3.player){ g3.player.iv=0; g3.player.downed=false; g3.player.ads=false; } if(!g3.over) __endRaid('abandon'); } }catch(_e){}
       try{ var K3=__keysRef(); for(var k3 in K3) K3[k3]=false; }catch(_k){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'14.19',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
