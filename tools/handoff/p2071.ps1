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

# A RESTORE CODE LEAVES THE FLOOR CRATES BEHIND (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  P.ghost=(o.gh&&typeof o.gh==='object'&&typeof o.gh.tag==='string'&&o.gh.tag)?o.gh:null;
'@ @'
  P.ghost=(o.gh&&typeof o.gh==='object'&&typeof o.gh.tag==='string'&&o.gh.tag)?o.gh:null;
  // v20.71, from the whole-game bug hunt of 2026-10-08 (H32, H36): THE CRATES ON THE FLOOR GO WITH THE SAVE THEY CAME FROM. Items
  // dropped on the Undercroft floor are written down (P.floorDrops) so a reload brings them home, and a restore code left that list
  // alone, so the reload after a restore put the replaced character's crates into the restored character's stash. The list is
  // cleared here and this window's own crates leave the floor (and the other floor in a party); the UNDO copy, written before this,
  // still holds them for the old save, so nothing is lost and nothing is copied.
  var _fdI={}, _fdA=P.floorDrops||[], _fdN;
  for(_fdN=0;_fdN<_fdA.length;_fdN++) if(_fdA[_fdN]&&_fdA[_fdN].id){ _fdI[_fdA[_fdN].id]=1; try{ if(typeof NET==='object'&&NET&&NET.on) netBroadcast({t:'hdrop',op:'took',id:_fdA[_fdN].id}); }catch(_fdb){} }
  P.floorDrops=[];
  if(typeof HB==='object'&&HB&&HB.drops) HB.drops=HB.drops.filter(function(q){ return !(q&&_fdI[q.id]===1); });
'@

SubRx @'
var VER='20.70';
'@ @'
var VER='20.71';
'@

$pat = "(?m)^  now:'v20\.70:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v20.71: A restore code no longer hands the floor crates of the replaced save to the restored character. Check 20.71 fails on v20.70',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
