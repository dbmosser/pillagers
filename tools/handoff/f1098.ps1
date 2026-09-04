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
  {v:'10.97',what:'nothing the game wants is classified as salvage
'@ @'
  {v:'10.98',what:'every control on the character screen can be pressed without throwing, and renaming your pillager updates the line under the title',
   run:function(){
     var ti=document.getElementById('title');
     if(!ti) return 'SKIP: there is no character screen in this document';
     if(!window.__P) return 'SKIP: this fixture cannot reach the profile';
     if(!__vpAlive()) return 'SKIP: the pane has no layout, so no click can land';
     var bad=[], prof=__P();
     var keepName=prof.pname, keepRuns=prof.runs, wasOn=ti.classList.contains('on');
     // THE CRASH HE REPORTED, FROM HIS OWN LOG: pressing SAVE on the name threw
     // ReferenceError four times, saved the name, and never updated the line.
     // Errors inside a DOM handler do not propagate to the caller, so a check
     // that just clicks and carries on would see nothing. It listens.
     var caught=[];
     function onErr(ev){ caught.push(String((ev&&ev.message)||ev)); }
     window.addEventListener('error',onErr);
     try{
       ti.classList.add('on');
       prof.runs=Math.max(1,prof.runs||0);        // the line only draws with a run logged
       var pin=document.getElementById('pnamein'), psv=document.getElementById('pnamesave');
       var sub=document.getElementById('titlesub');
       if(!pin||!psv) return 'SKIP: this build has no rename control on the character screen';
       if(!sub) return 'SKIP: this build draws no name line under the title';
       // Distinctive on purpose: a name the fallback could never produce, so a
       // line that happens to say PILLAGER cannot pass for a rename.
       var want='ZQXNAME'+(prof.runs);
       sub.textContent='';
       pin.value=want;
       psv.click();
       if(caught.length) bad.push('renaming your pillager threw: '+caught.join(' / '));
       if(prof.pname!==want) bad.push('the rename did not take, the profile says '+prof.pname);
       if(String(sub.textContent).indexOf(want)<0)
         bad.push('the line under the title still reads '+(sub.textContent||'nothing')+' after the rename');
       // CONTROL ONE: the listener has to be able to hear a throw, or the first
       // assertion above is decoration.
       var heard=caught.length;
       var boom=document.createElement('button');
       boom.onclick=function(){ throw new Error('zqx control throw'); };
       document.body.appendChild(boom);
       try{ boom.click(); }catch(_bc){}
       document.body.removeChild(boom);
       if(caught.length===heard) bad.push('control: a deliberate throw inside a click was not heard, so this check cannot see his crash');
       caught.length=0;
       // CONTROL TWO: and every other button on that screen survives a press.
       // His crash was one handler out of several and nothing was watching any
       // of them.
       var btns=ti.querySelectorAll('button'), pressed=0;
       for(var i=0;i<btns.length;i++){
         var b=btns[i], id=b.id||'';
         if(id==='titlestart'||id==='titlefs') continue;      // one leaves the screen, one needs a real gesture
         if(b.getAttribute('data-del')) continue;             // arms a deletion
         if(id==='delgo') continue;                           // erases a save
         try{ b.click(); pressed++; }catch(e){ bad.push('pressing '+(id||'a button')+' on the character screen threw: '+e.message); }
       }
       if(caught.length) bad.push('a button on the character screen threw: '+caught.join(' / '));
       if(pressed<1) bad.push('control: no button on the character screen was pressable, so nothing was tested');
     } finally {
       window.removeEventListener('error',onErr);
       prof.pname=keepName; prof.runs=keepRuns;
       try{ saveProfile(); }catch(_sp){}
       ti.classList.toggle('on',wasOn);
     }
     return bad.length?bad.join('; '):null; }},
  {v:'10.97',what:'nothing the game wants is classified as salvage
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
