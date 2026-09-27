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

# PING (co-op list item 3).

SubRx @'
      stand:function(x,y){ if(typeof G==='undefined'||!G||!G.player) return false; G.player.x=+x; G.player.y=+y; return true; },
'@ @'
      stand:function(x,y){ if(typeof G==='undefined'||!G||!G.player) return false; G.player.x=+x; G.player.y=+y; return true; },
      feed:function(){ var o=[], i; for(i=0;i<(NET.feed||[]).length;i++) o.push(NET.feed[i].txt); return o; },   // v16.43: the kill feed, for the live test
      pings:function(){ var o=[], i; for(i=0;i<(NET.pings||[]).length;i++) o.push({s:NET.pings[i].s,x:NET.pings[i].x,y:NET.pings[i].y,w:NET.pings[i].w}); return o; },
      ping:function(){ return netPingMake(); },
'@

SubRx @'
  if(code==='KeyQ'&&G&&!G.over&&!repeat) cycleThrow();
'@ @'
  if(code==='KeyQ'&&G&&!G.over&&!repeat) cycleThrow();
  if(code==='KeyN'&&G&&!G.over&&!repeat&&NET.on) netPingMake();   // v16.43: ping for the party
'@

SubRx @'
  if(e.button===2){ if(G&&!G.over) G.player.ads=true; return; }
'@ @'
  if(e.button===2){ if(G&&!G.over) G.player.ads=true; return; }
  if(e.button===1){ if(G&&!G.over&&NET.on){ netPingMake(); e.preventDefault(); } return; }   // v16.43: the middle button pings for the party
'@

SubRx @'
  PAD.prev[4]=_lbN; PAD.prev[5]=_rbN;
'@ @'
  if(_lbN&&_rbN&&(!PAD.prev[4]||!PAD.prev[5])&&G&&!G.over&&NET.on) netPingMake();   // v16.43: both bumpers ping; the two belt steps cancel
  PAD.prev[4]=_lbN; PAD.prev[5]=_rbN;
'@

SubRx @'
  try{ if(NET.on) netFeedDraw(); }catch(_nfd){}   // v16.42: the kill feed
'@ @'
  try{ if(NET.on) netFeedDraw(); }catch(_nfd){}   // v16.42: the kill feed
  try{ if(NET.on) netPingDraw(); }catch(_npd){}   // v16.43: the party pings
'@

SubRx @'
  if(m.t==='kf') return netFeedTake(peer,m);   // v16.42: a line for the kill feed, from the host
'@ @'
  if(m.t==='kf') return netFeedTake(peer,m);   // v16.42: a line for the kill feed, from the host
  if(m.t==='png') return netPingTake(peer,m);   // v16.43: a ping from one of the party
'@

