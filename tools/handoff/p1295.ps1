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

# FINDING 10 OF THE 2026-09-11 AUDIT, and it is the floor twin of the raid rule at
# v12.22. HIS 2026-09-03 ANSWER: CLOSE and ESC on every menu; the corollary is that
# what is in front owns the keyboard.
#
# WHAT HAPPENS. In the Undercroft he presses ESC, the box says PAUSED, and he presses
# SPACE while reading the key line the box itself prints. A clank sounds from nowhere
# and a roll is stored; the floor is frozen, so the roll is not spent until he closes
# the box, and then his character dodge-rolls out of nothing on resume. TAB or I
# toggles the backpack invisibly underneath, so closing the box reveals a backpack he
# never opened. H flips the controls panel under the box. ENTER spends the unread NEW
# IN card behind it, which only a returning player has.
#
# WHY. The floor's own busy test counts the title screen, any modal, the character
# screen and the terminal, and does not count the pause box, which is not a modal.
# The room really is frozen and the box really does say PAUSED: only the key handler
# disagrees.
#
# AND IT IS A REGRESSION, NOT AN OLD OMISSION. Until v12.22 the box focused its note
# field on open, and the TEXTAREA bail at the top of this listener swallowed every
# floor key as a side effect. v12.22 removed that focus, deliberately, and gave the
# RAID a replacement guard. The floor never got one.
#
# THE FIX IS THE SAME SHAPE AS THE RAID'S, which is a lockout rather than another
# entry in a list: a list has to be updated every time a key is added, and this one
# has been missed once already. P and ESC pass, because they are the two keys the
# box's own legend names and the two that close it; everything else stops.
SubRx @'
  if(state==='hub'){
    keys[e.code]=true;
'@ @'
  if(state==='hub'){
    keys[e.code]=true;
    // v12.95, audit finding 10: NOTHING ON THE FLOOR ANSWERS A KEY WHILE THE PAUSE
    // BOX IS UP, except the two its own legend names. The raid has had this rule
    // since v12.22 and its comment calls the floor the original; the floor itself
    // never had it. A regression rather than an omission: until v12.22 the box
    // focused its note field on open and the TEXTAREA bail above swallowed these
    // keys as a side effect, and when that focus went only the raid was given a
    // replacement.
    //
    // A LOCKOUT, NOT ANOTHER ENTRY IN THE BUSY LIST, for two reasons. The list has
    // to be updated every time a key is added and has been missed once already. And
    // ESC and P must still reach the toggle that closes the box, which is exactly
    // what the busy list would stop.
    if(pauseOpen&&e.code!=='KeyP'&&e.code!=='Escape'){ e.preventDefault(); return; }
'@

# NEW IN.
SubRx @'
  'GOING DOWN INSIDE A LANDED EXTRACTION SHOWS YOU THE WAY OUT, EVEN IF SOMEBODY ELSE CALLED IT.
'@ @'
  'THE PAUSE BOX IN THE UNDERCROFT OWNS THE KEYBOARD NOW. Pressing SPACE while it was up stored a roll your character spent the moment you closed it, TAB opened the backpack invisibly underneath, H flipped the controls panel behind it, and ENTER threw away the update card you had not read. Only P and ESC answer while it is up, which are the two keys it names.',
  'GOING DOWN INSIDE A LANDED EXTRACTION SHOWS YOU THE WAY OUT, EVEN IF SOMEBODY ELSE CALLED IT.
'@

# STAMPS.
SubRx @'
var VER='12.94';
'@ @'
var VER='12.95';
'@
SubRx @'
var WHATSNEW_VER='12.94';
'@ @'
var WHATSNEW_VER='12.95';
'@
$cnt=([regex]::Matches($s,"now:'v12\.94:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v12.94 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v12\.94:[^']*'",{ param($m) "now:'v12.95: finding 10 of the 2026-09-11 audit, and the floor twin of the raid rule at v12.22. In the Undercroft he presses ESC, the box says PAUSED, and he presses SPACE while reading the key line the box itself prints: a clank sounds from nowhere and a roll is stored, and because the floor is frozen the roll is not spent until he closes the box, so his character dodge-rolls out of nothing on resume. TAB or I toggles the backpack invisibly underneath, so closing the box reveals a backpack he never opened; H flips the controls panel under the box; and ENTER spends the unread NEW IN card behind it, which only a returning player has, because a profile with no runs has the card stamped seen already. The floor own busy test counts the title screen, any modal, the character screen and the terminal, and does not count the pause box, which is not a modal; the room really is frozen and the box really does say PAUSED, and only the key handler disagrees. It is a regression rather than an old omission: until v12.22 the box focused its note field on open and the TEXTAREA bail at the top of the listener swallowed every floor key as a side effect, and v12.22 removed that focus deliberately and gave the RAID a replacement guard while the floor never got one. The fix is the same shape as the raid, a lockout rather than another entry in a list, for two reasons: a list has to be updated every time a key is added and has been missed once already, and ESC and P must still reach the toggle that closes the box, which is exactly what the busy list would stop. Check 12.95 raises the box on the floor and presses SPACE, TAB, I, H and ENTER through the real listener, requiring no roll stored, no backpack opened, no controls panel flipped and the update card still unread, and controls that P still closes the box and that with the box down every one of those keys still does its job; fails on v12.94.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
