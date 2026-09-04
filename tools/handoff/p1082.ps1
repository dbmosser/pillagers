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

# ============ A DESTROYED BUILDING DID NOT LOOK DESTROYED.
# ============
# ============ v10.81 shipped the geometry and its own Not verified line said
# ============ this: the only thing telling you a building came down was the
# ============ absence of some wall. MEASURED on COLD STORAGE at seed 4242, the
# ============ mean brightness of the floor inside the building at 2980,1330
# ============ reads 124.76 with the ruin dial off and 124.81 with it on. Four
# ============ hundredths of one percent. The ground under a destroyed building
# ============ is the same ground, so from any distance it reads as a building
# ============ somebody forgot to finish rather than one that fell down.
# ============
# ============ THE FIX GOES IN THE BAKE, not the frame. The ground is a canvas
# ============ painted once per raid, so scorch and rubble cost nothing per frame
# ============ and cannot touch collision, sight or pathing: this is paint. Every
# ============ position and size comes from a hash of its own coordinates, so no
# ============ rr() is drawn, the seeded stream cannot move, and the same
# ============ building has the same rubble every time you see it.
SubRx @'
    c.fillStyle=gr; c.beginPath(); c.arc(cx,cy,rad,0,6.2832); c.fill();
  }
'@ @'
    c.fillStyle=gr; c.beginPath(); c.arc(cx,cy,rad,0,6.2832); c.fill();
  }
  // v10.82: AND A DESTROYED BUILDING LOOKS DESTROYED. Paint only, baked once.
  function _rubH(a,b){ var h=(Math.imul(a|0,374761393)^Math.imul(b|0,668265263))>>>0;
    h^=h>>>15; h=Math.imul(h,2246822519)>>>0; h^=h>>>13; return (h>>>8)/16777216; }
  for(i=0;i<map.buildings.length;i++){
    var RB=map.buildings[i];
    if(!RB.ruined) continue;
    var RD=DISTRICTS[RB.d];
    var rx0=RB.x+8, ry0=RB.y+8, rw0=RB.w-16, rh0=RB.h-16;
    if(rw0<40||rh0<40) continue;
    // 1. THE BURN. Everything inside goes darker and colder, which is the read
    //    from across the map before any single piece of rubble is legible.
    c.fillStyle=isDay()?'rgba(24,21,19,0.34)':'rgba(10,10,14,0.40)';
    c.fillRect(rx0,ry0,rw0,rh0);
    // 2. DUST SPILLING OUT past the line the walls used to hold. A ruin that
    //    stops exactly at its own footprint reads as a floor tile, not a
    //    collapse, so the spill is what makes it look like something happened.
    c.fillStyle=isDay()?'rgba(150,140,126,0.16)':'rgba(96,96,112,0.13)';
    for(k=0;k<26;k++){
      var _da=_rubH(RB.x+k*13,RB.y+k*29)*6.2832;
      var _dr=0.52+0.30*_rubH(RB.x+k*7,RB.y+k*41);
      var _dx=RB.x+RB.w/2+Math.cos(_da)*RB.w*_dr;
      var _dy=RB.y+RB.h/2+Math.sin(_da)*RB.h*_dr;
      var _ds=9+22*_rubH(RB.x+k*23,RB.y+k*11);
      c.fillRect(_dx-_ds/2,_dy-_ds/3,_ds,_ds*0.66);
    }
    // 3. THE RUBBLE ITSELF, scaled to the floor it is covering so a big shed and
    //    a small one both read. Two tones: the block and the shadow it throws,
    //    because one flat grey on a dark floor disappears at any distance.
    var _rn=Math.max(14,Math.min(60,Math.round((rw0*rh0)/5200)));
    for(k=0;k<_rn;k++){
      var _px=rx0+rw0*_rubH(RB.x+k*31,RB.y+k*17);
      var _py=ry0+rh0*_rubH(RB.x+k*19,RB.y+k*37);
      var _ps=7+19*_rubH(RB.x+k*43,RB.y+k*5);
      c.fillStyle=isDay()?'rgba(20,18,17,0.42)':'rgba(6,7,10,0.46)';
      c.fillRect(_px-_ps/2+2,_py-_ps/3+2,_ps,_ps*0.62);
      c.fillStyle=isDay()?hexA(RD.wallTop,0.62):hexA(darkHex(RD.wallTop,0.40),0.58);
      c.fillRect(_px-_ps/2,_py-_ps/3,_ps,_ps*0.62);
    }
    // 4. AND THE SCORCH AT THE MIDDLE, so the eye is given a place the thing
    //    came down from rather than an even scatter.
    var _bx=RB.x+RB.w/2, _by=RB.y+RB.h/2;
    var _sr=Math.min(rw0,rh0)*0.42;
    var _sg=c.createRadialGradient(_bx,_by,2,_bx,_by,_sr);
    _sg.addColorStop(0,'rgba(12,10,9,0.46)'); _sg.addColorStop(1,'rgba(12,10,9,0)');
    c.fillStyle=_sg; c.beginPath(); c.arc(_bx,_by,_sr,0,6.2832); c.fill();
  }
'@

SubRx @'
var VER='10.81';
'@ @'
var VER='10.82';
'@
SubRx @'
  now:'v10.81: destroyed buildings, the other half of your map note. All 104 buildings on the two maps were closed boxes with a door; now some of them have lost whole runs of outer wall, so you can see into them and go in from any side. Their inner walls are left standing, which is what a blast actually leaves.',
'@ @'
  now:'v10.82: and now a destroyed building LOOKS destroyed. The floor inside one read 124.76 against 124.81 with the wrecking on, four hundredths of one percent, so the only thing saying a building had come down was the missing wall. Burnt floor, rubble, and dust spilling out past where the wall used to be.',
'@
SubRx @'
  'SOME BUILDINGS ARE DESTROYED NOW.
'@ @'
  'A DESTROYED BUILDING NOW LOOKS IT. Burnt floor, rubble across it and dust spilling out past where the wall used to stand, so you can pick one out from across the map instead of only noticing when you are close enough to see the gap.',
  'SOME BUILDINGS ARE DESTROYED NOW.
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
