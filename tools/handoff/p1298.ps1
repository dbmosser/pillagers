$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# FINDING 16 OF THE 2026-09-11 AUDIT. Three places disagreed about one rule, and the
# bar sold him Credits' worth of a bonus it then did not pay.
#
# WHAT HAPPENS. He reads "the bar cuts you off at ten", buys six Liquor and six
# Blotter for $4,920, and the two rows read RAID XP +15% and RAID XP +15%. The in-raid
# conditions panel prints the same two. Every screen he can see says +30%. The raid
# pays +25%, because the bonus counts both kinds TOGETHER and stops at ten.
#
# AND THE GATE IS ON A THIRD BASIS AGAIN. It locks each drink at ten of ITS OWN kind,
# so the station will happily sell twenty doses under a line promising ten.
#
# NO NUMBER MOVES HERE. The cap is still ten, the rate is still 2.5 percent a dose.
# This is drift: the "cuts you off at ten" copy was written at v7.49 to describe the
# per-drink lock, before the combined-cap bonus existed, and the per-row percentage
# was never revisited when it did.
#
# THE FIX IS THAT ONE NUMBER IS SHOWN IN ONE PLACE, computed from the function that
# pays it. Two rows each printing a share of a capped total can always be read as a
# sum the game will not honour, so the rows keep the honest per-drink count and the
# bonus is printed once, live, on the bar line and once on the conditions panel.
SubRx @'
function buzzXpMul(){ var d=buzzDoses('drunk')+buzzDoses('lsd'); return 1+Math.min(d,10)*buzzXpPer(); }
'@ @'
function buzzXpMul(){ var d=buzzTotal(); return 1+Math.min(d,10)*buzzXpPer(); }
// v12.98, audit finding 16: ONE BASIS FOR EVERYTHING THAT COUNTS OR SHOWS A DOSE.
// The bonus has always counted both kinds together and stopped at ten; the bar gate
// counted each drink separately, and the bar and the conditions panel each printed a
// per-drink share of it, so two rows added up to a number no raid ever paid. These
// two are read by the gate and by every figure shown, so they cannot drift apart
// from the function that pays.
function buzzTotal(){ return buzzDoses('drunk')+buzzDoses('lsd'); }
function buzzXpPct(){ return Math.round((buzzXpMul()-1)*1000)/10; }
'@

SubRx @'
    'No tab, no credit. Every dose stacks on the last, and the bar cuts you off at ten. While a dose is in your blood, every XP a raid pays you is '+(Math.round(buzzXpPer()*1000)/10)+'% more per dose.';
'@ @'
    'No tab, no credit. Every dose stacks on the last, and the bar cuts you off at ten of anything. While a dose is in your blood, every XP a raid pays you is '+(Math.round(buzzXpPer()*1000)/10)+'% more per dose.'+
    // v12.98: the live total, once, from the function that pays it. It used to be
    // printed per drink on each row, where two rows read as a sum nothing honours.
    (buzzTotal()?('  IN YOUR BLOOD NOW: '+buzzTotal()+' dose'+(buzzTotal()===1?'':'s')+', RAID XP +'+buzzXpPct()+'%.'):'');
'@

SubRx @'
    var B=BOOZE[i],nB=buzzDoses(B.tag),atCap=nB>=10;
    h+='<div class="row"><div style="flex:1"><b>'+B.name+'</b>'+
       (nB?' <span style="color:#d98aff">IN YOUR BLOOD \u00d7'+nB+'  \u00b7  RAID XP +'+(Math.round(nB*buzzXpPer()*1000)/10)+'%</span>':'')+
'@ @'
    // v12.98: the limit is ten of ANYTHING, which is what the line above the rows has
    // always said and what the bonus has always counted. Per drink, it sold twenty.
    var B=BOOZE[i],nB=buzzDoses(B.tag),atCap=buzzTotal()>=10;
    h+='<div class="row"><div style="flex:1"><b>'+B.name+'</b>'+
       (nB?' <span style="color:#d98aff">IN YOUR BLOOD \u00d7'+nB+'</span>':'')+
'@

SubRx @'
      if(P.credits<B2.price||buzzDoses(B2.tag)>=10) return;
'@ @'
      if(P.credits<B2.price||buzzTotal()>=10) return;
'@

SubRx @'
      rows.push({k:_bzTags[_bq][1]+(_bn>1?(' \u00d7'+_bn):''),v:fmtMS(_bt)+' left, XP +'+(Math.round(_bn*buzzXpPer()*1000)/10)+'%',c:'#d98aff'});
    }
'@ @'
      // v12.98: what is in him and how long it has, per drink, which is true. The
      // bonus is one number for both and is printed once, below.
      rows.push({k:_bzTags[_bq][1]+(_bn>1?(' \u00d7'+_bn):''),v:fmtMS(_bt)+' left',c:'#d98aff'});
    }
    if(buzzTotal()) rows.push({k:'RAID XP',v:'+'+buzzXpPct()+'%',c:'#d98aff'});
'@

# NEW IN.
SubRx @'
  'A RESTORE CODE CARRIES NET LIFETIME EARNINGS.
'@ @'
  'THE LAST POUR SHOWS THE ONE BONUS IT ACTUALLY PAYS. Liquor and Blotter count together and stop at ten, which the bar line always said, but the gate locked each drink at ten of its own kind and each row printed its own share of the bonus, so six of each read as +15% and +15% on every screen against a raid that paid +25%. One number now, in one place, from the function that pays it. No dial moved.',
  'A RESTORE CODE CARRIES NET LIFETIME EARNINGS.
'@

# STAMPS.
SubRx @'
var VER='12.97';
'@ @'
var VER='12.98';
'@
SubRx @'
var WHATSNEW_VER='12.97';
'@ @'
var WHATSNEW_VER='12.98';
'@
$cnt=([regex]::Matches($s,"now:'v12\.97:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v12.97 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v12\.97:[^']*'",{ param($m) "now:'v12.98: finding 16 of the 2026-09-11 audit. Three places disagreed about one rule, and the bar sold him Credits worth of a bonus it then did not pay. He reads that the bar cuts you off at ten, buys six Liquor and six Blotter for 4920, and the two rows read RAID XP plus 15 percent and RAID XP plus 15 percent; the in-raid conditions panel prints the same two, so every screen he can see says plus 30 percent, and the raid pays plus 25 because the bonus counts both kinds TOGETHER and stops at ten. The gate is on a third basis again: it locks each drink at ten of its OWN kind, so the station will happily sell twenty doses under a line promising ten. No number moves here, the cap is still ten and the rate is still 2.5 percent a dose; this is drift, because the cuts you off at ten copy was written at v7.49 to describe the per-drink lock, before the combined-cap bonus existed, and the per-row percentage was never revisited when it did. The fix is that one number is shown in one place, computed from the function that pays it: two rows each printing a share of a capped total can always be read as a sum the game will not honour, so the rows keep the honest per-drink count and the bonus is printed once, live, on the bar line and once on the conditions panel, while the gate now counts the same total the bonus does. Check 12.98 stages six of each and requires no screen to show a figure other than the one the payout function returns, requires the gate to stop selling at ten of anything rather than ten of each, and controls that a single drink still shows its own dose count and that the payout itself is unchanged at both five and twelve doses; fails on v12.97.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
