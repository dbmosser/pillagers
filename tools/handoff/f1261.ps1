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

# v12.61 CHECK, inserted before the v12.60 entry. Both doors out of the lift are
# driven through the real floor update. The third arm is the one that matters
# most: a night he CHOSE on the page and ascended from the page has to stay
# night, or this build would have taken his choice away instead of giving him
# the default back.
SubRx @'
  {v:'12.60',what:'an Ammo Box bought from the Peddler puts its rounds in the reserve where they can be used, not a brick in the backpack where nothing can touch it, and the line says how many; an ordinary purchase still goes to the backpack and a full backpack no longer refuses ammunition (2026-09-08 audit)',
'@ @'
  {v:'12.61',what:'quick ascent starts at day like the other door does: pressing the ascent key at the lift no longer inherits the surface he chose last raid, the sector page door still resets it, and a night he chooses on the page and ascends from the page is still night (2026-09-08 audit, his answer 24)',
   run:function(){
     if(!(window.__hubEnter&&window.__hb&&window.__keys&&window.__showScreen&&window.__state&&window.__endRaid&&window.__P)) return 'SKIP: this fixture cannot walk the floor';
     if(typeof updateHubWorld!=='function'||typeof isDay!=='function'||typeof startRaid!=='function') return 'SKIP: this build has no floor update, no day test or no raid to start';
     var bad=[], P2=__P(), keepCond=P2.cond;
     function press(code){
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       try{ var g0=__state(); if(g0&&!g0.over){ g0.player.downed=false; __endRaid('abandon'); } }catch(_0){}
       __showScreen('hub'); __hubEnter();
       var HBx=__hb(); if(!HBx||!HBx.stations) return {none:'no floor to stand on'};
       var lift=null, i;
       for(i=0;i<HBx.stations.length;i++) if(HBx.stations[i].id==='lift') lift=HBx.stations[i];
       if(!lift) return {none:'this build has no lift'};
       var K=__keys(), k;
       for(k in K) delete K[k];
       HBx.player.x=lift.x; HBx.player.y=lift.y; HBx.eLock=false;
       P2.cond='night';                       // what he chose on the last raid
       K[code]=1;
       for(i=0;i<6;i++) updateHubWorld(0.05);
       for(k in K) delete K[k];
       try{ var sm=document.getElementById('sectormodal'); if(sm) sm.classList.remove('on'); }catch(_m){}
       return {cond:P2.cond,day:!!isDay()};
     }
     try{
       // THE FINDING: the quick ascent door, which never opened the page.
       var A=press('KeyR');
       if(!A) return 'SKIP: no floor to stand on';
       if(A.none) return 'SKIP: '+A.none;
       if(!A.day)
         bad.push('quick ascent took him up into the surface he chose on the last raid: the ascent key started a raid with the surface still reading '+A.cond+', so the ground, the lamps, the night bonus and the run record all followed a choice he made once and was never asked about again');
       // CONTROL ONE: the page door still resets it, which is what v10.05 shipped
       // and what this build must not have broken.
       var B=press('KeyE');
       if(B&&!B.none&&!B.day)
         bad.push('control: the sector page door no longer resets the surface to day either, so this build has broken the promise instead of extending it');
       // CONTROL TWO, THE ONE THAT MATTERS: a night he CHOSE and ascended from the
       // page must still be night, or the default has become a rule.
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       try{ var g1=__state(); if(g1&&!g1.over){ g1.player.downed=false; __endRaid('abandon'); } }catch(_1){}
       P2.cond='night';
       startRaid();
       if(isDay())
         bad.push('control: a night he chose on the sector page and ascended from the page came up as day, so this build has taken his choice away rather than giving him the default back');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ var K3=__keys(); for(var k3 in K3) delete K3[k3]; }catch(_k){}
       try{ var sm2=document.getElementById('sectormodal'); if(sm2) sm2.classList.remove('on'); }catch(_m2){}
       try{ P2.cond=keepCond; saveProfile(); }catch(_c){}
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       try{ __showScreen('hub'); }catch(_h){}
       __topClear(); __resetCfg(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'12.60',what:'an Ammo Box bought from the Peddler puts its rounds in the reserve where they can be used, not a brick in the backpack where nothing can touch it, and the line says how many; an ordinary purchase still goes to the backpack and a full backpack no longer refuses ammunition (2026-09-08 audit)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
