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

# RAID EVENTS: BOUNTY PILLAGER (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
// FLOW-MODULE-END (the next flow builds add their code above this line)
'@ @'
// v26.xx (flow7), HIS ANSWER (2026-10-14), the raid events, the third: BOUNTY PILLAGER, "a marked crew boss with a big score reward, who hunts you". A 15 s
// warning over a ring where he will come in (700 to 1,000 from you, off the rings), then a hostile pillager of the wave kind (arcadeWaveRaider: the CAREER
// save never hears of him) steps in with four times the health, a full rig of plate (at least 100) and a rich bag (a cache roll and two safe rolls on top of his
// own) for the body to drop. HE HUNTS YOU: every frame he is put on the chase toward where you stand, alert held up, so he comes for you through the streets
// whether or not he has seen you. The ring, the mark and BOUNTY $1,500 follow him. Put him down (the kill is yours) and the BOUNTY is paid into the run
// score at once (DEMO score, CAREER raid score); if something else killed him nothing is paid. After 150 s on the hunt he slips away. Made on a side stream
// of the event, so the seeded stream and the CAREER save are untouched. DEMO and CAREER are the same.
var BOUNTY={pay:1500};
EVENTS.bounty={name:'BOUNTY PILLAGER',sub:'HE HUNTS YOU',warn:15,dur:150,r:220,fade:4,col:'#ff5a4a',
  mx:function(ev){ var e=ev.d.e; return (ev.ph!=='warn'&&e&&e.hp>0)?e.x:ev.x; },
  my:function(ev){ var e=ev.d.e; return (ev.ph!=='warn'&&e&&e.hp>0)?e.y:ev.y; },
  pick:function(ev){
    var p=G.player, S=null;
    evStream(ev,function(){
      var k, a, d, x, y;
      for(k=0;k<80&&!S;k++){
        a=rr()*6.2832; d=700+rr()*300; x=p.x+Math.cos(a)*d; y=p.y+Math.sin(a)*d;
        if(x>300&&y>300&&x<WORLD_W-300&&y<WORLD_H-300&&spotFree(G.map,x,y,40)&&navReachable(G.map,x,y)&&!shutRoomAt(G.map,x,y)&&!flowZoneNear(x,y,350)) S={x:x,y:y};
      }
    });
    if(!S) return false;
    ev.x=S.x; ev.y=S.y;
    return true;
  },
  start:function(ev){
    var e=null, seed=(((G.seed>>>0)^Math.imul((ev.n|0)+71,2654435761))>>>0)||1;
    sideStream(seed,EV.tag+6,function(){
      var k;
      e=arcadeWaveRaider(ev.x,ev.y);
      e.hp=e.maxhp=Math.round(e.maxhp*4); e.armorCap=Math.max(e.armorCap||0,100); e.armor=e.armorCap; e.bounty=1;
      e.bag.push(rollLoot(LOOT.cache),rollLoot(LOOT.safe),rollLoot(LOOT.safe));
    });
    e.state='chase'; e.alert=3; e.tx=G.player.x; e.ty=G.player.y;
    G.ents.push(e);
    ev.d.e=e; ev.d.over=0; ev.r=60;
    try{ say('BOUNTY ON THE MAP','warn',{sub:'HE HUNTS YOU  $'+BOUNTY.pay}); }catch(_bs){}
  },
  tick:function(ev,dt){
    var e=ev.d.e, p=G.player, down;
    if(ev.d.over) return;
    if(!e){ ev.d.over=1; return; }
    down=!(e.hp>0)||e.downed||e.finished||G.ents.indexOf(e)<0;
    if(down){
      ev.d.over=1;
      if(e.byPlayer!==false){ flowChip(BOUNTY.pay,'BOUNTY CLAIMED','BOUNTY PILLAGER'); ev.d.won=1; }
      else { try{ say('BOUNTY GONE','info',{sub:'NOT YOUR KILL'}); }catch(_bg){} }
      return;
    }
    e.state='chase'; e.alert=3; e.chaseHold=0; e.tx=p.x; e.ty=p.y;
  },
  done:function(ev){ return !!ev.d.over; },
  end:function(ev){
    var e=ev.d.e, k;
    if(!ev.d.over&&e&&e.hp>0){
      k=G.ents.indexOf(e); if(k>=0) G.ents.splice(k,1);
      try{ say('BOUNTY SLIPPED AWAY','info'); }catch(_be){}
    }
  },
  live:function(ev){ return 'HUNTING YOU'; },
  draw:function(ev,c,s,q,z){
    var e=ev.d.e, U=function(v){ return LH(v)*z; };
    if(ev.ph!=='live'||!e||!(e.hp>0)) return;
    c.textAlign='center'; c.font=hudFS(TYPE.label); c.fillStyle='#ff6a5a';
    hudText('BOUNTY  $'+BOUNTY.pay,s.x,s.y+ev.r*q+U(16));
  }
};
// FLOW-MODULE-END (the next flow builds add their code above this line)
'@

SubRx @'
var VER='26.81';
'@ @'
var VER='26.82';
'@

$pat = "(?m)^  now:'v26\.81:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v26.82: The bounty pillager event: a marked crew boss hunts you, and downing him yourself pays 1,500. Check 26.82 fails on v26.81',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
