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

# ---- ONE PIN MOVES, AND IT IS NOT THE ONE I EXPECTED. Measured with the square
# ---- on THE FROST YARD rather than the sump: entities stay at 374 and crawlers
# ---- at 224 on the mile, and 85 and 52 on COLD STORAGE. Only the geometry and
# ---- the container count move, because TOWN SQUARE is nine fixed rectangles
# ---- where CARGO YARD is four rows of random ones.
# ----   walls      mile 2461 -> 2440, cold 616 -> 623
# ----   containers mile  552 ->  593 (pinned nowhere), cold 165 unchanged
SubRx @'
     if(mile.walls!==2461||cold.walls!==616)
       bad.push('control: the maps hold '+mile.walls+' and '+cold.walls+
                ' walls rather than 2461 and 616, so the split geometry moved');
'@ @'
     // v10.80: the square adds seven pieces to COLD STORAGE where there was no
     // archetype, and replaces the mile's frost yard, which had more geometry
     // in it than nine fixed rectangles.
     if(mile.walls!==2440||cold.walls!==623)
       bad.push('control: the maps hold '+mile.walls+' and '+cold.walls+
                ' walls rather than 2440 and 623, so the split geometry moved');
'@

# ---- caught this four builds ago: is every archetype the file defines actually
# ---- BUILT somewhere, or is it a comment claiming a feature nobody can reach.
SubRx @'
  {v:'10.79',what:'the drawing checks refuse a trace of a thing as proof the thing is there: every floor sits under the live reading and above a quarter of it',
'@ @'
  {v:'10.80',what:'both maps really build a town centre, monument and all, and no archetype the file defines is left as code no map calls',
   run:function(){
     if(!(window.__deploy&&window.__state)) return 'SKIP: this fixture cannot build a map';
     if(typeof LANDMARKS==='undefined'||typeof FIXED_MAPS==='undefined') return 'SKIP: this build has no archetype table';
     var bad=[];
     // 1. EVERY ARCHETYPE THE FILE DEFINES MUST BE BUILT SOMEWHERE. TOWN SQUARE
     //    carried a comment saying it was guaranteed on every map and was called
     //    by none, so his note read as answered for four months. FLOODED PLAZA
     //    is knowingly unused and is named here on purpose: the day somebody
     //    puts it on a map, or adds a seventh archetype and forgets to use it,
     //    this line says so.
     var used={}, mi, li;
     for(mi=0;mi<FIXED_MAPS.length;mi++){
       var LMS=FIXED_MAPS[mi].landmarks||[];
       for(li=0;li<LMS.length;li++) if(LMS[li].arch) used[LMS[li].arch]=1;
     }
     var idle=[];
     for(li=0;li<LANDMARKS.length;li++) if(!used[LANDMARKS[li].id]) idle.push(LANDMARKS[li].id);
     idle.sort();
     if(idle.join(',')!=='plaza')
       bad.push('the archetypes no map builds are ['+idle.join(', ')+'], and the only one meant to be idle is plaza');
     // 2. AND IT IS REALLY IN THE WORLD, not merely declared. A landmark can
     //    name an archetype and still get nothing, because a piece that falls
     //    inside a building is cut away by the lmCut rule; that is exactly why
     //    the mile's square could not go on any landmark without one.
     var seen=[];
     for(mi=0;mi<2;mi++){
       __runPrep(); __resetCfg(); __pinDefaults(0);
       __deploy({kit:[],safe:null,mapIx:mi,seed:4242});
       var g=__state(), M=g.map, sq=null, L;
       for(li=0;li<(M.landmarks||[]).length;li++){ L=M.landmarks[li]; if(L.arch==='townsq') sq=L; }
       if(!sq){ bad.push('map '+mi+' ('+(M.name||'?')+') has no town centre on it at all'); continue; }
       seen.push(sq.name);
       // THE MONUMENT IS THE CENTRE and it is what makes the place read as a
       // square rather than a yard with some slabs in it. It is put at the
       // landmark's own centre, so a wall must exist there.
       var cx=sq.x+sq.w/2, cy=sq.y+sq.h/2, mon=0, rim=0;
       for(var wi=0;wi<M.walls.length;wi++){
         var W=M.walls[wi];
         if(W.x<cx+40&&W.x+W.w>cx-40&&W.y<cy+34&&W.y+W.h>cy-34) mon++;
         else if(W.x>=sq.x-4&&W.x+W.w<=sq.x+sq.w+4&&W.y>=sq.y-4&&W.y+W.h<=sq.y+sq.h+4) rim++;
       }
       if(!mon) bad.push(sq.name+' has no monument at its centre, so it is a name on the map and nothing on the ground');
       // The stalls and benches. Without these the monument is a lone block.
       if(rim<4) bad.push(sq.name+' has only '+rim+' pieces round its rim, which is not a square');
       // AND IT IS STILL A PLACE YOU CAN CROSS. A square you cannot walk into is
       // worse than no square: the monument is meant to be circled, not a plug.
       var open=0, st;
       for(st=0;st<8;st++){
         var a=st*Math.PI/4, px=cx+Math.cos(a)*150, py=cy+Math.sin(a)*150;
         if(spotFree(M,px,py,14)) open++;
       }
       if(open<5) bad.push(sq.name+' is walled in: only '+open+' of the eight ways round the monument are clear');
     }
     // 3. CONTROL: the two squares must be DIFFERENT places, or one map got two
     //    and the other got none and every line above would still pass.
     if(seen.length===2&&seen[0]===seen[1]) bad.push('control: both maps named the same square, '+seen[0]);
     return bad.length?bad.join('; '):null; }},
  {v:'10.79',what:'the drawing checks refuse a trace of a thing as proof the thing is there: every floor sits under the live reading and above a quarter of it',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
