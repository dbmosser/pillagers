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
  {v:'11.01',what:'the end of raid buttons ask about this game
'@ @'
  {v:'11.02',what:'changing save says why it leaves fullscreen, and says it again on the way back in',
   run:function(){
     var ti=document.getElementById('title');
     if(!ti) return 'SKIP: there is no character screen in this document';
     if(!__vpAlive()) return 'SKIP: the pane has no layout';
     var bad=[], KEY='salvagerun:fsWanted', keepFlag=null;
     try{ keepFlag=localStorage.getItem(KEY); }catch(_lk){}
     var realFsOn=(typeof fsOn==='function')?fsOn:null;
     var wasOn=ti.classList.contains('on');
     try{
       ti.classList.add('on');
       // 1. THE PANEL SAYS WHY, WHERE THE CLICK IS. He asked the question, so the
       //    answer belongs beside the thing that raised it and not in a changelog.
       var panel=document.getElementById('slotpanel');
       var txt=panel?String(panel.textContent||'').toLowerCase():'';
       if(txt.indexOf('reload')<0||txt.indexOf('fullscreen')<0)
         bad.push('the saves panel does not say that changing save reloads the game and drops fullscreen');
       // 2. AND IT REMEMBERS, but only when he was actually in fullscreen. This is
       //    driven by making the game believe it is, which is the only way to test
       //    it: no check can put a browser into real fullscreen without a gesture.
       if(typeof fsMark!=='function'||typeof fsBackNote!=='function')
         return 'the build does not remember that he was in fullscreen when he switched save, so his question has no answer in the game';
       try{ localStorage.removeItem(KEY); }catch(_r1){}
       fsOn=function(){ return false; };
       fsMark();
       var afterNo=null; try{ afterNo=localStorage.getItem(KEY); }catch(_r2){}
       if(afterNo) bad.push('control: switching save while NOT in fullscreen still leaves the note armed, so it would fire for nothing');
       fsOn=function(){ return true; };
       fsMark();
       var afterYes=null; try{ afterYes=localStorage.getItem(KEY); }catch(_r3){}
       if(!afterYes) bad.push('switching save while in fullscreen is not remembered, so the way back is never offered');
       // 3. AND THE WAY BACK IS OFFERED, ONCE. The note belongs to the reload it
       //    came from; a note that stays is a note he stops reading.
       fsOn=function(){ return false; };
       var el=document.getElementById('fsback');
       if(!el) bad.push('there is no line to tell him what happened');
       else {
         var shown=fsBackNote();
         if(!shown) bad.push('the flag was set and the note did not fire');
         if(window.getComputedStyle(el).display==='none') bad.push('the note fired and is not visible');
         var still=null; try{ still=localStorage.getItem(KEY); }catch(_r4){}
         if(still) bad.push('the note did not clear its own flag, so it would appear on every boot from now on');
         fsBackNote();
         if(window.getComputedStyle(el).display!=='none') bad.push('the note is still showing on the next boot, when nothing was switched');
       }
       // 4. CONTROL: and it does not nag him when he is ALREADY back in
       //    fullscreen, which is the one case where the line is noise.
       try{ localStorage.setItem(KEY,'1'); }catch(_r5){}
       fsOn=function(){ return true; };
       fsBackNote();
       var el2=document.getElementById('fsback');
       if(el2&&window.getComputedStyle(el2).display!=='none')
         bad.push('control: the note tells him he lost fullscreen while he is in fullscreen');
     } finally {
       if(realFsOn) fsOn=realFsOn;
       try{ if(keepFlag===null) localStorage.removeItem(KEY); else localStorage.setItem(KEY,keepFlag); }catch(_r6){}
       var e3=document.getElementById('fsback'); if(e3) e3.style.display='none';
       ti.classList.toggle('on',wasOn);
     }
     return bad.length?bad.join('; '):null; }},
  {v:'11.01',what:'the end of raid buttons ask about this game
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
