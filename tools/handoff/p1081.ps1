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

# ============ HIS NOTE, THE OTHER HALF: DESTROYED BUILDINGS.
# ============
# ============ MEASURED FIRST: all 104 buildings across the two maps have a
# ============ complete shell, 20 of 20 on COLD STORAGE and 84 of 84 on THE COLD
# ============ MILE, every one of them a closed box with one or two doorways.
# ============ Not one building on either map has ever been destroyed.
# ============
# ============ RUINS ARE NOT THIS. The map already scatters collapsed rubble in
# ============ open ground, and its own comment says why they are different: "A
# ============ collapsed building draws as a broken silhouette, never as a box
# ============ with a door, because the whole point is that there is no way into
# ============ it." Those are solid blocks. What his note asks for is a real
# ============ building, one of the 104, that has been destroyed and that you can
# ============ still walk into and loot.
# ============
# ============ WHAT A WRECKED BUILDING IS HERE: its shell has lost whole runs of
# ============ wall, so you can see into it and enter it from any side. That is
# ============ the read from overhead and it is also the play: no cover on that
# ============ side, no corner to hold, and anything inside is visible from
# ============ outside long before you reach the door.
# ============
# ============ THE INTERIOR IS LEFT STANDING, deliberately. Partitions carry a
# ============ building id and the repair pass, the sealed-room pass and three
# ============ checks all count them; taking them out here would move numbers
# ============ those checks own for reasons that have nothing to do with this.
# ============ A building with its outer walls torn open and its inner ones still
# ============ up is also the truer picture of a blast.
# ============
# ============ NO RANDOM NUMBERS. The pass runs at the end of the map build, after
# ============ every roll, and chooses by a hash of each wall's own position, so
# ============ turning it off reproduces the old map exactly on the same seed.
# ============ It only ever REMOVES geometry, so it cannot seal a room, bury a
# ============ container or block a way out; every one of those faults needs
# ============ something added.
SubRx @'
  for(var k=0;k<walls.length;k++){
    var wl=walls[k]; wl.streaks=[];
'@ @'
  // ---- v10.81, HIS NOTE: DESTROYED BUILDINGS. See the long note in DESIGN.md.
  // Runs here, after every roll and after the sealed-room repair, so it consumes
  // no rr() and bldgRuin 0 reproduces the pre-v10.81 map exactly on any seed.
  var _ruinLog={picked:0,segsCut:0,skipSmall:0,skipLocked:0,skipThin:0};
  var _rrate=(CFG.bldgRuin===undefined?0.09:CFG.bldgRuin);
  if(_rrate>0){
    // One hash, used for both questions, so the same map always ruins the same
    // buildings and drops the same runs of wall.
    function _rh(a,b){ var h=(Math.imul(a|0,73856093)^Math.imul(b|0,19349663))>>>0;
      h^=h>>>13; h=Math.imul(h,1274126177)>>>0; return (h>>>8)/16777216; }
    for(var _rb=0;_rb<buildings.length;_rb++){
      var _RB=buildings[_rb];
      // Too small to read as anything but a shed with a hole in it.
      if(_RB.w<140||_RB.h<140){ _ruinLog.skipSmall++; continue; }
      // NEVER a building holding an authored strongroom. Those are placed by
      // hand, they are the reason a key exists, and opening one from the side
      // would give away the one room on the map you are meant to work for.
      var _lk=false, _LKS=def.locked||[];
      for(var _lq=0;_lq<_LKS.length;_lq++){ var _LK=_LKS[_lq];
        if(_LK.x<_RB.x+_RB.w&&_LK.x+_LK.w>_RB.x&&_LK.y<_RB.y+_RB.h&&_LK.y+_LK.h>_RB.y){ _lk=true; break; } }
      if(_lk){ _ruinLog.skipLocked++; continue; }
      if(_rh(_RB.x,_RB.y)>=_rrate) continue;
      // Its own shell: untagged, on the perimeter, and nothing that was added
      // later. Interior partitions carry ib and are left alone on purpose.
      var _sh=[], _t2=20;
      for(var _wq=0;_wq<walls.length;_wq++){
        var _WQ=walls[_wq];
        if(_WQ.ib!==undefined||_WQ.wreck||_WQ.ruin||_WQ.tree||_WQ.furn||_WQ.noDes) continue;
        if(_WQ.x<_RB.x-_t2||_WQ.x+_WQ.w>_RB.x+_RB.w+_t2||_WQ.y<_RB.y-_t2||_WQ.y+_WQ.h>_RB.y+_RB.h+_t2) continue;
        var _edge=(Math.abs(_WQ.y-_RB.y)<_t2)||(Math.abs(_WQ.y+_WQ.h-(_RB.y+_RB.h))<_t2)||
                  (Math.abs(_WQ.x-_RB.x)<_t2)||(Math.abs(_WQ.x+_WQ.w-(_RB.x+_RB.w))<_t2);
        if(_edge) _sh.push(_wq);
      }
      // A shell of three runs or fewer has nothing to lose without disappearing.
      if(_sh.length<4){ _ruinLog.skipThin++; continue; }
      var _drop=[];
      for(var _sq=0;_sq<_sh.length;_sq++){
        var _SW=walls[_sh[_sq]];
        if(_rh(_SW.x+7,_SW.y+13)<0.5) _drop.push(_sh[_sq]);
      }
      // TWO RUNS ALWAYS STAND. A building that loses its whole shell is not a
      // ruin, it is a hole in the map where a building used to be, and every
      // pass that names a building by its rectangle would still think it there.
      while(_sh.length-_drop.length<2&&_drop.length) _drop.pop();
      if(!_drop.length) continue;
      _drop.sort(function(a,b){ return b-a; });
      for(var _dq=0;_dq<_drop.length;_dq++) walls.splice(_drop[_dq],1);
      _RB.ruined=1; _ruinLog.picked++; _ruinLog.segsCut+=_drop.length;
    }
    // The holes are ways through, so the pathing grid has to know about them.
    if(_ruinLog.picked) mapNav=buildNav(walls);
  }
  for(var k=0;k<walls.length;k++){
    var wl=walls[k]; wl.streaks=[];
'@

SubRx @'
    roadRects:roadRects,roadDashes:roadDashes,cullLog:_cullLog,
'@ @'
    roadRects:roadRects,roadDashes:roadDashes,cullLog:_cullLog,ruinLog:_ruinLog,
'@

SubRx @'
raiderCrawl:1,nightDens:1.35};
'@ @'
raiderCrawl:1,nightDens:1.35,bldgRuin:0.09};
'@

SubRx @'
var VER='10.80';
'@ @'
var VER='10.81';
'@
SubRx @'
  now:'v10.80: both maps get the town centre you asked for. TOWN SQUARE has been written since v6.92 and no map ever called it, so the monument, the market stalls and the benches had never been built in the game. COLD STORAGE puts one on the packing floor; the mile turns one of its three identical cargo yards into THE FROST MARKET.',
'@ @'
  now:'v10.81: destroyed buildings, the other half of your map note. All 104 buildings on the two maps were closed boxes with a door; now some of them have lost whole runs of outer wall, so you can see into them and go in from any side. Their inner walls are left standing, which is what a blast actually leaves.',
'@
SubRx @'
  'BOTH MAPS NOW HAVE A CENTRE.
'@ @'
  'SOME BUILDINGS ARE DESTROYED NOW. Whole runs of their outer wall are gone, so you can see straight into them and walk in from any side. No cover on that wall, nothing to hold a corner behind, and whatever is inside is visible from a long way off. The rooms inside are still standing.',
  'BOTH MAPS NOW HAVE A CENTRE.
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
