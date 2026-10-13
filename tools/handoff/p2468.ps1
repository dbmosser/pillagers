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

# DEMO VAULTS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
// Run from startRaid right after the build, in every window that builds the arcade raid, so both builds stay identical.
function arcadePostBuild(g){
'@ @'
// v23.9x (feat4b), HIS ORDER (2026-10-12): "32 more interiors". DEMO VAULTS. COLD STORAGE already builds strongrooms: the 'core'
// buildings, a closed inner box with exactly one doorway. In a DEMO raid two of them are sealed into vaults: the doorway gets a
// keyed door (door:'arcvN', arc:1), the box walls become vault walls (lockWall: no charge or round goes through them), the room
// joins map.locked as VAULT A and VAULT B (the lamp, the map outline, the UNLOCK prompt and the party door word come with that),
// and two caches go inside, one with an elite gun. A Vault Keycard opens one (feat4a). A strongroom is used only when its four
// walls stand whole, nothing alive, no spawn, no ring and no drop point is inside, and it touches no map room. The pick and the
// loot are drawn on their own side stream, so the main stream does not move and both windows build the same vaults. The map
// build itself is untouched: a plain raid is exactly as before.
var ARCADE_VAULTS=2, ARCADE_VAULT_TAG=7, ARCADE_VAULT_GUNS=['gun_lance','gun_whisper','gun_sniper'];
function arcadeVaultBox(m,bi){
  var j, w, n=0, x0=1e9, y0=1e9, x1=-1e9, y1=-1e9;
  for(j=0;j<m.walls.length;j++){ w=m.walls[j]; if(!w||w.ib!==bi||w.furn) continue; n++;
    if(w.x<x0) x0=w.x; if(w.y<y0) y0=w.y; if(w.x+w.w>x1) x1=w.x+w.w; if(w.y+w.h>y1) y1=w.y+w.h; }
  if(n<4||x1-x0<80||y1-y0<80) return null;
  return {x:x0,y:y0,w:x1-x0,h:y1-y0};
}
// every point along the four wall lines of the box is wall (no window) or the one doorway
function arcadeVaultShut(m,B,D){
  var s, t, x, y, j, w, hit, S=[[B.x,B.y+8,1,0,B.w],[B.x,B.y+B.h-8,1,0,B.w],[B.x+8,B.y,0,1,B.h],[B.x+B.w-8,B.y,0,1,B.h]];
  for(s=0;s<4;s++) for(t=2;t<=S[s][4]-2;t+=4){
    x=S[s][0]+S[s][2]*t; y=S[s][1]+S[s][3]*t; hit=(x>=D.x&&x<=D.x+D.w&&y>=D.y&&y<=D.y+D.h);
    for(j=0;j<m.walls.length&&!hit;j++){ w=m.walls[j]; if(w&&!w.win&&x>=w.x&&x<=w.x+w.w&&y>=w.y&&y<=w.y+w.h) hit=true; }
    if(!hit) return false;
  }
  return true;
}
function arcadeVaultClear(m,x,y,pad){
  var j, w;
  for(j=0;j<m.walls.length;j++){ w=m.walls[j]; if(w&&x>w.x-pad&&x<w.x+w.w+pad&&y>w.y-pad&&y<w.y+w.h+pad) return false; }
  return true;
}
function arcadeVaults(g){
  var m=g&&g.map, made=[], cands=[], i, j, b, B, D, dn, k, s, ok, pts;
  if(!m||!Array.isArray(m.buildings)||!Array.isArray(m.walls)||!Array.isArray(g.containers)) return made;
  if(!m.locked) m.locked=[];
  var inB=function(B2,x,y){ return x>B2.x&&x<B2.x+B2.w&&y>B2.y&&y<B2.y+B2.h; };
  for(i=0;i<m.buildings.length;i++){
    b=m.buildings[i]; if(!b||b.plan!=='core') continue;
    B=arcadeVaultBox(m,i); if(!B) continue;
    dn=0; D=null;
    for(j=0;j<(m.idoors||[]).length;j++){ k=m.idoors[j]; if(k&&k.x>=B.x-1&&k.y>=B.y-1&&k.x+k.w<=B.x+B.w+1&&k.y+k.h<=B.y+B.h+1){ dn++; D=k; } }
    if(dn!==1) continue;
    ok=arcadeVaultShut(m,B,D);
    pts=[g.player].concat(g.ents||[],m.spawns||[],m.extracts||[],g.zones||[]); if(g.seal) pts.push(g.seal);
    for(j=0;j<pts.length&&ok;j++){ s=pts[j]; if(s&&isFinite(s.x)&&isFinite(s.y)&&inB(B,s.x,s.y)) ok=false; }
    for(j=0;j<m.locked.length&&ok;j++){ k=m.locked[j]; if(k.x<B.x+B.w&&k.x+k.w>B.x&&k.y<B.y+B.h&&k.y+k.h>B.y) ok=false; }
    if(ok) cands.push({bi:i,box:B,door:D});
  }
  if(!cands.length) return made;
  sideStream(g.seed,ARCADE_VAULT_TAG,function(){
    var q, c, n, id, V, sp, ct, sps, o, o0, QO=[[-1,-1],[1,1],[1,-1],[-1,1],[-1,0],[1,0],[0,-1],[0,1]];
    while(cands.length&&made.length<ARCADE_VAULTS){
      c=cands.splice(ri(0,cands.length-1),1)[0];
      n=made.length; id='arcv'+n;
      for(q=0;q<m.walls.length;q++) if(m.walls[q]&&m.walls[q].ib===c.bi&&!m.walls[q].furn) m.walls[q].lockWall=id;
      m.walls.push({x:c.door.x,y:c.door.y,w:c.door.w,h:c.door.h,d:3,door:id,arc:1,wid:m.walls.length});
      V={id:id,name:'VAULT '+'AB'.charAt(n),x:c.box.x,y:c.box.y,w:c.box.w,h:c.box.h,doorX:c.door.x+c.door.w/2,doorY:c.door.y+c.door.h/2,open:false,arc:1};
      m.locked.push(V);
      // two boxes in the quarters of the room, never on top of each other (a small strongroom leaves spotWall one narrow strip)
      sps=[]; o0=ri(0,3);
      for(q=0;q<QO.length&&sps.length<2;q++){
        o=QO[q<4?((q+o0)%4):q]; sp={x:c.box.x+c.box.w*(0.5+o[0]*0.25),y:c.box.y+c.box.h*(0.5+o[1]*0.25)};
        if(arcadeVaultClear(m,sp.x,sp.y,16)&&(!sps.length||dist(sps[0],sp)>=36)) sps.push(sp);
      }
      for(q=0;q<6&&sps.length<2;q++){ sp=spotWall(m,{x:c.box.x+20,y:c.box.y+20,w:c.box.w-40,h:c.box.h-40},18); if(sp&&(!sps.length||dist(sps[0],sp)>=36)) sps.push(sp); }
      for(q=0;q<sps.length;q++){
        sp=sps[q];
        ct=mkContainer(sp.x,sp.y,'cache',3); ct.cache=1; ct.inLocked=id; ct.vault=1;
        if(q===0){ ct.loot.push(ARCADE_VAULT_GUNS[ri(0,ARCADE_VAULT_GUNS.length-1)]); ct.loot.sort(function(a2,b2){ return ival(a2)-ival(b2); }); ct.best=bestRarity(ct.loot); }
        g.containers.push(ct);
      }
      made.push(V);
    }
  });
  if(made.length&&g===G) rebuildGeometry();
  return made;
}
// Run from startRaid right after the build, in every window that builds the arcade raid, so both builds stay identical.
function arcadePostBuild(g){
'@

SubRx @'
  for(i=g.ents.length-1;i>=0;i--){ e=g.ents[i]; if(e&&(e.kind==='peddler'||e.kind==='stray')) g.ents.splice(i,1); }
'@ @'
  for(i=g.ents.length-1;i>=0;i--){ e=g.ents[i]; if(e&&(e.kind==='peddler'||e.kind==='stray')) g.ents.splice(i,1); }
  try{ arcadeVaults(g); }catch(_av){}   // v23.9x (feat4b): two strongrooms sealed into vaults (side stream)
'@

SubRx @'
      if(x>30&&y>30&&x<WORLD_W-30&&y<WORLD_H-30&&spotFree(m,x,y,22)){ p.x=x; p.y=y; ok=true; }
'@ @'
      if(x>30&&y>30&&x<WORLD_W-30&&y<WORLD_H-30&&spotFree(m,x,y,22)&&!shutRoomAt(m,x,y)){ p.x=x; p.y=y; ok=true; }   // v23.9x (feat4b): never inside a shut vault
'@

SubRx @'
var VER='24.67';
'@ @'
var VER='24.68';
'@

$pat = "(?m)^  now:'v24\.67:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v24.68: A DEMO raid now has two locked vaults with elite loot. Check 24.68 fails on v24.67',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
