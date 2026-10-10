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

# THE KEPT RAID KEEPS ITS OWN TERMS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function termsOn(){ var R=termsRaid(); if(R&&!G.over) return R; if(!Array.isArray(P.terms)) P.terms=[]; return P.terms; }
'@ @'
// v22.27, from the whole-game bug hunt of 2026-10-08 (K38): THE RAID A HOST KEEPS FOR HIS PARTY KEEPS ITS OWN TERMS. Once the host
// was out, the raid he runs on for a teammate still up top (NET.specG) is over in his window, so it read his own signed list, and
// Terms he signed on the floor for his next run changed that teammate's raid at once: every new pillager wave hostile with a
// grudge under THEY KNOW YOU, every Listener hearing 50% farther under SILENT RUNNING, and no hazard pay for either. That raid now
// keeps the list it was built with (netSpecStart) and reads it until it ends; the floor still reads and signs his own list.
function termsOn(){ var R=termsRaid(); if(R&&(!G.over||(typeof NET==='object'&&NET&&NET.specG===G))) return R; if(!Array.isArray(P.terms)) P.terms=[]; return P.terms; }
'@

SubRx @'
  NET.specG=G; NET.specHow=String(how||'extract'); NET.specAcc=0; NET.specIdle=0; NET.specErr=0;
'@ @'
  NET.specG=G; NET.specHow=String(how||'extract'); NET.specAcc=0; NET.specIdle=0; NET.specErr=0;
  if(!Array.isArray(G.terms)) G.terms=termsOn().slice();   // v22.27 (K38): the Terms this raid was built with, kept for the party; Terms signed on the floor meanwhile are for the next run
'@

SubRx @'
var VER='22.26';
'@ @'
var VER='22.27';
'@

$pat = "(?m)^  now:'v22\.26:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v22.27: In co-op, Terms the host signs while his teammate is still up top no longer change that raid. Check 22.27 fails on v22.26',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
