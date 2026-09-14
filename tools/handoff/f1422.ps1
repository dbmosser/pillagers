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
  {v:'14.21',what:
'@ @'
  {v:'14.22',what:'a rebuilt panel keeps the pad on the same control: on a five-button probe window the pad moved down two, and A on a button whose click rebuilds the window leaves the focus on the rebuilt third button, not the first (controller audit finding 4)',
   run:function(){
     if(typeof pollPad!=='function'||typeof padMenu!=='function'||typeof PAD==='undefined') return 'SKIP: no pad menu in this build';
     var NG=navigator.getGamepads;
     if(typeof NG!=='function') return 'SKIP: this browser has no pad interface to fake';
     var bad=[], stubbed=false, md=null, clicks=0;
     try{ navigator.getGamepads=function(){ return []; }; stubbed=(navigator.getGamepads!==NG); }catch(_s){}
     if(!stubbed){ try{ navigator.getGamepads=NG; }catch(_r0){} return 'SKIP: this browser will not let the pad be faked'; }
     function padWith(down){
       var bts=[],i;
       for(i=0;i<16;i++) bts.push({pressed:(i===down),value:(i===down)?1:0,touched:(i===down)});
       var fake={connected:true,id:'probe pad',index:0,mapping:'standard',timestamp:1,axes:[0,0,0,0],buttons:bts};
       navigator.getGamepads=function(){ return [fake]; };
     }
     // Every click rebuilds the whole window, the way renderStage and renderSettings do.
     function build(){
       var h=''; for(var i=1;i<=5;i++) h+='<button style="display:block;margin:6px;padding:8px 22px">ZQX '+i+'</button>';
       md.innerHTML=h;
       Array.prototype.forEach.call(md.querySelectorAll('button'),function(b){ b.onclick=function(){ clicks++; build(); }; });
     }
     var label=function(){ return PAD.focus?String(PAD.focus.textContent||''):'(none)'; };
     try{
       __topClear(); __runPrep(); __cleanProfile();
       md=document.createElement('div'); md.className='modal on'; md.id='zqxpadfocus';
       document.body.appendChild(md); build();
       padWith(-1); pollPad(); pollPad();
       if(label()!=='ZQX 1') return 'SKIP: the pad did not start on the first probe button ('+label()+'), so the menu path is not reachable here';
       padWith(13); pollPad(); padWith(-1); pollPad();
       padWith(13); pollPad(); padWith(-1); pollPad();
       if(label()!=='ZQX 3') return 'SKIP: two presses down did not reach the third probe button ('+label()+'), so the probe does not stack here';
       padWith(0); pollPad();
       if(!clicks) bad.push('control: A on the third probe button did not click it');
       padWith(-1); pollPad();
       if(!PAD.focus||!md.contains(PAD.focus)) bad.push('after the click rebuilt the window the pad focus is not in the window');
       else if(label()!=='ZQX 3') bad.push('after a click rebuilt the window the pad focus jumped to "'+label()+'" instead of staying on the third button');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ if(md&&md.parentNode) md.parentNode.removeChild(md); }catch(_m){}
       try{ navigator.getGamepads=function(){ return []; }; pollPad(); }catch(_p0){}
       try{ padSetFocus(null); PAD.focus=null; PAD.focusIx=-1; PAD.focusMd=null; PAD.aSpent=0; padRelease(); }catch(_pr){}
       try{ navigator.getGamepads=NG; }catch(_p){}
       try{ var K3=__keysRef(); for(var k3 in K3) K3[k3]=false; }catch(_k){}
       try{ __topClear(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'14.21',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
