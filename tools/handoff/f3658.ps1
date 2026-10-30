$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
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

if ($s.Contains("  {v:'36.58',what:")) { throw "check 36.58 is in the fixture already" }

SubRx @'
  {v:'36.57',what:
'@ @'
  {v:'36.58',what:'zero-spread shots meet the reticle within 3 screen px at 300 world px in both roles; local, partner and hostile tracers share the muzzle-to-ground blend',
   run:function(){
     var g=null,p,k,keep={},owc=null,move,line,pts=[],last=null,role,angle,side,b,w,sent=[],oDay=isDay;
     function peer(seat){return {state:'in',seat:seat,name:'flight check',timers:[],dc:{readyState:'open',send:function(t){sent.push(JSON.parse(t));}}};}
     function paint(round,remote,label){
       var speed=Math.hypot(round.vx,round.vy),ux=round.vx/speed,uy=round.vy/speed;
       var sx=round.sx,sy=round.sy,tx=sx+ux*300,ty=sy+uy*300,sim,hit,q,z;
       round.x=tx;round.y=ty;round.tint='#12abef';round.life=2;
       g.bullets=remote?[]:[round];g.fxBullets=remote?[round]:[];
       sim=JSON.stringify(round);pts.length=0;GFX.tr=0;GFX.sx=0;GFX.sy=0;g.shake=0;
       mouse.x=(tx-g.camX)*ZOOM();mouse.y=(ty-g.camY)*ZOOM();mouse.init=true;
       __frame(0);
       if(JSON.stringify(round)!==sim) throw Error(label+' draw mutated the round');
       if(!pts.length) throw Error(label+' drew no tracer');
       hit=pts[0];q=w2s(tx,0,ty);z=ZOOM();
       if(Math.hypot(hit.x-q.x,hit.y-q.y)>3) throw Error(label+' misses reticle by '+Math.hypot(hit.x-q.x,hit.y-q.y).toFixed(2)+' screen px');
       if(Math.hypot(q.x-mouse.x,q.y-mouse.y)>3) throw Error(label+' cursor staging drift');
       if(typeof shotDrawLift!=='function') throw Error('missing shared drawn flight');
       var ly=round.ly>0?round.ly:12,md=round.mzd||0,saveX=round.x,saveY=round.y;
       round.x=sx+ux*md;round.y=sy+uy*md;
       if(Math.abs(shotDrawLift(round,0)-ly)>0.01) throw Error(label+' moved the muzzle height');
       round.x=saveX;round.y=saveY;
       if(Math.abs(hit.worldY-hit.tailY-uy*(round.rkt?26:9))>0.1) throw Error(label+' tail is still lifted at the reticle');
     }
     try{
       __runPrep();__topClear();__resetCfg();__pinDefaults(0);__cleanProfile();
       __deploy({kit:['gun_rifle'],safe:null,mapIx:0,seed:4242});
       g=__state();if(!g||!g.player||g.over) return 'SKIP: staging: no raid';
       for(k in NET) keep[k]=NET[k];
       p=g.player;p.iv=999;p.ads=false;p.bloom=0;p.bloomK=0;p.vx=0;p.vy=0;
       keys={};mouse.down=false;CFG.xfPix=0;CFG.fogWar=0;g.ents=[];g.sparks=[];g.puffs=[];
       g.mapOpen=false;g.mapFirst=false;g.bagOpen=false;g.paused=false;
       NET.on=false;__frame(0);owc=wc;move=wc.moveTo;line=wc.lineTo;
       wc.moveTo=function(x,y){if(this.strokeStyle==='#12abef') last={x:x,y:y};return move.apply(this,arguments);};
       wc.lineTo=function(x,y){if(this.strokeStyle==='#12abef'&&last){var t=this.getTransform();pts.push({x:(t.a*x+t.c*y+t.e)/DPR,y:(t.b*x+t.d*y+t.f)/DPR,worldY:y,tailY:last.y});}return line.apply(this,arguments);};
       isDay=function(){return true;};
       w=cloneObj(WEAPONS.rifle);w.spread=0;w.rng=900;
       for(role=0;role<2;role++){
         NET.role=role?'join':'host';NET.seat=role;NET.on=false;
         for(side=0;side<4;side++){
           angle=side*Math.PI/2;p.bloomK=0;g.bullets=[];
           fireWeapon(p,w,p.x+Math.cos(angle)*300,p.y+Math.sin(angle)*300,true);
           b=g.bullets[0];if(!b) throw Error('no fired round');
           if(Math.abs(b.vx/1180-Math.cos(angle))>1e-6||Math.abs(b.vy/1180-Math.sin(angle))>1e-6) throw Error('shot staging has spread');
           paint(b,false,'role '+role+' angle '+side);
         }
         var actors=[p,{kind:'raider',x:p.x,y:p.y,r:11,hp:70,face:0},{kind:'sentry',x:p.x,y:p.y,r:22,hp:150,face:0}];
         for(side=0;side<actors.length;side++){
           NET.on=false;p.bloomK=0;g.bullets=[];fireWeapon(actors[side],w,p.x+300,p.y,side===0);b=g.bullets[0];
           paint(b,false,'local kind '+side+' role '+role);
           NET.on=true;NET.up=[];NET.upSeed=g.seed>>>0;NET.roster=[{seat:0,pid:'flight-host',host:true},{seat:1,pid:'flight-mate'}];
           NET.peers=[peer(1-role)];
           // v28.xx (cw-cx-reticleflight): send a fresh muzzle position, not the 300 px probe location.
           NET.on=false;g.bullets=[];p.bloomK=0;fireWeapon(actors[side],w,p.x+300,p.y,side===0);b=g.bullets[0];
           NET.on=true;sent.length=0;netFxShot(b,actors[side],w,0);var word=sent.filter(function(m){return m.t==='fx'&&m.k==='b';})[0];
           if(!word) throw Error('no tracer packet');
           g.fxBullets=[];netFxTake(NET.peers[0],word);b=g.fxBullets[0];if(!b) throw Error('no received round');
           paint(b,true,'received kind '+side+' role '+role);NET.on=false;
         }
       }
       return null;
     } finally {
       isDay=oDay;if(owc){owc.moveTo=move;owc.lineTo=line;}
       if(g){g.bullets=[];g.fxBullets=[];}
       if(Object.keys(keep).length){for(k in NET) if(!(k in keep)) delete NET[k];for(k in keep) NET[k]=keep[k];}
       try{__endRaid('abandon');}catch(_e){}__topClear();
     }
   }},
  {v:'36.57',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
