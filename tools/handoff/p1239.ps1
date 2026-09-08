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

# FROM THE 2026-09-07 READ-ONLY AUDIT (dead-slot2), specced from the source and
# attacked by a skeptic before a line was written.
#
# A death splices the guns you carried out of the armoury. Since v2.82 the
# primary has been put back on a gun you still own; nothing has ever done it for
# the sidearm. So a death that took the second gun left gun 2 naming a gun that
# had just been removed from the armoury thirty lines above. The deploy refuses
# it, so he goes up with an empty second slot, but the ascent check reads the
# field raw and told him the dead gun was going up in his hands. Two edits: the
# same repair the primary already gets, and the same test the deploy makes on
# the one screen that has to agree with it.
SubRx @'
    if(P.equipped!=='fists'&&P.weapons.indexOf(P.equipped)<0) P.equipped=P.weapons.length?P.weapons[0]:'fists';
'@ @'
    if(P.equipped!=='fists'&&P.weapons.indexOf(P.equipped)<0) P.equipped=P.weapons.length?P.weapons[0]:'fists';
    // v12.39, audit dead-slot2: AND GUN 2 GETS THE SAME REPAIR. The line above has
    // put the primary back on a gun you still own since v2.82, and nothing has ever
    // done it for the sidearm, so a death that took the second gun left P.equippedSec
    // naming a gun the splice thirty lines up had just removed from the armoury.
    // buildRaid refuses it - it tests P.weapons before it bakes a sidearm - and sends
    // you up with an empty second slot, but the ascent check reads the field raw and
    // told him the dead gun was going up in his hands. An empty gun 2 is the v5.37
    // default, so that is what the slot goes back to.
    if(P.equippedSec&&P.equippedSec!=='none'&&P.equippedSec!=='fists'&&
       P.weapons.indexOf(P.equippedSec)<0) P.equippedSec='none';
'@

# THE DISPLAY.
SubRx @'
    var g2=(P.equippedSec&&P.equippedSec!=='none'&&P.equippedSec!=='fists')?WEAPONS[P.equippedSec]:null;
'@ @'
    // v12.39, audit dead-slot2: THE SAME TEST buildRaid MAKES, so this page can
    // never name a gun that will not come up. It read the slot raw, so after a death
    // that took the sidearm it printed the lost gun as your second gun, and it would
    // do the same for a slot 2 that had come to name the gun already in slot 1. Both
    // are cases buildRaid throws away. This is the last screen before the lift, so it
    // is the one screen that has to agree with the deploy.
    var _s2=P.equippedSec;
    var g2=(_s2&&_s2!=='none'&&_s2!=='fists'&&WEAPONS[_s2]&&
            (P.weapons||[]).indexOf(_s2)>=0&&_s2!==P.equipped)?WEAPONS[_s2]:null;
'@

# NEW IN.
SubRx @'
  'EXTRACTING WITH A GUN IN EACH HAND LEAVES A GUN IN EACH HAND. Banking the better gun into slot 1 used to leave slot 2 naming the same gun, so the next raid came up with an empty second slot and a gun you still owned quietly unslotted.',
'@ @'
  'EXTRACTING WITH A GUN IN EACH HAND LEAVES A GUN IN EACH HAND. Banking the better gun into slot 1 used to leave slot 2 naming the same gun, so the next raid came up with an empty second slot and a gun you still owned quietly unslotted.',
  'A GUN YOU DIED WITH IS NOT COMING UP WITH YOU. A death that took your sidearm left gun 2 still naming it, and the last screen before the lift told you it was going up in your hands. The slot is emptied now, and that screen makes the same test the deploy makes.',
'@

# STAMPS.
SubRx @'
var VER='12.38';
'@ @'
var VER='12.39';
'@
SubRx @'
var WHATSNEW_VER='12.38';
'@ @'
var WHATSNEW_VER='12.39';
'@
$cnt=([regex]::Matches($s,"now:'v12\.38:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v12.38 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v12\.38:[^']*'",{ param($m) "now:'v12.39: 2026-09-07 audit (dead-slot2). A death splices the guns you carried out of the armoury. Since v2.82 the primary has been put back on a gun you still own, and nothing has ever done it for the sidearm, so a death that took the second gun left gun 2 naming a gun the splice thirty lines above had just removed. The deploy refuses it, because it tests the armoury before it bakes a sidearm, so he went up with an empty second slot; but the ascent check, which is the last screen before the lift, read the field raw and told him the dead gun was going up in his hands. Two edits. The sidearm now gets the same repair the primary already gets, going back to the empty slot that has been the default since v5.37. And the ascent check makes the same test the deploy makes, so that screen can never name a gun that will not come up, which also covers a slot 2 that has come to name the gun already in slot 1 and a stale slot arriving from anywhere else. Check 12.39 stages two guns no starter roll, shop or freebie kit can hand out, dies carrying the second, and requires the slot to be empty and that screen to stop naming the lost gun, with a control that puts the gun back and requires the same page to name it again; fails on v12.38.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
