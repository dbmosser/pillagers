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

# BUILDING KINDS: FLOORS, FURNITURE SKINS, FLAT DETAILS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function makeBuilding(x,y,w,h,out,d,bid,forcePlan){
'@ @'
// v34.xx (cw-bldkinds), HIS ORDER (2026-10-20 22:55): "lets use that same art style to add more furniture and details inside buildings so as to give the buidlings more identity -- e.g. is this a house, an office, a warehouse, etc". Every building gets a kind from grit() of its id, position and size, never rr(), so the seeded stream and the 4242 fingerprint do not move. CFG.bkind 0 gives none (the A/B for the stream check).
var BKINDS=['house','office','warehouse','shop','workshop'];
function bldKind(B,bid,plan){
  if(CFG.bkind===0) return undefined;
  var a=B.w*B.h, r=grit(B.x+bid*977,B.y*3+bid*31+5);
  if(plan==='core') return r<0.6?'office':'warehouse';
  if(a>=70000) return r<0.55?'warehouse':(r<0.8?'workshop':'office');
  if(a<30000) return r<0.5?'house':(r<0.8?'shop':'workshop');
  return r<0.25?'house':(r<0.5?'office':(r<0.7?'shop':(r<0.85?'workshop':'warehouse')));
}
function makeBuilding(x,y,w,h,out,d,bid,forcePlan){
'@

SubRx @'
buildings.push({x:B.x,y:B.y,w:B.w,h:B.h,d:B.d,tag:ri(11,99),plan:pl,big:B.big||0});
'@ @'
buildings.push({x:B.x,y:B.y,w:B.w,h:B.h,d:B.d,tag:ri(11,99),plan:pl,big:B.big||0,kind:bldKind(B,buildings.length,pl)});   // v34.xx (cw-bldkinds): ri is drawn once, as before
'@

SubRx @'
var _bf=bldFloor(b3);
'@ @'
var _bf=(_px&&b3.kind)?bldKindFloor(b3):bldFloor(b3);   // v34.xx (cw-bldkinds): the pixel look floors by kind, the vector bake keeps its own
'@

SubRx @'
// The number stays on all five: it is how he tells one shed from another on
'@ @'
// v34.xx (cw-bldkinds): flat details of the kind, painted into the ground only (no wall, collider or sight entry)
    if(_px&&b3.kind) pixKindDetail(c,b3,_ix,_iy,_iw,_ih,_lw);
    // The number stays on all five: it is how he tells one shed from another on
'@

SubRx @'
function pixGroundHex(h){ var n=parseInt(h.slice(1),16); return [n>>16,(n>>8)&255,n&255]; }
'@ @'
// v34.xx (cw-bldkinds), his 10-20 22:55 order: the floor of each kind (house open floor, office tiled, warehouse racking or dock, shop tiled, workshop grid with hazard stripes) and the flat details baked into it. Positions come from grit() of the building and a counter, never rr(); every box sits on the 2 unit ground grid.
function bldKindFloor(b){
  var k=b.kind;
  if(k==='house') return 2;
  if(k==='office'||k==='shop') return 3;
  if(k==='warehouse') return grit(b.x,b.y+3)<0.5?1:4;
  if(k==='workshop') return 0;
  return bldFloor(b);
}
function pixKindDetail(c,b,ix,iy,iw,ih,lw){
  var k=b.kind, x0=ix+20, y0=iy+20, w0=iw-40, h0=ih-40, i, n, x, y, rw, rh;
  if(w0<40||h0<40) return;
  function gr(j){ return grit(b.x*3+j*101,b.y*5+j*37); }
  function bx(x1,y1,w1,h1,col){ c.fillStyle=col; c.fillRect(Math.round(x1/2)*2,Math.round(y1/2)*2,Math.max(2,Math.round(w1/2)*2),Math.max(2,Math.round(h1/2)*2)); }
  function stain(j){ var e=Math.max(10,Math.min(22,w0*0.09)); c.fillStyle='rgba(6,6,10,.30)'; c.beginPath(); c.ellipse(Math.round((x0+e+(w0-2*e)*gr(j))/2)*2,Math.round((y0+e+(h0-2*e)*gr(j+50))/2)*2,e*(0.7+0.5*gr(j+9)),e*(0.45+0.3*gr(j+19)),0,0,6.2832); c.fill(); }
  c.save();
  if(k==='house'){   // a rug, a runner when the room is wide
    rw=Math.min(64,Math.round(w0*0.5)); rh=Math.min(44,Math.round(h0*0.5)); x=x0+(w0-rw)*(0.2+0.6*gr(1)); y=y0+(h0-rh)*(0.2+0.6*gr(2));
    bx(x,y,rw,rh,'rgba(34,18,18,.36)'); bx(x+4,y+4,rw-8,2,'rgba(236,226,204,.24)'); bx(x+4,y+rh-6,rw-8,2,'rgba(236,226,204,.24)'); bx(x+4,y+4,2,rh-8,'rgba(236,226,204,.24)'); bx(x+rw-6,y+4,2,rh-8,'rgba(236,226,204,.24)');
    if(w0>140){ bx(x0+8,y0+h0-18,Math.min(70,w0*0.4),10,'rgba(34,18,18,.30)'); }
  } else if(k==='office'){   // papers on the floor, a dark carpet square
    rw=Math.min(90,Math.round(w0*0.5)); rh=Math.min(60,Math.round(h0*0.5)); x=x0+(w0-rw)*gr(3); y=y0+(h0-rh)*gr(4);
    bx(x,y,rw,rh,'rgba(16,22,34,.22)');
    for(i=0;i<6;i++){ x=x0+(w0-10)*gr(10+i); y=y0+(h0-8)*gr(30+i); bx(x,y,8,6,'rgba(238,238,228,.46)'); bx(x+2,y+2,4,2,'rgba(30,30,42,.30)'); }
  } else if(k==='warehouse'){   // pallets and oil
    n=w0>240?4:3;
    for(i=0;i<n;i++){ x=x0+(w0-34)*gr(20+i); y=y0+(h0-34)*gr(40+i); bx(x,y,32,32,'rgba(52,34,16,.46)'); bx(x,y+4,32,4,'rgba(214,176,114,.26)'); bx(x,y+14,32,4,'rgba(214,176,114,.26)'); bx(x,y+24,32,4,'rgba(214,176,114,.26)'); }
    stain(60); stain(61);
  } else if(k==='shop'){   // shelf lines along the long wall and a runner down the aisle
    for(i=0;i<2;i++){ y=y0+h0*(0.25+0.45*i); bx(x0+8,y,w0*0.7,2,'rgba(8,8,14,.40)'); bx(x0+8,y+2,w0*0.7,2,'rgba(230,224,210,.18)'); }
    bx(x0+10,y0+h0*0.5-3,w0-20,6,'rgba(110,34,34,.24)');
  } else if(k==='workshop'){   // oil and steel plates
    stain(70); stain(71); stain(72);
    for(i=0;i<2;i++){ x=x0+(w0-26)*gr(80+i); y=y0+(h0-26)*gr(90+i); bx(x,y,24,24,'rgba(200,206,218,.26)'); bx(x+2,y+2,2,2,'rgba(20,20,28,.40)'); bx(x+20,y+2,2,2,'rgba(20,20,28,.40)'); bx(x+2,y+20,2,2,'rgba(20,20,28,.40)'); bx(x+20,y+20,2,2,'rgba(20,20,28,.40)'); }
  }
  c.restore();
}
// v34.xx (cw-bldkinds): the furniture of a kind wears its colours (table, shelving and locker); anything else, the look off and a building with no kind keep today's
var FNPAL={none:{k:'-',tl:'#6a4a2e',tt:'#8a6a42',th:'#a8845a',sf:null,lk:'#55606b'},
  house:{k:'h',tl:'#6a4a2e',tt:'#8a6a42',th:'#a8845a',sf:null,lk:'#55606b'},
  office:{k:'o',tl:'#3c444c',tt:'#6c7782',th:'#9aa6b0',sf:null,lk:'#5c6a78'},
  warehouse:{k:'w',tl:'#4e4028',tt:'#7a6a48',th:'#9a8a62',sf:'#6a5a40',lk:'#6b5a3a'},
  shop:{k:'s',tl:'#5a3a2e',tt:'#7a5a4a',th:'#b08a74',sf:'#5a4a52',lk:'#55606b'},
  workshop:{k:'k',tl:'#2e2a28',tt:'#5a5048',th:'#8a8070',sf:'#4a4e52',lk:'#4a5560'}};
function pixFurnPal(F){
  var b=pixOn()&&typeof G!=='undefined'&&G&&G.map&&G.map.buildings&&F&&G.map.buildings[F.ib], k=b&&b.kind;
  return (k&&FNPAL[k])||FNPAL.none;
}
function pixGroundHex(h){ var n=parseInt(h.slice(1),16); return [n>>16,(n>>8)&255,n&255]; }
'@

SubRx @'
      var F1=FN.furn;
      shadowE(FN.x+FN.w/2,FN.y+FN.h+1,FN.w*.55,4,.3);
      if(F1===1){
'@ @'
      var F1=FN.furn;
      shadowE(FN.x+FN.w/2,FN.y+FN.h+1,FN.w*.55,4,.3);
      var FP=pixFurnPal(FN);   // v34.xx (cw-bldkinds): the kind's colours
      var fnPaint=function(){
      if(F1===1){
'@

SubRx @'
wc.fillStyle='#6a4a2e'; wc.fillRect(FN.x,FN.y+FN.h-4,3,4);
'@ @'
wc.fillStyle=FP.tl; wc.fillRect(FN.x,FN.y+FN.h-4,3,4);
'@

SubRx @'
wc.fillStyle='#8a6a42'; rrF(FN.x,FN.y-8,FN.w,FN.h,2);
'@ @'
wc.fillStyle=FP.tt; rrF(FN.x,FN.y-8,FN.w,FN.h,2);
'@

SubRx @'
wc.fillStyle='#a8845a'; wc.fillRect(FN.x+1,FN.y-8,FN.w-2,2);
'@ @'
wc.fillStyle=FP.th; wc.fillRect(FN.x+1,FN.y-8,FN.w-2,2);
'@

SubRx @'
wc.fillStyle=dcol(fd,'wall'); rrF(FN.x,FN.y-18,FN.w,FN.h+18,2);
'@ @'
wc.fillStyle=FP.sf||dcol(fd,'wall'); rrF(FN.x,FN.y-18,FN.w,FN.h+18,2);
'@

SubRx @'
wc.fillStyle='#55606b'; rrF(FN.x,FN.y-24,FN.w,FN.h+23,1.5);
'@ @'
wc.fillStyle=FP.lk; rrF(FN.x,FN.y-24,FN.w,FN.h+23,1.5);
'@

SubRx @'
        wc.fillStyle='#c9b458'; wc.fillRect(FN.x+FN.w*0.5-3.6,FN.y-13,1.8,1.8);
      }
    } else if(it.w){
'@ @'
        wc.fillStyle='#c9b458'; wc.fillRect(FN.x+FN.w*0.5-3.6,FN.y-13,1.8,1.8);
      }
      };
      // v34.xx (cw-bldkinds): with the pixel look on a piece is one cached sprite at PIX_ENV, by piece, size, kind colours and district; the ground shadow above stays a live draw
      var fnE=null;
      if(pixOn()) fnE=pixWrap('fn:'+F1+':'+Math.round(FN.w)+'x'+Math.round(FN.h)+':'+FP.k+':'+fd,Math.round(FN.w)+8,Math.round(FN.h)+38,PIX_ENV,fnPaint,FN.x+FN.w/2,FN.y+FN.h,{up:Math.round(FN.h)+30});
      if(!fnE) fnPaint();
    } else if(it.w){
'@

SubRx @'
var VER='34.48';
'@ @'
var VER='34.49';
'@

$pat = "(?m)^  now:'v34\.48:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v34.49: With the pixel look on, houses, offices, warehouses, shops and workshops have their own floors, furniture colours and floor details. Walls, paths and sight lines are unchanged. With the look off nothing changes. Check 34.49 fails on v34.48',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
