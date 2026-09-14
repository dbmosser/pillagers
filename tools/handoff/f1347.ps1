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
  {v:'13.46',what:
'@ @'
  {v:'13.47',what:'on a controller on the Undercroft floor View opens and closes the backpack and Menu raises and closes the pause box, one change per press, and View does nothing under the pause box, as the keyboard I and P behave there (key remap review 2026-09-13)',
   run:function(){
     if(typeof pollPad!=='function'||typeof hubBagOpenSet!=='function'||typeof togglePauseBox!=='function'||!window.__hubEnter) return 'SKIP: no pad poll or floor backpack in this build';
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
     function tap(b){ padWith(b); pollPad(); padWith(-1); pollPad(); }
     function boxOn(){ var pb=document.getElementById('pausebox'); return !!(pb&&pb.classList.contains('on')); }
     try{
       __topClear(); __cleanProfile(); __hubEnter();
       if(state!=='hub') return 'SKIP: the floor did not open';
       [].forEach.call(document.querySelectorAll('.modal.on'),function(x){ x.classList.remove('on'); });   // a fresh profile opens the welcome window, and an open window owns the pad
       if(document.querySelector('.modal.on')) return 'SKIP: a window stayed open over the floor';
       if(hubBagOpen) hubBagOpenSet(false);
       if(boxOn()) togglePauseBox(false);
       padWith(-1); pollPad();
       tap(8);
       if(!hubBagOpen) bad.push('View on the floor did not open the backpack');
       tap(8);
       if(hubBagOpen) bad.push('a second View on the floor did not close the backpack');
       tap(9);
       if(!boxOn()) bad.push('Menu on the floor did not raise the pause box');
       tap(8);
       if(hubBagOpen) bad.push('View opened the backpack under the pause box, which the keyboard refuses');
       tap(9);
       if(boxOn()) bad.push('a second Menu on the floor did not close the pause box');
       padWith(8); pollPad(); pollPad(); pollPad(); padWith(-1); pollPad();
       if(!hubBagOpen) bad.push('a View held for three frames did not leave the backpack open');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ navigator.getGamepads=function(){ return []; }; pollPad(); }catch(_p0){}
       try{ navigator.getGamepads=NG; }catch(_p){}
       try{ if(hubBagOpen) hubBagOpenSet(false); }catch(_b){}
       try{ if(boxOn()) togglePauseBox(false); }catch(_x){}
       try{ var K3=__keysRef(); for(var k3 in K3) K3[k3]=false; }catch(_k){}
       try{ __topClear(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'13.46',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
