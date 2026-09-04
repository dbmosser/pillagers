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

# ============ THE ALPHA, second finding from driving a friend's first session
# ============ in a completely empty browser.
# ============
# ============ The welcome pack says, in its own words, "a green gun and a blue
# ============ one" and puts them in the armoury. Then the first raid hands him
# ============ a Scuttle. Measured on v10.66 from a clean store: take the pack,
# ============ walk to the lift, press MY LOADOUT, and the gun in his hands is
# ============ one of the four issued starters rolled fresh for that raid, while
# ============ the armoury holds pistol, smg and carbine and P.equipped is still
# ============ 'fists'. The deploy issues a starter whenever nothing is
# ============ deliberately equipped, which is right, and a brand new character
# ============ has deliberately equipped nothing.
# ============
# ============ So the gift he was just given is invisible in the raid it was
# ============ given for, and he has to find the stash and equip it himself to
# ============ see it at all. Taking the pack now puts its two guns in his hands.
# ============
# ============ This is not the auto-equip he refused on 2026-08-24. That was
# ============ about a gun FOUND in a raid shoving aside the gun you chose. This
# ============ displaces nothing: it only fills slots that hold fists.
SubRx @'
    P.stash=P.stash||[];
    for(var i2=0;i2<WELCOME_PACK.items.length;i2++) if(ITEMS[WELCOME_PACK.items[i2]]) P.stash.push(WELCOME_PACK.items[i2]);
    P.welcomed=1; saveProfile();
'@ @'
    P.stash=P.stash||[];
    for(var i2=0;i2<WELCOME_PACK.items.length;i2++) if(ITEMS[WELCOME_PACK.items[i2]]) P.stash.push(WELCOME_PACK.items[i2]);
    // v10.67: and into his HANDS. The deploy issues a starter to anyone who has
    // equipped nothing, so without this the two guns he was just given sit in
    // the armoury while his first raid hands him something else entirely.
    // Only into empty slots: a player who has already chosen keeps his choice.
    var _wg=WELCOME_PACK.guns;
    if((!P.equipped||P.equipped==='fists')&&_wg[0]&&WEAPONS[_wg[0]]) P.equipped=_wg[0];
    if((!P.equippedSec||P.equippedSec==='none'||P.equippedSec==='fists')&&_wg[1]&&WEAPONS[_wg[1]]&&_wg[1]!==P.equipped) P.equippedSec=_wg[1];
    P.welcomed=1; saveProfile();
'@

SubRx @'
var VER='10.66';
'@ @'
var VER='10.67';
'@
SubRx @'
  now:'v10.66: a new character actually gets the briefing. The welcome pack used to open on top of FIRST TIME OUT and destroy it, so the one card that teaches the game was never read by anyone new. The cards wait their turn now.',
'@ @'
  now:'v10.67: the two guns in the welcome pack go into your hands, not just into your armoury. A new character used to be given a green gun and a blue one and then handed something else entirely on his first raid.',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
