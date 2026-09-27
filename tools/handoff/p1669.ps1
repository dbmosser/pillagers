$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $new = $new.Replace("`r`n", "`n")
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# NOTHING LEFT OPEN IN THE UNDERCROFT RIDES UP INTO THE RAID (stability pass, 2026-09-27; drafted by a review agent, reviewed by a second).

SubRx @'
  if(netGuestHeld()) return false;   // v15.91: in a party only the host takes the lift; a guest goes up on the host word (the net section)
  G=buildRaid(false);
'@ @'
  if(netGuestHeld()) return false;   // v15.91: in a party only the host takes the lift; a guest goes up on the host word (the net section)
  // v16.69, stability (co-op review): NOTHING LEFT OPEN IN THE UNDERCROFT RIDES UP. A teammate with the pause box or the floor
  // backpack open when the host took the party up (netUpStart), or a host who opened either during the kit wait (netKitGo), went
  // up with it still open. The floor pause box, labelled PAUSED and RETURN TO THE UNDERCROFT, sat over the raid start and took
  // the pad and every raid key, and the unseen floor backpack kept its flag and its stale copy for the whole raid (v16.66 already
  // stops B from shutting it up top). The box shuts through its own door while this window is still on the floor, so a note
  // typed in it is banked as a floor note. The backpack is dropped without saving, as endRaid and showScreen(hub) drop it: the
  // kit that goes up was committed before this line. No player text, no number and no seeded draw moved.
  try{ if(pauseOpen) togglePauseBox(false); }catch(_pz){}
  hubBagOpen=false; hubBagG=null;
  G=buildRaid(false);
'@

SubRx @'
  snap=netUpSnapP();
  try{ commitKit(); }catch(e0){}   // its own packed kit, as MY LOADOUT commits it, saved under its own dials
'@ @'
  // v16.69: the pause box shuts before the snapshot, under this window own dials, so a note typed in it is banked and saved with
  // the save that a surface which does not match puts back, not told Noted and then rolled away. startRaid shuts it for the rest.
  try{ if(pauseOpen) togglePauseBox(false); }catch(_pz0){}
  snap=netUpSnapP();
  try{ commitKit(); }catch(e0){}   // its own packed kit, as MY LOADOUT commits it, saved under its own dials
'@

SubRx @'
var VER='16.68';
'@ @'
var VER='16.69';
'@

$pat = "(?m)^  now:'v16\.68:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v16.69: NOTHING LEFT OPEN IN THE UNDERCROFT RIDES UP INTO THE RAID. Stability pass before a co-op session. A teammate with the pause box or his Undercroft backpack open when the host took the party up arrived with the pause box over the raid start, holding his controller, and the unseen backpack still open for the whole raid. Both now shut when a raid starts; a note typed in the box is kept as a floor note. Check 16.69 fails on v16.68',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
