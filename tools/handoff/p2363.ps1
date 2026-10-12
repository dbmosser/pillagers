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

# TRIPWIRE MINE ON THE BELT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  frag:{name:'Frag Charge',val:180,wt:1,r:'uncommon',c:'#e07040',use:'throw',tk:'frag'}
};
'@ @'
  frag:{name:'Frag Charge',val:180,wt:1,r:'uncommon',c:'#e07040',use:'throw',tk:'frag'},
  // v23.xx (feat1a), HIS #6 (2026-10-12): "tripwire mine -- good idea", and his answer 32: on the belt like a grenade.
  trip:{name:'Tripwire Mine',val:160,wt:1,r:'uncommon',c:'#ff4a4a',use:'throw',tk:'trip'}
};
'@

SubRx @'
var THROWKEYS=['smoke','decoy','frag'];
'@ @'
var THROWKEYS=['smoke','decoy','frag','trip'];   // v23.xx (feat1a): the Tripwire Mine is a throw like the other three
'@

SubRx @'
bag:[],pouch:{smoke:0,decoy:0,frag:0},tsel:0,
'@ @'
bag:[],pouch:{smoke:0,decoy:0,frag:0,trip:0},tsel:0,
'@

SubRx @'
throws:[],smokes:[],decoys:[],frags:[],labels:[]
'@ @'
throws:[],smokes:[],decoys:[],frags:[],trips:[],labels:[]
'@

SubRx @'
notes:[],thr:{smoke:0,decoy:0,frag:0}}};
'@ @'
notes:[],thr:{smoke:0,decoy:0,frag:0,trip:0}}};
'@

SubRx @'
  for(var i=1;i<=3;i++){
    var n=(G.tsel+i)%3;
'@ @'
  for(var i=1;i<=THROWKEYS.length;i++){
    var n=(G.tsel+i)%THROWKEYS.length;   // v23.xx (feat1a): four throws now, the Tripwire Mine is the fourth
'@

SubRx @'
    var tk=THROWKEYS[i];
    out.push({k:'throw:'+tk,name:ITEMS[tk].name,kind:'throw',icon:tk,
'@ @'
    var tk=THROWKEYS[i];
    if(tk==='trip') continue;   // v23.xx (feat1a): the Tripwire Mine cell is added after Medical, below, and only while carried
    out.push({k:'throw:'+tk,name:ITEMS[tk].name,kind:'throw',icon:tk,
'@

SubRx @'
    count:countArmor(),c:'#5aa9e6'});
'@ @'
    count:countArmor(),c:'#5aa9e6'});
  // v23.xx (feat1a), HIS #6 and his answer 32 (2026-10-12): THE TRIPWIRE MINE GOES ON THE BELT LIKE A GRENADE. Its cell is added
  // only while one is carried, and after Medical and the plate, so no key anyone has learned moves: the belt of anyone without a
  // mine is the belt of before, and with one it takes the first free key (key 9 on the usual belt). A pin on that key yields as it
  // does for the plate (v8.04).
  if(G.pouch&&G.pouch.trip>0&&ITEMS.trip&&out.length<HOTBAR_N) out.push({k:'throw:trip',name:ITEMS.trip.name,kind:'throw',icon:'trip',
    count:G.pouch.trip,c:ITEMS.trip.c});
'@

SubRx @'
pq={smoke:0,decoy:0,frag:0};
'@ @'
pq={smoke:0,decoy:0,frag:0,trip:0};
'@

SubRx @'
tc={smoke:0,decoy:0,frag:0}, i;
'@ @'
tc={smoke:0,decoy:0,frag:0,trip:0}, i;
'@

SubRx @'
    G.frags.push({x:th.tx,y:th.ty,t:0,fuse:Math.max(0.08,FRAG_FUSE-(th.cook||0)),mine:1});
  }
}
'@ @'
    G.frags.push({x:th.tx,y:th.ty,t:0,fuse:Math.max(0.08,FRAG_FUSE-(th.cook||0)),mine:1});
  }
  else if(th.kind==='trip'){ sfx("clank",th.tx,th.ty); tripArm(th); }   // v23.xx (feat1a): a Tripwire Mine strings its wire where it lands
}
'@

SubRx @'
function explodeFrag(f){
'@ @'
// v23.xx (feat1a), HIS #6 (2026-10-12): "tripwire mine -- good idea", and his answer 32: on the belt like a grenade. A Tripwire Mine
// is thrown as any grenade is (its belt key or Q, then the trigger or G; the pad walks the belt and holds RT), through throwFrom, so
// it stops at the first wall like every throw. Where it lands it strings a wire ACROSS the throw: each half runs out sideways until a
// wall stops it (4 short of the face) or 80 in the open, so it spans a doorway or a corridor by itself. It arms after 0.6 s and lasts
// 240 s; an owner has at most 3 strung and the oldest goes. What sets it off and what it does is the next build. No draw on any
// stream: the wire is pure geometry.
var TRIP_LIFE=240, TRIP_ARM=0.6, TRIP_MAX=3, TRIP_HALF=80, TRIP_REACH=120;
function tripArm(th){
  if(!G) return null;
  if(!G.trips) G.trips=[];
  var dx=th.tx-th.sx, dy=th.ty-th.sy, d=Math.sqrt(dx*dx+dy*dy);
  var ux=d>1?dx/d:1, uy=d>1?dy/d:0, nx=-uy, ny=ux;
  var half=function(sx,sy){ var h=rayHitG(th.tx,th.ty,sx,sy,TRIP_REACH); return h<TRIP_REACH?Math.max(2,h-4):TRIP_HALF; };
  var a=half(nx,ny), b=half(-nx,-ny), seat=th.seat||0, i, own=[];
  var tr={id:(seat?'s'+seat:'p')+'-'+(G.tripN=(G.tripN||0)+1), x:th.tx, y:th.ty, ax:th.tx+nx*a, ay:th.ty+ny*a, bx:th.tx-nx*b, by:th.ty-ny*b,
          arm:TRIP_ARM, life:TRIP_LIFE, seat:seat};
  for(i=0;i<G.trips.length;i++) if((G.trips[i].seat||0)===seat&&!G.trips[i].fx) own.push(i);
  while(own.length>=TRIP_MAX){ G.trips.splice(own.shift(),1); for(i=0;i<own.length;i++) own[i]--; }
  G.trips.push(tr);
  if(!G.sim&&!seat) say('TRIPWIRE SET','info');
  return tr;
}
function explodeFrag(f){
'@

SubRx @'
var VER='23.62';
'@ @'
var VER='23.63';
'@

$pat = "(?m)^  now:'v23\.62:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v23.63: A Tripwire Mine now goes on the belt like a grenade and strings a wire across a doorway where it lands. Check 23.63 fails on v23.62',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
