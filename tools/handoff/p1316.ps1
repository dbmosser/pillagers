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

# HIS NOTE, 2026-09-12: "if the player loots and finds an armor plate, it
# shouldn't automatically convert to armor. it should go to their tact belt or
# backpack, and then they have to equip it, which takes time, then it serves as
# armor on the armor bar."
#
# HE IS DESCRIBING A RULE THE GAME ALREADY HALF HAS AND CONTRADICTS. startPrep
# armour, with its two second wind-up, is the equip path and it works; his own
# baked text edit for the plate already tells the player "Armour plates don't
# auto equip; you must put them in during the raid." The pickup line below made
# that sentence a lie for every plate found in a container.
#
# WHAT THE INSTANT APPLY COSTS, beyond his note. A plate soaked into the bar on
# pickup could never be carried home, never be sold, never be belted, and never
# be spent at a moment of his choosing; and because the apply was silent and
# immediate, the two second cost that makes armour a decision under fire was
# skipped entirely by the most common way of getting one.
#
# THE BRANCH IS SIMPLY DELETED. The chain already ends in a default that pushes
# the item into the backpack and offers it to the tactical belt, and the belt
# builds its plate cell from whatever armour is in the bag, so removing this
# line is the whole of "goes to the belt or the backpack". Nothing is added.
SubRx @'
    // A plate is worth 55 but only applied below 20 armour, so deploying with a
    // plate from stash put you at 55 and made every plate you then found dead
    // weight you could never use, flatly contradicting the legend. Plates now
    // apply until armour is actually full.
    else if(itm.use==='armor'&&p.armor<armorCap()) p.armor=Math.min(armorCap(),p.armor+itm.amt);
'@ @'
    // v13.16, HIS NOTE 2026-09-12: a looted plate is not armour yet. It used to
    // soak straight into the bar the instant it left the container, which meant
    // it could never be carried home, never be sold, never be put on a belt key
    // and never be spent at a moment of his choosing, and it skipped the two
    // second wind-up that makes armour a decision under fire. His own baked text
    // for the plate has said "Armour plates don't auto equip; you must put them
    // in during the raid" the whole time this line was making that a lie.
    // There is no replacement branch on purpose: the chain already ends in a
    // default that pushes the item into the backpack and offers it to the
    // tactical belt, and the belt builds its plate cell from whatever armour is
    // in the bag. Equipping stays where it already was, startPrep armour.
'@

SubRx @'
      itm.name+(itm.use==='ammo'?' +'+itm.amt+' ammo':(itm.use==='armor'&&p.armor<armorCap()?' +'+Math.round(Math.min(armorCap()-p.armor,itm.amt))+' armor':' '+ival(key)+'c')),
'@ @'
      itm.name+(itm.use==='ammo'?' +'+itm.amt+' ammo':' '+ival(key)+'c'),
'@

SubRx @'
var VER='13.15';
'@ @'
var VER='13.16';
'@

$pat = "(?m)^  now:'v13\.15:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v13.16: HIS NOTE of 2026-09-12, that a looted armour plate should not convert itself into armour but go to the tactical belt or the backpack and be equipped, which takes time, before it counts on the bar. He is describing a rule the game already half had and contradicted: the two second armour wind-up is the equip path and it works, and his own baked text for the plate already says that plates do not auto equip and must be put in during the raid, which the pickup line made a lie for every plate found in a container. What the instant apply cost beyond his note: a plate soaked into the bar could never be carried home, never be sold, never be put on a belt key and never be spent at a moment of his choosing, and because it was silent and immediate it skipped the cost that makes armour a decision under fire, by the most common way of getting one. The branch is simply DELETED with no replacement, because the chain already ends in a default that pushes the item into the backpack and offers it to the tactical belt, and the belt builds its plate cell from whatever armour is in the bag, so removing the line IS the whole of goes to the belt or the backpack. The pickup label stops promising plus armour and names the item and its value like everything else. Check 13.16 loots a real plate from a real container on a live raid and requires the bar not to move, the plate to be in the backpack, the belt to offer it, and then the wind-up to be what puts it on the bar; two arms fail on v13.15',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
