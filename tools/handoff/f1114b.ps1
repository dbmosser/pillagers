$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# v9.81: THE WALL FINGERPRINT FOLLOWS v11.14. A piece of furniture landing in a
# doorway zone is no longer placed. Measured at seed 4242: 2403 to 2308 on the
# mile, 610 to 580 on cold storage. Entities 374 and 85 on the line below are
# the half that says the seeded stream did not move.
SubRx @'
     if(mile.walls!==2403||cold.walls!==610)
       bad.push('control: the maps hold '+mile.walls+' and '+cold.walls+
                ' walls rather than 2403 and 610, so the split geometry moved');
'@ @'
     // v11.14: 2403 and 610 became 2308 and 580. Furniture landing in a doorway
     // zone is not placed any more, so fewer pieces stand. The entity line
     // below is the half of this fingerprint that says the seeded stream itself
     // did not move.
     if(mile.walls!==2308||cold.walls!==580)
       bad.push('control: the maps hold '+mile.walls+' and '+cold.walls+
                ' walls rather than 2308 and 580, so the split geometry moved');
'@

# v9.65: THE COVER FINGERPRINT FOLLOWS TOO, the same way it followed v9.77.
SubRx @'
     if(wrecks.length!==483)
       bad.push('the mile has '+wrecks.length+' pieces of outdoor cover rather than 483, so a footprint moved');
'@ @'
     // v11.14: 483 to 488. Furniture in doorway zones is not placed, so the wall
     // list spotFree asks against is shorter and five more candidate spots are
     // accepted. Entities are still 374 on the line below.
     if(wrecks.length!==488)
       bad.push('the mile has '+wrecks.length+' pieces of outdoor cover rather than 488, so a footprint moved');
'@

# v9.79: A ROOM, NOT A SLIVER. v10.40 ruled that a pocket narrower than a body,
# left between furniture pieces, is cosmetic and its own line; only a pocket of
# at least 32 by 32 units is floor a player could have stood on. This survey had
# no floor and passed only because the buildings holding slivers were the ones
# whose plugged doorway got them stripped bare. v11.14 opens those doors. The
# anchor runs into the return line so it cannot land on v9.77's copy of the loop.
SubRx @'
             if(inLk(x*F+F/2,y*F+F/2)) continue;
             un=1;
           }
         if(un) stuck.push(b);
       }
       return {buildings:B.length, demolished:demo, sealed:stuck.join(','),
               landmarkWalls:lmw, landmarkLength:lmlen, parts:parts, ents:g.ents.length};
'@ @'
             if(inLk(x*F+F/2,y*F+F/2)) continue;
             // v11.14: a ROOM, not a sliver. v10.40 ruled a pocket narrower than
             // a body cosmetic and its own line; only 32 by 32 units, 8 by 8
             // cells here, is floor somebody could have stood on. This passed
             // before only because the buildings holding slivers were the ones
             // whose plugged doorway got them stripped bare.
             var _rm=true;
             for(var _by=y;_by<y+8&&_rm;_by++) for(var _bx=x;_bx<x+8;_bx++){
               if(_by>=fh||_bx>=fw||blk[_by*fw+_bx]||seen[_by*fw+_bx]){ _rm=false; break; } }
             if(_rm) un=1;
           }
         if(un) stuck.push(b);
       }
       return {buildings:B.length, demolished:demo, sealed:stuck.join(','),
               landmarkWalls:lmw, landmarkLength:lmlen, parts:parts, ents:g.ents.length};
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
