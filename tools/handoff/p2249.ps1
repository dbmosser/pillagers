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

# THE KIT PISTOL STAYS OFF GUN 1 (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
        } else if(G.bag.indexOf('gun_'+_d3g)<0) continue;
        _d3[_d3i]=_d3g;
'@ @'
        } else if(G.bag.indexOf('gun_'+_d3g)<0) continue;
        // v22.49, from the review of build 4: THE FREEBIE KIT PISTOL IN THE BACKPACK IS STILL THE KIT PISTOL. Drawing a backpack gun
        // with the kit pistol in hand puts the pistol in the backpack, still on key 1, and this read then made it gun 1 at home, which
        // v15.58 forbids (the kit never changes the gun he goes up with). On a freebie raid his own guns stay home, so a gun of the
        // kit pistol id in the backpack is the kit pistol, or one found in the raid, which v15.58 never equips from his hands either.
        if(G.freeKit&&_d3w<0&&_d3g===FREEKIT_GUN) continue;
        _d3[_d3i]=_d3g;
'@

SubRx @'
var VER='22.48';
'@ @'
var VER='22.49';
'@

$pat = "(?m)^  now:'v22\.48:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v22.49: The freebie kit pistol carried out in the backpack is kept but never becomes gun 1 or gun 2. Check 22.49 fails on v22.48',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
