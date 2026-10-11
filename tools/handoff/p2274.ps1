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

# WIND-UPS ON THE USE BAR ONLY (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  G.bag.splice(idx,1); startPrep('heal',k); blip('pick');
  say('Applying '+it.name+'...');
'@ @'
  G.bag.splice(idx,1); startPrep('heal',k); blip('pick');
  // v22.74, the raid text rewrite (R29): WIND-UPS SHOW ON THE USE BAR ONLY. Applying a Bandage or a Medkit, slotting a plate, and
  // bandaging or slotting a plate for a teammate each said a feed line as the wind-up began, while the use bar under the belt
  // already draws APPLYING BANDAGE, SLOTTING ARMOUR PLATE or ... ON NAME with its fill and seconds. The lines are gone; the
  // refusals and the results (healed, armour up, patched up) still speak.
'@

SubRx @'
      G.bag.splice(ix,1); startPrep('heal',s2.itemKey); blip('pick');
      say('Applying '+ait.name+'...');
'@ @'
      G.bag.splice(ix,1); startPrep('heal',s2.itemKey); blip('pick');   // v22.74 (R29): the use bar says APPLYING
'@

SubRx @'
  G.bag.splice(ix,1); startPrep('armor',k4);
  say(('Slotting '+it.name).toUpperCase());   // v22.58: the shooter voice
'@ @'
  G.bag.splice(ix,1); startPrep('armor',k4);   // v22.74 (R29): the use bar says SLOTTING
'@

SubRx @'
  say((arm?'Slotting a plate for ':'Bandaging ')+nm+'.'); blip('pick');
'@ @'
  blip('pick');   // v22.74 (R29): the use bar says APPLYING or SLOTTING ... ON NAME
'@

SubRx @'
var VER='22.73';
'@ @'
var VER='22.74';
'@

$pat = "(?m)^  now:'v22\.73:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v22.74: Healing and slotting a plate no longer put a line in the feed as they start; the use bar shows it. Check 22.74 fails on v22.73',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
