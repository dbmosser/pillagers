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

# YOUR HIRE LEAVES DROPPED ITEMS ALONE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
              if(_CT.opened||_CT.mine||(_CT.prog||0)>0||shutRoomAt(G.map,_CT.x,_CT.y)) continue;
'@ @'
              // v21.70, from the whole-game bug hunt of 2026-10-08 (K2): AND HE LEAVES A PILE YOU DROPPED WHERE IT IS. A dropped item
              // lands a few steps from your feet, well inside his 160 reach while he follows you, so he walked over, knelt and took it
              // into a pack nobody can search: a Medkit dropped for a teammate (the co-op trade since v18.27), or anything dropped to
              // free a slot. A pile you or the party dropped (dropped, set by dropItem and netPileTake) is skipped now; every other
              // box is picked as before. Nothing here draws from the seeded stream.
              if(_CT.opened||_CT.mine||_CT.dropped||(_CT.prog||0)>0||shutRoomAt(G.map,_CT.x,_CT.y)) continue;
'@

SubRx @'
          var ct=G.containers[c4]; if(ct.opened) continue;
'@ @'
          var ct=G.containers[c4]; if(ct.opened) continue; if(e.merc&&ct.dropped) continue;   // v21.70 (K2): your hire on LOOT leaves a dropped pile alone too; pillagers still take one
'@

SubRx @'
var VER='21.69';
'@ @'
var VER='21.70';
'@

$pat = "(?m)^  now:'v21\.69:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v21.70: Your hire no longer picks up items you or your teammate drop. Check 21.70 fails on v21.69',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
