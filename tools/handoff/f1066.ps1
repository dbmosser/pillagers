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
  {v:'10.65',what:'the end of raid card can copy the report: the button is there, it logs the raid it just played into the text, it cannot log it twice, and it leaves the card open',
'@ @'
  {v:'10.66',what:'a brand new character meets the welcome pack and then the primer, one at a time, and the primer is still owed after a first raid instead of being stamped away unread',
   run:function(){
     var bad=[];
     if(!(window.__hubEnter&&window.__P)) return 'SKIP: this build cannot arrive on the floor';
     var P2=__P();
     function openIds(){ return Array.prototype.map.call(document.querySelectorAll('.modal.on'),function(e){ return e.id; }); }
     function shut(){ Array.prototype.forEach.call(document.querySelectorAll('.modal.on'),function(e){ e.classList.remove('on'); }); }
     var keep={welcomed:P2.welcomed,runs:P2.runs,stash:(P2.stash||[]).slice(),weapons:(P2.weapons||[]).slice(),
               credits:P2.credits,primerSeen:P2.primerSeen,primerOff:P2.primerOff,shareAsked:P2.shareAsked};
     function fresh(){
       shut();
       P2.welcomed=0; P2.runs=0; P2.stash=[]; P2.weapons=[]; P2.credits=0;
       P2.primerSeen=0; P2.primerOff=false;
       try{ saveProfile(); }catch(_s){}
     }
     try{
       // 1. ARRIVAL on a brand new save: the welcome pack, and nothing on top of it.
       fresh();
       __hubEnter();
       var first=openIds();
       if(first.indexOf('welcomemodal')<0) bad.push('a new character does not meet the welcome pack on arrival (open: '+first.join(',')+')');
       if(first.length>1) bad.push('a new character meets '+first.length+' windows at once on arrival: '+first.join(','));
       // 2. TAKING THE PACK hands over to the primer instead of ending it there.
       var take=document.getElementById('welcometake');
       if(!take) return 'SKIP: this build has no welcome pack button';
       take.onclick();
       var second=openIds();
       if(second.indexOf('primermodal')<0) bad.push('closing the welcome pack does not bring up FIRST TIME OUT (open: '+(second.join(',')||'nothing')+')');
       if(second.length>1) bad.push('closing the welcome pack opened '+second.length+' windows: '+second.join(','));
       // 3. The pack still arrived: this is the queue, not a swap.
       if(!(P2.stash||[]).length) bad.push('taking the pack put nothing in the stash');
       if(!(P2.weapons||[]).length) bad.push('taking the pack put no gun in the armoury');
       // 4. CLOSING THE PACK the other way does the same.
       fresh();
       __hubEnter();
       var no=document.getElementById('welcomeno');
       if(no){ no.onclick();
         var third=openIds();
         if(third.indexOf('primermodal')<0) bad.push('closing the pack with CLOSE does not bring up FIRST TIME OUT (open: '+(third.join(',')||'nothing')+')');
       }
       // 5. A NEW PLAYER WHO GOES STRAIGHT UP still meets the primer when he
       //    comes back down. This is the one that was silently lost.
       fresh();
       __hubEnter();          // pack up
       shut();                 // he closes it and walks to the lift
       P2.welcomed=1; P2.runs=1; try{ saveProfile(); }catch(_s2){}
       __hubEnter();          // back from his first raid
       var fourth=openIds();
       if(fourth.indexOf('primermodal')<0) bad.push('after one raid the primer is gone unread (open: '+(fourth.join(',')||'nothing')+', seen flag '+P2.primerSeen+')');
       // 6. And it does stop eventually, or it becomes a nag.
       shut();
       P2.runs=9; P2.primerSeen=0; try{ saveProfile(); }catch(_s3){}
       __hubEnter();
       if(openIds().indexOf('primermodal')>=0) bad.push('the primer still opens for a player with nine raids behind him');
     } finally {
       shut();
       P2.welcomed=keep.welcomed; P2.runs=keep.runs; P2.stash=keep.stash; P2.weapons=keep.weapons;
       P2.credits=keep.credits; P2.primerSeen=keep.primerSeen; P2.primerOff=keep.primerOff; P2.shareAsked=keep.shareAsked;
       try{ saveProfile(); }catch(_s4){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'10.65',what:'the end of raid card can copy the report: the button is there, it logs the raid it just played into the text, it cannot log it twice, and it leaves the card open',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
