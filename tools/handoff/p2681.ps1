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

# RAID EVENTS: MACHINE CONVOY (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
// FLOW-MODULE-END (the next flow builds add their code above this line)
'@ @'
// v26.xx (flow6), HIS ANSWER (2026-10-14), the raid events, the second: MACHINE CONVOY, "an armoured crawler train crosses the map with a loot crate". A 20 s
// warning over a ring at the START (700 to 1,100 from you, off the rings), then the train forms there and sets off for a DESTINATION at least 1,700 across
// the map (1,100 on a small ground): the CARRIER, a Bulwark with 2.2 times the health and its front shield (it takes a flank), and four ARMOURED
// CRAWLERS, elite, each with 70 of plate. They march by the nav grid: every frame each one that is not fighting is sent on (the carrier to the destination,
// the others to the carrier), and a body that is chasing or alarmed fights as ever and rejoins after. The ring and the mark follow the carrier.
// KILL THE CARRIER and it drops the CONVOY CRATE where it fell: three cache rolls and a safe roll, marked on the maps until opened. If it reaches the
// destination the train is gone (CONVOY AWAY) and the crate with it. The train is made on a side stream of the event, never flagged as a wave
// (the arcade cull leaves it), and nothing else changes. DEMO and CAREER are the same.
function convoyCrew(ev){ var a=[], i, e; for(i=0;ev.d.crew&&i<ev.d.crew.length;i++){ e=ev.d.crew[i]; if(e&&e.hp>0&&G.ents.indexOf(e)>=0) a.push(e); } return a; }
function convoyLeave(ev){
  var i, k;
  for(i=0;ev.d.crew&&i<ev.d.crew.length;i++){ k=G.ents.indexOf(ev.d.crew[i]); if(k>=0) G.ents.splice(k,1); }
}
function convoyCrate(ev,x,y){
  var L=[], c=null, E=evS(), seed=(((G.seed>>>0)^Math.imul((ev.n|0)+101,2654435761))>>>0)||1;
  sideStream(seed,EV.tag+4,function(){ var k; for(k=0;k<3;k++) L.push(rollLoot(LOOT.cache)); L.push(rollLoot(LOOT.safe)); });
  sideStream(seed,EV.tag+5,function(){ c=setLoot(mkContainer(x,y,'cache'),L); });
  c.time=3.4; c.tag='CONVOY CRATE'; c.wreck=1; G.containers.push(c); E.wrecks.push(c);
  return c;
}
EVENTS.convoy={name:'MACHINE CONVOY',sub:'ARMOURED TRAIN',warn:20,dur:170,r:240,fade:4,col:'#ff9a4a',
  mx:function(ev){ var c=ev.d.car; return (ev.ph!=='warn'&&c&&c.hp>0)?c.x:ev.x; },
  my:function(ev){ var c=ev.d.car; return (ev.ph!=='warn'&&c&&c.hp>0)?c.y:ev.y; },
  pick:function(ev){
    var p=G.player, S=null, D=null;
    function ok(x,y){ return x>300&&y>300&&x<WORLD_W-300&&y<WORLD_H-300&&spotFree(G.map,x,y,40)&&navReachable(G.map,x,y)&&!shutRoomAt(G.map,x,y)&&!flowZoneNear(x,y,300); }
    evStream(ev,function(){
      var k, a, d, x, y;
      for(k=0;k<60&&!S;k++){ a=rr()*6.2832; d=700+rr()*400; x=p.x+Math.cos(a)*d; y=p.y+Math.sin(a)*d; if(ok(x,y)) S={x:x,y:y}; }
      if(!S) return;
      for(k=0;k<120&&!D;k++){
        x=300+rr()*(WORLD_W-600); y=300+rr()*(WORLD_H-600); d=Math.hypot(x-S.x,y-S.y);
        if(d<(k<60?1700:1100)||d>3400) continue;
        if(ok(x,y)) D={x:x,y:y};
      }
    });
    if(!S||!D) return false;
    ev.x=S.x; ev.y=S.y; ev.d.dx=D.x; ev.d.dy=D.y;
    return true;
  },
  start:function(ev){
    var crew=[], car=null, seed=(((G.seed>>>0)^Math.imul((ev.n|0)+51,2654435761))>>>0)||1, i;
    sideStream(seed,EV.tag+3,function(){
      var k, e;
      car=mkBulwark(ev.x,ev.y); car.hp=car.maxhp=Math.round(car.maxhp*2.2); car.carrier=1; car.name='CONVOY CARRIER'; crew.push(car);
      for(k=0;k<4;k++){ e=mkCrawler(ev.x+(k-1.5)*46,ev.y+((k&1)?26:-26)); arcadeWaveElite(e); e.armor=70; e.name='ARMOURED '+e.name; crew.push(e); }
    });
    for(i=0;i<crew.length;i++) G.ents.push(crew[i]);
    ev.d.car=car; ev.d.crew=crew; ev.d.over=0;
    try{ say('CONVOY MOVING','warn',{sub:'KILL THE CARRIER'}); }catch(_cs){}
  },
  tick:function(ev,dt){
    var car=ev.d.car, crew=ev.d.crew||[], i, e;
    if(ev.d.over) return;
    if(!car){ ev.d.over=1; return; }
    if(!(car.hp>0)||G.ents.indexOf(car)<0){
      ev.d.over=1; ev.d.won=1;
      convoyCrate(ev,car.x,car.y);
      try{ say('CONVOY DOWN','ext',{sub:'SEARCH THE CRATE'}); }catch(_cd){}
      return;
    }
    if(Math.hypot(car.x-ev.d.dx,car.y-ev.d.dy)<70){
      ev.d.over=1; convoyLeave(ev);
      try{ say('CONVOY AWAY','info'); }catch(_ca){}
      return;
    }
    for(i=0;i<crew.length;i++){
      e=crew[i];
      if(!e||!(e.hp>0)||e.downed||G.ents.indexOf(e)<0) continue;
      if(e.state==='chase'||e.state==='alarm'||e.state==='hunt') continue;
      e.state='investigate'; e.alert=0; e.invT=0;
      if(e===car){ e.tx=ev.d.dx; e.ty=ev.d.dy; }
      else { e.tx=car.x+(i-2)*14; e.ty=car.y+((i&1)?20:-20); }
    }
  },
  done:function(ev){ return !!ev.d.over; },
  end:function(ev){
    if(!ev.d.won&&ev.d.crew&&!ev.d.left){ ev.d.left=1; if(ev.d.car&&ev.d.car.hp>0) convoyLeave(ev); }
  },
  live:function(ev){ var n=convoyCrew(ev).length; return n+' LEFT'; }
};
// FLOW-MODULE-END (the next flow builds add their code above this line)
'@

SubRx @'
var VER='26.80';
'@ @'
var VER='26.81';
'@

$pat = "(?m)^  now:'v26\.80:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v26.81: The machine convoy event: kill the carrier of an armoured crawler train to take its loot crate before it gets away. Check 26.81 fails on v26.80',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
