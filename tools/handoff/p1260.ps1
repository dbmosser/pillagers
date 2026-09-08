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

# FROM THE 2026-09-08 READ-ONLY AUDIT, confirmed by a skeptic against the source.
#
# Ammunition never lives in the backpack anywhere else in the game. Every other
# path that hands you a box puts the rounds straight into the reserve, which is
# the single pool the spec calls for, and the box itself stops existing. The
# Peddler is the one path that pushes the key into the backpack instead, and
# nothing in the game consumes it there: the belt use verb handles a throwable,
# a heal, a stim, armour and a gun, and then falls through to "valuables are
# carried, not used" and returns without a word.
#
# So run dry mid-raid, walk to the stall, buy the Ammo Box, and the reserve does
# not move. You paid 171 credits at the exact moment you had nothing to shoot
# with, for a one weight brick worth 90 back if you live. The toast says
# "In your backpack", and the item's own description promises it refills a
# magazine, so you will buy it again.
#
# I audited pedBuy myself at v12.28 and wrote that it was sound. I checked that
# what he bought arrived somewhere; I never asked whether he could use it.
SubRx @'
  var cap=PACKCAP[P.pack],wt=(ITEMS[st.k]?ITEMS[st.k].wt:1);
  if(bagWeight()+wt>cap){ say('No room in the backpack for that.'); return; }
  P.credits-=st.price; saveProfile();
  st.sold=true; G.bag.push(st.k); autoBelt(st.k); G.trade.traded=1;
'@ @'
  var cap=PACKCAP[P.pack],wt=(ITEMS[st.k]?ITEMS[st.k].wt:1);
  // v12.60, 2026-09-08 audit: AMMUNITION GOES WHERE AMMUNITION GOES. Every other
  // path that hands him a box puts the rounds into the reserve, which is the one
  // pool the spec asks for, and the box stops existing. This one pushed the key
  // into the backpack, where nothing in the game can consume it: the belt use
  // verb knows a throwable, a heal, a stim, armour and a gun, and falls past an
  // ammo box without a word. He paid at the exact moment he had nothing to shoot
  // with and got a brick. The weight test is skipped for it too, because rounds
  // in the reserve take no room in a backpack, and a full backpack must not stop
  // a man buying ammunition.
  var _pAmmo=!!(ITEMS[st.k]&&ITEMS[st.k].use==='ammo');
  if(!_pAmmo&&bagWeight()+wt>cap){ say('No room in the backpack for that.'); return; }
  P.credits-=st.price; saveProfile();
  st.sold=true; G.trade.traded=1;
  if(_pAmmo){ var _pp=G.player; _pp.reserve=(_pp.reserve||0)+(ITEMS[st.k].amt||0); }
  else { G.bag.push(st.k); autoBelt(st.k); }
'@

SubRx @'
  say('Bought '+ITEMS[st.k].name+' for '+'$'+st.price.toLocaleString()+'. '+(_bk?('On your tactical belt, key '+_bk+'.'):'In your backpack.'));
'@ @'
  say('Bought '+ITEMS[st.k].name+' for '+'$'+st.price.toLocaleString()+'. '+
      (_pAmmo?((ITEMS[st.k].amt||0)+' rounds into your reserve.')
             :(_bk?('On your tactical belt, key '+_bk+'.'):'In your backpack.')));   // v12.60: say where the rounds actually went
'@

# NEW IN.
SubRx @'
  'THE OPEN BACKPACK STOPS THE FLOOR. Reading it in the Undercroft used to leave every station live underneath: standing on the lift and pressing R started a raid from behind the panel, with no sector page, no day reset and no question about what you were taking up.',
'@ @'
  'THE OPEN BACKPACK STOPS THE FLOOR. Reading it in the Undercroft used to leave every station live underneath: standing on the lift and pressing R started a raid from behind the panel, with no sector page, no day reset and no question about what you were taking up.',
  'AN AMMO BOX FROM THE PEDDLER ACTUALLY GIVES YOU ROUNDS. It went into your backpack, where nothing in the game can use it, so you paid at the moment you were dry and got a brick. It goes into your reserve now, like every other box in the game, and the line says how many.',
'@

# STAMPS.
SubRx @'
var VER='12.59';
'@ @'
var VER='12.60';
'@
SubRx @'
var WHATSNEW_VER='12.59';
'@ @'
var WHATSNEW_VER='12.60';
'@
$cnt=([regex]::Matches($s,"now:'v12\.59:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v12.59 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v12\.59:[^']*'",{ param($m) "now:'v12.60: from the 2026-09-08 read-only audit, confirmed by a skeptic against the source. Ammunition never lives in the backpack anywhere else in the game: every other path that hands him a box puts the rounds straight into the reserve, which is the single pool the spec calls for, and the box itself stops existing. The Peddler is the one path that pushed the key into the backpack instead, and nothing in the game consumes it there, because the belt use verb knows a throwable, a heal, a stim, armour and a gun and then falls past an ammo box without a word. So he ran dry mid-raid, walked to the stall, paid 171 credits at the exact moment he had nothing to shoot with, and the reserve did not move: he had bought a one weight brick worth 90 back if he lived, while the toast said In your backpack and the item description promised it refills a magazine, so he would buy it again. The rounds go into the reserve now, the line says how many, and the weight test is skipped for ammunition because rounds take no room in a backpack and a full backpack must not stop a man buying them. I audited pedBuy myself at v12.28 and wrote that it was sound: I checked that what he bought arrived somewhere and never asked whether he could use it. Check 12.60 stands him at the stall with an empty reserve, buys the Ammo Box through the real purchase, and requires the reserve to rise by the boxs own count with nothing left in the backpack, with a control that an ordinary item still lands in the backpack and one that a full backpack no longer refuses ammunition; fails on v12.59.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
