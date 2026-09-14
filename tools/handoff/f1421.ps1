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
  {v:'14.20',what:
'@ @'
  {v:'14.21',what:'an A that clicks a menu button does not fire on arrival: A pressed on a window button and still held when the raid starts leaves the trigger off, and once let go a fresh A fires (controller audit finding 3)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     if(typeof pollPad!=='function'||typeof padMenu!=='function'||typeof PAD==='undefined'||typeof mouse==='undefined') return 'SKIP: no pad menu in this build';
     var NG=navigator.getGamepads;
     if(typeof NG!=='function') return 'SKIP: this browser has no pad interface to fake';
     var bad=[], stubbed=false, md=null, clicked=0;
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
       // A probe window with one button, standing in for ASCEND: A on it clicks it.
       md=document.createElement('div'); md.className='modal on'; md.id='zqxpadascend';
       md.innerHTML='<button id="zqxpadgo" style="padding:8px 22px">ZQX GO</button>';
       document.body.appendChild(md);
       md.querySelector('button').onclick=function(){ clicked++; };
       padWith(-1); pollPad(); pollPad();
       padWith(0); pollPad();
       if(!clicked) return 'SKIP: A on the probe window did not click its button, so the menu path is not reachable here';
       // The button starts the raid, as ASCEND does, with A still held.
       md.parentNode.removeChild(md); md=null;
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(); if(!g||!g.player) return 'SKIP: no live raid';
       g.ents.length=0; g.player.iv=99;
       pollPad(); pollPad();
       if(mouse.down) bad.push('A still held from the menu click set the trigger on the first raid frames, a shot at the spawn point');
       // CONTROL: let go, then a fresh A fires.
       padWith(-1); pollPad();
       padWith(0); pollPad();
       if(!mouse.down) bad.push('control: a fresh A in the raid did not set the trigger, so this check cannot see a shot');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ if(md&&md.parentNode) md.parentNode.removeChild(md); }catch(_m){}
       try{ navigator.getGamepads=function(){ return []; }; pollPad(); }catch(_p0){}
       try{ padRelease(); mouse.down=false; PAD.aSpent=0; }catch(_pr){}
       try{ navigator.getGamepads=NG; }catch(_p){}
       try{ var g3=__state(); if(g3){ if(g3.player){ g3.player.iv=0; g3.player.ads=false; } if(!g3.over) __endRaid('abandon'); } }catch(_e){}
       try{ var K3=__keysRef(); for(var k3 in K3) K3[k3]=false; }catch(_k){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'14.20',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
