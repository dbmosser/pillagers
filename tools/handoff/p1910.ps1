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

# THE USE BAR CLEARS THE EXTRACTION LINES (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  y=Math.round(by-LH(6)-cap-LH(12)-h);
'@ @'
  y=Math.round(by-LH(6)-cap-LH(12)-h);
  // v19.10, from the review (2026-10-07): the extraction lines (EXTRACT A INBOUND, the distance and arrow, HOLD E TO CALL) are drawn
  // in this same band above the belt, later in the frame, so putting a bandage on while waiting at a ring printed them across the
  // bar. While they show, the bar goes above them; while the emote strip is open, above that too.
  try{ if((G.beaconT!==null&&!G.over)||(G.active&&dist(p,G.active)<G.active.r)) y=Math.min(y,Math.round(by-LH(48)-LH(34)-h)); }catch(_ex){}
  if(G.emoteBar) y=Math.min(y,Math.round(H-LH(112)-LH(30)-h));
'@

SubRx @'
var VER='19.09';
'@ @'
var VER='19.10';
'@

$pat = "(?m)^  now:'v19\.09:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v19.10: Healing while you wait for extraction no longer prints the extraction text over the bar. Check 19.10 fails on v19.09',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
