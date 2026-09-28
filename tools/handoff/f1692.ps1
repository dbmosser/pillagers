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

if ($s.Contains("  {v:'16.92',what:")) { throw "check 16.92 is in the fixture already" }

SubRx @'
  {v:'16.91',what:
'@ @'
  {v:'16.92',what:'a key the player 2 window handed to player 1 is handed back up when that window loses focus or closes, and a key let go over a text box there is still handed up, so player 1 never keeps walking with no key down',
   run:function(){
     if(typeof netKeyFwd!=='function'||typeof netSameOnMsg!=='function'||typeof netSamePost!=='function'||typeof NET!=='object'||!NET||!window.__deploy||!window.__endRaid) return 'SKIP: this build has no same machine pair';
     var keep={same:NET.same,pair:NET.pair}, oPost=netSamePost, sent=[], bad=[], k0=keys, K=window.KeyboardEvent, inp=null;
     function press(el,code,ty){ el.dispatchEvent(new K(ty||'keydown',{code:code,key:code.replace(/^Key/,'').toLowerCase(),bubbles:true,cancelable:true})); }
     function count(ty,code){ return sent.filter(function(m){ return m&&m.t==='key'&&m.ty===ty&&m.code===code; }).length; }
     function play(){ var j, s=sent.slice(); NET.same='host'; keys={}; for(j=0;j<s.length;j++) netSameOnMsg(s[j]); NET.same='p2'; }
     try{
       __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       netSamePost=function(m){ sent.push(m); return true; };
       NET.same='p2'; NET.pair='zqxheld'; keys={};
       press(document.body,'KeyW'); press(document.body,'ShiftLeft');
       if(!count('keydown','KeyW')||!count('keydown','ShiftLeft')) return 'SKIP: staging: the player 2 window did not hand the keys down ('+JSON.stringify(sent)+')';
       window.dispatchEvent(new Event('blur'));
       if(count('keyup','KeyW')!==1||count('keyup','ShiftLeft')!==1) bad.push('the player 2 window lost focus with W and Shift held and handed up '+count('keyup','KeyW')+' W and '+count('keyup','ShiftLeft')+' Shift, not one of each');
       play();
       if(keys['KeyW']||keys['ShiftLeft']) bad.push('player 1 kept walking or sprinting with no key down after the player 2 window lost focus');
       sent.length=0; window.dispatchEvent(new Event('blur'));
       if(sent.length) bad.push('a second loss of focus handed keys up again ('+sent.length+')');
       sent.length=0; press(document.body,'KeyE'); window.dispatchEvent(new Event('pagehide'));
       if(count('keyup','KeyE')!==1) bad.push('closing the player 2 window with E held did not hand E up');
       sent.length=0; inp=document.createElement('input'); document.body.appendChild(inp);
       press(document.body,'KeyD'); press(inp,'KeyD','keyup');
       if(count('keyup','KeyD')!==1) bad.push('D let go over a text box in the player 2 window was not handed up');
       play();
       if(keys['KeyD']) bad.push('player 1 kept D down after it was let go over a text box in the player 2 window');
       sent.length=0; press(inp,'KeyQ'); press(inp,'KeyQ','keyup');
       if(sent.length) bad.push('a key typed into a text box in the player 2 window was handed to player 1');
       press(document.body,'KeyA'); NET.same=''; sent.length=0; keys={};
       window.dispatchEvent(new Event('blur'));
       if(sent.length) bad.push('outside a pair a loss of focus handed keys on');
     } finally {
       NET.same='p2'; NET.pair='zqxheld';
       try{ if(typeof netKeyLetGo==='function') netKeyLetGo(); }catch(e){}
       netSamePost=oPost; NET.same=keep.same; NET.pair=keep.pair; keys=k0||{};
       if(inp&&inp.parentNode) inp.parentNode.removeChild(inp);
       try{ __endRaid('abandon'); __topClear(); }catch(e){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'16.91',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
