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
  {v:'10.70',what:'the LOADOUT number counts everything going up: the backpack, the copies on tactical belt keys, and the safe pocket',
'@ @'
  {v:'10.71',what:'the safe pocket says when it is naming something that is not going up, the ascent check names it, and the loadout total counts it once or not at all',
   run:function(){
     var bad=[];
     if(!(window.__hubEnter&&window.__P&&window.__deploy)) return 'SKIP: this build cannot arrive and deploy';
     if(typeof ival!=='function') return 'SKIP: no item values in this build';
     var P2=__P();
     var keep={stash:(P2.stash||[]).slice(),kit:(P2.kit||[]).slice(),hot:P2.hotAssign,safe:P2.safe,free:P2.freeKit};
     function txt(id){ var e=document.getElementById(id); return e?String(e.textContent||'').trim():null; }
     function num(id){ var t=txt(id); if(t===null) return null; var c=t.replace(/[^0-9.-]/g,''); return c===''?null:+c; }
     var A='medkit', B='plate', D='bandage';
     if(!(ITEMS[A]&&ITEMS[B]&&ITEMS[D])) return 'SKIP: this build lacks the items this uses';
     var vD=ival(D);
     if(!(vD>0)) return 'SKIP: the '+D+' is worth nothing, so double counting could not be seen';
     // One arm: set the stash, the backpack and the pocket, then read the floor.
     function arm(kit,safe){
       if(window.__cleanProfile) __cleanProfile();
       P2.freeKit=0; P2.hotAssign={};
       P2.stash=[D,A,B]; P2.kit=kit.slice(); P2.safe=safe;
       try{ saveProfile(); }catch(_s){}
       __hubEnter();
       return {safen:txt('safen'), kitval:num('kitval'), kitn:num('kitn')};
     }
     try{
       // 1. NAMED BUT NOT PACKED. The deploy arms nothing, so the screen must
       //    not read like an armed pocket.
       var away=arm([A,B],D);
       __deploy({kit:[A,B],safe:D,mapIx:0,seed:4242});
       var armedAway=P2.safeUp;
       if(armedAway) bad.push('control: the deploy armed the pocket for an item that was not packed (safeUp='+armedAway+')');
       else if(away.safen==='1/1') bad.push('the pocket names a '+D+' that is not in the backpack, so nothing comes home, and the screen still reads 1/1');
       // 2. NAMED AND PACKED is the working case and must still read as armed.
       var withIt=arm([A,B,D],D);
       __deploy({kit:[A,B,D],safe:D,mapIx:0,seed:4242});
       if(P2.safeUp!==D) bad.push('control: a packed '+D+' did not arm the pocket at deploy (safeUp='+String(P2.safeUp)+')');
       if(withIt.safen!=='1/1') bad.push('a packed and named '+D+' does not read as armed (the screen says '+JSON.stringify(withIt.safen)+')');
       // 3. THE TOTAL COUNTS IT ONCE. Naming an item already in the backpack
       //    must not change what is going up, and naming one that is NOT there
       //    must not add anything either.
       var plain=arm([A,B,D],null);
       if(withIt.kitval!==plain.kitval) bad.push('naming the packed '+D+' as the safe pocket changed the loadout total from '+plain.kitval+' to '+withIt.kitval+', and it is one item either way');
       var bare=arm([A,B],null);
       if(away.kitval!==bare.kitval) bad.push('naming a '+D+' that stays at home added '+(away.kitval-bare.kitval)+' to the loadout total');
       if(plain.kitval!==bare.kitval+vD) bad.push('control: the '+D+' is worth '+vD+' and packing it moved the total from '+bare.kitval+' to '+plain.kitval);
       // 4. THE ASCENT CHECK NAMES IT, and says which of the two it is.
       var st=document.getElementById('stagemodal');
       if(!st||!window.__stage) bad.push('SKIPPABLE: no ascent check to read');
       else{
         arm([A,B,D],D); __stage.render();
         var t1=(st.innerText||'').replace(/\s+/g,' ');
         if(!/safe pocket/i.test(t1)) bad.push('the ascent check never mentions the safe pocket');
         else if(t1.indexOf(ITEMS[D].name)<0) bad.push('the ascent check mentions a safe pocket without naming what is in it');
         arm([A,B],D); __stage.render();
         var t2=(st.innerText||'').replace(/\s+/g,' ');
         if(!/not packed/i.test(t2)) bad.push('the ascent check does not say the safe pocket names something that is not packed');
         arm([A,B],null); __stage.render();
         var t3=(st.innerText||'').replace(/\s+/g,' ');
         if(!/no safe pocket/i.test(t3)) bad.push('the ascent check says nothing when there is no safe pocket at all');
       }
     } finally {
       P2.stash=keep.stash; P2.kit=keep.kit; P2.hotAssign=keep.hot; P2.safe=keep.safe; P2.freeKit=keep.free;
       try{ saveProfile(); }catch(_s2){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'10.70',what:'the LOADOUT number counts everything going up: the backpack and the copies on tactical belt keys',
'@

# v10.70's own check asserted the safe pocket ADDS its value to the total, which
# was the mistake this build corrects. Rewritten to assert the opposite, and the
# rest of it, which was right, is untouched.
SubRx @'
       // 2. THE SAFE POCKET GOES UP TOO, so it is in the number.
       P2.hotAssign={}; P2.safe=D;
       try{ saveProfile(); }catch(_s3){}
       __hubEnter();
       var withSafe=num('kitval');
       if(withSafe!==base+vD) bad.push('the '+D+' in the safe pocket is worth '+vD+' and goes up, and the loadout reads '+withSafe+' instead of '+(base+vD));
'@ @'
       // 2. v10.71: THE SAFE POCKET IS A NAME, NOT AN EXTRA THING CARRIED. It
       //    names one item you are already carrying, so naming one that is not
       //    even packed must not add anything to what is going up. v10.70, mine,
       //    asserted the opposite here and was wrong in both directions.
       P2.hotAssign={}; P2.safe=D;
       try{ saveProfile(); }catch(_s3){}
       __hubEnter();
       var withSafe=num('kitval');
       if(withSafe!==base) bad.push('naming a '+D+' that is not packed changed what is going up from '+base+' to '+withSafe+'; it stays at home');
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
