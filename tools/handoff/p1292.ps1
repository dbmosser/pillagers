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

# FINDING 15 OF THE 2026-09-11 AUDIT, and the worst case is not a mislabel, it is a
# loss: the button the lift calls "go up" is the one that skips the loadout question.
#
# WHAT HAPPENS. He plugs in the pad, walks to THE LIFT and reads the prompt the
# station draws: [X] go up, [Y] quick ascent, [RB] the terms. He presses X expecting
# the sector page and the question about what he is taking up. On the floor X is
# bound to KeyR, so the raid starts immediately: no sector page, no loadout
# question, no chance to answer MY LOADOUT or FREEBIE KIT.
#
# EVERY STATION IS SHIFTED THE SAME WAY. At SHOP, CRAFT, AND HIRE the sub line says
# [X] shop, [Y] craft, [D-DOWN] hire, while X opens CRAFT, Y opens HIRE and D-DOWN
# does nothing at all down here. At THE MAINFRAME, [X] contracts opens REWARDS. And
# the big bottom prompt reads [X] THE STASH over a station that opens on A.
#
# WHY. ONE LABEL TABLE WAS SERVING TWO DIFFERENT BINDING SETS. In a raid the pad
# really does put KeyE on X, KeyR on Y and KeyF on D-DOWN, and PADLABEL says so. The
# Undercroft deliberately keeps the FIRST act on A, because there is nothing to
# shoot down here, and then hangs the other three on X, Y and RB. That is one button
# lower all the way along, and PADLABEL has no entry that says A at all.
#
# THE v6.83 COMMENT ASSERTS THE OPPOSITE in as many words: X, Y and RB carry the
# second, third and fourth action, "matching the labels PADLABEL prints". They do
# not, because the labels name the second, third and fourth entries of a table whose
# first entry is the one the floor moved.
#
# THE FIX IS A SECOND TABLE, NOT A REBINDING. Moving the floor onto the raid buttons
# would take A away from the stations, which the v6.83 comment kept on purpose. One
# label table per binding set, chosen by the screen being drawn. Only the four
# station keys are in it, which is exactly the set the floor binds: the three
# station prompt lines are the only places keyLabel is called on the floor.
SubRx @'
function keyLabel(code,fallback){
  if(padOn()&&PADLABEL[code]) return PADLABEL[code];
  return fallback===undefined?code:fallback;
}
'@ @'
// v12.92, audit finding 15: THE FLOOR HAS ITS OWN BUTTONS, SO IT HAS ITS OWN
// LABELS. The Undercroft keeps the first station act on A and hangs the other three
// on X, Y and RB; the raid puts the same four keys one button higher. One table was
// labelling both, so every station prompt down here named the button for the act
// BELOW the one it was offering, and the lift's [X] go up was really the quick
// ascent that skips the loadout question. These four are the whole set the floor
// binds, and the station prompt lines are the only place it labels anything.
var PADLABEL_HUB={KeyE:'A',KeyR:'X',KeyF:'Y',KeyT:'RB'};
function keyLabel(code,fallback){
  if(padOn()){
    if(state==='hub'&&PADLABEL_HUB[code]) return PADLABEL_HUB[code];
    if(PADLABEL[code]) return PADLABEL[code];
  }
  return fallback===undefined?code:fallback;
}
'@

SubRx @'
    // v6.83: a station's other actions were unreachable on a pad. A opened the shop and
    // nothing could reach CRAFT, HIRE, REWARDS or the TERMS. X, Y and RB now carry the
    // second, third and fourth action, matching the labels PADLABEL prints.
'@ @'
    // v6.83: a station's other actions were unreachable on a pad. A opened the shop and
    // nothing could reach CRAFT, HIRE, REWARDS or the TERMS. X, Y and RB now carry the
    // second, third and fourth action.
    // v12.92: and the claim that used to end this comment, that they match the
    // labels PADLABEL prints, was untrue for five years of builds. PADLABEL is the
    // RAID table and has no entry for A, so it named the act below the one each
    // button actually performed. PADLABEL_HUB is the table for these four.
'@

# NEW IN.
SubRx @'
  'THE LEFT STICK CRAWLS WHEN YOU ARE DOWN.
'@ @'
  'ON A CONTROLLER THE STATIONS NAME THE BUTTON THEY ACTUALLY USE. Every prompt in the Undercroft named the button for the act below the one it was offering, so the lift said [X] go up and X launched the raid instead, with no sector page and no question about what you were taking up. The raid prompts were always right; the floor uses different buttons and was borrowing the raid labels.',
  'THE LEFT STICK CRAWLS WHEN YOU ARE DOWN.
'@

# STAMPS.
SubRx @'
var VER='12.91';
'@ @'
var VER='12.92';
'@
SubRx @'
var WHATSNEW_VER='12.91';
'@ @'
var WHATSNEW_VER='12.92';
'@
$cnt=([regex]::Matches($s,"now:'v12\.91:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v12.91 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v12\.91:[^']*'",{ param($m) "now:'v12.92: finding 15 of the 2026-09-11 audit, and the worst case is not a mislabel, it is a loss: the button the lift calls go up is the one that skips the loadout question. He plugs in the pad, walks to THE LIFT and reads the prompt the station draws, X go up, Y quick ascent, RB the terms; he presses X expecting the sector page and the question about what he is taking up, and on the floor X is bound to KeyR, so the raid starts immediately with no sector page, no loadout question and no chance to answer MY LOADOUT or FREEBIE KIT. Every station is shifted the same way: at SHOP, CRAFT, AND HIRE the sub line says X shop, Y craft, D-DOWN hire, while X opens CRAFT, Y opens HIRE and D-DOWN does nothing at all down here; at THE MAINFRAME, X contracts opens REWARDS; and the big bottom prompt reads X THE STASH over a station that opens on A. One label table was serving two different binding sets: in a raid the pad really does put KeyE on X, KeyR on Y and KeyF on D-DOWN and PADLABEL says so, while the Undercroft deliberately keeps the FIRST act on A because there is nothing to shoot down here and then hangs the other three on X, Y and RB, which is one button lower all the way along, and PADLABEL has no entry that says A at all. The v6.83 comment asserted the opposite in as many words, that X, Y and RB carry the second, third and fourth action matching the labels PADLABEL prints; they do not, because the labels name the second, third and fourth entries of a table whose first entry is the one the floor moved, and that sentence has been removed rather than left to mislead the next reader. The fix is a second table and not a rebinding, because moving the floor onto the raid buttons would take A away from the stations, which v6.83 kept on purpose: one label table per binding set, chosen by the screen being drawn, holding exactly the four station keys the floor binds, which is the whole set the three station prompt lines ever label. Check 12.92 fakes a connected pad and requires every station act the floor draws to name the button the floor actually binds it to, reads the lift line and requires the first act not to be named with the button that launches the raid, and controls that the raid prompts are unchanged and that with no pad the keyboard letters still print; fails on v12.91.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
