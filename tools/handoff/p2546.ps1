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

# RING BADGES: SHORT CALLOUTS, CLEAR OF THE GUN CARD (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function zoneBadge(z){
  if(!z.open) return 'EXTRACTION POINT - CLOSED FOR THE REMAINDER OF THIS RAID';
  if(z.beaconT===null||z.beaconT===undefined) return 'EXTRACTION POINT - SOUND THE ALARM TO BEGIN COUNTDOWN';
  if(z.beaconT>0) return 'EXTRACTION POINT - '+Math.max(0,Math.ceil(z.beaconT))+'S UNTIL EXTRACTION BEGINS';
  if(z.hold!==null&&z.hold!==undefined) return 'EXTRACTION POINT - EXTRACT IN PROGRESS! '+Math.max(0,Math.ceil(z.hold))+'S UNTIL EXTRACTION ENDS';   // v17.95: his words of 2026-10-03
  return 'EXTRACTION POINT - SOUND THE ALARM TO BEGIN COUNTDOWN';
}
'@ @'
// v24.9x (ringbadge), his raid text map and his #50 (2026-10-12), in the AAA voice: THE RING BADGE IS A SHORT CALLOUT. The four
// states keep their order and their live seconds, named as the rest of the raid names them: EXTRACTION A AVAILABLE (nobody has
// called it), EXTRACTION A INBOUND 18S (as the ring prompt and the alert lane say INBOUND), EXTRACT IN PROGRESS! A 12S (his phrase of
// 2026-10-03, as the band says it) and EXTRACTION A CLOSED (the alert lane line). Each fits in 28 characters; the sentences ran to 64
// and, held at the screen edge, printed under the gun card.
var EDGEBOX={}, GUNCARD_LAST=null;   // v24.9x (ringbadge): the gun card, pickup rows and co-op kill feed as last drawn, screen pixels
function zoneBadge(z){
  var L=extLetter(z); L=(L==='?')?'':' '+L;
  if(!z.open) return 'EXTRACTION'+L+' CLOSED';
  if(z.beaconT===null||z.beaconT===undefined) return 'EXTRACTION'+L+' AVAILABLE';
  if(z.beaconT>0) return 'EXTRACTION'+L+' INBOUND '+Math.max(0,Math.ceil(z.beaconT))+'S';
  if(z.hold!==null&&z.hold!==undefined) return 'EXTRACT IN PROGRESS!'+L+' '+Math.max(0,Math.ceil(z.hold))+'S';   // v17.95: his words of 2026-10-03
  return 'EXTRACTION'+L+' AVAILABLE';
}
// v24.9x (ringbadge): a badge held at the screen edge, from l to r across and from y-up to y+dn down, slides up or down along the edge
// to the nearest place clear of every panel there (the HUD panels, the gun card, the pickup rows, the kill feed, the teammate rows and
// the corner readout, as last drawn). Where it is already clear, or nowhere on screen is, it stays where it was.
function ringBadgeSlide(l,r,y,up,dn){
  var bx=[], k, B, i, c, best=y, bd=1e9, cand=[], m=LH(4)*Math.max(1,hudRes());
  for(k in HUDBOX){ B=HUDBOX[k]; if(B&&B.w>0&&B.h>0) bx.push(B); }
  for(k in EDGEBOX){ B=EDGEBOX[k]; if(B&&B.w>0&&B.h>0) bx.push(B); }
  if(typeof NETTEAMBOX==='object'&&NETTEAMBOX&&NETTEAMBOX.n&&NETTEAMBOX.w>0) bx.push(NETTEAMBOX);
  if(G&&G.cornerBox) bx.push(G.cornerBox);
  function hit(yy){ for(var j=0;j<bx.length;j++){ var b=bx[j]; if(r>b.x&&l<b.x+b.w&&yy+dn+m>b.y&&yy-up-m<b.y+b.h) return true; } return false; }
  if(!hit(y)) return y;
  for(i=0;i<bx.length;i++){ B=bx[i]; if(r>B.x&&l<B.x+B.w) cand.push(B.y-m-dn-1,B.y+B.h+m+up+1); }
  for(i=0;i<cand.length;i++){ c=cand[i]; if(c-up<4||c+dn>H-4||hit(c)) continue; if(Math.abs(c-y)<bd){ bd=Math.abs(c-y); best=c; } }
  return best;
}
'@

