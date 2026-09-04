$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# ============ HIS NOTE, 2026-09-03 about 20:00: "sprint footprint glitch is
# ============ still happening". Reproduced with the live stepper on a v10.52
# ============ fixture: hold a direction into a wall and the boots keep stamping
# ============ the ground every 0.22 seconds at sprint (0.34 at a walk) while he
# ============ covers no ground at all, so a pile of prints builds under him,
# ============ and each one is stamped BEFORE the wall push, at a spot he was
# ============ never allowed to stand. The stamp was keyed to time with a key
# ============ held; it is keyed to ground covered now, measured after the wall
# ============ push, one print every 56 units, which is what 0.34 s of walking
# ============ and 0.22 s of sprinting both came to in the open. Pinned, he
# ============ stamps nothing. The same disease the Undercroft walk cycle had at
# ============ v10.51.
SubRx @'
    if(wading) p.wetT=6;
    if(p.wetT>0) p.wetT-=dt;
    p.printAcc=(p.printAcc||0)+dt;
    var pintv=sprint?0.22:0.34;
    if(p.printAcc>=pintv&&!G.sim){
      p.printAcc=0; p.printSide=!p.printSide;
      var pma=Math.atan2(my,mx),poff=p.printSide?1:-1;
      var ppx=p.x+Math.cos(pma+1.5708)*4*poff,ppy=p.y+Math.sin(pma+1.5708)*4*poff;
'@ @'
    if(wading) p.wetT=6;
    if(p.wetT>0) p.wetT-=dt;
    collide(p,G.map.walls);
    // v10.55, his note: "sprint footprint glitch is still happening". The
    // stamp was keyed to time with a key held, and taken before the wall push,
    // so pinned against a wall the boots piled prints under him at a spot he
    // could not stand. It is keyed to ground actually covered now, after the
    // push: one print every 56 units, which is what a walk and a sprint both
    // came to in the open, and none at all when he is going nowhere.
    var _pdx=p.x-ox,_pdy=p.y-oy,_pdd=Math.sqrt(_pdx*_pdx+_pdy*_pdy);
    p.printAcc=(p.printAcc||0)+_pdd;
    var pintv=56;
    if(p.printAcc>=pintv&&_pdd>0.01&&!G.sim){
      p.printAcc=0; p.printSide=!p.printSide;
      var pma=Math.atan2(_pdy,_pdx),poff=p.printSide?1:-1;
      var ppx=p.x+Math.cos(pma+1.5708)*4*poff,ppy=p.y+Math.sin(pma+1.5708)*4*poff;
'@
SubRx @'
        pushPrint({x:ppx,y:ppy,c:p.wetT>0?'#141d26':'#241f16',s:p.wetT>0?7:5.5,
          a:p.wetT>0?.62:.34,a0:p.wetT>0?.62:.34,rot:pma,print:1,mine:1,t:0,life:6});
      }
    }
    collide(p,G.map.walls);
    T.distance+=dist({x:ox,y:oy},p);
'@ @'
        pushPrint({x:ppx,y:ppy,c:p.wetT>0?'#141d26':'#241f16',s:p.wetT>0?7:5.5,
          a:p.wetT>0?.62:.34,a0:p.wetT>0?.62:.34,rot:pma,print:1,mine:1,t:0,life:6});
      }
    }
    T.distance+=_pdd;
'@

SubRx @'
var VER='10.54';
'@ @'
var VER='10.55';
'@
SubRx @'
  now:'v10.54: OUTFITS. A new rack at the top of the Depot with seven full-body suits that overrule every other slot: the Skeleton, the Machine, the Trooper, the Android, the Tomb Explorer, the Baller and the Street Poet. Own Clothes puts the racks back in charge.',
'@ @'
  now:'v10.55: footprints follow the ground you actually cover, one every 56 units after the wall push, so sprinting into a wall no longer piles prints under you at a spot you could not stand.',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
