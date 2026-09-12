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

# v13.09 CHECK, inserted before the v13.08 entry.
#
# IT CANNOT GO FULLSCREEN AND DOES NOT PRETEND TO. A hidden pane cannot enter
# fullscreen and no test can prove what a browser does with a real Escape key. What
# CAN be proved is the decision: that entering fullscreen asks for the lock, that
# leaving releases it, that the request names Escape and not the whole keyboard, and
# that a browser without the interface is left exactly as it was.
#
# THE LAST ARM IS THE ONE THAT PROTECTS HIS FRIENDS. Firefox and Safari have no
# keyboard lock. If this threw there, every one of them would meet a broken game the
# first time they pressed the fullscreen button.
SubRx @'
  {v:'13.08',what:'the Undercroft is not a raid
'@ @'
  {v:'13.09',what:'entering fullscreen asks the browser to hand over Escape and leaving releases it, the request names Escape alone, and a browser with no keyboard lock is left exactly as it was rather than thrown (his note of 2026-09-12)',
   run:function(){
     if(typeof fsKeyLock!=='function')
       return 'nothing asks the browser for the Escape key, so pressing Escape in fullscreen drops him out of it, which is what he reported';
     if(typeof fsOn!=='function') return 'SKIP: this build has no fullscreen state to read';
     var bad=[], oFsOn=fsOn, had=Object.prototype.hasOwnProperty.call(navigator,'keyboard'), oKb=navigator.keyboard;
     var locked=null, unlocked=0, stubbed=false;
     try{
       try{
         Object.defineProperty(navigator,'keyboard',{configurable:true,writable:true,
           value:{lock:function(a){ locked=a; return {then:function(){return this;},catch:function(){return this;}}; },
                  unlock:function(){ unlocked++; }}});
         stubbed=(navigator.keyboard&&typeof navigator.keyboard.lock==='function');
       }catch(_s){}
       if(!stubbed) return 'SKIP: this browser will not let the keyboard interface be faked';

       // ENTERING fullscreen asks for Escape.
       fsOn=function(){ return true; };
       fsKeyLock();
       if(locked===null)
         bad.push('entering fullscreen asks the browser for nothing, so Escape stays the browser key and drops him out of fullscreen the moment he presses it');
       else if(!(locked&&locked.length===1&&locked[0]==='Escape'))
         bad.push('entering fullscreen asks for ['+(locked||[]).join(', ')+'] rather than Escape alone, and taking the whole keyboard from a player is not what was asked for');

       // LEAVING releases it. A lock left on after fullscreen ends would keep Escape
       // away from the browser on an ordinary page.
       locked=null; unlocked=0;
       fsOn=function(){ return false; };
       fsKeyLock();
       if(!unlocked)
         bad.push('leaving fullscreen never releases the key, so the page keeps holding Escape when it has no business holding it');
       if(locked!==null)
         bad.push('leaving fullscreen asks for the key again rather than giving it back');

       // A BROWSER WITHOUT IT must be untouched. Firefox and Safari have none.
       try{ Object.defineProperty(navigator,'keyboard',{configurable:true,writable:true,value:undefined}); }catch(_u){}
       var threw=null;
       try{ fsOn=function(){ return true; }; fsKeyLock(); }catch(e2){ threw=String(e2&&e2.message||e2); }
       if(threw)
         bad.push('a browser with no keyboard lock throws on entering fullscreen: '+threw+'. Firefox and Safari have none, so every friend on one would meet a broken game the first time he pressed the fullscreen button');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ fsOn=oFsOn; }catch(_f){}
       try{
         if(had) Object.defineProperty(navigator,'keyboard',{configurable:true,writable:true,value:oKb});
         else delete navigator.keyboard;
       }catch(_r){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'13.08',what:'the Undercroft is not a raid
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
