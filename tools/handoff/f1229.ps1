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

# v12.29 CHECK, inserted before the v12.28 entry. One crawler, parked on
# patrol 120 units from a still, visible player with a clear sight line, its
# wander target away from him (the idle branch zeroes the clock within 30
# units of the target, so the target must be far) and 6.5 s on its clock;
# stepped at 60 frames a second, the first bite must land inside 2 s. The
# control runs the same room with the clock at zero. A third arm sends the
# same crawler in by packCall with 6.5 s of clock and requires a bite inside
# 3 s. On v12.28 arms one and three bite at about 6.5 s.
SubRx @'
  {v:'12.28',what:'a Peddler purchase says where it went: a bought rifle names the belt key autoBelt pinned it to, a medkit with no key set says In your backpack, and a medkit on key 6 says key 6, with the credits falling by the prices (his note of 2026-09-07: purchases did not show up in the inventory)',
'@ @'
  {v:'12.29',what:'a crawler that sees you bites when it reaches you: parked on patrol with 6.5 s of wander clock 120 units from a still, visible player it bites inside 2 s, the same with the clock at zero, and a crawler called in by packCall with 6.5 s of clock bites inside 3 s (2026-09-07 audit P1, his crawler note)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__ents)) return 'SKIP: this fixture cannot deploy and step';
     if(typeof packCall!=='function'||typeof losClear!=='function'||typeof spotFree!=='function') return 'SKIP: no pack call or sight test in this build';
     var bad=[];
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(), p=g.player, i, e=null;
       for(i=0;i<g.ents.length;i++) if(g.ents[i].kind==='crawler'){ e=g.ents[i]; break; }
       if(!e) return 'SKIP: no crawler on this map';
       for(i=g.ents.length-1;i>=0;i--) if(g.ents[i]!==e) g.ents.splice(i,1);   // only the crawler moves in this room
       p.downed=false; p.crouch=false; p.iv=0; keys={};
       if(typeof refreshVseg==='function') refreshVseg();
       // A spot 120 units out, clear of walls, with the sight line to him clear.
       var spot=null, a;
       for(a=0;a<16&&!spot;a++){ var ang=a*Math.PI/8, sx=p.x+Math.cos(ang)*120, sy=p.y+Math.sin(ang)*120; if(spotFree(g.map,sx,sy,24)&&losClear(sx,sy,p.x,p.y,g.vseg)) spot={x:sx,y:sy}; }
       if(!spot) return 'SKIP: no clear spot 120 units from the drop';
       function park(cd,state){
         e.x=spot.x; e.y=spot.y; e.cd=cd; e.path=null; e.pathGoal=null; e.chaseHold=0; e.alert=0; e.state=state; e.role=null; e.roleT=0;
         e.tx=e.x+(e.x-p.x)*4; e.ty=e.y+(e.y-p.y)*4;   // the wander target AWAY from him: within 30 units of it the idle branch zeroes the clock
         e.face=Math.atan2(p.y-e.y,p.x-e.x);
         p.hp=100; p.armor=0; p.iv=0; p.downed=false;
       }
       function firstBite(maxF){ var hp0=p.hp+(p.armor||0), f; for(f=0;f<maxF;f++){ __ents(1/60); if(p.hp+(p.armor||0)<hp0) return (f+1)/60; } return -1; }
       // ARM A, THE FINDING: 6.5 s of wander clock, on patrol, in plain sight.
       park(6.5,'patrol'); var tA=firstBite(600);
       if(tA<0) bad.push('a patrolling crawler with 6.5 s of clock never bit a still, visible man 120 units away in 10 s (ended '+e.state+' at '+Math.round(dist(e,p))+' units)');
       else if(tA>2) bad.push('a patrolling crawler with 6.5 s of clock took '+tA.toFixed(1)+' s to its first bite from 120 units, not under 2 s: it stood there serving out its wander clock');
       // ARM B, CONTROL: the clock at zero, the same room.
       park(0,'patrol'); var tB=firstBite(600);
       if(tB<0||tB>2) bad.push('control: with the clock at zero the first bite took '+(tB<0?'more than 10':tB.toFixed(1))+' s, so this room cannot tell a stalled crawler from a slow one');
       // ARM C: called in by another machine rather than by sight, with 6.5 s of clock.
       park(6.5,'patrol'); var caller={x:p.x+50,y:p.y,kind:'sentry',state:'chase',alert:2.6}; packCall(caller,p.x,p.y);
       if(e.state!=='chase') bad.push('staging: packCall did not put the crawler in chase');
       var tC=firstBite(600);
       if(tC<0||tC>3) bad.push('a crawler called in by packCall with 6.5 s of clock took '+(tC<0?'more than 10':tC.toFixed(1))+' s to its first bite from 120 units, not under 3 s');
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{ keys={}; try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('extract'); } }catch(_e){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'12.28',what:'a Peddler purchase says where it went: a bought rifle names the belt key autoBelt pinned it to, a medkit with no key set says In your backpack, and a medkit on key 6 says key 6, with the credits falling by the prices (his note of 2026-09-07: purchases did not show up in the inventory)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
