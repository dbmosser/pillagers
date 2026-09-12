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

# v13.18 CHECK, inserted before the v13.17 entry.
#
# IT CLICKS THE REAL BUTTON TWICE. The fault is not visible in any single
# purchase; it is that the second one works. So the check measures a CHANGE
# across two presses rather than a state after one, which is the rule this file
# has written down three times under "measure a rise, never a level".
#
# IT RESTORES THE PROFILE IT SPENT. Every later check in the corpus runs on the
# profile this one leaves behind, and a check that quietly empties his credits
# would show up as somebody else's unrelated red.
SubRx @'
  {v:'13.17',what:'B backs out of whatever is in front, in the Undercroft and in a raid, and a B with nothing open does not raise the pause box (his note of 2026-09-12, since Escape is not working for him)',
'@ @'
  {v:'13.18',what:'the Limited Time Offer is limited: once bought it is gone from the counter for that window, and pressing Buy again takes nothing more (his note of 2026-09-12)',
   run:function(){
     if(typeof renderWirtLot!=='function'||typeof wirtLotKey!=='function'||typeof WIRT_LOT_PRICE==='undefined')
       return 'SKIP: this fixture cannot reach the counter';
     var bad=[];
     var _cr=P.credits, _st=(P.stash||[]).slice(), _gl=(P.gambleLog||[]).slice(), _wb=P.wirtLotBought;
     try{
       var lot=wirtLotKey();
       if(!lot||!lot.length||!ITEMS[lot[0]]) return 'SKIP: the counter is empty this window';
       P.wirtLotBought=undefined;
       P.credits=WIRT_LOT_PRICE*4;
       P.stash=[];
       renderWirtLot();
       var b1=document.getElementById('wirtlotbtn');
       if(!b1||b1.disabled) return 'SKIP: the counter drew no live Buy button to press';

       var c0=P.credits, s0=P.stash.length;
       b1.click();
       var c1=P.credits, s1=P.stash.length;
       if(!(c1<c0)) return 'SKIP: the first purchase took nothing, so there is no second purchase to test';
       if(!(s1>s0)) return 'SKIP: the first purchase banked nothing, so there is no second purchase to test';

       // AND AGAIN. This is the whole finding: the second press must do nothing.
       renderWirtLot();
       var b2=document.getElementById('wirtlotbtn');
       if(b2&&!b2.disabled){
         b2.click();
         if(P.credits<c1)
           bad.push('the Limited Time Offer can be bought again the moment it is bought, so it is not limited at all and a man with credits can stand at the counter and drain them into the same lot until the clock turns');
         if(P.stash.length>s1)
           bad.push('buying the same offer twice banks the lot twice, so one limited offer is an unlimited supply for as long as its window lasts');
         if(bad.length===0)
           bad.push('the counter still offers a live Buy button for an offer already bought, so the press does nothing and says nothing, which reads as a broken button');
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       // PUT BACK WHAT THIS SPENT. Every later check runs on this profile.
       try{ P.credits=_cr; P.stash=_st; P.gambleLog=_gl; P.wirtLotBought=_wb;
            if(typeof saveProfile==='function') saveProfile();
            renderWirtLot(); }catch(_r){}
       try{ __topClear(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'13.17',what:'B backs out of whatever is in front, in the Undercroft and in a raid, and a B with nothing open does not raise the pause box (his note of 2026-09-12, since Escape is not working for him)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
