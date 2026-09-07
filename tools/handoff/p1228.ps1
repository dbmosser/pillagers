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

# HIS NOTE (2026-09-07 morning): "I bought stuff from the peddler and it didn't
# show up in my inventory including an auto rifle". Traced by the 2026-09-07
# read-only notes investigation and verified by reading at v12.27: the purchase
# itself is sound (pedBuy refuses on credits and on weight BEFORE it spends, and
# the spend, the stock mark, the bag push and the line sit on one straight
# line, so credits and bag can never disagree). What goes wrong is WHERE the
# bought thing lands and that nothing says so: autoBelt pins a bought gun or
# stim to the first empty tactical belt cell, his own plan claims anything he
# has bound, and bagStacks then keeps every belt-claimed copy out of the
# backpack grid (v8.78, in one place or the other, never both). So the rifle he
# paid for never appears in the backpack he opens with I; its home is a belt
# cell, and the line said only "Bought Auto Rifle for $2,850." The line names
# the surface now, the way the found-gun line ("to your empty slot") does.
# (His run #11 then ended dead, and a death discards the bag by design.)
SubRx @'
  say('Bought '+ITEMS[st.k].name+' for '+'$'+st.price.toLocaleString()+'.');
'@ @'
  // v12.28, HIS NOTE: "I bought stuff from the peddler and it didn't show up in
  // my inventory including an auto rifle". autoBelt above claims a bought gun or
  // stim for the first empty belt cell, his own plan claims anything he has
  // bound, and the backpack grid keeps a belt-claimed copy off its cells (v8.78),
  // so the rifle he paid for was on the belt and not in the backpack he opened.
  // The line says which surface it is on, as the found-gun line does.
  var _bk=0; if(G.hotAssign) for(var _bi in G.hotAssign) if(G.hotAssign[_bi]===st.k){ _bk=(+_bi)+1; break; }
  say('Bought '+ITEMS[st.k].name+' for '+'$'+st.price.toLocaleString()+'. '+(_bk?('On your tactical belt, key '+_bk+'.'):'In your backpack.'));
'@

# NEW IN.
SubRx @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
'@ @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
  'A PEDDLER PURCHASE NOW SAYS WHERE IT WENT: on your tactical belt, key N, or in your backpack. A bought gun is pinned to a free belt key, and the backpack grid keeps a belted item off its cells, which is why a rifle you paid for was not in the backpack.',
'@

# STAMPS.
SubRx @'
var VER='12.27';
'@ @'
var VER='12.28';
'@
SubRx @'
var WHATSNEW_VER='12.27';
'@ @'
var WHATSNEW_VER='12.28';
'@
$cnt=([regex]::Matches($s,"now:'v12\.27:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v12.27 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v12\.27:[^']*'",{ param($m) "now:'v12.28: his note of 2026-09-07 (Peddler purchases, an Auto Rifle among them, did not show up in the inventory): the purchase is sound, but autoBelt pins a bought gun or stim to the first empty belt cell, his own plan claims anything he has bound, and the backpack grid keeps a belt-claimed copy off its cells, so the rifle he paid for was on the belt and not in the backpack he opened, and the line said only Bought X for Y. The line now says On your tactical belt, key N, or In your backpack. Check 12.28 opens a stall with a fixed stock in a raid, buys a rifle and requires the line to name a belt key, buys a medkit with no key set and requires In your backpack, sets key 6 to medkit and buys another and requires key 6; fails on v12.27. NOT built: the run report line Spent at the stall still does not name what was bought.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