SubRx @'
var NET_FEED_T=6;
'@ @'
var NET_FEED_T=6;
// v16.43, THE CO-OP LIST (item 3): A PING. N or the middle mouse button (both bumpers on a controller) marks the point under the
// cursor for the party, or the enemy nearest it within NET_PING_SNAP. Everyone sees a marker with who pinged it for NET_PING_T
// seconds, pulled to the screen edge when it is off screen, and hears a blip. One ping every half second.
var NET_PING_T=8, NET_PING_SNAP=70;
function netPingMake(){
  var w, i, e, bd=NET_PING_SNAP, d, hit=null, m;
  if(typeof G==='undefined'||!G||G.over||!G.player||!NET.on||!NET.upSeed) return null;
  if(NET.pingAt&&Date.now()-NET.pingAt<500) return null;
  NET.pingAt=Date.now();
  w=mouseWorld();
  for(i=0;i<G.ents.length;i++){ e=G.ents[i]; if(!e.nid||e.hp<=0||e.merc) continue; d=dist(e,w); if(d<bd){ bd=d; hit=e; } }
  m={t:'png',x:Math.round(hit?hit.x:w.x),y:Math.round(hit?hit.y:w.y),w:hit?((hit.kind==='raider'&&hit.name)?netClean(hit.name,24):String(hit.kind).toUpperCase()):''};
  if(hit) m.id=hit.nid;
  netBroadcast(m);
  netPingPush(NET.seat,m);
  return m;
}
function netPingTake(peer,m){
  var s;
  if(!peer||peer.state!=='in') return 'ignored';
  if(typeof m.x!=='number'||typeof m.y!=='number'||!isFinite(m.x)||!isFinite(m.y)) return 'bad';
  if(NET.role==='host') s=peer.seat; else { s=(m.s===undefined)?0:m.s; if(typeof s!=='number'||s!==(s|0)) return 'bad'; }
  if(s===NET.seat) return 'ignored';
  var o={x:clamp(m.x,-9000,NET_UP_MAX),y:clamp(m.y,-9000,NET_UP_MAX),w:netClean(m.w,24)};
  if(typeof m.id==='number') o.id=m.id|0;
  if(NET.role==='host'){ var i; for(i=0;i<NET.peers.length;i++) if(NET.peers[i]!==peer&&NET.peers[i].state==='in') netSend(NET.peers[i],{t:'png',s:s,x:o.x,y:o.y,w:o.w,id:o.id}); }
  netPingPush(s,o);
  return 'png';
}
function netPingPush(s,o){
  if(!NET.pings) NET.pings=[];
  NET.pings.push({s:s,x:o.x,y:o.y,w:o.w||'',id:o.id,at:Date.now()});
  if(NET.pings.length>6) NET.pings.shift();
  try{ if(typeof G!=='undefined'&&G&&!G.sim) blip('pick'); }catch(_bp){}
  return NET.pings.length;
}
function netPingDraw(){
  var i, p, now=Date.now(), s, M=LH(30), e, nm, lbl, x, y, n=0, c;
  if(!NET.pings||!NET.pings.length) return 0;
  for(i=NET.pings.length-1;i>=0;i--){
    p=NET.pings[i];
    if((now-p.at)/1000>NET_PING_T){ NET.pings.splice(i,1); continue; }
    e=(p.id&&NET.entMap)?NET.entMap[p.id]:null;
    if(e&&e.hp>0){ p.x=e.x; p.y=e.y; }   // a pinged enemy is followed while it lives
    s=w2s(p.x,0,p.y); if(!s) continue;
    x=clamp(s.x,M,W-M); y=clamp(s.y,M,H-M);
    c=p.w?'#ff8a3c':'#6fe0ff';
    ctx.save(); ctx.globalAlpha=0.55+0.45*Math.abs(Math.sin(now/180));
    ctx.strokeStyle=c; ctx.lineWidth=2.5;
    ctx.beginPath(); ctx.moveTo(x,y-LH(12)); ctx.lineTo(x+LH(9),y); ctx.lineTo(x,y+LH(12)); ctx.lineTo(x-LH(9),y); ctx.closePath(); ctx.stroke();
    ctx.restore();
    nm=(p.s===NET.seat)?'YOU':(netSeatName(p.s)||'PILLAGER');
    lbl=nm+(p.w?(': '+p.w):'')+'  '+((G&&G.player)?metres(dist(G.player,p)):0)+'M';
    ctx.font=FS(TYPE.micro); ctx.textAlign='center'; ctx.fillStyle=c; ctx.fillText(lbl,clamp(x,LH(60),W-LH(60)),y-LH(16)); ctx.textAlign='left';
    n++;
  }
  return n;
}
'@

SubRx @'
var VER='16.42';
'@ @'
var VER='16.43';
'@

$pat = "(?m)^  now:'v16\.42:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v16.43: PING. Co-op list item 3. N or the middle mouse button (both bumpers on a controller) marks the point under the cursor for the party, or snaps to the enemy nearest it and follows him while he lives. Everyone sees a pulsing marker with who pinged it and how far it is for 8 seconds, pulled to the screen edge when off screen, with a blip. One ping every half second. Check 16.43 fails on v16.42',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
