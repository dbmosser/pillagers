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

# RAID EVENTS: COOLANT RUPTURE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function VF(){ return CFG.viewFar*wx().view*opticMag(); }
'@ @'
function VF(){ return CFG.viewFar*wx().view*opticMag()*flowVis(); }   // v26.xx (flow8): and a coolant rupture shortens it
'@

SubRx @'
  return CFG.ambient*(0.6+0.4*wx().view)*(m>1?0.55:1);
'@ @'
  return CFG.ambient*(0.6+0.4*wx().view)*(m>1?0.55:1)*flowVis();   // v26.xx (flow8): same
'@

SubRx @'
e.chill=(e.chill||0)+clamp(d/25,0.35,3); e.chillT=2.5;
'@ @'
e.chill=(e.chill||0)+clamp(d/25,0.35,3)*flowCryo(e); e.chillT=2.5;   // v26.xx (flow8): twice the cold inside a coolant rupture
'@

SubRx @'
// FLOW-MODULE-END (the next flow builds add their code above this line)
'@ @'
// v26.xx (flow8), HIS ANSWER (2026-10-14), the raid events, the fourth: COOLANT RUPTURE, "a district fogs over, with lower visibility, stronger cryo and richer
// crates". An 18 s warning over a ring 420 wide (450 to 1,000 from you, off the rings), then the district is a white cloud for 75 s, three things at once:
// (1) LOWER VISIBILITY: inside it what you can see (VF, the view distance, and AMBR, the ambient reach) falls to 45 percent at the middle, feathering back to
// full from half way out to the rim (flowVis; the machines' own eyes are not touched); (2) STRONGER CRYO: a cryo round (the Forge element) builds cold twice as
// fast on any body inside, so the 6 cold of a freeze comes in half the hits (flowCryo); (3) RICHER CRATES: at the moment it goes live every crate, locker, safe
// and cache inside that is still shut gets one more item (a locker roll for a crate, a safe roll for a locker, a cache roll for the rest) on a side stream of
// the event, and a pale glint on the HUD shows which. The cloud is drawn on the HUD with a feathered edge and slow puffs, from the clock. It fades 4 s at the
// end and everything goes back. DEMO and CAREER are the same.
var COOL={vis:0.45};
function coolIn(x,y){
  var S=G&&G.flow, i, ev, E;
  E=S&&S.ev; if(!E) return null;
  for(i=0;i<E.live.length;i++){ ev=E.live[i]; if(ev.id==='cool'&&ev.ph==='live'&&Math.hypot(x-ev.x,y-ev.y)<ev.r) return ev; }
  return null;
}
function flowVis(){
  var S=G&&G.flow, E, i, ev, p, d, k=1, f;
  if(!S||!S.ev||!S.ev.live.length||!G.player) return 1;
  E=S.ev; p=G.player;
  for(i=0;i<E.live.length;i++){
    ev=E.live[i]; if(ev.id!=='cool'||ev.ph!=='live') continue;
    d=Math.hypot(p.x-ev.x,p.y-ev.y); if(d>=ev.r) continue;
    f=COOL.vis+(1-COOL.vis)*clamp((d-ev.r*0.5)/(ev.r*0.5),0,1);
    if(f<k) k=f;
  }
  return k;
}
function flowCryo(e){ return (e&&coolIn(e.x,e.y))?2:1; }
EVENTS.cool={name:'COOLANT RUPTURE',sub:'FOG AND COLD',warn:18,dur:75,r:420,fade:4,col:'#8fd8ff',
  pick:function(ev){
    var p=G.player, S=null;
    evStream(ev,function(){
      var k, a, d, x, y;
      for(k=0;k<80&&!S;k++){
        a=rr()*6.2832; d=450+rr()*550; x=p.x+Math.cos(a)*d; y=p.y+Math.sin(a)*d;
        if(x>400&&y>400&&x<WORLD_W-400&&y<WORLD_H-400&&spotFree(G.map,x,y,40)&&navReachable(G.map,x,y)&&!shutRoomAt(G.map,x,y)&&!flowZoneNear(x,y,450)) S={x:x,y:y};
      }
    });
    if(!S) return false;
    ev.x=S.x; ev.y=S.y;
    return true;
  },
  start:function(ev){
    var i, c, n=0, up={crate:'locker',locker:'safe',safe:'cache',cache:'cache'}, seed=(((G.seed>>>0)^Math.imul((ev.n|0)+81,2654435761))>>>0)||1, list=[];
    for(i=0;i<G.containers.length;i++){
      c=G.containers[i];
      if(!c||c.opened||c.rich||!up[c.type]||!c.loot) continue;
      if(Math.hypot(c.x-ev.x,c.y-ev.y)<ev.r) list.push(c);
    }
    sideStream(seed,EV.tag+7,function(){
      var j, k;
      for(j=0;j<list.length;j++){ k=rollLoot(LOOT[up[list[j].type]]); setLoot(list[j],list[j].loot.concat([k])); list[j].rich=1; n++; }
    });
    ev.d.rich=n;
    try{ say('COOLANT RUPTURE','crit',{sub:'RICHER CRATES  '+n}); }catch(_cs){}
  },
  live:function(ev){ return Math.max(0,Math.ceil(ev.dur-ev.lt))+'S'; },
  draw:function(ev,c,s,q,z){
    var k=(ev.ph==='live')?Math.min(1,ev.lt/3):((ev.ph==='end')?Math.max(0,1-ev.et/ev.fade):0), R=ev.r*q, t=G.t||0, i, a, rx, ry, gr, n=12, cr, sc, u=10*z;
    if(k<=0) return;
    gr=c.createRadialGradient(s.x,s.y,R*0.3,s.x,s.y,R*1.05);
    gr.addColorStop(0,'rgba(196,228,246,'+(0.34*k).toFixed(3)+')'); gr.addColorStop(0.75,'rgba(176,214,238,'+(0.26*k).toFixed(3)+')'); gr.addColorStop(1,'rgba(170,210,236,0)');
    c.fillStyle=gr; c.beginPath(); c.arc(s.x,s.y,R*1.05,0,6.2832); c.fill();
    for(i=0;i<n;i++){
      a=i/n*6.2832+t*0.05*((i&1)?1:-1);
      rx=s.x+Math.cos(a+i)*R*(0.35+0.4*((i*0.37)%1)); ry=s.y+Math.sin(a*1.3+i)*R*(0.35+0.4*((i*0.61)%1));
      c.fillStyle='rgba(225,242,252,'+(0.07*k).toFixed(3)+')'; c.beginPath(); c.arc(rx,ry,R*(0.16+0.05*Math.sin(t*0.7+i)),0,6.2832); c.fill();
    }
    if(ev.ph==='live'){
      c.strokeStyle='rgba(150,226,255,'+(0.55+0.3*Math.sin(t*5)).toFixed(3)+')'; c.lineWidth=2*z;
      for(i=0;i<G.containers.length;i++){
        cr=G.containers[i]; if(!cr||!cr.rich||cr.opened) continue;
        sc=w2s(cr.x,0,cr.y);
        c.beginPath(); c.moveTo(sc.x,sc.y-u*1.5); c.lineTo(sc.x+u,sc.y); c.lineTo(sc.x,sc.y+u*1.5); c.lineTo(sc.x-u,sc.y); c.closePath(); c.stroke();
      }
    }
  }
};
// FLOW-MODULE-END (the next flow builds add their code above this line)
'@

SubRx @'
var VER='26.82';
'@ @'
var VER='26.83';
'@

$pat = "(?m)^  now:'v26\.82:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v26.83: The coolant rupture event fogs a district: shorter view, double cryo and richer crates inside. Check 26.83 fails on v26.82',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
