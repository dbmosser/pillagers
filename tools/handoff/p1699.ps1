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

# A PILLAGER WHO IS PICKED UP NO LONGER COUNTS AS A PLAYER 2 KILL WHEN HE DIES LATER (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
      downRdr.byPlayer=false;   // v11.64: his next death is not yours unless you cause it
'@ @'
      downRdr.byPlayer=false;   // v11.64: his next death is not yours unless you cause it
      downRdr.bySeat=0;   // v16.99, co-op hunt 2026-09-28: nor a teammate kill; the player 2 mark outlived the pick-up and a later shell or bleed-out was sent to player 2 as his kill
'@

SubRx @'
          TG.byPlayer=false;   // v13.98, AI audit: as your own revive does, his next death is not yours unless you cause it
'@ @'
          TG.byPlayer=false;   // v13.98, AI audit: as your own revive does, his next death is not yours unless you cause it
          TG.bySeat=0;   // v16.99, co-op hunt 2026-09-28: nor a teammate kill, as your own pick-up now clears it too
'@

SubRx @'
var VER='16.98';
'@ @'
var VER='16.99';
'@

$pat = "(?m)^  now:'v16\.98:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v16.99: Kill credit, co-op hunt 2026-09-28: v15.80 added bySeat beside byPlayer, but the two places a downed pillager stands back up (your pick-up with E in updatePlayer and a crewmate pick-up in updateEnts) cleared only byPlayer. The seat mark from the player 2 downing blow survived the revive, and a later death that writes no mark (a Howler shell, a crawler bite, a bleed-out) reached netEntGone with bySeat still set, so player 2 was sent a kill word, a contract tick and a grudge for a man he did not kill. Both pick-ups now clear bySeat too, the same way netShotTake clears both marks on a blow he survives. No number and no player text moved. Check 16.99 fails on v16.98',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
