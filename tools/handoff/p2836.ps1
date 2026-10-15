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

# PLAYER 2 GOES UP WITH HIS KEPT KIT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    askKit(function(){ netSend(peer,{t:'kitok'}); },true);
'@ @'
    NET.kitCard=1; askKit(function(){ netSend(peer,{t:'kitok'}); },true);   // v28.36 (cloud-coop-p2-kept-kit), CLOUD HUNT 2026-10-15: the card was raised, so its answer (or its timeout, current kit) is the kit for this raid
'@

SubRx @'
  if(!m.arc) try{ commitKit(); }catch(e0){}   // its own packed kit, as MY LOADOUT commits it, saved under its own dials   // v23.25 (arcade6): never for an arcade word, whose kit is the sandbox random kit
'@ @'
  if(!m.arc&&!NET.kitCard&&kitPickOf()!=='mine') try{ kitApply(kitPickOf()); }catch(eK){}   // v28.36 (cloud-coop-p2-kept-kit), CLOUD HUNT 2026-10-15: no kit card was raised (the host lift R, a drop in), so player 2 takes his kept kit as the quick ascent does for player 1
  NET.kitCard=0;   // v28.36 (cloud-coop-p2-kept-kit), CLOUD HUNT 2026-10-15: the card is spent with this raid
  if(!m.arc) try{ commitKit(); }catch(e0){}   // its own packed kit, as MY LOADOUT commits it, saved under its own dials   // v23.25 (arcade6): never for an arcade word, whose kit is the sandbox random kit
'@

SubRx @'
var VER='28.35';
'@ @'
var VER='28.36';
'@

$pat = "(?m)^  now:'v28\.35:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v28.36: In co-op, player 2 now goes up with the kit he picked on the map select screen (RANDOM KIT, BEST KIT or FREEBIE KIT) when player 1 takes the quick ascent or when he drops into a raid in progress. Check 28.36 fails on v28.35',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
