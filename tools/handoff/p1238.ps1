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

# FROM THE 2026-09-07 READ-ONLY AUDIT (gun-slot-reconcile), specced from the
# source and attacked by a skeptic before a line was written.
#
# An extraction banks the guns you carried and then rewrites gun 1 from the tier
# sort. Nothing has ever reconciled gun 2 with that rewrite, so a run where the
# better gun rode in slot 2 comes back with BOTH slots naming it. The ascent
# check prints the same gun name twice, and buildRaid refuses a sidearm equal to
# the primary, so the next raid comes up with fists in gun 2 and a gun he still
# owns quietly unslotted, out of a run in which he lost nothing. The welcome
# pack hands out the smg then the carbine, which is exactly the losing order, so
# this is the FIRST extraction of a brand new player.
SubRx @'
    if(kept.length) P.equipped=kept[0].id;
    for(i=0;i<THROWKEYS.length;i++){
'@ @'
    if(kept.length) P.equipped=kept[0].id;
    // v12.38, audit gun-slot-reconcile: SLOT TWO IS RECONCILED WITH SLOT ONE.
    // The line above rewrites gun 1 from the tier sort, so a run where the
    // better gun rode in slot 2 leaves BOTH slots naming it. The ascent check
    // then prints the same gun name twice, and the deploy guard refuses a
    // sidearm equal to the primary, so the next raid comes up with fists in
    // gun 2 and a gun he still owns quietly unslotted, out of a run in which
    // he lost nothing. The welcome pack hands out smg then carbine, which is
    // exactly the losing order, so this is the first extraction of a new
    // player. Only the collision is repaired: the other gun he actually
    // carried takes slot 2, and where there is no other gun the slot is
    // honestly empty. Two distinct slots are left untouched. Same rule the
    // armoury menu applies when a gun is put into a slot it already sits in.
    if(kept.length&&(P.equippedSec||'none')===P.equipped)
      P.equippedSec=(kept.length>1&&kept[1].id!==P.equipped)?kept[1].id:'none';
    for(i=0;i<THROWKEYS.length;i++){
'@

# NEW IN.
SubRx @'
  'A KEY ALREADY DOWN IS NOT A PRESS. F is the melee strike, so a hand resting on it when the hit landed used to spend your one self-revive on the first downed frame, with no decision made. The revive now waits for a release and a real press.',
'@ @'
  'A KEY ALREADY DOWN IS NOT A PRESS. F is the melee strike, so a hand resting on it when the hit landed used to spend your one self-revive on the first downed frame, with no decision made. The revive now waits for a release and a real press.',
  'EXTRACTING WITH A GUN IN EACH HAND LEAVES A GUN IN EACH HAND. Banking the better gun into slot 1 used to leave slot 2 naming the same gun, so the next raid came up with an empty second slot and a gun you still owned quietly unslotted.',
'@

# STAMPS.
SubRx @'
var VER='12.37';
'@ @'
var VER='12.38';
'@
SubRx @'
var WHATSNEW_VER='12.37';
'@ @'
var WHATSNEW_VER='12.38';
'@
$cnt=([regex]::Matches($s,"now:'v12\.37:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v12.37 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v12\.37:[^']*'",{ param($m) "now:'v12.38: 2026-09-07 audit (gun-slot-reconcile). An extraction banks the guns you carried and then rewrites gun 1 from the tier sort, and nothing has ever reconciled gun 2 with that rewrite. So a run in which the better gun rode in slot 2 came back with BOTH slots naming it: the ascent check printed the same gun name twice, and buildRaid refuses a sidearm equal to the primary, so the next raid came up with fists in gun 2 and a gun he still owned quietly unslotted, out of a run in which he lost nothing. The welcome pack hands out the smg and then the carbine, which is exactly the losing order, so this is the first extraction of a brand new player. One line repairs the collision only: where the two slots have come to name the same gun, the other gun he actually carried takes slot 2, and where there is no other gun the slot is honestly empty. Two distinct slots are untouched, which is the same rule the armoury menu already applies. Check 12.38 stages the weakest gun in slot 1 and the strongest in slot 2, extracts with both, and requires the tier sort to have promoted the strong one while slot 2 still holds the other, the ascent check to name each gun once, and the next raid to deploy with a gun in each hand; fails on v12.37.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
