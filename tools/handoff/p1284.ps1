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

# FOUND BY tools/lint.ps1, and it is the SAME DEFECT AS v12.73 in a second place.
# The lint class is "a message written and then written over in the same breath",
# and it named five functions. I read all five. Three are false alarms, where the
# calls sit in branches that cannot both run. This one is real.
#
# WHAT IT IS. Equipping a gun out of the backpack has to tell him two things: what
# happened to the gun it displaced, and what he is now holding. It says both, one
# after the other, into a message line that holds exactly one string. So the first
# is destroyed by the second every single time.
#
# The line he loses is the one he cannot work out for himself. "Left behind"
# means an issued loaner is gone for good. "It goes back to the armoury" means a
# gun he owns has left his hands and is waiting at base, not in his backpack. He
# is told neither: he is told the name of the thing he just equipped, which he
# already knew, because he chose it.
#
# Same shape as the fix at v12.73: the first line is kept rather than spoken, and
# the one line that is spoken carries both facts.
SubRx @'
    if(oldIssued) say(oldW.name+' was issued kit, left behind.');
'@ @'
    // v12.84: KEPT, not spoken. The line below about what he is now holding used
    // to overwrite this in the same frame, so he was never told.
    if(oldIssued) _oldLine=oldW.name+' was issued kit, left behind.';
'@

SubRx @'
    else if(oldArm&&P.weapons.indexOf(oldW.id)>=0) say(oldW.name+' is yours; it goes back to the armoury.');
'@ @'
    else if(oldArm&&P.weapons.indexOf(oldW.id)>=0) _oldLine=oldW.name+' is yours; it goes back to the armoury.';
'@

SubRx @'
  if(_kept) say(g.name+' to your empty slot. '+_kept.name+' stays in hand.');
  else say(g.name+(toSec?' to secondary':' equipped'));
'@ @'
  // v12.84: one line, both facts. What happened to the gun he displaced is the
  // half he cannot work out for himself, and it was the half being destroyed.
  var _newLine=_kept?(g.name+' to your empty slot. '+_kept.name+' stays in hand.')
                    :(g.name+(toSec?' to secondary':' equipped'));
  say(_oldLine?(_oldLine+' '+_newLine):_newLine);
'@

SubRx @'
  G.bag.splice(ix,1);
  if(oldW&&oldW.id!=='fists'){
'@ @'
  G.bag.splice(ix,1);
  var _oldLine='';   // v12.84: what happened to the gun this one displaces
  if(oldW&&oldW.id!=='fists'){
'@

# NEW IN.
SubRx @'
  'SEVEN MORE LINES USE THE WORDS YOU CHOSE. The shop said cash, the seal said tier, and three lines called the backpack a bag. A sweep written for this found them; the same sweep says the rest of the game is clean.',
'@ @'
  'SEVEN MORE LINES USE THE WORDS YOU CHOSE. The shop said cash, the seal said tier, and three lines called the backpack a bag. A sweep written for this found them; the same sweep says the rest of the game is clean.',
  'EQUIPPING A GUN TELLS YOU WHAT HAPPENED TO THE ONE IT REPLACED. That a loaner was left behind, or that a gun you own went back to the armoury rather than into your backpack, was written and then written over by the name of the gun you had just chosen, in the same frame, every time.',
'@

# STAMPS.
SubRx @'
var VER='12.83';
'@ @'
var VER='12.84';
'@
SubRx @'
var WHATSNEW_VER='12.83';
'@ @'
var WHATSNEW_VER='12.84';
'@
$cnt=([regex]::Matches($s,"now:'v12\.83:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v12.83 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v12\.83:[^']*'",{ param($m) "now:'v12.84: found by tools/lint.ps1, and it is the same defect as v12.73 in a second place. The lint class is a message written and then written over in the same breath, and it named five functions; I read all five, three are false alarms where the calls sit in branches that cannot both run, and this one is real. Equipping a gun out of the backpack has to tell him two things, what happened to the gun it displaced and what he is now holding, and it says both one after the other into a message line that holds exactly one string, so the first is destroyed by the second every single time. The line he loses is the one he cannot work out for himself: left behind means an issued loaner is gone for good, and it goes back to the armoury means a gun he owns has left his hands and is waiting at base rather than sitting in his backpack. He was told neither. He was told the name of the thing he had just equipped, which he already knew, because he chose it. Same shape as the fix at v12.73: the first line is kept rather than spoken, and the one line that is spoken carries both facts. Check 12.84 equips a gun over an issued loaner and requires the line he is left with to say what became of the loaner, does the same over a gun he owns and requires the armoury to be named, and controls that equipping over an empty hand still says exactly what it always said; fails on v12.83.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
