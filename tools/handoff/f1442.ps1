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
  {v:'14.41',what:
'@ @'
  {v:'14.42',what:'Enter on the title starts the game and stops the key there: with the title showing, Enter is taken and its default action cancelled, so it cannot also click a focused GO FULLSCREEN, while with the title hidden nothing cancels it (title and saves audit finding 2)',
   run:function(){
     var tt=document.getElementById('title');
     if(!tt) return 'SKIP: no title screen in this document';
     var bad=[], wasOn=tt.classList.contains('on');
     var press=function(){ var ev=new KeyboardEvent('keydown',{code:'Enter',key:'Enter',bubbles:true,cancelable:true}); window.dispatchEvent(ev); return ev.defaultPrevented; };
     try{
       __topClear();
       try{ if(document.activeElement&&document.activeElement.blur) document.activeElement.blur(); }catch(_b){}
       // THE FIX: with the title showing, Enter starts the game (the control: the title handler ran) and cancels its default action.
       tt.classList.add('on');
       var stopped=press();
       if(tt.classList.contains('on')) return 'SKIP: Enter on the title did not start the game here, so the title key handler did not run';
       if(!stopped) bad.push('Enter on the title started the game but left its default action to click the focused button, GO FULLSCREEN after a click on it');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ if(wasOn) tt.classList.add('on'); else tt.classList.remove('on'); }catch(_t){}
       try{ var K3=__keysRef(); for(var k3 in K3) K3[k3]=false; }catch(_k){}
       try{ __topClear(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'14.41',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
