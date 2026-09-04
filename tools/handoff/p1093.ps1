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

# ============ HIS NOTE: THE UNDERCROFT TEXT IS TOO TRANSPARENT, AND THE
# ============ DISCOUNT FASHION DEPOT IS NOW CALLED FASHION.
# ============
# ============ "text in the undercroft should be less transparent/more opaque --
# ============ change 'Discount Fashion Depot' to 'Fashion' wherever it occurs",
# ============ 2026-09-04.
# ============
# ============ REPRODUCED, and the cause is not the one the note points at. The
# ============ station names are dimmed TWICE. They are painted at 75 percent
# ============ alpha, which is the obvious half; and they are painted into the
# ============ world BEFORE the room's darkness is laid over it, a full-screen
# ============ sheet of rgba(14,12,36,.40) with holes punched where the lamps
# ============ are. So a name away from a lamp keeps 60 percent of what is left
# ============ of 75 percent.
# ============
# ============ MEASURED, by drawing the same frame twice, once with the names
# ============ suppressed, and differencing: the ink each name actually
# ============ contributes to the finished picture averages 64 to 89 out of a
# ============ possible 152, with the darkest stations, the racks and the wheel,
# ============ at 83 and the lift at 67.
# ============
# ============ THE FIX: names are UI, not scenery, so they are painted AFTER the
# ============ room's darkness rather than under it, in the same place and at the
# ============ same size, and at full opacity on a firmer plate. Raising the
# ============ alpha alone would have bought a third of this.

# ---- 1. cut the block out from under the light sheet
SubRx @'
  }catch(_hsE){}
  // station names float above their posts
  wc.textAlign='center';
  for(i=0;i<HB.stations.length;i++){
    var s3=HB.stations[i],on=HB.near===s3;
    wc.font=FS(TYPE.label);
    var tw=wc.measureText(s3.label).width;
    wc.fillStyle='rgba(6,9,13,'+(on?.8:.5)+')';
    // v10.23, his note: a station can carry its name under it instead of over
    // it. The cheat box does, because its name ran into the Depot's.
    var _lyP=s3.labelBelow?(s3.y+s3.r+4):(s3.y-56), _lyT=_lyP+10;
    wc.fillRect(s3.x-tw/2-5,_lyP,tw+10,13);
wc.fillStyle=on?s3.c:'rgba(160,172,184,.75)';
    // v6.73: keep the name inside the room. Centred text on a station near a wall used
    // to have its first letters cut off by the edge of the floor.
    var _lw2=wc.measureText(s3.label).width, _lx2=s3.x;
    var _lm2=34;                         // the 20 unit shell wall, plus a little air
    if(_lw2<HUBW-_lm2*2){
      if(_lx2-_lw2/2<_lm2)       _lx2=_lm2+_lw2/2;
      if(_lx2+_lw2/2>HUBW-_lm2)  _lx2=HUBW-_lm2-_lw2/2;
    }
    wc.fillText(s3.label,_lx2,_lyT);
    if(s3.id==='bar'){
      // v7.74, his order, his asterisks.
      wc.font=FS(TYPE.micro);
      wc.fillStyle=on?'#d98aff':'rgba(160,172,184,.65)';
      wc.fillText('***Experimental***',_lx2,s3.y-35);
      wc.font=FS(TYPE.label);
    }
    if(s3.season){
      var _sr=seasonReady();
      if(_sr){
        var _sl=_sr+' REWARD'+(_sr===1?'':'S')+' WAITING';
        wc.font=FS(TYPE.label);
        var _sw=wc.measureText(_sl).width;
        var _sp=.55+.45*Math.sin(HB.t*2.4);
        wc.fillStyle='rgba(6,9,13,.8)';
        wc.fillRect(s3.x-_sw/2-5,s3.y-74,_sw+10,13);
        wc.fillStyle='rgba(255,192,74,'+(0.55+0.45*_sp).toFixed(3)+')';
        wc.fillText(_sl,s3.x,s3.y-64);
        wc.font=FS(TYPE.label);
      }
    }
  }
  wc.textAlign='left';
  wc.restore();
