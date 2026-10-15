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

# THE MAGNET POWER-UP IS GONE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  {k:'mag',n:'MAGNET',sec:20,w:12,hex:'#4aa8ff',rgb:'74,168,255'},

'@ @'

'@

SubRx @'
  mag:[[0,1200,300,0.35,'sine',0.06],[0.1,300,900,0.3,'sine',0.04]],

'@ @'

'@

SubRx @'
  else if(k==='mag'){
    c.beginPath(); c.arc(x,y+s*0.15,s*0.6,0,3.1416); c.stroke();
    c.beginPath(); c.moveTo(x-s*0.6,y+s*0.15); c.lineTo(x-s*0.6,y-s*0.6); c.moveTo(x+s*0.6,y+s*0.15); c.lineTo(x+s*0.6,y-s*0.6); c.stroke();
    c.fillStyle='rgba(255,255,255,1)'; c.fillRect(x-s*0.85,y-s*0.9,s*0.5,s*0.32); c.fillRect(x+s*0.35,y-s*0.9,s*0.5,s*0.32);
  }

'@ @'

'@

SubRx @'
var PWRX={magR:520,magSp:340,magPick:520,magStop:56,pulsePer:30,pulseMax:400,pulseT:0.8,flash:0.3};
'@ @'
var PWRX={pulsePer:30,pulseMax:400,pulseT:0.8,flash:0.3};
'@

SubRx @'
function pwrMagnet(p,dt,S){
  var i, c, it, d, st, nx, ny, mt={body:1,botwreck:1,cache:1};
  for(i=0;i<S.items.length;i++){
    it=S.items[i]; d=Math.hypot(p.x-it.x,p.y-it.y);
    if(d<PWRX.magR*1.3&&d>PWR.pick*0.5){ st=Math.min(d,PWRX.magPick*dt); it.x+=(p.x-it.x)/d*st; it.y+=(p.y-it.y)/d*st; }
  }
  for(i=0;G.containers&&i<G.containers.length;i++){
    c=G.containers[i];
    if(!c||!mt[c.type]||!c.loot||!c.loot.length||G.searching===c) continue;
    if((c.tag&&EV_WRECK_TAGS[c.tag])||NET.on) continue;   // v27.45 (rvw3, cloud review 9): the reward of an event stays where the event put it, and in a party nobody drags boxes (each window would move its own copy and the host would answer FAR for a box the other player sees at his feet)
    d=Math.hypot(p.x-c.x,p.y-c.y); if(d>PWRX.magR||d<=PWRX.magStop) continue;
    st=Math.min(d-PWRX.magStop,PWRX.magSp*dt); nx=c.x+(p.x-c.x)/d*st; ny=c.y+(p.y-c.y)/d*st;
    if(spotFree(G.map,nx,ny,12)&&!shutRoomAt(G.map,nx,ny)&&!shutRoomAt(G.map,c.x,c.y)){ c.x=nx; c.y=ny; if(fxr()<dt*4) spark(c.x,c.y,'#7fc4ff',2,60); }
  }
}

'@ @'
// v27.92 (nomagnet), HIS ORDER (2026-10-15) about the magnet power-up: "i don't like the idea, get rid of it". THE MAGNET IS GONE, completely: its row in the drop table, its pickup, its
// effect (the function that slid bodies, wrecks, caches and pickups toward you, and its constants), its picture, its timer chip, its note, its callout and the words that named it. The other five
// power-ups (BOTTOMLESS CLIP, DOUBLE DAMAGE, RAPID FIRE, SHIELD BUBBLE, SCREEN CLEAR) are unchanged and drop as before; the drop table is five kinds. The notes above that talk about the magnet
// (v26.xx party3, v27.45 rvw3) are history. No seeded draw: the drop roll is the same side stream, one kind fewer on the table.

'@

SubRx @'
  if(S.act.mag>0) pwrMagnet(p,dt,S);

'@ @'

'@

SubRx @'
  pwrTick2(p,dt,S);   // v26.xx (party3): the magnet, the pulse clock and the bubble flash
'@ @'
  pwrTick2(p,dt,S);   // v26.xx (party3): the pulse clock and the bubble flash
'@

SubRx @'
// table). MAGNET (20 s): loose wrecks and bodies that still hold something, and the pickups on the floor, slide toward you from PWRX.magR (52 m) and stop
// at your feet; a wreck never slides through a wall or out of a shut room, and not while you search it. SHIELD BUBBLE (10 s): a bubble round you takes every
'@ @'
// table). (The MAGNET of this build was taken out at his order, v27.92 nomagnet.) SHIELD BUBBLE (10 s): a bubble round you takes every
'@

SubRx @'
var VER='27.91';
'@ @'
var VER='27.92';
'@

$pat = "(?m)^  now:'v27\.91:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v27.92: The magnet power-up is gone; the other five power-ups stay. Check 27.92 fails on v27.91',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
