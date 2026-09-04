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
  {v:'10.68',what:'a gun found in a raid fills the empty second slot instead of shoving the gun out of his hands, and with both slots full it still replaces the gun in his hands',
'@ @'
  {v:'10.69',what:'the briefing says how many of its cards are still under the fold, the line scrolls to them, and it goes quiet at the end',
   run:function(){
     var bad=[];
     if(typeof renderPrimer!=='function'||typeof openPrimer!=='function') return 'SKIP: no briefing in this build';
     if(!window.__vpAlive||!__vpAlive()) return 'SKIP: the page is not laid out';
     var pm=document.getElementById('primermodal');
     var host=document.getElementById('primerlist');
     if(!pm||!host) return 'SKIP: this build has no briefing card';
     var mo=document.getElementById('primermore');
     if(!mo) return 'the briefing has no line telling him there is more below';
     var P2=__P(), keepOff=P2.primerOff, keepSeen=P2.primerSeen;
     var wasOn=pm.classList.contains('on');
     function hidden(){
       var box=host.getBoundingClientRect(), k=0;
       for(var i=0;i<host.children.length;i++){
         if(host.children[i].getBoundingClientRect().top>=box.bottom-4) k++;
       }
       return k;
     }
     function shown(){ return mo.classList.contains('show')&&mo.getBoundingClientRect().height>0; }
     try{
       P2.primerOff=false; P2.primerSeen=0;
       openPrimer();
       if(!pm.classList.contains('on')) return 'SKIP: the briefing would not open';
       var cards=host.children.length;
       if(cards<4) return 'SKIP: only '+cards+' cards in the briefing, nothing could be under the fold';
       var n0=hidden();
       if(host.scrollHeight<=host.clientHeight+4){
         // Nothing is hidden at this size, so the only thing to prove is silence.
         if(shown()) bad.push('the whole briefing fits and it still claims there is more below');
       } else {
         if(n0<1) bad.push('control: the list is '+host.scrollHeight+' tall in a '+host.clientHeight+' box and yet no card reads as hidden');
         if(!shown()) bad.push(n0+' of the '+cards+' briefing cards are under the fold and nothing on the card says so');
         var said=/(\d+) more below/.exec(mo.textContent||'');
         if(!said) bad.push('the line does not say how many are below (it reads '+JSON.stringify((mo.textContent||'').slice(0,60))+')');
         else if(+said[1]!==n0) bad.push('the line says '+said[1]+' more below and '+n0+' cards are actually hidden');
         // CLICKING IT MOVES THE LIST. A cue he cannot act on is only half of it.
         var top0=host.scrollTop;
         if(typeof mo.onclick!=='function') bad.push('the line is not clickable');
         else{
           mo.onclick();
           if(host.scrollTop<=top0) bad.push('clicking the line did not move the list (still at '+host.scrollTop+')');
           if(hidden()>=n0) bad.push('clicking the line did not bring any new card into view');
         }
         // AND IT GOES QUIET AT THE END, or it is a nag rather than a signal.
         host.scrollTop=host.scrollHeight;
         primerCue();
         if(hidden()>0) bad.push('control: scrolled to the bottom and '+hidden()+' cards still read as hidden');
         else if(shown()) bad.push('at the bottom of the list it still says there is more below');
       }
       // THE BAR IS WIDE ENOUGH TO SEE. Measured on v10.68 at 7 pixels including
       // its border, which is what made the list read as a full page.
       var bar=host.offsetWidth-host.clientWidth;
       if(bar<10) bad.push('the briefing scrollbar is '+bar+' pixels wide, which is not a signal');
     } finally {
       host.scrollTop=0;
       try{ primerCue(); }catch(_pc){}
       if(!wasOn) pm.classList.remove('on');
       P2.primerOff=keepOff; P2.primerSeen=keepSeen;
       try{ saveProfile(); }catch(_sv){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'10.68',what:'a gun found in a raid fills the empty second slot instead of shoving the gun out of his hands, and with both slots full it still replaces the gun in his hands',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
