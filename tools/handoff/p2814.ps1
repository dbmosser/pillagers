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

# A KIT IS FOR ONE RAID (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
liftResetDay(); if(kitPickOf()!=='mine') kitApply(kitPickOf()); commitKit(); ac(); startRaid(); }],
'@ @'
liftResetDay(); commitKit(); ac(); startRaid(); }],   // v26.xx (kit4): the quick ascent skips the map select screen, so it takes what you packed and never a kit from an earlier visit (cloud review 20)
'@

SubRx @'
function kitDeploy(){ kitAnswer(kitPickOf()); }
'@ @'
// v26.xx (kit4), CLOUD REVIEW FINDING 20: A KIT IS FOR THE RAID YOU PICK IT FOR. A kept RANDOM KIT or BEST KIT rewrote his hands, his gun keys and his packing on every ascent that came after, and the
// lift R quick ascent did it with no page to see. The pick stays on the page until he goes up with it, then it falls back to MY LOADOUT (P.kitPick), so the next map select screen opens on his own
// loadout; the quick ascent never applies a kit; and the line under the row says THIS RAID ONLY while a kit is picked. RANDOM KIT and BEST KIT also leave a gun he locked in the stash alone
// (cloud review 32): a locked gun is never picked and so never moved into the armoury.
function kitDeploy(){ var k=kitPickOf(); P.kitPick='mine'; kitAnswer(k); }
'@

SubRx @'
if(it&&it.use==='gun'&&it.gk&&WEAPONS[it.gk]&&!seen[it.gk]){ seen[it.gk]=1; out.push(it.gk); }
'@ @'
if(it&&it.use==='gun'&&it.gk&&WEAPONS[it.gk]&&!seen[it.gk]&&!stashLocked(P.stash[i])){ seen[it.gk]=1; out.push(it.gk); }   /* v26.xx (kit4): a gun he locked stays where it is */
'@

SubRx @'
el.innerHTML='<b>Going up with:</b> '+KIT_INFO[_kp][0]+'  \u00b7  '+KIT_INFO[_kp][1]; return; }
'@ @'
el.innerHTML='<b>Going up with:</b> '+KIT_INFO[_kp][0]+'  \u00b7  '+KIT_INFO[_kp][1]+'  \u00b7  THIS RAID ONLY'; return; }
'@

SubRx @'
var VER='28.13';
'@ @'
var VER='28.14';
'@

$pat = "(?m)^  now:'v28\.13:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v28.14: A kit is for one raid: the pick resets to MY LOADOUT, and a locked gun is never taken. Check 28.14 fails on v28.13',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
