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
  {v:'14.22',what:
'@ @'
  {v:'14.23',what:'the pause box works on a pad: with a raid paused the pad focus lands on a control in the box, D-UP leaves the map shut behind it, and B resumes the run (controller audit finding 5)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     if(typeof pollPad!=='function'||typeof padMenu!=='function'||typeof togglePauseBox!=='function'||typeof PAD==='undefined') return 'SKIP: no pad menu or pause box in this build';
     var box=document.getElementById('pausebox');
     if(!box) return 'SKIP: no pause box in this document';
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
       var g=__state(); if(!g||!g.player) return 'SKIP: no live raid';
       g.ents.length=0; g.player.iv=99; g.mapOpen=false;
       padWith(-1); pollPad();
       togglePauseBox(true);
       // CONTROL: the box is open.
       if(!box.classList.contains('on')) return 'SKIP: togglePauseBox did not open the pause box here';
       pollPad();
       if(!PAD.focus||!box.contains(PAD.focus)) bad.push('with the raid paused the pad focus is not on a control in the pause box ('+(PAD.focus?PAD.focus.textContent:'none')+')');
       padWith(12); pollPad(); padWith(-1); pollPad();
       if(g.mapOpen) bad.push('D-UP on the pause box opened the map behind it');
       padWith(1); pollPad(); padWith(-1); pollPad();
       if(box.classList.contains('on')) bad.push('B on the pause box did not resume the run');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ if(box.classList.contains('on')) togglePauseBox(false); }catch(_tp){}
       try{ navigator.getGamepads=function(){ return []; }; pollPad(); }catch(_p0){}
       try{ padSetFocus(null); PAD.focus=null; PAD.focusIx=-1; PAD.focusMd=null; PAD.aSpent=0; padRelease(); }catch(_pr){}
       try{ navigator.getGamepads=NG; }catch(_p){}
       try{ var g3=__state(); if(g3){ g3.mapOpen=false; if(g3.player) g3.player.iv=0; if(!g3.over) __endRaid('abandon'); } }catch(_e){}
       try{ var K3=__keysRef(); for(var k3 in K3) K3[k3]=false; }catch(_k){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'14.22',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
