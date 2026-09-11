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

# HIS NOTE, after a live round: "weapon replacement is broken. scav pistol should
# ALWAYS get booted in favor of a better weapon. Other weapons should never
# auto-replace each other, e.g. weapon 3 (not including scav pistol) should go
# into the backpack."
#
# WHAT IT WAS. A found gun took the second slot if that slot was empty, which is
# right. If it was not empty, the pickup replaced THE GUN IN HIS HANDS on nothing
# more than a tier or a condition comparison, and pushed the gun he was holding
# into the backpack. So a good rifle he had chosen could be knocked out of his
# hands by the next thing he pulled out of a crate, mid raid, because the game
# judged it a step up. He never asked for that trade and was never asked.
#
# THE RULE HE WANTS, and it is a better rule. A slot YIELDS if it is empty, if it
# is Bare Hands, or if it holds the Scav Pistol, which is the starter and is meant
# to be replaced by the first real thing he finds. A slot holding anything else is
# his and is left alone. A third gun, with both slots holding real weapons, goes
# into the backpack, where he can equip it himself if he wants it.
#
# The empty-magazine case is kept: a gun with no rounds and none to feed it is not
# a weapon he is relying on, and that test predates this note.
SubRx @'
      var _secFree=(!p.sec||p.sec.id==='fists'||p.sec.mag===0);
'@ @'
      // v12.78, HIS NOTE after a live round: A SLOT YIELDS, OR IT IS LEFT ALONE.
      // The Scav Pistol is the starter and is always booted for something better,
      // and so are Bare Hands and an empty slot. Any other gun is one he chose,
      // and a pickup no longer knocks it out of his hands: with both slots
      // holding real weapons the find goes to the backpack, where equipping it is
      // his decision to make.
      function _yields(w){ return !w||w.id==='fists'||w.id==='pistol'||w.mag===0; }
      var _secFree=_yields(p.sec);
      var _handFree=_yields(p.wep);
'@

SubRx @'
      else if(autoEquipOn()&&(tierUp||condUp)){
'@ @'
      else if(autoEquipOn()&&(tierUp||condUp)&&_handFree){
'@

# NEW IN.
SubRx @'
  'THE PRICE OF WALKING OUT IS THE PRICE YOU ACTUALLY PAY. The confirm button quoted a fine of a hundred or more XP to players who did not have it, and the line afterwards announced taking it, when the fine has always stopped at zero and took nothing.',
'@ @'
  'THE PRICE OF WALKING OUT IS THE PRICE YOU ACTUALLY PAY. The confirm button quoted a fine of a hundred or more XP to players who did not have it, and the line afterwards announced taking it, when the fine has always stopped at zero and took nothing.',
  'A GUN YOU CHOSE IS NOT SWAPPED OUT BEHIND YOUR BACK. A pickup used to replace the weapon in your hands whenever the game judged it a step up. Only an empty slot, Bare Hands or the Scav Pistol yields now; with two real guns on you, the find goes to the backpack and equipping it is your call.',
'@

# STAMPS.
SubRx @'
var VER='12.77';
'@ @'
var VER='12.78';
'@
SubRx @'
var WHATSNEW_VER='12.77';
'@ @'
var WHATSNEW_VER='12.78';
'@
$cnt=([regex]::Matches($s,"now:'v12\.77:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v12.77 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v12\.77:[^']*'",{ param($m) "now:'v12.78: HIS NOTE after a live round, and it is a better rule than the one that was there. A found gun took the second slot if that slot was empty, which is right. If it was not empty, the pickup replaced THE GUN IN HIS HANDS on nothing more than a tier or condition comparison and pushed the gun he was holding into the backpack, so a rifle he had chosen could be knocked out of his hands by the next thing he pulled out of a crate, mid raid, because the game judged it a step up. He never asked for that trade and was never asked about it. His rule: the Scav Pistol is the starter and should ALWAYS be booted for something better, other weapons should never auto-replace each other, and a third gun goes into the backpack. So a slot YIELDS if it is empty, if it is Bare Hands, or if it holds the Scav Pistol; a slot holding anything else is his and is left alone, and with both slots holding real weapons the find goes to the backpack where equipping it is his decision. The empty-magazine test is kept, because a gun with no rounds and nothing to feed it is not a weapon he is relying on and that rule predates this note. Check 12.78 pulls a better gun with a real weapon in each hand and requires both hands untouched and the gun in the backpack, pulls the same gun with the Scav Pistol in hand and requires the pistol booted, and controls that an empty second slot still takes it; fails on v12.77.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
