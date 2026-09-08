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
# A contract whose whole physical payout is a gun pays nothing at all if you have
# acquired that gun since the card was written, and the receipt says it paid.
#
# The gear is rolled ONCE, when the card is made, and the roll refuses a gun you
# already own AT THAT MOMENT. The card then sits on the board indefinitely, and
# the panel says so in its own words: they do not expire while you are down here.
# Between the roll and the claim the gun is easy to come by: extract carrying
# one and it banks to the armoury, or buy one. Claim the contract and the payout
# adds the gun only if it is new, then returns the same sentence either way, so
# the line reads "and Marksman Rifle to the armoury" for a gun that was already
# yours and nothing changed hands.
#
# The credits arrive. The gear does not exist. And you are told it did.
SubRx @'
    if(P.weapons.indexOf(g.k)<0) P.weapons.push(g.k);
    return WEAPONS[g.k].name+' to the armoury';
'@ @'
    if(P.weapons.indexOf(g.k)<0){ P.weapons.push(g.k); return WEAPONS[g.k].name+' to the armoury'; }
    // v12.63, 2026-09-08 audit: A RECEIPT FOR SOMETHING THAT NEVER ARRIVED. The
    // gear is rolled once, when the card is written, and that roll refuses a gun
    // he already owns at that moment; the card then sits on the board for as
    // long as he likes, and by the time he claims it he may well have bought or
    // carried out the same gun. The line above added nothing in that case and
    // the sentence below said it had. He is paid what the gun is worth instead,
    // and the line says exactly that, so nothing on the receipt is a fiction.
    var _pgv=(ITEMS['gun_'+g.k]&&ITEMS['gun_'+g.k].val)||0;
    if(_pgv>0){ P.credits=(P.credits||0)+_pgv;
      return WEAPONS[g.k].name+', already yours, so its value of '+'$'+_pgv.toLocaleString()+' instead'; }
    return WEAPONS[g.k].name+', which you already own';
'@

# NEW IN.
SubRx @'
  'THE COUNTER SAYS WHAT IT DID WITH YOUR MONEY, and buying a spare gun no longer takes the slot off the gun in your hands. It said nothing at all on a successful sale, and a cheap pistol bought as a spare quietly demoted your best gun.',
'@ @'
  'THE COUNTER SAYS WHAT IT DID WITH YOUR MONEY, and buying a spare gun no longer takes the slot off the gun in your hands. It said nothing at all on a successful sale, and a cheap pistol bought as a spare quietly demoted your best gun.',
  'A CONTRACT THAT PAYS A GUN YOU ALREADY HAVE PAYS ITS VALUE INSTEAD. The card is written long before you claim it, so the gun it promised can be one you picked up in the meantime; it used to hand over nothing and print a receipt saying it had.',
'@

# STAMPS.
SubRx @'
var VER='12.62';
'@ @'
var VER='12.63';
'@
SubRx @'
var WHATSNEW_VER='12.62';
'@ @'
var WHATSNEW_VER='12.63';
'@
$cnt=([regex]::Matches($s,"now:'v12\.62:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v12.62 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v12\.62:[^']*'",{ param($m) "now:'v12.63: from the 2026-09-08 read-only audit, confirmed by a skeptic against the source. A contract whose whole physical payout is a gun paid nothing at all if he had acquired that gun since the card was written, and the receipt said it paid. The gear is rolled ONCE, when the card is made, and that roll refuses a gun he already owns at that moment; the card then sits on the board indefinitely, and the panel says so in its own words, that they do not expire while he is down here. Between the roll and the claim the gun is easy to come by: extract carrying one and it banks to the armoury, or buy one at the counter. Claim the contract and the payout added the gun only if it was new, then returned the same sentence either way, so the line read and Marksman Rifle to the armoury for a gun that was already his while nothing changed hands. The credits arrived, the gear did not exist, and he was told it did. He is paid what the gun is worth instead, and the line says exactly that, so nothing on the receipt is a fiction. Check 12.63 claims a gun payout he already owns and requires the credits to rise by the guns own value with the armoury unchanged and the line saying so, with a control that the same payout on a gun he does not own still hands over the gun and says the armoury; fails on v12.62.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
