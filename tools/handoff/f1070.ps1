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
  {v:'10.69',what:'the briefing says how many of its cards are still under the fold, the line scrolls to them, and it goes quiet at the end',
'@ @'
  {v:'10.70',what:'the LOADOUT number counts everything going up: the backpack, the copies on tactical belt keys, and the safe pocket',
   run:function(){
     var bad=[];
     if(!(window.__hubEnter&&window.__P)) return 'SKIP: this build cannot arrive on the floor';
     if(typeof ival!=='function') return 'SKIP: no item values in this build';
     var P2=__P();
     var keep={stash:(P2.stash||[]).slice(),kit:(P2.kit||[]).slice(),
               hot:P2.hotAssign,safe:P2.safe};
     function num(id){ var e=document.getElementById(id); if(!e) return null;
       var t=String(e.textContent||'').replace(/[^0-9.-]/g,''); return t===''?null:+t; }
     // Distinctive on purpose: three items whose values differ, so no total can
     // be right by accident and the delta names which one moved.
     var A='medkit', B='plate', C='servo', D='bandage';
     if(!(ITEMS[A]&&ITEMS[B]&&ITEMS[C]&&ITEMS[D])) return 'SKIP: this build does not have the four items this uses';
     var vA=ival(A), vD=ival(D);
     if(!(vA>0)||!(vD>0)) return 'SKIP: '+A+' or '+D+' is worth nothing, so nothing could be seen to go missing';
     try{
       P2.stash=[A,B,C,D]; P2.kit=[A,B,C]; P2.hotAssign={}; P2.safe=null;
       try{ saveProfile(); }catch(_s){}
       __hubEnter();
       var base=num('kitval'), packed=num('kitn');
       if(base===null) return 'SKIP: the loadout panel has no value on it';
       if(packed!==3) return 'SKIP: the backpack did not take the three items (it holds '+packed+')';
       // 1. PUTTING IT ON A KEY MOVES NOTHING OUT OF THE LOADOUT.
       P2.hotAssign={'3':A};
       try{ saveProfile(); }catch(_s2){}
       __hubEnter();
       var onKey=num('kitval');
       if(onKey!==base) bad.push('putting the '+A+' on a key changed what is going up from '+base+' to '+onKey+', and it is worth '+vA+'; it still goes up');
       if(num('kitn')!==2) bad.push('control: the backpack grid did not drop to 2 when one of the three went on a key (it says '+num('kitn')+')');
       if(num('quickn')!==1) bad.push('control: nothing reads as being on a key');
       // 2. THE SAFE POCKET GOES UP TOO, so it is in the number.
       P2.hotAssign={}; P2.safe=D;
       try{ saveProfile(); }catch(_s3){}
       __hubEnter();
       var withSafe=num('kitval');
       if(withSafe!==base+vD) bad.push('the '+D+' in the safe pocket is worth '+vD+' and goes up, and the loadout reads '+withSafe+' instead of '+(base+vD));
       // 3. CONTROL: the number is not simply frozen. Taking a real item out of
       //    the backpack must still move it, or every assertion above passes on
       //    a number that never changes.
       P2.safe=null; P2.kit=[B,C];
       try{ saveProfile(); }catch(_s4){}
       __hubEnter();
       var less=num('kitval');
       if(less!==base-vA) bad.push('control: leaving the '+A+' behind should take '+vA+' off the total, and it reads '+less+' against '+base);
     } finally {
       P2.stash=keep.stash; P2.kit=keep.kit; P2.hotAssign=keep.hot; P2.safe=keep.safe;
       try{ saveProfile(); }catch(_s5){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'10.69',what:'the briefing says how many of its cards are still under the fold, the line scrolls to them, and it goes quiet at the end',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
