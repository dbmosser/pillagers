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
# A DELETION NEEDS A DIFFERENT TOOL. Reproducing seventy lines of a block exactly
# is where a hand-written anchor goes wrong, so a cut is expressed as its two
# ends: a unique first line, and the unique line that must survive directly
# after it. Both are asserted to appear exactly once and in that order, and the
# number of lines removed is printed, so the patch says out loud how much it took.
function CutRx([string]$startLine, [string]$keepLine, [int]$expectLines) {
  $sPat = [regex]::Escape($startLine.TrimEnd("`r"))
  $kPat = [regex]::Escape($keepLine.TrimEnd("`r"))
  if (([regex]::Matches($script:s, $sPat)).Count -ne 1) { throw "cut start matched not once: $startLine" }
  if (([regex]::Matches($script:s, $kPat)).Count -ne 1) { throw "cut keep matched not once: $keepLine" }
  $a = $script:s.IndexOf($startLine)
  $b = $script:s.IndexOf($keepLine)
  if ($a -lt 0 -or $b -lt 0 -or $b -le $a) { throw "cut markers out of order: $startLine" }
  $cut = $script:s.Substring($a, $b - $a)
  $lines = ($cut -split "`n").Count - 1
  if ($lines -ne $expectLines) { throw "cut would remove $lines lines, expected $expectLines : $startLine" }
  $script:s = $script:s.Remove($a, $b - $a)
  $script:n++
  Write-Output "  cut $lines lines at: $($startLine.Trim().Substring(0,[Math]::Min(60,$startLine.Trim().Length)))"
}

# HIS ORDER, 2026-09-08: "remove the safe pocket from the stash and just delete
# the entire concept."
#
# He asked first why a gun and a throwable were refused and what the pocket was
# for, and then how he was meant to put anything in it during a raid. The honest
# answer to the second was that he could not: the pocket lives on the stash
# screen only and its choice is frozen at the lift, so it can protect something
# he carried from home and never the thing he just pulled out of a vault, which
# is the only thing worth protecting. He decided that was not worth fixing and
# that the idea goes. It goes completely: the panel, the two functions that read
# it, the menu verb, the ascent line, the death payout branch, the field on the
# profile and the styles. Nothing is left half-wired, because a dead field that
# something still reads is how the frozen-loot bug shipped three times.
#
# WHAT DOES NOT MOVE, and it shares the word: the world container type called a
# safe, the secure cases in buildings and camps, the contract that asks you to
# search them, and every line that draws them. Different thing, same five letters.

# THE PANEL on the stash screen.
SubRx @'
            <div class="loslab">Safe pocket<b><span id="safen">0/1</span></b></div>
            <div class="invgrid" id="safegrid"></div>
'@ @'
'@

# THE STYLES that only ever dressed it.
SubRx @'
    #safegrid{ grid-template-columns:repeat(auto-fill,minmax(66px,1fr)) !important; }
'@ @'
'@
SubRx @'
  #hub[data-slayout="10"] #safegrid, #hub[data-slayout="6"] #safegrid, #hub[data-slayout="7"] #safegrid{ grid-template-columns:repeat(auto-fill,minmax(46px,52px)) !important; max-height:74px; }
  #hub[data-slayout="10"] #safegrid .ic, #hub[data-slayout="6"] #safegrid .ic, #hub[data-slayout="7"] #safegrid .ic{ width:26px !important; height:26px !important; }
  #hub[data-slayout="10"] #safegrid .cellempty, #hub[data-slayout="6"] #safegrid .cellempty, #hub[data-slayout="7"] #safegrid .cellempty{ aspect-ratio:auto; height:52px; grid-column:1/-1; }
'@ @'
'@

SubRx @'
  /* The safe pocket is one cell and must not stretch like a grid. */
  #safegrid{ flex:none; min-height:0; padding:8px 12px 10px;
    grid-template-columns:repeat(auto-fill,minmax(52px,1fr)); }
  #safegrid .cellempty{ border:1px dashed var(--steel-hi); border-radius:3px;
    aspect-ratio:1/1; display:flex; align-items:center; justify-content:center;
    font-size:10.5px; letter-spacing:.1em; color:var(--ash); text-align:center;
    padding:4px; grid-column:span 2; }
'@ @'
'@

# THE PROFILE. The old cleanup line went with the concept, and its place is taken
# by one that clears both fields off any save that still carries them, so an old
# profile does not keep a pocket nothing can read.
SubRx @'
// v12.15: a pocket saved on a grenade or an ammo box protects nothing; cleared so the ascent screen stops saying 1/1.
if(P.safe&&ITEMS[P.safe]&&(ITEMS[P.safe].use==='throw'||ITEMS[P.safe].use==='ammo')) P.safe=null;
'@ @'
// v12.35, his order: the safe pocket is gone. Both fields are cleared off any
// save that still carries one, so nothing is left naming a feature that no
// longer exists. This line can go once no live profile has been near v12.34.
if(P.safe!==undefined) delete P.safe;
if(P.safeUp!==undefined) delete P.safeUp;
'@

# THE ARMING at the drop, and the six lines of comment that only exist to
# explain it. An orphaned comment is how the next reader learns a feature that
# is gone is still here.
SubRx @'
      // v8.40, audit: AND HERE IS THE SAFE POCKET, armed against what is actually
      // going up. _dk is the final kit on every live path - staged, quick ascent,
      // or auto-packed from the stash a moment ago - so the hub's promise that
      // the named item "comes home if you die carrying it" is now true whichever
      // way he deployed. It used to be armed in commitKit, before the auto-pack
      // had run, and so was null for anyone who never used the staging screen.
      P.safeUp=(P.safe&&_dk.indexOf(P.safe)>=0)?P.safe:null;
      saveProfile();