'@ @'
  }catch(_hsE){}
  // v10.93, HIS NOTE: the station names used to be painted here, under the
  // room's darkness. They are drawn after it now, in hubStationNames below.
  wc.textAlign='left';
  wc.restore();
'@

# ---- 2. and paint it on top of the darkness instead
SubRx @'
  wc.globalAlpha=1; wc.globalCompositeOperation='source-over';
  drawHubHUD(ox,oy);
}
'@ @'
  wc.globalAlpha=1; wc.globalCompositeOperation='source-over';
  // v10.93, HIS NOTE: ON TOP OF THE DARKNESS, NOT UNDER IT. The names are how
  // you find a station, which makes them UI and not scenery, and the room being
  // dark is no reason for its signage to be. Same place, same size, same
  // transform; only the moment changed, and the alpha with it.
  hubStationNames(S,ox,oy);
  drawHubHUD(ox,oy);
}
// The station names, lifted out of drawHubWorld at v10.93 so they can be drawn
// after the light sheet. It takes the camera it is drawn with rather than
// working it out again, because a second copy of the camera is a second camera.
function hubStationNames(S,ox,oy){
  var i;
  wc.save(); wc.scale(S,S); wc.translate(-ox,-oy);
  wc.textAlign='center';
  for(i=0;i<HB.stations.length;i++){
    var s3=HB.stations[i],on=HB.near===s3;
    wc.font=FS(TYPE.label);
    var tw=wc.measureText(s3.label).width;
    // v10.93: a firm plate. It was half transparent, so the floor showed through
    // the name as well as dimming it.
    wc.fillStyle='rgba(6,9,13,'+(on?.92:.86)+')';
    // v10.23, his note: a station can carry its name under it instead of over
    // it. The cheat box does, because its name ran into its neighbour.
    var _lyP=s3.labelBelow?(s3.y+s3.r+4):(s3.y-56), _lyT=_lyP+10;
    wc.fillRect(s3.x-tw/2-5,_lyP,tw+10,13);
    // v10.93: opaque. This was rgba(160,172,184,.75).
    wc.fillStyle=on?s3.c:'#cfd8e2';
    // v6.73: keep the name inside the room. Centred text on a station near a wall used
    // to have its first letters cut off by the edge of the floor.
    var _lw2=wc.measureText(s3.label).width, _lx2=s3.x;
    var _lm2=34;                         // the 20 unit shell wall, plus a little air
    if(_lw2<HUBW-_lm2*2){
      if(_lx2-_lw2/2<_lm2)       _lx2=_lm2+_lw2/2;
      if(_lx2+_lw2/2>HUBW-_lm2)  _lx2=HUBW-_lm2-_lw2/2;
    }
    wc.fillText(s3.label,_lx2,_lyT);
    if(s3.id==='bar'){
      // v7.74, his order, his asterisks.
      wc.font=FS(TYPE.micro);
      wc.fillStyle=on?'#d98aff':'#c3cdd8';
      wc.fillText('***Experimental***',_lx2,s3.y-35);
      wc.font=FS(TYPE.label);
    }
    if(s3.season){
      var _sr=seasonReady();
      if(_sr){
        var _sl=_sr+' REWARD'+(_sr===1?'':'S')+' WAITING';
        wc.font=FS(TYPE.label);
        var _sw=wc.measureText(_sl).width;
        var _sp=.55+.45*Math.sin(HB.t*2.4);
        wc.fillStyle='rgba(6,9,13,.9)';
        wc.fillRect(s3.x-_sw/2-5,s3.y-74,_sw+10,13);
        wc.fillStyle='rgba(255,192,74,'+(0.70+0.30*_sp).toFixed(3)+')';
        wc.fillText(_sl,s3.x,s3.y-64);
        wc.font=FS(TYPE.label);
      }
    }
  }
  wc.textAlign='left';
  wc.restore();
}
'@

