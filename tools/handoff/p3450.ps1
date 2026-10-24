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

# SOLID PIECES PER BUILDING KIND (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function carveDoors(nav,doors,walls,jamb){
'@ @'
// v34.xx (cw-bldsolid), HIS ORDER (2026-10-20 22:55 and 23:00, "quit queuing stuff for after the party -- just do it all as it naturally arises"): a few SOLID pieces per building kind, so a house has a bed and a sofa, an office a desk row, a warehouse rack rows, a shop a counter and shelves, a workshop benches. They use the 7 furniture ids the game already draws. Placed at the very end of the map build, after every roll (like the partition door cut), with grit() of the building and a counter and never rr(), so the seeded stream does not move. Each piece sits flush to a wall, clear of every doorway (the same zones the old furniture keeps), of locked rooms, of every wall and piece by 30 units or touching, and a building whose floor would be cut off by its pieces loses all of them (CFG.bsolid 0 gives none).
var BSOLID={
  house:[{f:5,w:28,h:22,n:1},{f:6,w:40,h:17,n:1},{f:1,w:26,h:20,n:1}],
  office:[{f:1,w:30,h:20,n:2,x:1},{f:7,w:16,h:26,n:1}],
  warehouse:[{f:2,w:34,h:18,n:2,x:1},{f:2,w:34,h:18,n:2,x:1}],
  shop:[{f:3,w:62,h:13,n:1},{f:2,w:34,h:18,n:2}],
  workshop:[{f:1,w:34,h:22,n:2},{f:7,w:16,h:26,n:1}]};
