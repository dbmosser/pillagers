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
  {v:'15.10',what:
'@ @'
  {v:'15.11',what:'the packing set aside for the freebie kit does not outlive its raid: a load clears it, an instant quit on a freebie raid clears it, and a later death with no freebie kit taken does not say packed items are in the stash (quit audit finding 9)',
   run:function(){
     if(!(window.__deploy&&window.__startRaid&&window.__state&&window.__endRaid&&window.__P&&window.__applyLoaded)) return 'SKIP: this fixture cannot deploy';
     if(typeof commitKit!=='function'||typeof elapsed!=='function'||!ITEMS.medkit||!ITEMS.bandage||!ITEMS.stim) return 'SKIP: no freebie kit commit or items in this build';
     var man=document.getElementById('oc_manifest'), oc=document.getElementById('outcome');
     if(!man||!oc) return 'SKIP: this build has no outcome card in the page';
     var bad=[], snap=null, g=null, g2=null;
     var LIST=['medkit','medkit','bandage'];
     var needle='before choosing the '+'freebie kit';
     var held=function(){ var q=__P(); return (q&&q.kitBeforeFree&&q.kitBeforeFree.length)?q.kitBeforeFree.length:0; };
     // A later control that cannot run keeps a failure already found, so the old build fails rather than skips.
     var skip=function(m){ return bad.length?(bad.join('; ')+' (then SKIP: '+m+')'):('SKIP: '+m); };
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       snap=JSON.parse(JSON.stringify(__P()));
       // ONE: a save that still holds the list, as a raid lost to a closed tab leaves it, is loaded.
       var s2=JSON.parse(JSON.stringify(__P())); s2.kitBeforeFree=LIST.slice(); s2.raidSpliced=[];
       var p0=__P();
       __applyLoaded(s2);
       // CONTROL: the loader replaced the profile and ran the block that settles a raid the page lost.
       if(__P()===p0||__P().raidSpliced!==undefined) return skip('the loader did not take the staged save here');
       if(held()) bad.push('a loaded save still holds the '+held()+' items packed before a freebie kit taken on a raid the page lost');
       // TWO: the freebie kit is taken over a real packing, and the freebie raid is quit in its first moments.
       __resetCfg(); __pinDefaults(0); __cleanProfile();
       var q=__P(); q.kitBeforeFree=null; q.kit=[]; q.dropKit=[]; q.kitChosen=0; q.stash=LIST.slice(); q.kitSaved={kit:LIST.slice(),hot:{}}; q.freeKit=1;
       commitKit();
       // CONTROL: the commit set the packing aside.
       if(held()!==LIST.length) return skip('taking the freebie kit did not set the packing aside here ('+held()+')');
       __startRaid({mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player) return skip('no live raid');
       if(CFG.raidSec>0) g.timeLeft=(g.raidLen===undefined?CFG.raidSec:g.raidLen); else g.t=0;
       var T0=g.tel||{}, runs0=__P().runs||0;
       // CONTROL: the raid went up on the freebie kit with the list still set aside, and it is an instant quit: no time on the clock, no steps, nothing looted, nothing fired.
       if(g.freeKit!==1) return skip('this raid did not go up on the freebie kit here');
       if(held()!==LIST.length) return skip('the list did not survive the ascent here');
       if(!(elapsed()<1.5&&(T0.distance||0)<8&&T0.containers===0&&T0.shots===0)) return skip('this raid is not an instant quit here (elapsed '+elapsed()+', distance '+T0.distance+')');
       __endRaid('abandon');
       // CONTROL: the abandon was thrown away as never having happened.
       if(g.over!=='abandon'||__state()!==null||(__P().runs||0)!==runs0) return skip('the abandon was not an instant quit here');
       if(held()) bad.push('an instant quit on a freebie raid kept the '+held()+' items packed before the freebie kit, so the next death counts them');
       // THREE: his own kit goes up with no freebie kit taken, and he dies. The card is what he reads.
       __resetCfg(); __pinDefaults(0);
       __deploy({kit:['stim'],stash:['stim','medkit','medkit','medkit','medkit','bandage','bandage'],safe:null,mapIx:0,seed:4242});
       g2=__state(); if(!g2||!g2.player) return skip('no live raid for the death');
       var have={}, st=__P().stash||[], cnt=0, i;
       for(i=0;i<st.length;i++) have[st[i]]=(have[st[i]]||0)+1;
       for(i=0;i<LIST.length;i++) if((have[LIST[i]]||0)>0){ have[LIST[i]]--; cnt++; }
       // CONTROL: the stash holds copies of the old packing, so a stale list has something to count, and this is not a freebie raid.
       if(!cnt) return skip('the stash held none of the packed items, so the card line could not show');
       if(g2.freeKit) return skip('this raid went up on the freebie kit, so the line would be true');
       man.innerHTML='';
       __endRaid('dead');
       var txt=String(man.textContent||'');
       // CONTROL: the raid ended as a death and its card was drawn.
       if(g2.over!=='dead'||!oc.classList.contains('on')||!txt.length) return skip('the death card was not drawn here');
       var at=txt.indexOf(needle);
       if(at>=0) bad.push('a death on a raid with no freebie kit taken says: '+txt.slice(Math.max(0,at-40),at+90));
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ var gl=__state(); if(gl&&!gl.over) __endRaid('abandon'); }catch(_e){}
       try{ if(snap) __applyLoaded(snap); }catch(_r){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'15.10',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