# ---- 3. the line of controls along the bottom of the Undercroft, also see-through
SubRx @'
  ctx.font=FS(TYPE.micro); ctx.fillStyle='rgba(140,152,163,.75)';
  ctx.textAlign='center';
'@ @'
  // v10.93, HIS NOTE: this was rgba(140,152,163,.75).
  ctx.font=FS(TYPE.micro); ctx.fillStyle='#aab6c2';
  ctx.textAlign='center';
'@

# ---- 4. and the line under the station prompt, a dim grey rather than a bright one
SubRx @'
    ctx.font=FS(TYPE.label); ctx.fillStyle='#8a96a1';
    ctx.fillText(typeof s.sub==='function'?s.sub():s.sub,W/2,H-42);
'@ @'
    // v10.93, HIS NOTE: this was #8a96a1, which is the dimmest grey in the file.
    ctx.font=FS(TYPE.label); ctx.fillStyle='#b7c2cd';
    ctx.fillText(typeof s.sub==='function'?s.sub():s.sub,W/2,H-42);
'@

# ============ HIS SECOND HALF: THE NAME. Every player-facing place the station
# ============ was called the Discount Fashion Depot, or the Depot for short,
# ============ which is the same station under a second name and his vocabulary
# ============ rule allows one word per thing.
SubRx @'
  <h3>Discount Fashion Depot</h3>
'@ @'
  <h3>Fashion</h3>
'@
SubRx @'
    {id:'mirror',x:230,y:400,r:42,label:'DISCOUNT FASHION DEPOT',sub:'a cracked mirror and a change of clothes',c:'#f2c9a0',
'@ @'
    {id:'mirror',x:230,y:400,r:42,label:'FASHION',sub:'a cracked mirror and a change of clothes',c:'#f2c9a0',
'@
SubRx @'
  'FULL-BODY OUTFITS. A new rack at the top of the Depot, above everything else:
'@ @'
  'FULL-BODY OUTFITS. A new rack at the top of FASHION, above everything else:
'@
SubRx @'
  'THE DISCOUNT FASHION DEPOT HAS FOURTEEN RACKS:
'@ @'
  'FASHION HAS FOURTEEN RACKS:
'@
SubRx @'
  'THE FIGURE AT THE DEPOT IS DRAWN BY THE RAID PAINTER,
'@ @'
  'THE FIGURE AT FASHION IS DRAWN BY THE RAID PAINTER,
'@
SubRx @'
  'THE DISCOUNT FASHION DEPOT is its own station in the Undercroft.
'@ @'
  'FASHION is its own station in the Undercroft.
'@
SubRx @'
the stash, the lift, the bar, the Depot and Settings.',
'@ @'
the stash, the lift, the bar, Fashion and Settings.',
'@
SubRx @'
      if(_tk3) _tk3.textContent=P.cosAll?'Every rack in the Depot is open.
'@ @'
      if(_tk3) _tk3.textContent=P.cosAll?'Every rack in FASHION is open.
'@

SubRx @'
var VER='10.92';
'@ @'
var VER='10.93';
'@
SubRx @'
  now:'v10.92: your marker on the map was 8 pixels across, the smallest thing on a screen it is meant to own, and the only marker that did not grow with the map. It is roughly double now, scaled like its neighbours, with a halo under it and a longer heading line.',
'@ @'
  now:'v10.93: the text in the Undercroft, your note. The station names were painted into the world BEFORE the room darkness went over it, so they kept 60 percent of an already see-through 75 percent. They are drawn on top of the darkness now, opaque, on a firm plate. And the Discount Fashion Depot is called FASHION everywhere.',
'@
SubRx @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
'@ @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
  'THE UNDERCROFT READS PROPERLY NOW. The station names were painted into the room before the room went dark, so the darkness went over them as well; they are drawn on top of it now and are no longer see-through. The controls line and the line under each station prompt came up with them. THE DISCOUNT FASHION DEPOT IS NOW CALLED FASHION.',
'@
SubRx @'
var WHATSNEW_VER='10.92';
'@ @'
var WHATSNEW_VER='10.93';
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
