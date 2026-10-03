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

if ($s.Contains("  {v:'17.75',what:")) { throw "check 17.75 is in the fixture already" }

SubRx @'
  {v:'17.74',what:
'@ @'
  {v:'17.75',what:'remappable keys: binding interact onto F swaps it with melee, a real F press then reads as E in the game and the pause legend says F interact; RESET puts the defaults back; Settings has a CHANGE KEYS row and the Keys window lists the actions',
   run:function(){
     if(typeof keysBind!=='function'||typeof keyRemap!=='function') return 'the keys cannot be changed';
     if(!window.__deploy||!window.__endRaid||typeof renderSettings!=='function') return 'SKIP: no raid or Settings in this fixture';
     var bad=[], km0=P.keymap, oSay=say, kd, ku, m;
     try{
       say=function(){};
       P.keymap={}; KEYS.inv=null; keysInv();
       if(!keysBind('KeyE','KeyF')) bad.push('binding interact onto F was refused');
       if(keysOf('KeyE')!=='KeyF'||keysOf('KeyF')!=='KeyE') bad.push('the swap did not happen ('+JSON.stringify(P.keymap)+')');
       if(keyRemap('KeyF')!=='KeyE'||keyRemap('KeyE')!=='KeyF') bad.push('the translation reads '+keyRemap('KeyF')+' for F and '+keyRemap('KeyE')+' for E');
       if(keysLegendHtml().indexOf('F</b> interact')<0) bad.push('the pause legend does not say F interact');
       __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       if(!G||G.over) return 'SKIP: staging: no raid';
       keys={};
       kd=new KeyboardEvent('keydown',{code:'KeyF',key:'f',bubbles:true,cancelable:true}); window.dispatchEvent(kd);
       if(!keys['KeyE']) bad.push('a real F press did not read as E in the game ('+JSON.stringify(Object.keys(keys).filter(function(k){ return keys[k]; }))+')');
       ku=new KeyboardEvent('keyup',{code:'KeyF',key:'f',bubbles:true,cancelable:true}); window.dispatchEvent(ku);
       if(keys['KeyE']) bad.push('letting F go did not let E go');
       keysReset(); if(keyRemap('KeyF')!=='KeyF') bad.push('RESET did not put the defaults back');
       renderSettings(); if(!document.getElementById('set_keys')) bad.push('Settings has no CHANGE KEYS row');
       keysOpen(); m=document.getElementById('keysmodal');
       if(!m||!m.classList.contains('on')) bad.push('the Keys window did not open');
       else if(m.querySelectorAll('.keybtn').length<15) bad.push('the Keys window lists '+m.querySelectorAll('.keybtn').length+' actions');
       if(m) m.classList.remove('on');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       say=oSay; P.keymap=km0||{}; KEYS.inv=null; keysInv(); keys={}; KEYS.waiting=null;
       try{ var mm=document.getElementById('keysmodal'); if(mm) mm.classList.remove('on'); }catch(_m){}
       try{ if(G) __endRaid('abandon'); __topClear(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'17.74',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