SubRx @'
    var zcx=(zwid+24*_zr<W)?clamp(zs.x,zwid/2+12*_zr,W-zwid/2-12*_zr):zs.x;
    var zsy=hudDodge(zcx,zs.y,zwid/2+6*_zr,LH(15)*_zr,0);
'@ @'
    // v24.9x (ringbadge), from his raid text map (2026-10-12) and his #50: A RING BADGE AT THE SCREEN EDGE POINTS AT ITS RING AND STAYS
    // CLEAR OF THE EDGE STACK. A ring just off the right of the screen had its badge pushed against the edge at mid height, where the
    // gun card on pickup, the pickup rows and the co-op kill feed live, so its words printed under the card. A badge held at the edge
    // now carries an arrow on the side its ring is on, pointing at the ring, and where it would sit under a panel at that edge (the gun
    // card, the pickup rows, the kill feed, CONDITIONS, the gear corner, the CURRENT PILLAGERS board, the key legend, the vitals or the
    // teammate rows, as each was drawn last frame) it slides along the edge to the nearest clear place. A badge over its ring is untouched.
    var _zaw=0, _zcl=false, zcx=(zwid+24*_zr<W)?clamp(zs.x,zwid/2+12*_zr,W-zwid/2-12*_zr):zs.x;
    if(zcx!==zs.x&&zwid+24*_zr+LH(12)*_zr<W){ _zcl=true; _zaw=LH(12)*_zr; zcx=clamp(zs.x,(zwid+_zaw)/2+12*_zr,W-(zwid+_zaw)/2-12*_zr); }
    var _zhw=(zwid+_zaw)/2, zsy=hudDodge(zcx,zs.y,_zhw+6*_zr,LH(15)*_zr,0);
    if(_zcl) zsy=ringBadgeSlide(zcx-_zhw-6*_zr,zcx+_zhw+6*_zr,zsy,LH(11)*_zr,LH(4)*_zr);
'@

SubRx @'
    if(_zbp&&zcx-zwid/2-6*_zr<_zbp.x+_zbp.w&&zcx+zwid/2+6*_zr>_zbp.x&&zsy-LH(11)*_zr<_zbp.y+_zbp.h&&zsy+LH(4)*_zr>_zbp.y) continue;
    ctx.fillStyle='rgba(6,9,13,.78)';
    ctx.fillRect(zcx-zwid/2-6*_zr,zsy-LH(11)*_zr,zwid+12*_zr,LH(15)*_zr);
    ctx.fillStyle=za?'#4de3d0':'rgba(168,180,193,.95)';
    ctx.fillText(zlab,zcx,zsy);
'@ @'
    if(_zbp&&zcx-_zhw-6*_zr<_zbp.x+_zbp.w&&zcx+_zhw+6*_zr>_zbp.x&&zsy-LH(11)*_zr<_zbp.y+_zbp.h&&zsy+LH(4)*_zr>_zbp.y) continue;
    ctx.fillStyle='rgba(6,9,13,.78)';
    ctx.fillRect(zcx-_zhw-6*_zr,zsy-LH(11)*_zr,zwid+_zaw+12*_zr,LH(15)*_zr);
    ctx.fillStyle=za?'#4de3d0':'rgba(168,180,193,.95)';
    var _zar=(zs.x>=zcx);   // v24.9x (ringbadge): the arrow on the side its ring is on, the words beside it
    ctx.fillText(zlab,_zcl?(_zar?zcx-_zaw/2:zcx+_zaw/2):zcx,zsy);
    if(_zcl){
      var _zax=_zar?(zcx+_zhw-_zaw/2):(zcx-_zhw+_zaw/2), _zay=zsy-LH(3.5)*_zr, _zan=Math.atan2(zs.y-_zay,zs.x-_zax), _zas=LH(5)*_zr;
      ctx.beginPath();
      ctx.moveTo(_zax+Math.cos(_zan)*_zas,_zay+Math.sin(_zan)*_zas);
      ctx.lineTo(_zax+Math.cos(_zan+2.5)*_zas*0.85,_zay+Math.sin(_zan+2.5)*_zas*0.85);
      ctx.lineTo(_zax+Math.cos(_zan-2.5)*_zas*0.85,_zay+Math.sin(_zan-2.5)*_zas*0.85);
      ctx.closePath(); ctx.fill();
    }
