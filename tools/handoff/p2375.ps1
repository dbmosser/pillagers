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

# TRIPWIRE MINES IN CO-OP (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  for(i=0;i<G.trips.length;i++) if((G.trips[i].seat||0)===seat&&!G.trips[i].fx) own.push(i);
  while(own.length>=TRIP_MAX){ G.trips.splice(own.shift(),1); for(i=0;i<own.length;i++) own[i]--; }
  G.trips.push(tr);
  if(!G.sim&&!seat) say('TRIPWIRE SET','info');
  return tr;
}
'@ @'
  // v23.xx (feat1c): IN CO-OP THE WIRE IS THE HOST WIRE. Player 2 strings a copy he only sees (fx) under his own seat id and tells
  // the host, which strings the real one under his seat; the host tells the party of its own. See netThrTake and tripTake.
  if(!seat&&typeof NET!=='undefined'&&NET.role==='join'&&netEntsPeer()){ tr.fx=1; tr.id='s'+Math.max(1,NET.seat|0)+'-'+G.tripN; }
  tripAdd(tr);
  if(!G.sim&&!seat) say('TRIPWIRE SET','info');
  if(!seat) netThrSend('trip',tr.x,tr.y,{ax:Math.round(tr.ax),ay:Math.round(tr.ay),bx:Math.round(tr.bx),by:Math.round(tr.by),id:tr.id});
  return tr;
}
// v23.xx (feat1c): strings a wire, keeping each owner (seat) to TRIP_MAX real wires; the oldest goes, and the party is told it went.
function tripAdd(tr){
  var i, own=[], gone;
  if(!G.trips) G.trips=[];
  if(!tr.fx){
    for(i=0;i<G.trips.length;i++) if((G.trips[i].seat||0)===(tr.seat||0)&&!G.trips[i].fx) own.push(i);
    while(own.length>=TRIP_MAX){ gone=G.trips.splice(own.shift(),1)[0]; for(i=0;i<own.length;i++) own[i]--; if(gone) netThrSend('tgo',gone.x,gone.y,{id:gone.id}); }
  }
  G.trips.push(tr);
  return tr;
}
// v23.xx (feat1c): a wire word from the party. The host strings the real wire of player 2 under the seat of the window it came from
// (never a seat the word claims) and passes a copy on; player 2 strings a copy only. A wire end more than 260 from its middle, or an
// id that is not a wire id, is refused.
function tripTake(peer,m,x,y){
  var i, q, tr, f=['ax','ay','bx','by'];
  for(i=0;i<4;i++) if(typeof m[f[i]]!=='number'||!isFinite(m[f[i]])) return 'bad';
  if(typeof m.id!=='string'||!(/^[ps][0-9]{0,2}-[0-9]{1,7}$/).test(m.id)) return 'bad';
  if(Math.hypot(m.ax-x,m.ay-y)>260||Math.hypot(m.bx-x,m.by-y)>260) return 'bad';
  for(i=0;i<(G.trips||[]).length;i++) if(G.trips[i].id===m.id) return 'thr:trip';
  tr={id:m.id,x:x,y:y,ax:+m.ax,ay:+m.ay,bx:+m.bx,by:+m.by,arm:TRIP_ARM,life:TRIP_LIFE,seat:0};
  if(NET.role==='host'){
    tr.seat=Math.max(1,peer.seat|0);
    for(i=0;i<NET.peers.length;i++){ q=NET.peers[i]; if(q!==peer&&q.state==='in') netSend(q,{t:'thr',k:'trip',x:Math.round(x),y:Math.round(y),ax:Math.round(tr.ax),ay:Math.round(tr.ay),bx:Math.round(tr.bx),by:Math.round(tr.by),id:tr.id}); }
  } else { tr.fx=1; tr.seat=-1; }
  tripAdd(tr);
  return 'thr:trip';
}
// v23.xx (feat1c): the host says a wire is gone (it went off, ran out, or was the oldest of four). Every other window takes its copy
// down, and shows the blast when it went off (b). Only the host says so; a wire word of this kind from player 2 is ignored.
function tripGone(m,x,y){
  var i;
  if(NET.role==='host') return 'ignored';
  if(typeof m.id!=='string') return 'bad';
  for(i=(G.trips||[]).length-1;i>=0;i--) if(G.trips[i].id===m.id) G.trips.splice(i,1);
  if(m.b&&!G.sim){ sfx("boom",x,y); spark(x,y,'#ff6a4a',28,320); flash(x,y,260,'#ff7a4a',.42); G.shake=Math.max(G.shake,4); }
  return 'thr:tgo';
}
'@

SubRx @'
  for(i=G.trips.length-1;i>=0;i--){ T=G.trips[i]; if(T.arm>0) T.arm-=dt; T.life-=dt; if(T.life<=0) G.trips.splice(i,1); }
'@ @'
  for(i=G.trips.length-1;i>=0;i--){ T=G.trips[i]; if(T.arm>0) T.arm-=dt; T.life-=dt; if(T.life<=0){ G.trips.splice(i,1); if(!T.fx) netThrSend('tgo',T.x,T.y,{id:T.id}); } }   // v23.xx (feat1c): and the party is told
'@

SubRx @'
  var p=G.player, R=TRIP_R, seat=(T&&T.seat)|0, i, e, de, dm, bp={x:x,y:y}, sd=Math.hypot(x-p.x,y-p.y);
'@ @'
  var p=G.player, R=TRIP_R, seat=(T&&T.seat)|0, i, e, de, dm, bp={x:x,y:y}, sd=Math.hypot(x-p.x,y-p.y);
  if(T&&T.id&&!T.fx) netThrSend('tgo',x,y,{id:T.id,b:1});   // v23.xx (feat1c): the party takes its copy down and sees the blast
'@

SubRx @'
      if(!seat) notoAggress(e);
'@ @'
      if(!seat) notoAggress(e); else if(e.kind==='raider'&&e.hostile===false&&!e.friendlyPC) e.hostile=true;   // v23.xx (feat1c): a wire of player 2 turns a neutral as his round does
'@

SubRx @'
  if(k!=='smoke'&&k!=='decoy'&&k!=='nz'&&k!=='frag'&&k!=='sh') return 'bad';
'@ @'
  if(k!=='smoke'&&k!=='decoy'&&k!=='nz'&&k!=='frag'&&k!=='sh'&&k!=='trip'&&k!=='tgo') return 'bad';   // v23.xx (feat1c): and a Tripwire Mine wire, strung or gone
'@

SubRx @'
  w={t:'thr',k:k,x:x,y:y};
  if(k==='frag'){ fu=clamp(+m.f||FRAG_FUSE,0.05,3); w.f=fu; }
'@ @'
  if(k==='trip') return tripTake(peer,m,x,y);   // v23.xx (feat1c)
  if(k==='tgo') return tripGone(m,x,y);
  w={t:'thr',k:k,x:x,y:y};
  if(k==='frag'){ fu=clamp(+m.f||FRAG_FUSE,0.05,3); w.f=fu; }
'@

SubRx @'
var VER='23.74';
'@ @'
var VER='23.75';
'@

$pat = "(?m)^  now:'v23\.74:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v23.75: In co-op, a Tripwire Mine from either player is shared, and its kills go to whoever strung it. Check 23.75 fails on v23.74',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
