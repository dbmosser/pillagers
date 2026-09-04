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
# Cut everything between two exact markers, asserting first that what is being
# cut really is the thing named. A deletion is verified by what it swallowed.
function CutBetween([string]$startLit, [string]$endLit, [string]$mustHold, [int]$minLen) {
  $a = $script:s.IndexOf($startLit)
  if ($a -lt 0) { throw "cut start not found: $startLit" }
  if ($script:s.IndexOf($startLit, $a + 1) -ge 0) { throw "cut start is not unique: $startLit" }
  $b = $script:s.IndexOf($endLit, $a)
  if ($b -lt 0) { throw "cut end not found after start: $endLit" }
  $block = $script:s.Substring($a, $b - $a)
  if ($block.Length -lt $minLen) { throw "cut is only $($block.Length) chars, expected at least $minLen" }
  if ($block.IndexOf($mustHold) -lt 0) { throw "the cut does not hold $mustHold, so it is cutting the wrong thing" }
  $script:s = $script:s.Remove($a, $b - $a)
  $script:n++
}

# ============ HIS NOTE: DELETE FIRST TIME OUT ENTIRELY.
# ============
# ============ "get rid of the 'first time out' menu/screen -- delete it
# ============ entirely, no more references to it -- they player has to figure
# ============ this shit out on their own", 2026-09-04.
# ============
# ============ Everything goes and it is a real deletion, not a stubbed-out
# ============ function left in place: the window, its eighteen cards, the
# ============ renderer, the under-the-fold cue v10.69 built, the scroll wiring,
# ============ the never-show tick box, the close handler and the css for the
# ============ list and the cue. Thirty-two references to zero.
# ============
# ============ WHAT MUST NOT BREAK, and this is the reason it is not one big
# ============ delete: firstRunNext is a CHAIN, welcome pack then share question
# ============ then primer, and the first two have to keep working. The call goes
# ============ with the function rather than being left pointing at nothing.
# ============ The WHATSNEW line that advertised the card goes too, or the game
# ============ would announce a screen nobody can open.
# ============
# ============ v10.69's check is retired in the same build. A check left
# ============ asserting a screen that no longer exists is worse than no check.
# ============
# ============ THE TWO PROFILE FLAGS, primerOff and primerSeen, are simply never
# ============ read or written again. They stay harmlessly in old saves; nothing
# ============ migrates, because nothing depends on them.

# ---- 1. the window
SubRx @'
<div class="modal" id="primermodal">
  <h3>FIRST TIME OUT</h3>
  <div class="msub">What is worth knowing before you take the lift up. The first three are the ones that get people killed. You can bring this back any time from Settings.</div>
  <div id="primerlist" class="plist"></div>
  <div id="primermore" class="pmore"></div>
  <div style="display:flex;gap:10px;margin-top:10px;align-items:center">
    <label style="display:flex;gap:6px;align-items:center;font-size:13px;color:var(--ash);cursor:pointer">
      <input type="checkbox" id="primernever" style="cursor:pointer"> Do not show this again
    </label>
    <button id="closeprimer" style="padding:8px 22px;margin-left:auto">CLOSE</button>
  </div>
</div>
'@ @'
'@

# ---- 2. its close handler
SubRx @'
document.getElementById('closeprimer').onclick=function(){
  var cb=document.getElementById('primernever');
  P.primerOff=!!(cb&&cb.checked);
  P.primerSeen=1;
  saveProfile();
  document.getElementById('primermodal').classList.remove('on');
};
'@ @'
'@

# ---- 3. the css for the list scrollbar and the cue
SubRx @'
  #primerlist::-webkit-scrollbar { width:12px; }
  #primerlist::-webkit-scrollbar-thumb { background:var(--amber); border-radius:6px; }
