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

# NO CLOSE CALL ON THE FLOOR (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  if(!p||G.sim||G.over||!(p.roll>0)||!(p.iv>0)) return false;
'@ @'
  // v28.51 (cloud-feel-closecall-downed), CLOUD HUNT 2026-10-15: a man on the floor or in the death beat is not dodging anything, so a round
  // that reaches him there pays no CLOSE CALL (a crawler hanging on him could down him in the middle of a roll, with the roll's i-frames still on).
  if(!p||G.sim||G.over||p.downed||p.dying||!(p.roll>0)||!(p.iv>0)) return false;
'@

SubRx @'
p.hp=0; p.downed=true; p.downT=CFG.downTime; p.pendKiller=src; p.prep=null; p.prepA=null; G.crouchTog=false; G.pCrouch=false;
'@ @'
    // v28.51 (cloud-feel-closecall-downed), CLOUD HUNT 2026-10-15: and going down ends a roll. The roll counts down below the downed return of
    // updatePlayer, so a man downed mid-roll kept it frozen through the bleed-out and every revive handed it back: he slid on, and the next round
    // paid a CLOSE CALL for a dodge he never made.
p.hp=0; p.downed=true; p.downT=CFG.downTime; p.pendKiller=src; p.prep=null; p.prepA=null; G.crouchTog=false; G.pCrouch=false; p.roll=0;
'@

SubRx @'
var VER='28.50';
'@ @'
var VER='28.51';
'@

$pat = "(?m)^  now:'v28\.50:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v28.51: A round that reaches you while you are down, or right after you get up, no longer pays a CLOSE CALL, and you no longer slide on after getting up. Check 28.51 fails on v28.50',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
