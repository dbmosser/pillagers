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

# FOCUS AIM DOES NOT CARRY INTO THE NEXT RAID (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  hubBagOpen=false; hubBagG=null;
  G=buildRaid(false);
'@ @'
  hubBagOpen=false; hubBagG=null;
  // v20.44, from the whole-game bug hunt of 2026-10-08 (H43): FOCUS AIM NEVER RIDES UP FROM THE LAST RAID. RS click toggles focus aim
  // on a pad, and the toggle was cleared only by a pad poll that saw the raid over, which never comes: the end-of-raid card owns the
  // pad from the frame the raid ends (an instant quit goes straight to the floor), so pollPad returns before that line. A raid left
  // in focus aim started the next one in it: 62% walking speed, no sprint, [ADS] on the HUD, until RS was clicked again. Every raid
  // now starts with the toggle off and the steadying after a shot spent. No player text, no number and no seeded draw moved.
  if(typeof PAD!=='undefined'&&PAD){ PAD.adsTog=false; PAD.adsT=0; }
  G=buildRaid(false);
'@

SubRx @'
var VER='20.43';
'@ @'
var VER='20.44';
'@

$pat = "(?m)^  now:'v20\.43:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v20.44: On a controller, a new raid always starts with focus aim off, whatever the last raid ended in. Check 20.44 fails on v20.43',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
