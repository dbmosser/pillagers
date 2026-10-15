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

# THE AIR STRIKE PLATE MOVES TO THE RIGHT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  var A=G.flow&&G.flow.air, z, q, s, m, T, i, j, st, tf, dd, pt, pulse, bw, bh, x, y, c0, fl, rdy, R, t=G.t||0, ar, bx, bwid, by, hd;
'@ @'
  var A=G.flow&&G.flow.air, z, q, s, m, T, i, j, st, tf, dd, pt, pulse, bw, bh, x, y, c0, fl, rdy, R, t=G.t||0, ar, bx, bwid, by, hd, R0;
'@

SubRx @'
    bw=U(200); bh=U(28); x=Math.round(W/2+U(16)); y=Math.round(c0-U(112));
'@ @'
    bw=U(200); bh=U(28); R0=airPlateAt(bw,bh,z); x=R0.x; y=R0.y;   // v27.36 (strikeplace): over on the right, at the end of the gun bar (was just right of the middle, in the way of the power-up chips and the item in hand)
    G.airBox={x:x,y:y,w:bw,h:bh};
'@

SubRx @'
// FLOW-MODULE-END (the next flow builds add their code above this line)
'@ @'
// v27.36 (strikeplace), HIS PLAYTEST NOTE (2026-10-14): "air strike bar is in a weird place and is causing collisions, should be over on the right further". The meter plate sat just right of the middle of the
// screen, 112 over the gun bar, which is where the power-up timer chips (centred, a row over the bar), the item in hand and the bar's own hover and ammo text live, so they ran into it. It goes to the RIGHT END OF
// THE GUN BAR now: its right edge on the right edge of the last belt key, one chip row up (the chips sit 40 over the keys and are 24 tall), so it is past the chips and the item in hand, clear of the keys, and short of
// the gun card in the corner. The gun card starts at the belt's right end, so there is no room beside the bar; if the plate would meet the gear card, the pickup stack, the pickup gun card or the kill feed (their boxes
// are recorded as they are drawn) it is lifted clear above whatever it met. Player 1 and both player 2 windows draw it by the same code, each its own meter. The box it was drawn in is G.airBox.
function airPlateAt(bw,bh,z){
  var hc=G.hotCells, L=(hc&&hc.length)?hc[hc.length-1]:null, g8=Math.round(8*z), x, y, top=1e9, i, o, tries, hit, E, R;
  if(!L) return {x:Math.round(W-bw-16*z),y:Math.round(H*0.6)};
  for(i=0;i<hc.length;i++) top=Math.min(top,hc[i].y);
  x=Math.round(L.x+L.w-bw);
  y=Math.round(top-64*z-g8-bh);
  E=[HUDBOX.gear,(typeof EDGEBOX==='object'&&EDGEBOX)?EDGEBOX.pick:null,(typeof EDGEBOX==='object'&&EDGEBOX)?EDGEBOX.gun:null,(typeof EDGEBOX==='object'&&EDGEBOX)?EDGEBOX.feed:null];
  for(tries=0;tries<4;tries++){
    hit=null;
    for(i=0;i<E.length;i++){ o=E[i]; if(o&&o.w>0&&o.h>0&&x<o.x+o.w+g8&&x+bw>o.x-g8&&y<o.y+o.h+g8&&y+bh>o.y-g8){ hit=o; break; } }
    if(!hit) break;
    y=Math.round(hit.y-g8-bh);
  }
  return {x:clamp(x,g8,Math.max(g8,W-bw-g8)),y:Math.max(g8,y)};
}
// FLOW-MODULE-END (the next flow builds add their code above this line)
'@

SubRx @'
var VER='27.35';
'@ @'
var VER='27.36';
'@

$pat = "(?m)^  now:'v27\.35:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v27.36: The air strike meter now sits over on the right of the gun bar, out of the way of the power-up timers. Check 27.36 fails on v27.35',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
