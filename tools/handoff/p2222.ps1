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

# THE MEDICAL KEY NEVER BINDS A BANDAGE YOU DO NOT HAVE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
        var _dk=_hs2?(_hs2.itemKey||((_hs2.kind==='heal'||_hs2.kind==='armor'||_hs2.kind==='throw')&&_hs2.icon&&ITEMS[_hs2.icon]&&(_hs2.kind!=='heal'||_hs2.count>0)?_hs2.icon:null)):null;   // an empty Medical cell shows a bandage it does not hold
'@ @'
        // v22.22, from the whole-game bug hunt of 2026-10-08 (K33): A PRESS ON THE MEDICAL KEY OF THE RAID BELT DRAGS ONLY A HEAL THE
        // BACKPACK HOLDS. At full health findHeal skips every heal, so the Medical cell shows a Bandage as a stand-in while it counts
        // the Medkits, and the count test let the press pick that Bandage up: the release bound a dead Bandage key (grey, 0) into the
        // belt plan and the Medkits stayed on Medical. The floor belt has tested the backpack since v15.69; the raid belt does too
        // now. A Medkit still goes on any key from its backpack tile.
        var _dk=_hs2?(_hs2.itemKey||((_hs2.kind==='heal'||_hs2.kind==='armor'||_hs2.kind==='throw')&&_hs2.icon&&ITEMS[_hs2.icon]&&(_hs2.kind!=='heal'||G.bag.indexOf(_hs2.icon)>=0)?_hs2.icon:null)):null;   // an empty Medical cell shows a bandage it does not hold
'@

SubRx @'
var VER='22.21';
'@ @'
var VER='22.22';
'@

$pat = "(?m)^  now:'v22\.21:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v22.22: In a raid at full health, dragging the Medical belt key no longer binds a Bandage you do not carry. Check 22.22 fails on v22.21',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
