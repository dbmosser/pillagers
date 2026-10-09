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

# THE PARTY SCORE SHOWS ON THE RUN CARD (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  return el.innerHTML;
}function netUpEnd(how){
'@ @'
  el.style.display=(n>1)?'':'none';   // v20.66, from the whole-game bug hunt of 2026-10-08 (H26, H41): the block shows; the element starts hidden and nothing here ever showed it
  return el.innerHTML;
}function netUpEnd(how){
'@

SubRx @'
  var el=document.getElementById('oc_party'), r=NET.roster||[], h='', i, e, st, c;
  if(!el) return false;
'@ @'
  var el=document.getElementById('oc_party'), r=NET.roster||[], h='', i, e, st, c;
  if(!el) return false;
  // v20.66, from the whole-game bug hunt of 2026-10-08 (H26, H41): THE PARTY SCORE BLOCK IS THE ONE THAT SHOWS. Both end of raid
  // blocks write this one element, and this older one (how it ended, kills, value) always wrote last, on this window and again when
  // a teammate finished, so the PARTY block of his pick 5 (v17.39: items carried out, downs and revives too) never once showed on a
  // run card. When this window sent its score word for the raid, that block is drawn here instead; this one stays for a raid without it.
  if(NET.on&&NET.sc&&NET.scSd!==undefined&&NET.sc[NET.seat]&&NET.sc[NET.seat].sd===NET.scSd&&netScoreDraw()) return true;
'@

SubRx @'
var VER='20.65';
'@ @'
var VER='20.66';
'@

$pat = "(?m)^  now:'v20\.65:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v20.66: In co-op, the run card now shows the party score with downs, revives and items for every player. Check 20.66 fails on v20.65',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