'@ @'
'@
SubRx @'
  .pmore { display:none; margin-top:6px; padding:6px 10px; cursor:pointer;
'@ @'
  .pmoreGONE { display:none; margin-top:6px; padding:6px 10px; cursor:pointer;
'@
SubRx @'
  #setlist,#primerlist,#sectorlist,#contracts,#loglist{ border:1px solid var(--steel-hi); }
'@ @'
  #setlist,#sectorlist,#contracts,#loglist{ border:1px solid var(--steel-hi); }
'@

# ---- 4. the link in the first-run chain, leaving the welcome pack and the
# ----    share question exactly as they were
SubRx @'
  if(typeof maybeShareAsk==='function'){ maybeShareAsk(); if(document.querySelector('.modal.on')) return; }
  if(typeof maybePrimer==='function') maybePrimer();
'@ @'
  // v10.88, HIS NOTE: the briefing card used to be the third link in this chain
  // and is deleted. The welcome pack and the share question are untouched.
  if(typeof maybeShareAsk==='function') maybeShareAsk();
'@

# ---- 5. the card, its cards, the renderer, the cue and the opener
CutBetween "// THE FIRST TIME OUT CARD, v3.37. His note:" "// v10.29, his note: the welcome pack." "This is a raid, not a level" 3000

# ---- 6. maybePrimer itself
CutBetween "function maybePrimer(){" "// PLAIN WORDS INSTEAD OF DIALS, v3.41." "openPrimer();" 300

# ---- 7. the WHATSNEW line that advertised it
SubRx @'
  'FIRST TIME OUT IS A REAL BRIEFING NOW. A new character reads it instead of having it painted over by the welcome pack, and the card says how many of its eighteen pages are still below the fold.',
'@ @'
'@

SubRx @'
var VER='10.87';
'@ @'
var VER='10.88';
'@
SubRx @'
var WHATSNEW_VER='10.87';
'@ @'
var WHATSNEW_VER='10.88';
'@
SubRx @'
  now:'v10.87: hold SHIFT to sprint, your note. It was a toggle since v10.07, so a press and release left you running. The movement code reads the key itself now; crouch stays a toggle, which is still what you asked for. Speed, stamina and noise are all unchanged.',
'@ @'
  now:'v10.88: FIRST TIME OUT is gone, your note. The window, its eighteen cards, the under-the-fold cue, the never-show tick box, the close handler and the css are all deleted, thirty-two references down to none. The welcome pack and the share question still run, in that order.',
'@


# ---- 8. every remaining mention of the word, in three shipped WHATSNEW lines
# ----    and three comments. "no more references to it" was his instruction.
SubRx @'
  'THE HOTBAR IS THE TACTICAL BELT, everywhere a word names it: the stash, the raid, the legends, the pause screen, the primer.',
'@ @'
  'THE HOTBAR IS THE TACTICAL BELT, everywhere a word names it: the stash, the raid, the legends and the pause screen.',
'@
SubRx @'
  'CLOSE ON EVERY WINDOW, AND ESC CLOSES THE TOP ONE, anywhere: the stash, the lift, the bar, the Depot, Settings, the primer.',
'@ @'
  'CLOSE ON EVERY WINDOW, AND ESC CLOSES THE TOP ONE, anywhere: the stash, the lift, the bar, the Depot and Settings.',
'@
SubRx @'
  'THE PILLBOX. The listening machine in the walls has its name: PILLBOX, its slits, its wrecks and its line in the primer.',
'@ @'
  'THE PILLBOX. The listening machine in the walls has its name: PILLBOX, its slits and its wrecks.',
'@
SubRx @'
    // v10.66: one at a time and in order, or the pack paints over the primer
'@ @'
    // v10.66: one at a time and in order, or one card paints over another
'@
SubRx @'
  // (the tuning console's latch) and v8.20 (the primer's tick box) were two
'@ @'
  // (the tuning console's latch) and v8.20 (a tick box on a card since deleted) were two
'@
SubRx @'
    firstRunNext();   // v10.39: the question follows the pack; v10.66: and the primer follows that
'@ @'
    firstRunNext();   // v10.39: the consent question follows the pack
'@
$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + ([regex]::Matches($src, "(?m)^CutBetween ")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
if (([regex]::Matches($script:s, "primer")).Count -ne 0) { throw "still $((([regex]::Matches($script:s,'primer')).Count)) references to primer left" }
# The ONE mention allowed is the BUILDING line saying it is gone.
if (([regex]::Matches($script:s, "FIRST TIME OUT")).Count -ne 1) { throw "FIRST TIME OUT appears the wrong number of times" }
if ($script:s.IndexOf("v10.88: FIRST TIME OUT is gone") -lt 0) { throw "the one allowed mention is not the BUILDING line" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
