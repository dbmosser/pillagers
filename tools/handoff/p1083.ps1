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

# ============ THE MAP COULD NOT TELL YOU WHICH BUILDINGS HAD FALLEN.
# ============
# ============ v10.82's own Not verified line named this. A destroyed building is
# ============ now a tactical fact: no cover on the missing side, open from any
# ============ direction, and visible into from a long way off. The map is where
# ============ you decide which way to go, and it painted every building with the
# ============ same rule.
# ============
# ============ MEASURED on COLD STORAGE at seed 4242, mean brightness of each
# ============ building's rectangle on the map screen at 1920x1080:
# ============   the two destroyed ones  69.29 and 64.31
# ============   the seven standing ones in the same district
# ============                           72.86 to 82.22
# ============ So the gap to the nearest standing building is 3.57 while the
# ============ standing buildings vary among themselves by 9.36. The ruins are
# ============ only darker BY ACCIDENT, because fewer wall pixels land on them,
# ============ and a difference smaller than the noise is not a difference a
# ============ player can read.
# ============
# ============ THE MARK: the fill drops to less than half its alpha so the shape
# ============ reads as not solid, a diagonal hatch is cut across it, and the
# ============ outline is broken rather than continuous. Three signals, because
# ============ one of them alone is a shade and a shade is what failed here.
SubRx @'
  for(i=0;i<G.map.buildings.length;i++){
    var b=G.map.buildings[i];
    ctx.fillStyle=hexA(DISTRICTS[b.d].wallTop,.15);
    ctx.fillRect(ox+b.x*sc,oy+b.y*sc,b.w*sc,b.h*sc);
  }
'@ @'
  for(i=0;i<G.map.buildings.length;i++){
    var b=G.map.buildings[i];
    var _bx=ox+b.x*sc, _by=oy+b.y*sc, _bw=b.w*sc, _bh=b.h*sc;
    // v10.83: a building that has fallen is not drawn like one that is standing.
    ctx.fillStyle=hexA(DISTRICTS[b.d].wallTop,b.ruined?.06:.15);
    ctx.fillRect(_bx,_by,_bw,_bh);
    if(b.ruined){
      // HATCH. Diagonals at a fixed screen spacing, so the mark is the same
      // weight on a small building and a large one and at any monitor size.
      ctx.save();
      ctx.beginPath(); ctx.rect(_bx,_by,_bw,_bh); ctx.clip();
      ctx.strokeStyle='rgba(232,176,96,.34)'; ctx.lineWidth=1;
      ctx.beginPath();
      for(var _hx=-_bh;_hx<_bw;_hx+=7){
        ctx.moveTo(_bx+_hx,_by+_bh); ctx.lineTo(_bx+_hx+_bh,_by);
      }
      ctx.stroke();
      ctx.restore();
      // BROKEN OUTLINE. A continuous box says the walls are there, which is the
      // one thing this building no longer has.
      ctx.strokeStyle='rgba(232,176,96,.55)'; ctx.lineWidth=1;
      var _dash=6, _gap=5, _t;
      ctx.beginPath();
      for(_t=0;_t<_bw;_t+=_dash+_gap){
        var _l=Math.min(_dash,_bw-_t);
        ctx.moveTo(_bx+_t,_by);       ctx.lineTo(_bx+_t+_l,_by);
        ctx.moveTo(_bx+_t,_by+_bh);   ctx.lineTo(_bx+_t+_l,_by+_bh);
      }
      for(_t=0;_t<_bh;_t+=_dash+_gap){
        var _m=Math.min(_dash,_bh-_t);
        ctx.moveTo(_bx,_by+_t);       ctx.lineTo(_bx,_by+_t+_m);
        ctx.moveTo(_bx+_bw,_by+_t);   ctx.lineTo(_bx+_bw,_by+_t+_m);
      }
      ctx.stroke();
    }
  }
'@

SubRx @'
var VER='10.82';
'@ @'
var VER='10.83';
'@
SubRx @'
  now:'v10.82: and now a destroyed building LOOKS destroyed. The floor inside one read 124.76 against 124.81 with the wrecking on, four hundredths of one percent, so the only thing saying a building had come down was the missing wall. Burnt floor, rubble, and dust spilling out past where the wall used to be.',
'@ @'
  now:'v10.83: the map tells you which buildings have fallen. A destroyed building sat at 64 to 69 brightness against 73 to 82 for the standing ones near it, a gap of 3.6 where the standing buildings vary by 9.4 among themselves, so it was only darker by accident. It is hatched and broken-outlined now.',
'@
SubRx @'
  'A DESTROYED BUILDING NOW LOOKS IT.
'@ @'
  'THE MAP MARKS THE FALLEN BUILDINGS. Press M and the destroyed ones are hatched with a broken outline, so you can plan a route past the ones with no cover instead of finding out when you get there.',
  'A DESTROYED BUILDING NOW LOOKS IT.
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
