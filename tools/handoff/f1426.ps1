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
  {v:'14.25',what:
'@ @'
  {v:'14.26',what:'the title screen works on a pad: with the title showing the pad focus lands on ENTER THE UNDERCROFT, and B leaves the title up instead of stripping it to a blank screen (controller audit finding 7)',
   run:function(){
     if(typeof pollPad!=='function'||typeof padMenu!=='function'||typeof padFocusables!=='function'||typeof PAD==='undefined') return 'SKIP: no pad menu in this build';
     var tt=document.getElementById('title'), go=document.getElementById('titlestart');
     if(!tt||!go) return 'SKIP: no title screen in this document';
     var NG=navigator.getGamepads;
     if(typeof NG!=='function') return 'SKIP: this browser has no pad interface to fake';
     var bad=[], stubbed=false, wasOn=tt.classList.contains('on');
     try{ navigator.getGamepads=function(){ return []; }; stubbed=(navigator.getGamepads!==NG); }catch(_s){}
     if(!stubbed){ try{ navigator.getGamepads=NG; }catch(_r0){} return 'SKIP: this browser will not let the pad be faked'; }
     function padWith(down){
       var bts=[],i;
       for(i=0;i<16;i++) bts.push({pressed:(i===down),value:(i===down)?1:0,touched:(i===down)});
       var fake={connected:true,id:'probe pad',index:0,mapping:'standard',timestamp:1,axes:[0,0,0,0],buttons:bts};
       navigator.getGamepads=function(){ return [fake]; };
     }
     try{
       __topClear(); __runPrep(); __cleanProfile();
       try{ padSetFocus(null); PAD.focus=null; }catch(_f){}
       tt.classList.add('on');
       // CONTROL: ENTER THE UNDERCROFT is laid out as a control a pad could reach on this screen.
       if(padFocusables(tt).indexOf(go)<0) return 'SKIP: ENTER THE UNDERCROFT is not laid out as a reachable control here';
       padWith(-1); pollPad(); pollPad();
       if(PAD.focus!==go) bad.push('with the title showing the pad focus is on '+(PAD.focus?'"'+String(PAD.focus.textContent||'').trim()+'"':'nothing')+', not ENTER THE UNDERCROFT');
       padWith(1); pollPad(); padWith(-1); pollPad();
       if(!tt.classList.contains('on')) bad.push('B on the title screen took the title away and left a blank screen');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ if(wasOn) tt.classList.add('on'); else tt.classList.remove('on'); }catch(_t){}
       try{ navigator.getGamepads=function(){ return []; }; pollPad(); }catch(_p0){}
       try{ padSetFocus(null); PAD.focus=null; PAD.focusIx=-1; PAD.focusMd=null; PAD.aSpent=0; padRelease(); }catch(_pr){}
       try{ navigator.getGamepads=NG; }catch(_p){}
       try{ var K3=__keysRef(); for(var k3 in K3) K3[k3]=false; }catch(_k){}
       try{ __topClear(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'14.25',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
