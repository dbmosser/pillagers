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

# ============ HIS NOTE, 2026-09-03 about 19:30: "WEIRD COLLISION IN UNDERCROFT,
# ============ ONLY HAPPENS WHEN PLAYER IS BEHIND THE TERMINAL", and about 19:45:
# ============ "weird collission and running-in-place behaviors are happening in
# ============ the undercroft". Two faults, one wall. The terminal plinth is a
# ============ collider at y 385 to 405, and the room paints every wall top 26
# ============ units above its collider, the same lift the raid uses (his #45).
# ============ The raid got the v9.27 see-through pass for exactly this; the room
# ============ duplicates the raid wall renderer and never got the pass. So from
# ============ behind, he stops on the collider at y 374 and is painted under the
# ============ drawn top, which spans 359 to 385, and vanishes into the terminal
# ============ against a line he cannot see. And the walk cycle was keyed to the
# ============ keys, not to movement, so pinned against that wall he ran in place.

# 1. The walk cycle follows movement, not the keys.
SubRx @'
  var mg=Math.sqrt(mx*mx+my*my);
  p.moving=mg>0;
'@ @'
  var mg=Math.sqrt(mx*mx+my*my);
  // v10.51, his note: running in place. moving was the keys; it is now the
  // distance he actually covered this frame, measured after the wall push.
  var _pmx0=p.x,_pmy0=p.y;
'@
SubRx @'
  } else p.bob+=dt*1.2;
'@ @'
  } else p.bob+=dt*1.2;
  p.moving=Math.hypot(p.x-_pmx0,p.y-_pmy0)>0.02;
'@

# 2. The see-through pass, the raid's v9.27 arithmetic against the room's own
#    wall list. Drawn after the sorted pass so it lands on top of the wall that
#    swallowed him.
SubRx @'
  // station names float above their posts
'@ @'
  // v10.51, HIS NOTE: "WEIRD COLLISION IN UNDERCROFT, ONLY HAPPENS WHEN PLAYER
  // IS BEHIND THE TERMINAL". The room paints every wall top 26 units above its
  // collider and never had the raid's v9.27 see-through pass, so behind the
  // terminal plinth he stopped on the collider and vanished into the drawn top.
  // Same test the raid uses: a wall paints after him when its sort key y+h is
  // greater than his key, and covers him when its drawn top, y-L to y-L+h,
  // contains him. Wrapped, because a fault in a cosmetic pass must never cost
  // the frame.
  try{
  if(CFG.seeThrough!==0){
    var _hsK=p.y-((G&&G.map&&G.map.liftAt)?G.map.liftAt(p.x,p.y)*0.5:0), _hsHid=false;
    for(var _hsI=0;_hsI<HB.walls.length&&!_hsHid;_hsI++){
      var _hsw=HB.walls[_hsI], _hsL=(_hsw.w<=60&&_hsw.h<=60)?14:26;
      if((_hsw.y+_hsw.h)<=_hsK) continue;                   // painted before him
      if(p.x<_hsw.x||p.x>_hsw.x+_hsw.w) continue;
      if(p.y<_hsw.y-_hsL||p.y>_hsw.y-_hsL+_hsw.h) continue; // not under the top face
      _hsHid=true;
    }
    if(_hsHid){
      wc.save();
      wc.globalAlpha=0.5;
      drawOp(p.x,p.y,p.face,(p.rollT>0)?(1-p.rollT/.38)*12.6:p.bob,'#9fd8ff',0,0,
        (p.rollT>0)?'roll':((P.equipped&&P.equipped!=='fists')?'':'none'),0,
        {hero:1,moving:p.moving,sprint:false,ads:false,hurt:0,rl:0,own:{wep:WEAPONS[P.equipped]||null}});
      wc.restore();
    }
  }
  }catch(_hsE){}
  // station names float above their posts
'@

SubRx @'
var VER='10.50';
'@ @'
var VER='10.51';
'@
SubRx @'
  now:'v10.50: the freckles, the scar, the mud and every beard sit clear of the eyes, on the cheeks and the jaw where they belong, and boots are boots: the lower leg is trousers cut from the coat and the boot colour is the foot and a collar. In the Depot and in the raid alike.',
'@ @'
  now:'v10.51: behind the terminal in the Undercroft you no longer vanish into the plinth: the room shows you through the wall the way a raid does, and the walk cycle follows the ground you cover, so you never run in place against a wall.',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