function bsFree(walls,b,fx,fy,fw,fh,locked){
  var i, d, h, zx, zy, zw, zh, o, gx, gy, gap, ds=[BDOORS,IDOORS], q;
  for(q=0;q<2;q++) for(i=0;i<ds[q].length;i++){
    d=ds[q][i]; h=d.w>=d.h;
    zx=h?d.x-12:d.x-40; zy=h?d.y-40:d.y-12; zw=h?d.w+24:d.w+80; zh=h?d.h+80:d.h+24;
    if(fx<zx+zw&&fx+fw>zx&&fy<zy+zh&&fy+fh>zy) return false;
  }
  for(i=0;i<locked.length;i++){ d=locked[i]; if(fx<d.x+d.w+24&&fx+fw>d.x-24&&fy<d.y+d.h+24&&fy+fh>d.y-24) return false; }
  for(i=0;i<walls.length;i++){
    o=walls[i];
    if(o.x+o.w<b.x-1||o.x>b.x+b.w+1||o.y+o.h<b.y-1||o.y>b.y+b.h+1) continue;
    if(fx<o.x+o.w&&fx+fw>o.x&&fy<o.y+o.h&&fy+fh>o.y) return false;
    gx=Math.max(0,o.x-(fx+fw),fx-(o.x+o.w)); gy=Math.max(0,o.y-(fy+fh),fy-(o.y+o.h));
    gap=(gx>0&&gy>0)?Math.sqrt(gx*gx+gy*gy):Math.max(gx,gy);
    if(gap>2.5&&gap<30) return false;
  }
  return true;
}
// every floor cell of the building (and 32 units round it) that a body could reach before must still join the outside after the new pieces take their padding
function bsReach(nav,seen0,b,mine){
  var c=nav.c, gw=nav.w, gh=nav.h, blk=nav.blk, x0=Math.max(0,Math.floor((b.x-32)/c)), x1=Math.min(gw-1,Math.ceil((b.x+b.w+32)/c)), y0=Math.max(0,Math.floor((b.y-32)/c)), y1=Math.min(gh-1,Math.ceil((b.y+b.h+32)/c)),
      rw=x1-x0+1, rh=y1-y0+1, S=new Uint8Array(rw*rh), st=[], i, j, m, id, cx, cy, hit, cur, left=0, M;
  for(j=0;j<rh;j++) for(i=0;i<rw;i++){
    id=(y0+j)*gw+x0+i; if(blk[id]||!seen0[id]) continue;
    cx=(x0+i)*c+c*0.5; cy=(y0+j)*c+c*0.5; hit=false;
    for(m=0;m<mine.length;m++){ M=mine[m]; if(cx>M.x-12&&cx<M.x+M.w+12&&cy>M.y-12&&cy<M.y+M.h+12){ hit=true; break; } }
    if(!hit){ S[j*rw+i]=1; left++; }
  }
  for(j=0;j<rh;j++) for(i=0;i<rw;i++) if((i===0||j===0||i===rw-1||j===rh-1)&&S[j*rw+i]===1){ S[j*rw+i]=2; st.push(j*rw+i); left--; }
  while(st.length){
    cur=st.pop(); j=(cur/rw)|0; i=cur-j*rw;
    if(i>0&&S[cur-1]===1){ S[cur-1]=2; left--; st.push(cur-1); }
    if(i<rw-1&&S[cur+1]===1){ S[cur+1]=2; left--; st.push(cur+1); }
    if(j>0&&S[cur-rw]===1){ S[cur-rw]=2; left--; st.push(cur-rw); }
    if(j<rh-1&&S[cur+rw]===1){ S[cur+rw]=2; left--; st.push(cur+rw); }
  }
  return left===0;
}
function bldSolid(walls,buildings,nav,locked){
  var seen0=floodNav(nav), added=0, bi, b, ix, iy, iw, ih, plan, mine, gi, P, side, vert, pw, ph, n, L, lo, hi, st, r, fx, fy, k, W;
  for(bi=0;bi<buildings.length;bi++){
    b=buildings[bi]; plan=BSOLID[b.kind];
    if(!plan||b.ruined) continue;
    ix=b.x+16; iy=b.y+16; iw=b.w-32; ih=b.h-32;
    if(iw<150||ih<130) continue;
    mine=[];
    for(gi=0;gi<plan.length;gi++){
      P=plan[gi];
      side=(grit(b.x*7+bi*13+gi*303,b.y*5+bi*29+gi*171)*4)|0; vert=side>1;
      pw=P.w; ph=P.h; if(vert&&P.f===3){ pw=P.h; ph=P.w; }
      n=P.n+((P.x&&grit(b.x*7+bi*13+gi*303+101,b.y*5+bi*29+gi*171+57)<0.5)?1:0);
      lo=(vert?iy:ix)+44; hi=(vert?iy+ih:ix+iw)-44;
      for(;;){ L=n*(vert?ph:pw)+(n-1)*34; if(n<=1||lo+L<=hi) break; n--; }
      if(lo+L>hi) continue;
      st=lo+(hi-lo-L)*grit(b.x*7+bi*13+gi*303+202,b.y*5+bi*29+gi*171+114);
      for(r=0;r<n;r++){
        if(vert){ fx=(side===2)?ix+1:ix+iw-1-pw; fy=st+r*(ph+34); }
        else { fy=(side===0)?iy+1:iy+ih-1-ph; fx=st+r*(pw+34); }
        if(!bsFree(walls,b,fx,fy,pw,ph,locked)) continue;
        W={x:fx,y:fy,w:pw,h:ph,d:b.d,ib:bi,furn:P.f,bs:1,streaks:[]};
        walls.push(W); mine.push(W);
      }
    }
    if(mine.length&&!bsReach(nav,seen0,b,mine)){
      for(k=walls.length-1;k>=0;k--) if(walls[k].bs&&walls[k].ib===bi) walls.splice(k,1);
      mine=[];
    }
    added+=mine.length;
  }
  return added;
}
function carveDoors(nav,doors,walls,jamb){
'@

SubRx @'
  var _nb=(CFG.navBody===undefined?15:CFG.navBody);
'@ @'
  // v34.xx (cw-bldsolid): the solid pieces of each building kind, last of all, grit() only
  if((CFG.bsolid===undefined?1:CFG.bsolid)&&bldSolid(walls,buildings,mapNav,lockedRooms)) mapNav=buildNav(walls);
  var _nb=(CFG.navBody===undefined?15:CFG.navBody);
'@

SubRx @'
var VER='34.49';
'@ @'
var VER='34.50';
'@

$pat = "(?m)^  now:'v34\.49:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v34.50: Buildings have a few more solid pieces that match what they are: beds and sofas, desk rows, rack rows, counters, benches. They block movement and bullets like the other furniture, and every door and room stays reachable. Check 34.50 fails on v34.49',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
