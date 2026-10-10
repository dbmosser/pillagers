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

# AN OLD BELT PLAN NEVER COVERS MEDICAL OR THE PLATE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  for(i=0;i<over.length;i++) for(j=HOTBAR_N-1;j>=0;j--) if(out[j]===undefined){ out[j]=over[i]; break; }
'@ @'
  // v22.39, from the review of the four-gun belt (build 3): A BINDING PUSHED PAST KEY 9 NEVER COVERS MEDICAL OR THE PLATE. Keys 8 and 9
  // were the two free keys before the slide, so an old plan with a Medkit on key 8 and a Stim on key 9 is natural; both slid past key
  // 9 and took the highest free keys, key 9 (the plate key) and key 8 (Medical). With Medical covered the Bandages issued at every
  // ascent, and any heal he did not bind, could not be used from the belt for the whole raid, and a carried plate had no key at all.
  // Such a binding now takes a free gun key 3 or 4 (any item may go on a gun key, decision D2), and with neither free it is dropped
  // from the plan rather than covering a throw, Medical or the plate.
  for(i=0;i<over.length;i++) for(j=2;j<GUNKEYS&&j<HOTBAR_N;j++) if(out[j]===undefined){ out[j]=over[i]; break; }
'@

SubRx @'
var VER='22.38';
'@ @'
var VER='22.39';
'@

$pat = "(?m)^  now:'v22\.38:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v22.39: An old belt plan with items on keys 8 and 9 now moves them to keys 3 and 4, so Medical and the plate keep their keys. Check 22.39 fails on v22.38',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
