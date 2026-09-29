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

# A KEPT PLAYER 2 CONTROLLER PICK FOR A PAD THAT IS NOT PLUGGED IN NO LONGER GIVES THE ONLY CONTROLLER TO PLAYER 1 (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  if(pick>=0&&pick!==taken) return (pick<n&&gps[pick]&&gps[pick].connected)?pick:-1;
'@ @'
  // v17.26, co-op hunt 2026-09-28: a player 2 pick that is not plugged in, while the host picked none, falls through to the
  // first free pad. It returned -1 here, so the host rule above (no pick: the first pad player 2 is not on) gave the only
  // controller to player 1, and player 2, whose window cannot reopen PARTY to change the kept pick, stood still.
  if(pick>=0&&pick!==taken&&pick<n&&gps[pick]&&gps[pick].connected) return pick;
  if(pick>=0&&pick!==taken&&taken>=0) return -1;
'@

SubRx @'
  if(NET.same==='p2') return (netPadIxOk(NET.padIx)>=0&&NET.padIx!==NET.padOther)?NET.padIx:-2;
'@ @'
  // v17.26, co-op hunt 2026-09-28: a pick this window last saw unplugged, while the host picked none, takes any pad but the
  // sender own, as no pick does, since netPadFor then gives player 2 the first free pad and the host hands that one over.
  if(NET.same==='p2') return (netPadIxOk(NET.padIx)>=0&&NET.padIx!==NET.padOther&&(NET.padOther>=0||NET.padPickOk!==false))?NET.padIx:-2;
'@

SubRx @'
  if(focused){
    NET.padFwd=null;
'@ @'
  if(focused){
    NET.padFwd=null;
    NET.padPickOk=(netPadIxOk(NET.padIx)<0)||!!(NET.padIx<gps.length&&gps[NET.padIx]&&gps[NET.padIx].connected);   // v17.26, co-op hunt 2026-09-28: whether this window pick was plugged in on its last live read, for netPadWant
'@

SubRx @'
var VER='17.25';
'@ @'
var VER='17.26';
'@

$pat = "(?m)^  now:'v17\.25:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v17.26: Co-op hunt 2026-09-28, finding 8: netPadFor gave player 2 -1 for a kept pick that was not plugged in, so the host with no pick worked out player 2 as on no pad and took the first connected one under his v16.35 rule (a second controller goes to player 1). With one controller plugged in that is the only one, so it drove player 1 in both windows, and the pick is kept in localStorage and read at every player 2 boot, and the PARTY window that changes it cannot be reopened from the player 2 window. netPadFor now lets a player 2 pick that is not plugged in fall through to the first free pad when the host picked none, so the host rule takes only a pad beyond the one player 2 is on. A pick while the host picked a controller keeps its old rule (nothing), as check 15.77 asks. netPadTick notes on each live read whether this window pick is plugged in (NET.padPickOk), and netPadWant in the player 2 window then takes any pad but the host own from the window in front, as it does with no pick, so player 2 also plays when the player 1 window is the one in front. No number and no player text moved. Check 17.26 fails on v17.25',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
