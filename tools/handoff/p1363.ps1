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

# IN-RAID AUDIT OF 2026-09-14, finding 2: BELT ITEMS COULD BE USED WHILE DOWNED, AND WERE LOST.
# The belt key and the trigger on a belt cell reach useHot, and neither it nor useMedical,
# useArmor or useStim checked for a downed player; only the throws did. The downed branch of
# updatePlayer returns before the heal ticks, so a Medkit used on the floor left the bag,
# said Applying, and never healed; hauled aboard, it was not banked either. A Stim burned
# its ten seconds while he crawled. Using anything from the belt is now refused while down,
# with a line saying why; the self-revive and the surrender are untouched.
SubRx @'
function useHot(){
  var sl=hotbarSlots(),s2=sl[hotSel()];
  if(!s2) return;
'@ @'
function useHot(){
  // v13.63, in-raid audit: nothing on the belt is used from the floor. The heal never ticks
  // while he is down, so the item was spent for nothing.
  if(G&&G.player&&G.player.downed){ if(!G.sim) say('Not while you are down.'); return; }
  var sl=hotbarSlots(),s2=sl[hotSel()];
  if(!s2) return;
'@
SubRx @'
var VER='13.62';
'@ @'
var VER='13.63';
'@

$pat = "(?m)^  now:'v13\.62:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v13.63: NOTHING ON THE BELT IS SPENT FROM THE FLOOR. In-raid audit of 2026-09-14, finding 2: the belt key and the trigger on a belt cell reach useHot, and nothing on that path checked for a downed player, while the downed branch of updatePlayer returns before the heal ticks, so a Medkit used while down left the bag, said Applying and never healed, and a Stim burned its ten seconds on the floor. useHot now refuses while down and says why; the self-revive and the surrender are untouched. Check 13.63 downs the player with a Bandage on the Medical cell and requires the use refused with the Bandage kept, with the same use standing as the control; it fails on v13.62',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
