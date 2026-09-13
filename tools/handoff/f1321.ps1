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

# v13.21 CHECK, inserted before the v13.20 entry.
#
# THE SAME INSTRUMENT AS CHECK 11.32, on purpose. navigator.clipboard is hidden
# with defineProperty and document.execCommand is stubbed, which keeps every
# branch synchronous so the check can read the result without awaiting a promise
# the corpus runner cannot wait for. Both are restored in finally.
#
# THREE ARMS. Refused everywhere must say so and must name Ctrl+C. Accepted must
# say Copied. And refused must NEVER say Copied, which is the silent-success
# shape this file has shipped under other names.
SubRx @'
  {v:'13.20',what:'a run report does not claim to have been saved on a page that cannot save files: embedded says so and points at Copy report, and a normal page still downloads (the game is hosted in an itch iframe, which has no allow-downloads)',
'@ @'
  {v:'13.21',what:'the Recorder Copy button, where a failed Copy report sends the player, says whether the copy worked: Copied when it did, and when every copy route is refused it keeps the report selected and says press Ctrl+C (the only feedback path on itch)',
   run:function(){
     var btn=document.getElementById('copybtn'), ta=document.getElementById('exporttext');
     if(!btn||!ta||typeof btn.onclick!=='function') return 'SKIP: this fixture has no Recorder copy button to press';
     var desc; try{ desc=Object.getOwnPropertyDescriptor(navigator,'clipboard'); }catch(_d){ desc=null; }
     var redefined=false;
     try{ Object.defineProperty(navigator,'clipboard',{value:undefined,configurable:true}); redefined=(navigator.clipboard===undefined); }catch(_x){}
     if(!redefined) return 'SKIP: navigator.clipboard cannot be hidden here, so the button cannot be pressed synchronously';
     var bad=[], origExec=document.execCommand, was=btn.textContent, oldVal=ta.value;
     try{
       ta.value='PILLAGERS REPORT ZQX 5521';

       // ONE: refused everywhere. It must say so, and must say how to get it out.
       document.execCommand=function(){ return false; };
       btn.textContent=was;
       btn.onclick();
       var t1=String(btn.textContent||'');
       if(t1===was)
         bad.push('a refused copy leaves the Recorder button exactly as it was, so the place a failed Copy report sends the player cannot tell him the copy failed either, and on itch that is the last way his run reaches Daniel');
       if(t1.indexOf('Copied')>=0)
         bad.push('a copy refused on every route announces Copied, so he pastes an empty clipboard to Daniel and believes he sent a report');
       if(t1===was||t1.indexOf('Ctrl+C')<0)
         bad.push('when every copy route is refused he is not told the one thing that always works, that the report is selected and Ctrl+C copies it');

       // TWO: accepted. It must say so.
       document.execCommand=function(){ return true; };
       btn.textContent=was;
       btn.onclick();
       var t2=String(btn.textContent||'');
       if(t2.indexOf('Copied')<0)
         bad.push('a copy that worked says nothing, so he cannot tell a working button from a blocked one');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ document.execCommand=origExec; }catch(_r1){}
       try{ if(desc) Object.defineProperty(navigator,'clipboard',desc); else delete navigator.clipboard; }catch(_r2){}
       try{ btn.textContent=was; ta.value=oldVal; }catch(_r3){}
       try{ __topClear(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'13.20',what:'a run report does not claim to have been saved on a page that cannot save files: embedded says so and points at Copy report, and a normal page still downloads (the game is hosted in an itch iframe, which has no allow-downloads)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
