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
# The counter in the Undercroft takes your credits and says nothing at all. No
# line, no sound. The only sentence it has ever spoken is a failure: a short
# order says how many it could fill, so the one time it talks is the time it
# went wrong. Goods go to the stash rather than the backpack, which is exactly
# the confusion behind his note of 2026-09-07 about a purchase not showing up.
#
# And a gun is worse than silent. Buying one takes your primary slot outright.
# Buy a cheap spare pistol while carrying a Marksman Rifle and the rifle is
# demoted with no word said, and you ascend holding the pistol unless you happen
# to read the ascent panel on the way out.
#
# v12.28 fixed exactly this class of complaint for the Peddler and gave that
# stall a line that names where the thing went. The Undercroft counter was never
# given one, and the same two lines exist twice, here and on the ascent screen.
SubRx @'
function say2(t){ HUBSAY=t; HUBSAY_T=5; hubToast(t); }
'@ @'
function say2(t){ HUBSAY=t; HUBSAY_T=5; hubToast(t); }
// v12.62, 2026-09-08 audit: A COUNTER THAT TAKES MONEY SAYS WHAT IT DID, and
// buying a spare does not quietly demote the gun in your hands. The buy handler
// set the primary slot to whatever was bought, so a cheap pistol bought as a
// spare took the slot from a better gun with nothing said; and the whole
// purchase was silent, so the only sentence that counter ever spoke was a
// failure. Both live in two places, the counter and the ascent screen, so the
// rule is one named thing used by both.
function shopTakeGun(k){
  P.weapons.push(k);
  // Into an empty hand only. A gun you already carry is not replaced by a
  // purchase you never said was a replacement.
  if(!P.equipped||P.equipped==='fists'){ P.equipped=k; return 'It is in your hands.'; }
  return 'It is in the armoury; put it in a hand on the character screen when you want it.';
}
function shopBought(label,price,where){
  say2('Bought '+label+' for '+'$'+(price||0).toLocaleString()+'. '+where);
}
'@

# THE COUNTER.
SubRx @'
        P.credits-=o.price;
        if(o.kind==='wep'){ P.weapons.push(o.k); P.equipped=o.k; }
        else if(o.kind==='pack'){ P.pack=o.lvl; }
        else P.stash.push(o.k);
        saveProfile(); renderShop(); renderHub();
'@ @'
        P.credits-=o.price;
        var _sw,_sn;   // v12.62: where it went, and what to call it
        if(o.kind==='wep'){ _sn=WEAPONS[o.k].name; _sw=shopTakeGun(o.k); }
        else if(o.kind==='pack'){ _sn='Backpack Tier '+(o.lvl+1); P.pack=o.lvl; _sw='You can carry more.'; }
        else { _sn=ITEMS[o.k].name; P.stash.push(o.k); _sw='It is in the stash.'; }
        shopBought(_sn,o.price,_sw);
        saveProfile(); renderShop(); renderHub();
'@

# AND THE SAME COUNTER ON THE ASCENT SCREEN.
SubRx @'
        P.credits-=o.price;
        if(o.kind==='wep'){ P.weapons.push(o.k); P.equipped=o.k; }
        else if(o.kind==='pack'){ P.pack=o.lvl; }
        else { P.stash.push(o.k); if(stageKit().length<DEPLOY_SLOTS) P.kit.push(o.k); }
        saveProfile(); renderStage();
'@ @'
        P.credits-=o.price;
        var _aw,_an;   // v12.62: the same rule and the same line as the counter below
        if(o.kind==='wep'){ _an=WEAPONS[o.k].name; _aw=shopTakeGun(o.k); }
        else if(o.kind==='pack'){ _an='Backpack Tier '+(o.lvl+1); P.pack=o.lvl; _aw='You can carry more.'; }
        else { _an=ITEMS[o.k].name; P.stash.push(o.k);
               if(stageKit().length<DEPLOY_SLOTS){ P.kit.push(o.k); _aw='It is packed for this raid.'; }
               else _aw='It is in the stash; there is no room left in the pack for this raid.'; }
        shopBought(_an,o.price,_aw);
        saveProfile(); renderStage();
'@

# NEW IN.
SubRx @'
  'QUICK ASCENT STARTS AT DAY LIKE THE OTHER DOOR DOES. Pressing R at the lift used to inherit whatever surface you chose last raid, so a night you picked once followed you up every time until you opened the sector page again.',
'@ @'
  'QUICK ASCENT STARTS AT DAY LIKE THE OTHER DOOR DOES. Pressing R at the lift used to inherit whatever surface you chose last raid, so a night you picked once followed you up every time until you opened the sector page again.',
  'THE COUNTER SAYS WHAT IT DID WITH YOUR MONEY, and buying a spare gun no longer takes the slot off the gun in your hands. It said nothing at all on a successful sale, and a cheap pistol bought as a spare quietly demoted your best gun.',
'@

# STAMPS.
SubRx @'
var VER='12.61';
'@ @'
var VER='12.62';
'@
SubRx @'
var WHATSNEW_VER='12.61';
'@ @'
var WHATSNEW_VER='12.62';
'@
$cnt=([regex]::Matches($s,"now:'v12\.61:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v12.61 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v12\.61:[^']*'",{ param($m) "now:'v12.62: from the 2026-09-08 read-only audit, confirmed by a skeptic against the source. The counter in the Undercroft took his credits and said nothing at all, no line and no sound; the only sentence it has ever spoken is a failure, because a short order says how many it could fill, so the one time it talks is the time it went wrong. Goods go to the stash rather than the backpack, which is exactly the confusion behind his note of 2026-09-07 about a purchase not showing up. A gun was worse than silent: buying one took the primary slot outright, so a cheap spare pistol bought while carrying a Marksman Rifle demoted the rifle with no word said and he ascended holding the pistol unless he happened to read the ascent panel on the way out. v12.28 fixed exactly this class for the Peddler and gave that stall a line naming where the thing went; the Undercroft counter was never given one, and the same two lines exist twice, at the counter and on the ascent screen. One named rule used by both now: a bought gun goes into an empty hand only, and every purchase says what it was, what it cost and where it went. Check 12.62 buys a gun while already carrying one and requires the gun in hand to be untouched with the purchase in the armoury and a line saying so, buys one with empty hands and requires it to arrive in them, and buys an ordinary item and requires a line naming the stash; fails on v12.61.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
