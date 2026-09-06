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

# HIS NOTES, 2026-09-06 (his 06:26 and 06:39 exports, runs 4 and 5): "survivor
# should pay more -- don't need to say 'already banked'" and "survivor should
# give you something instantly when you meet his request, not just mark a
# cache". Three times the money (MY number; he gave none), banked as before,
# and something from his own pockets in your hands now, through the same
# grant a container uses, so a full bag is handled the way it always is. The
# review moved the grant ahead of the cache line and folded the money and the
# gift into that one sentence, because say() holds one line and three calls
# in one frame left only the last; and the card names the gift only on an
# extraction, since a death or an abandonment loses the bag it went into.
SubRx @'
  var c=strayReveal();
  if(c){
    c.revealed=1;
    say('He tells you where a cache is. It is on your map.');
    label(e.x,e.y-20,'CACHE MARKED','#e6b4ff',0,true);
  } else {
    say('He has nothing left to tell you, so he gives you what he has.');
  }
  // A little money, banked the way the Peddler banks it: he pays before you
  // have earned the right to survive the trip.
  var pay=ri(260,540);
  P.credits+=pay;
  G.strayPaid=(G.strayPaid||0)+pay;
'@ @'
  // Money, banked the way the Peddler banks it: he pays before you have earned
  // the right to survive the trip. v11.86, HIS NOTES: three times what it was
  // (my number; he said "more"), and something in your hands NOW, not only a
  // mark on the map: one piece of salvage from his own pockets, through the
  // same grant a container uses. The grant goes first so its own Found line
  // is the one that gets overwritten; say() holds one line, so what he did is
  // one sentence, built below and appended to the cache line.
  var pay=ri(900,1500);
  P.credits+=pay;
  G.strayPaid=(G.strayPaid||0)+pay;
  var gift=pick(['titan','core','optic','servo']);
  try{ grantLoot(mkContainer(e.x,e.y,'crate'),[gift]); G.strayGave=gift; }catch(_sg){}
  var _tail=' He pays you $'+pay.toLocaleString()+(G.strayGave?' and presses a '+ITEMS[gift].name+' into your hands.':'.');
  var c=strayReveal();
  if(c){
    c.revealed=1;
    say('He tells you where a cache is. It is on your map.'+_tail);
    label(e.x,e.y-20,'CACHE MARKED','#e6b4ff',0,true);
  } else {
    say('He has nothing left to tell you, so he gives you what he has.'+_tail);
  }
'@
SubRx @'
    lines.push('<span style="color:var(--coolant)">The survivor paid you '+'$'+G.strayPaid.toLocaleString()+', already banked.</span>');
'@ @'
    // v11.86, HIS NOTE: no "already banked"; and the gift, on the card of a run
    // that brought it home (a death or an abandonment lost the bag it went into).
    lines.push('<span style="color:var(--coolant)">The survivor paid you '+'$'+G.strayPaid.toLocaleString()+
      (how==='extract'&&G.strayGave&&ITEMS[G.strayGave]?' and gave you a '+escHtml(ITEMS[G.strayGave].name):'')+'.</span>');
'@
# Two comments that stated the old numbers.
SubRx @'
  // pays 260 to 540, the in-raid Peddler pays whatever you fence, the merc's cut
'@ @'
  // pays 900 to 1500 (v11.86), the in-raid Peddler pays whatever you fence, the merc's cut
'@
SubRx @'
// What he pays with is the interesting part. Not much money: he tells you where
'@ @'
// v11.86, HIS NOTES: three times the money and a piece of salvage in hand as
// well; the cache is still marked. The paragraph below is the original design.
// What he pays with is the interesting part. Not much money: he tells you where
'@

# STAMPS.
SubRx @'
var VER='11.85';
'@ @'
var VER='11.86';
'@
SubRx @'
var WHATSNEW_VER='11.85';
'@ @'
var WHATSNEW_VER='11.86';
'@
SubRx @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
'@ @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
  'THE SURVIVOR PAYS THREE TIMES AS MUCH and hands you a piece of salvage on the spot when you meet his request.',
'@
$cnt=([regex]::Matches($s,"now:'v11\.85:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v11.85 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v11\.85:[^']*'",{ param($m) "now:'v11.86: HIS NOTES of 2026-09-06, the survivor should pay more, give something instantly when his request is met, and the card should not say already banked. He pays 900 to 1500 (was 260 to 540; my number), hands over one piece of salvage through the same grant a container uses, one sentence says all of it, and the card names the gift on an extraction. Check 11.86 stages a survivor who wants a bandage, hands it over through strayGive, requires the pay at 900 or more, the gift in the bag, and the card line without the old wording; fails on v11.85.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
