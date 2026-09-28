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

# GOING DOWN OR ROLLING STOPS A TEAMMATE PICK-UP INSTEAD OF FREEZING IT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    if(tickDowned(dt)) return;
'@ @'
    // v17.05, co-op hunt 2026-09-28: GOING DOWN LETS GO OF A PICK-UP. The pick-up clock is reset only inside netRevHold, on a
    // standing frame, so going down part way through froze it: the REVIVING bar hung over the teammate for the whole bleed-out and
    // E held on once up again carried on from the old progress instead of starting over (v16.05). Cleared here, every downed frame.
    G.netRevT=0; G.netRevS=-1; G.netRevDone=-1;
    if(tickDowned(dt)) return;
'@

SubRx @'
    p.roll-=dt;
'@ @'
    if(G.netRevT){ G.netRevT=0; G.netRevS=-1; }   // v17.05, co-op hunt 2026-09-28: a roll breaks a pick-up hold too; netRevHold, which reset it, runs only after a roll
    p.roll-=dt;
'@

SubRx @'
var VER='17.04';
'@ @'
var VER='17.05';
'@

$pat = "(?m)^  now:'v17\.04:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v17.05: The pick-up clock (G.netRevT, G.netRevS) and the kept pick-up (G.netRevDone) were reset only inside netRevHold, which runs only on a standing frame, and the downed and roll branches of updatePlayer return before it, so going down or rolling mid pick-up froze the clock: the REVIVING bar drew over the teammate for the whole bleed-out and a later hold resumed at the old progress with no Reviving line, against the v16.05 rule that a broken hold starts again. The downed branch now clears all three at its top and the roll branch clears the clock, so every route into those states lets go of the pick-up. The wait for his up word (G.netRevWait) is left as it was. No number moved. Check 17.05 fails on v17.04',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
