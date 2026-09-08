$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# v12.30 CHECK, inserted before the v12.29 entry. THE CLOCK IS NOT STAGED. The
# crawler is parked on patrol just outside bite range, facing a still player,
# and the game rolls its own wander clock on the first idle frame exactly as it
# does in a raid; the only thing measured is how long the first bite takes. A
# second arm proves the room can bite at all, so the first arm's deadline is a
# measurement and not a hope, and a third arm proves the wander itself still
# runs and no longer leaves anything on the bite cooldown.
SubRx @'
  {v:'12.29',what:'a fresh profile opens on Few machines and a Light extraction, the two Settings rows draw those words as their own default rather than in the changed colour, and the world the corpus measures is unmoved (his order of 2026-09-08)',
'@ @'
  {v:'12.30',what:'a crawler that reaches a still player bites inside a second and a half, carrying whatever wander clock the game rolled for it; a crawler already chasing with a clear cooldown bites inside 0.6 s; and a crawler wandering out of sight still wanders with its bite cooldown left clear (2026-09-07 audit P1, his standing crawler note)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__ents)) return 'SKIP: this fixture cannot deploy and step';
     if(typeof losClear!=='function'||typeof spotFree!=='function') return 'SKIP: no sight or placement test in this build';
     var bad=[];
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(), p=g.player, i, e=null;
       for(i=0;i<g.ents.length;i++) if(g.ents[i].kind==='crawler'){ e=g.ents[i]; break; }
       if(!e) return 'SKIP: no crawler on this map';
       for(i=g.ents.length-1;i>=0;i--) if(g.ents[i]!==e) g.ents.splice(i,1);   // only the crawler moves in this room
       p.downed=false; p.crouch=false; p.iv=0; g.crouchTog=false; keys={};
       if(typeof refreshVseg==='function') refreshVseg();
       function findSpot(r){
         var a, sx, sy;
         for(a=0;a<24;a++){ var ang=a*Math.PI/12; sx=p.x+Math.cos(ang)*r; sy=p.y+Math.sin(ang)*r; if(spotFree(g.map,sx,sy,24)&&losClear(sx,sy,p.x,p.y,g.vseg)) return {x:sx,y:sy}; }
         return null;
       }
       var near=findSpot(25);
       if(!near) return 'SKIP: no clear spot 25 units from the drop, so nothing can be parked in bite range';
       function park(st){
         e.x=near.x; e.y=near.y; e.path=null; e.pathGoal=null; e.chaseHold=0; e.alert=0;
         e.state=st; e.role=null; e.roleT=0; e.beat=0; e.cd=0; e.wanderT=0;
         e.tx=e.x; e.ty=e.y; e.face=Math.atan2(p.y-e.y,p.x-e.x);
         p.hp=100; p.armor=0; p.iv=0; p.downed=false;
       }
       function bite(maxF){
         var hp0=p.hp+(p.armor||0), f;
         for(f=0;f<maxF;f++){ __ents(1/60); if(p.hp+(p.armor||0)<hp0) return (f+1)/60; }
         return -1;
       }
       // ARM ONE, THE FINDING. Nothing is staged on the clock: the crawler is put
       // on patrol in bite range of a still man, and the game rolls its own wander
       // on the first idle frame, which is the roll he meets in a raid.
       park('patrol');
       var tA=bite(300);
       if(tA<0) bad.push('a crawler on patrol 25 units from a still man never bit him in 5 s (it ended '+e.state+' at '+Math.round(dist(e,p))+' units, cooldown '+(e.cd||0).toFixed(1)+')');
       else if(tA>1.5) bad.push('a crawler that reached a still man took '+tA.toFixed(1)+' s to bite him, which is the wander clock it was carrying and not the walk');
       // ARM TWO, THE RULER. Already chasing, cooldown clear: this room must be
       // able to produce a bite quickly, or the deadline above proves nothing.
       park('chase'); e.alert=2.4; e.tx=p.x; e.ty=p.y;
       var tB=bite(300);
       if(tB<0||tB>0.6) bad.push('control: a crawler already chasing with a clear cooldown took '+(tB<0?'more than 5':tB.toFixed(1))+' s to bite from 25 units, so this room cannot measure a first bite and arm one proves nothing');
       // ARM THREE: the wander still runs, and it no longer leaves anything on the
       // bite cooldown. Far away and out of his sight, so nothing chases.
       var far=findSpot(900)||findSpot(700);
       if(!far) bad.push('staging: no clear spot far enough out to watch a wander');
       else {
         e.x=far.x; e.y=far.y; e.state='patrol'; e.cd=0; e.wanderT=0; e.alert=0;
         e.tx=e.x; e.ty=e.y; e.path=null; e.pathGoal=null;
         var wx=e.x, wy=e.y;
         for(i=0;i<360;i++) __ents(1/60);
         var moved=Math.sqrt((e.x-wx)*(e.x-wx)+(e.y-wy)*(e.y-wy));
         if(moved<60) bad.push('a crawler left to wander for 6 s moved '+Math.round(moved)+' units, so the wander itself is broken');
         if((e.cd||0)>0.05) bad.push('after 6 s of wandering the crawler carries '+(e.cd||0).toFixed(1)+' s on its bite cooldown, which is the wander clock sitting in the field the bite reads');
       }
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{ keys={}; try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('extract'); } }catch(_e){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'12.29',what:'a fresh profile opens on Few machines and a Light extraction, the two Settings rows draw those words as their own default rather than in the changed colour, and the world the corpus measures is unmoved (his order of 2026-09-08)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