'@ @'
      saveProfile();
'@

# THE LINE ON THE DEATH CARD. It is fed by the automatic rebate, which is a
# separate dev dial that has sat at zero since v5.57, not by the pocket; but it
# printed the pocket's name, so with the pocket gone it would have been the one
# place in the game still claiming one. It names what it actually is now.
SubRx @'
    if(saved.length) lines.push('Safe pocket held '+saved.length+' item'+(saved.length>1?'s':'')+' ('+'$'+savedVal.toLocaleString()+')');
'@ @'
    if(saved.length) lines.push('Rebate held '+saved.length+' item'+(saved.length>1?'s':'')+' ('+'$'+savedVal.toLocaleString()+')');   // v12.35: the automatic rebate, not the deleted pocket
'@

# THE TWO OLDER ENTRIES IN THE PLAYER-FACING HISTORY that describe the pocket as
# a live feature. One goes; the other counted the stash screen and is corrected.
SubRx @'
  'THE SAFE POCKET TELLS YOU THE TRUTH. It only saves the item it names if you are actually carrying it, and it says NOT PACKED when you are not, on the stash screen and on the ascent check.',
'@ @'
'@
SubRx @'
  'THE STASH IS FIVE THINGS: the stash, your backpack, your tactical belt, the safe pocket and the freebie kit. Everything else that crowded it is gone. The backpack is a grid of twelve cells there and in the raid, empty cells drawn.',
'@ @'
  'THE STASH IS FOUR THINGS: the stash, your backpack, your tactical belt and the freebie kit. Everything else that crowded it is gone. The backpack is a grid of twelve cells there and in the raid, empty cells drawn.',
'@

# THE DEATH PAYOUT branch, with the spec comment that explains it.
CutRx '    // v6.01, his spec "ONE safe-pocket item survives death". Checked against the' '    var savedVal=0;' 16

# THE TWO READERS, THE SETTER AND THE PANEL RENDERER, in one block.
CutRx '// v6.01: the safe pocket. P.safe names ONE item key; one copy of it comes home if' 'function renderKitCol(){' 75

# THE CALL that drew the panel.
SubRx @'
  renderSafe();
  kg.innerHTML='';
'@ @'
  kg.innerHTML='';
'@

# THE MENU VERB. Written out rather than cut, because the line that has to
# survive after it is not unique in the file and a cut on an ambiguous end is
# exactly the way a deletion takes something it was not aiming at.
SubRx @'
  // v6.01: naming the safe pocket is a menu verb as well as a drop target.
  if(it.use!=='gun'&&it.use!=='throw'&&it.use!=='ammo'){   // v12.15: the pocket refuses these, so the menu does not offer it
    var _isSafe=(P.safe===key);
    rows.push({label:_isSafe?'Take out of safe pocket':'Put in safe pocket',
      hint:_isSafe?null:'survives death',
      act:function(){ var why=setSafe(_isSafe?null:key); if(why) say2(why); refreshInv(); }});
  }
'@ @'
'@

# THE LINE ON THE ASCENT PAGE.
CutRx '    // v10.71: and the safe pocket, on the page that calls itself the last stop' '    sw.innerHTML=bits.join' 7

# A STALE POINTER. This comment sent the reader to code that no longer exists.
# Dated history that says what the pocket WAS stays, here and elsewhere; a
# comment that tells you where to find it does not.
SubRx @'
    P.dropKit=[]; P.kit=[]; P.kitChosen=1; saveProfile(); return true;   // v8.40: safeUp is armed in buildRaid
'@ @'
    P.dropKit=[]; P.kit=[]; P.kitChosen=1; saveProfile(); return true;
'@

# THE PLAYER-FACING HISTORY. The entry about the pocket refusing a throwable
# describes a rule on a thing that no longer exists, so it comes out with it.
SubRx @'
  'THE SAFE POCKET REFUSES A THROWABLE OR AN AMMO BOX. Neither rides in the backpack, so neither could ever come home from it; the pocket said 1/1 anyway.',
'@ @'
'@

# NEW IN.
SubRx @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
'@ @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
  'THE SAFE POCKET IS GONE. It could only ever protect something you carried up from home, never the thing you found, because it was chosen at the lift and there was no way to reach it in a raid. Dying costs you the whole backpack now, with no exception.',
'@

# STAMPS.
SubRx @'
var VER='12.34';
'@ @'
var VER='12.35';
'@
SubRx @'
var WHATSNEW_VER='12.34';
'@ @'
var WHATSNEW_VER='12.35';
'@
$cnt=([regex]::Matches($s,"now:'v12\.34:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v12.34 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v12\.34:[^']*'",{ param($m) "now:'v12.35: his order of 2026-09-08, remove the safe pocket and delete the entire concept. He asked what was supposed to go in it and how he was meant to reach it during a raid; the honest answer to the second was that he could not, because the pocket lives on the stash screen only and its choice is frozen at the lift, so it could protect something carried from home and never the thing just pulled out of a vault. Out goes the panel, the styles, the two readers, the setter, the renderer, the menu verb, the line on the ascent page, the arming at the drop, the branch in the death payout and both fields on the profile, which are deleted from any save that still carries them. The world container called a safe is a different thing with the same five letters and is untouched. Check 12.35 requires the panel, the functions and the fields to be gone, requires a death to pay out and list what was lost with no pocket line, and requires the secure cases still to be built and drawn; fails on v12.34.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + ([regex]::Matches($src, "(?m)^CutRx ")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
if ($script:s -match 'safegrid|safeUpKey|renderSafe|setSafe\(') { throw 'a safe pocket reference survived the cut' }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
