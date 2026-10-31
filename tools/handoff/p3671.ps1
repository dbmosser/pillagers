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

# COOKED GRENADE WARNING STAYS OVER YOUR HEAD (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function cookFeed(p){
  var s=cookShout(p);
  if(!s||!G||G.sim||!G.player) return null;
  return feedAdd([{t:s,c:HUDC.danger}],'danger',{key:'cookshout'});
}

'@ @'
// v36.xx (cw-cx-cookline), his 10-31 report with a screenshot of a red feed line "cooked grenade! throw grenade now x6": "this is a glitch, i am not near any cooked grenades". The last-second shout is NOT a feed line any more (cookFeed is gone, the cw-feedall copy); it flashes only over his own pillager's countdown while he holds the cooked frag, drawn by the HUD from cookShout.

'@

SubRx @'
      try{ cookFeed(p); }catch(_cfd){}   // v28.xx (cw-feedall): the shout is in the feed too
'@ @'
      // v36.xx (cw-cx-cookline): no feed copy of the shout; it stays over his own head only.
'@

SubRx @'
var VER='36.70';
'@ @'
var VER='36.71';
'@

$pat = "(?m)^  now:'v36\.70:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v36.71: The cooked grenade warning no longer shows in the message feed. It still flashes over your own head while you hold a cooked frag. Check 36.71 fails on v36.70',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
