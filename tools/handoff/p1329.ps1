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

# HIS RULING, 2026-09-13: "initial welcome pack should go to the stash".
#
# WHAT IT REVERSES. Since v10.67 TAKE put the pack guns into the armoury AND into
# the player's hands, the first into an empty first slot and the second into an
# empty second slot, so a new player went up holding both. The pack window said the
# guns went to the armoury, and the pack description already said everything went
# "straight into your stash". His rule makes the description the truth.
#
# EVERYTHING GOES TO THE STASH, GUNS INCLUDED, AS THE STASH ALREADY HOLDS GUNS. A gun
# in the stash is an item, gun_smg and gun_carbine, the same form a gun found in a
# container or crafted at the bench takes, and the stash right-click menu already
# offers Equip as your gun on it. Nothing is equipped for him: he packs on purpose,
# which is the same stash-first rule as coming back empty (v12.87).
#
# THE CONSEQUENCE IS STATED, NOT HIDDEN. A new player who takes the pack and does not
# equip a gun goes up with nothing of his own, and the ascent screen already warns
# him in exactly those words, "Going up with no gun of your own", before he climbs.
#
# THE ROWS SAY TO YOUR STASH FOR EVERY LINE, because that is now where every line goes.
SubRx @'
    rows+='<div class="row"><div style="flex:1"><b class="r-'+rr2+'">'+W.name+'</b><div class="hint">'+rr2+' gun, to your armoury</div></div></div>'; }
'@ @'
    rows+='<div class="row"><div style="flex:1"><b class="r-'+rr2+'">'+W.name+'</b><div class="hint">'+rr2+' gun, to your stash</div></div></div>'; }
'@

SubRx @'
    for(var g2=0;g2<WELCOME_PACK.guns.length;g2++) if(WEAPONS[WELCOME_PACK.guns[g2]]&&P.weapons.indexOf(WELCOME_PACK.guns[g2])<0) P.weapons.push(WELCOME_PACK.guns[g2]);
    P.stash=P.stash||[];
'@ @'
    // v13.29, HIS RULING 2026-09-13: the whole pack goes to the stash, guns included,
    // as the gun items a container or the bench would give. Nothing is equipped for
    // him and nothing is added to the armoury.
    P.stash=P.stash||[];
    for(var g2=0;g2<WELCOME_PACK.guns.length;g2++){ var _gi='gun_'+WELCOME_PACK.guns[g2]; if(WEAPONS[WELCOME_PACK.guns[g2]]&&ITEMS[_gi]) P.stash.push(_gi); }
'@

SubRx @'
    var _wg=WELCOME_PACK.guns;
    if((!P.equipped||P.equipped==='fists')&&_wg[0]&&WEAPONS[_wg[0]]) P.equipped=_wg[0];
    if((!P.equippedSec||P.equippedSec==='none'||P.equippedSec==='fists')&&_wg[1]&&WEAPONS[_wg[1]]&&_wg[1]!==P.equipped) P.equippedSec=_wg[1];
'@ @'
    // v13.29: v10.67 equipped the pack guns here. His ruling puts the pack in the
    // stash instead, so he packs on purpose and the ascent screen tells him if he is
    // going up with no gun of his own.
'@

SubRx @'
var VER='13.28';
'@ @'
var VER='13.29';
'@

$pat = "(?m)^  now:'v13\.28:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v13.29: HIS RULING of 2026-09-13, the initial welcome pack goes to the stash. It reverses v10.67, which had TAKE put the pack guns into the armoury and into the player hands, the first into an empty first slot and the second into an empty second slot, while the pack window said the guns went to the armoury and the pack description already said everything went straight into the stash; his rule makes that description the truth. Everything goes to the stash, guns included, as gun items, gun_smg and gun_carbine, the same form a gun found in a container or crafted at the bench takes, and the stash right-click menu already offers Equip as your gun on them. Nothing is equipped for him and nothing is added to the armoury, so he packs on purpose, the same stash-first rule as coming back empty at v12.87. The consequence is stated, not hidden: a new player who takes the pack and does not equip a gun goes up with nothing of his own, and the ascent screen already warns him in exactly those words before he climbs. Every row in the pack window now says to your stash. Three checks encoded the reversed rule and are repaired in the same build: 13.07 required the pack to put a gun in his hands, and keeps its declining and consent arms; 10.67 was entirely the hands rule, and now guards the part that survives, that TAKE never touches a gun the player chose; 10.29 required the guns in the armoury, and now requires them in the stash. Check 13.29 presses the real TAKE on a brand-new player and requires both guns in the stash as items, none added to the armoury, nothing equipped, and every row saying to your stash; it fails on v13.28',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