'@

SubRx @'
    hudPlate(x,y,w,h,vc,HUDC.plate);
'@ @'
    hudPlate(x,y,w,h,vc,HUDC.plate);
    GUNCARD_LAST={x:x,y:y,w:w,h:h};   // v24.9x (ringbadge): where the card is, for a ring badge at the edge
'@

SubRx @'
  return gunCardDraw(gunCompare(C.w,C.vs),W-8*rs,Math.round(H*0.6),Math.max(0,Math.min(1,(GUNCARD_T-age)/0.5)),C.route);
'@ @'
  var _gch=gunCardDraw(gunCompare(C.w,C.vs),W-8*rs,Math.round(H*0.6),Math.max(0,Math.min(1,(GUNCARD_T-age)/0.5)),C.route);
  EDGEBOX.gun=GUNCARD_LAST;   // v24.9x (ringbadge)
  return _gch;
'@

SubRx @'
      hudPlate(xR-w,y-rh,w,rh,col,HUDC.plate);
'@ @'
      hudPlate(xR-w,y-rh,w,rh,col,HUDC.plate);
      EDGEBOX.pick=EDGEBOX.pick?{x:Math.min(EDGEBOX.pick.x,xR-w),y:y-rh,w:xR-Math.min(EDGEBOX.pick.x,xR-w),h:EDGEBOX.pick.y+EDGEBOX.pick.h-(y-rh)}:{x:xR-w,y:y-rh,w:w,h:rh};   // v24.9x (ringbadge)
'@

SubRx @'
    ctx.fillStyle='rgba(6,9,13,.62)'; ctx.fillRect(x-tw-LH(6),y-LH(13),tw+LH(12),LH(18));
'@ @'
    ctx.fillStyle='rgba(6,9,13,.62)'; ctx.fillRect(x-tw-LH(6),y-LH(13),tw+LH(12),LH(18));
    (function(){ var bx=(x-tw-LH(6))*_fhr, by=(y-LH(13))*_fhr, bw=(tw+LH(12))*_fhr, bh=LH(18)*_fhr, E=EDGEBOX.feed;   // v24.9x (ringbadge)
      EDGEBOX.feed=E?{x:Math.min(E.x,bx),y:E.y,w:Math.max(E.x+E.w,bx+bw)-Math.min(E.x,bx),h:by+bh-E.y}:{x:bx,y:by,w:bw,h:bh}; })();
'@

SubRx @'
  try{ if(NET.on) netFeedDraw(); }catch(_nfd){}
'@ @'
  EDGEBOX.feed=null; try{ if(NET.on) netFeedDraw(); }catch(_nfd){}
'@

SubRx @'
  try{ drawPickups(); }catch(_dpk){}
'@ @'
  EDGEBOX.pick=null; EDGEBOX.gun=null; try{ drawPickups(); }catch(_dpk){}
'@

SubRx @'
var VER='25.45';
'@ @'
var VER='25.46';
'@

$pat = "(?m)^  now:'v25\.45:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v25.46: Extraction ring badges are short callouts now, point at their ring from the screen edge, and never sit under the gun card. Check 25.46 fails on v25.45',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
