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

# THE PARTNER AND THE MACHINES GLIDE ON THE OTHER SCREEN (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var NET_HUB_STEP=0.1, NET_HUB_SNAP=160, NET_HUB_STALE=3, NET_HUB_EASE=12;
'@ @'
var NET_HUB_STEP=0.1, NET_HUB_SNAP=160, NET_HUB_STALE=3, NET_HUB_EASE=12;
// v36.xx (cw-coopsmooth), HIS ANSWER 2.27 b ("no more than 50 ms extra for player 2, with prediction"): the partner and the machines on the other screen
// used to chase the newest 10 Hz sample with a plain exponential ease, which moved a walking body 1.55x, then 0.57x its speed inside each 100 ms and kept
// it about 130 ms behind. Now the receiving window reads each body speed from its last two samples (netLeadSample), aims at the sample plus that speed
// times the time since it came (at most NET_LEAD_CAP, so a lost word never runs a body far) and moves the body at that speed while it eases out the
// error (netLeadStep). Nothing that is sent changes. A body that stopped, jumped, rolled fast or would be led into a wall gets no lead and eases as before.
var NET_LEAD_CAP=0.12, NET_LEAD_VMAX=700;
function netLeadClear(x,y){
  var ws=(typeof G==='object'&&G&&G.map)?G.map.walls:null, i, w;
  if(!ws) return 1;
  if(G.wgrid&&G.wgrid.walls===ws) ws=wallsNear(G.wgrid,x,y,10);
  for(i=0;i<ws.length;i++){ w=ws[i]; if(x>w.x-8&&x<w.x+w.w+8&&y>w.y-8&&y<w.y+w.h+8) return 0; }
  return 1;
}
// A new sample (x, y) came age seconds after the one at (px, py). Returns 1 when the body gets a lead.
function netLeadSample(o,x,y,px,py,age){
  var dx=x-px, dy=y-py, d=Math.sqrt(dx*dx+dy*dy), gap, vx, vy;
  if(!(age>=0.04)) return o.nlead?1:0;   // two words in one frame say nothing about speed; keep what was read
  o.nlead=0;
  if(age>0.3||!(d>=0.6)||d>NET_HUB_SNAP){ o.nvx=0; o.nvy=0; return 0; }   // stopped, a long silence or a jump
  gap=Math.max(age,0.07);
  vx=dx/gap; vy=dy/gap;
  if(o.nvx||o.nvy){ vx=(vx+o.nvx)*0.5; vy=(vy+o.nvy)*0.5; }
  if(Math.sqrt(vx*vx+vy*vy)>NET_LEAD_VMAX){ vx=0; vy=0; }
  o.nvx=vx; o.nvy=vy;
  if((vx||vy)&&netLeadClear(x+vx*NET_LEAD_CAP*0.5,y+vy*NET_LEAD_CAP*0.5)&&netLeadClear(x+vx*NET_LEAD_CAP,y+vy*NET_LEAD_CAP)) o.nlead=1;
  return o.nlead;
}
// One frame: moves o toward (tx, ty) plus the lead, at its read speed, and leaves how far it moved in nmx, nmy.
function netLeadStep(o,tx,ty,age,dt,k){
  var ox=o.x, oy=o.y, a;
  if(o.nlead){
    a=Math.min(age,NET_LEAD_CAP); tx+=o.nvx*a; ty+=o.nvy*a;
    if(age<NET_LEAD_CAP){ o.x+=o.nvx*dt; o.y+=o.nvy*dt; }
  }
  o.x+=(tx-o.x)*k; o.y+=(ty-o.y)*k;
  o.nmx=o.x-ox; o.nmy=o.y-oy;
}
'@

SubRx @'
  g.tx=x; g.ty=y; g.tf=f; g.mv=m.m?1:0; g.roll=clamp(+m.r||0,0,0.38); g.age=0; g.n++;

'@ @'
  if(up) netLeadSample(g,x,y,g.tx,g.ty,g.age);   // v36.xx (cw-coopsmooth): his speed from this word and the last; read before the new spot is filed
  g.tx=x; g.ty=y; g.tf=f; g.mv=m.m?1:0; g.roll=clamp(+m.r||0,0,0.38); g.age=0; g.n++;

'@

SubRx @'
    if(g.seat===NET.seat||netSeatName(g.seat)===null){ NET.up[i]=null; continue; }
    g.age+=dt;
    dx=(g.tx-g.x)*k; dy=(g.ty-g.y)*k;
    g.x+=dx; g.y+=dy;
'@ @'
    if(g.seat===NET.seat||netSeatName(g.seat)===null){ NET.up[i]=null; continue; }
    g.age+=dt;
    netLeadStep(g,g.tx,g.ty,g.age,dt,k); dx=g.nmx; dy=g.nmy;   // v36.xx (cw-coopsmooth): a steady glide at his read speed, not a chase of a 10 Hz staircase
'@

SubRx @'
    e.nT=1; e.ntx=x; e.nty=y; e.ntf=f; e.nAge=0;
'@ @'
    netLeadSample(e,x,y,e.nT?e.ntx:x,e.nT?e.nty:y,e.nAge);   // v36.xx (cw-coopsmooth): its speed from this row and the last; read before the new spot is filed
    e.nT=1; e.ntx=x; e.nty=y; e.ntf=f; e.nAge=0;
'@

SubRx @'
      dx=(e.ntx-e.x)*k; dy=(e.nty-e.y)*k; e.x+=dx; e.y+=dy;
'@ @'
      netLeadStep(e,e.ntx,e.nty,e.nAge,dt,k); dx=e.nmx; dy=e.nmy;   // v36.xx (cw-coopsmooth): a steady glide at its read speed, not a chase of a 10 Hz staircase
'@

SubRx @'
var VER='36.87';
'@ @'
var VER='36.88';
'@

$pat = "(?m)^  now:'v36\.87:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v36.88: In a two player raid, the partner and the machines on the other screen glide at a steady speed instead of surging and stalling, and sit closer to where they really are. Check 36.88 fails on v36.87',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
