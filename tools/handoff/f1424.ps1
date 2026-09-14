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
  {v:'14.23',what:
'@ @'
  {v:'14.24',what:'A does not fire under the open map or the open backpack on a pad: A held with the map open, then with the backpack open, leaves the trigger off, while with both shut A sets it (controller audit finding 6)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     if(typeof pollPad!=='function'||typeof PAD==='undefined'||typeof mouse==='undefined') return 'SKIP: no pad poll in this build';
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
       var g=__state(), p=g&&g.player; if(!g||!p) return 'SKIP: no live raid';
       g.ents.length=0; p.iv=99; PAD.aSpent=0;
       g.mapOpen=false; g.bagOpen=false;
       padWith(-1); pollPad();
       // CONTROL: nothing open, A sets the trigger.
       padWith(0); pollPad();
       if(!mouse.down) bad.push('control: A in the raid with nothing open did not set the trigger, so this check cannot see a shot');
       padWith(-1); pollPad();
       // THE FIX: the map open.
       g.mapOpen=true;
       padWith(0); pollPad(); pollPad();
       if(mouse.down) bad.push('A held with the map open set the trigger');
       padWith(-1); pollPad(); g.mapOpen=false;
       // and the backpack open.
       g.bagOpen=true;
       padWith(0); pollPad(); pollPad();
       if(mouse.down) bad.push('A held with the backpack open set the trigger');
       padWith(-1); pollPad(); g.bagOpen=false;
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ var g2=__state(); if(g2){ g2.mapOpen=false; g2.bagOpen=false; } }catch(_t){}
       try{ navigator.getGamepads=function(){ return []; }; pollPad(); }catch(_p0){}
       try{ padRelease(); mouse.down=false; PAD.aSpent=0; }catch(_pr){}
       try{ navigator.getGamepads=NG; }catch(_p){}
       try{ var g3=__state(); if(g3){ if(g3.player){ g3.player.iv=0; g3.player.ads=false; } if(!g3.over) __endRaid('abandon'); } }catch(_e){}
       try{ var K3=__keysRef(); for(var k3 in K3) K3[k3]=false; }catch(_k){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'14.23',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
