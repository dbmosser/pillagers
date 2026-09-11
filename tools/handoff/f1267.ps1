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

# v12.67 CHECK, inserted before the v12.66 entry. It sells through the real
# button, with the profile parked one XP short of a level boundary so a single
# sale has to cross it. The gate is asked the same question the racks ask, so
# what is tested is what actually locks a rack. The control is the formula
# itself at three known figures, because this build must move WHERE the level is
# worked out and not WHAT it works out.
SubRx @'
  {v:'12.66',what:'the contract board counts contracts: after one HARD claim the line reads one contract completed rather than the weighted two, and the gate under it asks for credits in its own words while the credit itself is unchanged (2026-09-08 audit, my own wording)',
'@ @'
  {v:'12.67',what:'selling salvage moves the level and the racks it gates, at the counter, instead of leaving the card showing a level that disagrees with the XP printed under it until the next raid ends (2026-09-08 audit)',
   run:function(){
     if(!window.__P) return 'SKIP: this fixture cannot read the profile';
     if(typeof cosOwned!=='function'||typeof ival!=='function') return 'SKIP: this build has no cosmetic gate or no salvage value';
     var sb=document.getElementById('sellall');
     if(!sb) return 'SKIP: this build has no sell button to press';
     var bad=[], P2=__P();
     var keep={xp:P2.xp,xpLevel:P2.xpLevel,credits:P2.credits,stash:(P2.stash||[]).slice(),junk:P2.junk};
     // Something worth enough to cross a boundary on its own, taken off the item
     // table rather than named here, and tagged junk so the button will take it.
     var SELL=null, k;
     for(k in ITEMS){ if(ITEMS[k]&&ival(k)>=60){ SELL=k; break; } }
     if(!SELL) return 'SKIP: nothing in this build is worth enough to cross a level on one sale';
     var GAIN=ival(SELL);
     try{
       __topClear(); __runPrep(); __resetCfg(); __cleanProfile();
       // ONE XP SHORT OF LEVEL TWO, which is 220 by the formula this build does
       // not change, so a single sale has to cross it.
       P2.xp=219; P2.xpLevel=1; P2.credits=0;
       P2.stash=[SELL]; P2.junk={}; P2.junk[SELL]=1;
       if((P2.xpLevel||1)!==1) return 'staging: the profile did not start at level one';
       if(cosOwned({how:'level:2'})) return 'staging: a level two rack is already open at level one, so the gate cannot be read here';
       // v12.67 check repair: re-render the panel after staging, or a second run
       // presses the button over a list that no longer holds the item.
       try{ if(typeof renderStash==="function") renderStash(); else if(typeof renderStage==="function") renderStage(); }catch(_rr){}
       sb.click();
       if((P2.xp||0)!==219+GAIN)
         return 'SKIP: the sell button did not take the '+SELL+' ('+(P2.xp||0)+' XP against an expected '+(219+GAIN)+'), so nothing was sold here';
       // THE FINDING: the XP moved past the boundary, so the level must have too.
       if((P2.xpLevel||1)<2)
         bad.push('selling salvage moved his XP to '+(P2.xp||0)+' and left the level at '+(P2.xpLevel||1)+': the card shows a level that disagrees with the XP printed under it, and he has to go up and come back before it catches up');
       if(!cosOwned({how:'level:2'}))
         bad.push('the racks gated on level two are still locked after he earned level two at the counter, so an unlock he has paid for is being withheld until the next raid ends');
       // CONTROL: the formula itself must be exactly what it was.
       var probe=[[0,1],[220,2],[880,3]], i;
       for(i=0;i<probe.length;i++){
         P2.xp=probe[i][0];
         if(typeof syncXpLevel==='function') syncXpLevel();
         if((P2.xpLevel||1)!==probe[i][1])
           bad.push('control: at '+probe[i][0]+' XP the level reads '+(P2.xpLevel||1)+' and not '+probe[i][1]+', so this build has changed what the level IS rather than when it is worked out');
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ P2.xp=keep.xp; P2.xpLevel=keep.xpLevel; P2.credits=keep.credits;
            P2.stash=keep.stash; P2.junk=keep.junk; saveProfile(); }catch(_p){}
       __topClear(); __resetCfg(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'12.66',what:'the contract board counts contracts: after one HARD claim the line reads one contract completed rather than the weighted two, and the gate under it asks for credits in its own words while the credit itself is unchanged (2026-09-08 audit, my own wording)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
