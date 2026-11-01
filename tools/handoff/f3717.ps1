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

if ($s.Contains("  {v:'37.17',what:")) { throw "check 37.17 is in the fixture already" }

SubRx @'
  {v:'37.16',what:
'@ @'
  {v:'37.17',what:'cw-p0stat, his progression plan of 11-01 (m0 foundation): one place every stat reads gear from. A raid sums what the pillager wears once onto its body (nothing worn, a bot sim raid and the demo carry nothing), and the real code paths read it: move speed, sprint drain and refill, reload, bandage time, time on the floor and its bar, damage taken, noise, how far an enemy sees him and the revive hold all move by exactly the worn fraction, and with nothing worn every one is exactly what it was',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__runPrep&&window.__cleanProfile)) return 'SKIP: no raid fixture';
     if(typeof updatePlayer!=='function'||typeof damagePlayer!=='function'||typeof startPrep!=='function'||typeof ping!=='function'||typeof updateEnts!=='function') return 'SKIP: no player, damage, heal, noise or enemy code here';
     if(typeof wornMods!=='function'||typeof wornAdd!=='function') return 'SKIP: no worn gear records in this build';
     if(typeof raidWornMods!=='function'||typeof wornM!=='function'||typeof netRevNeed!=='function') return 'no single gear reader in this build (raidWornMods, wornM, netRevNeed)';
     var bad=[], kk=keys, mm=Object.assign({},mouse), nk=Object.assign({},NET), pk=Object.assign({},PAD), cp=Object.assign({},CFG), w0=JSON.stringify(P.worn||{}), gr0=JSON.stringify(P.gear||[]), gn0=P.gearN,
         oldLH=listenersHear, oldCS=canSee, g, p, a, b, x0, y0, dirs, d, i, e, ents0, pc, seen, M={spd:0.1,stam:0.2,reload:0.2,heal:0.2,grit:0.25,tough:0.15,quiet:0.2,hide:0.2,revive:0.25};
     function need(ok,msg){ if(!ok) bad.push(msg); }
     function near(x,y,tol){ return Math.abs(x-y)<=tol*Math.max(1,Math.abs(y)); }
     function calm(){
       keys={}; mouse.down=false; PAD.on=false; PAD.mx=0; PAD.my=0; NET.on=false;
       p.hand=null; p.prep=null; p.prepA=null; p.reloading=0; p.rlTot=0; p.ads=false; p.stimT=0; p.roll=0; p.rollCd=0; p.iv=0; p.downed=false; p.dying=false; p.specOut=false;
       p.hp=100; p.maxhp=100; p.armor=0; p.stam=100; p.stamLock=0; p.cooking=false; g.wheel=null; g.sprintOn=false; g.sprinting=false; g.crouchTog=false; g.pCrouch=false; g.deathBeat=null;
       g.shWas=false; p.shotSprintRelease=false; p.stamRelease=0; p.trigYield=0; try{ HHOLD.arm=0; }catch(_h){}
       p.x=x0; p.y=y0;
     }
     function sprintRun(m){ arm(m); updatePlayer(0.001); arm(m); keys[d]=true; keys.ShiftLeft=true; updatePlayer(0.016); p.stam=100; updatePlayer(0.1); return {drain:100-p.stam, on:!!g.sprinting}; }
     function arm(m){ calm(); p.wm=m; }
     try{
       __runPrep();
       // ONE: the raid body carries what is worn, summed once; nothing worn, the bot sim and the demo carry nothing
       P.gear=[]; P.worn={};
       __deploy({kit:[],seed:4242}); g=__state();
       need(g&&g.player&&g.player.wm===null,'ONE: nothing worn, the body carries '+JSON.stringify(g&&g.player&&g.player.wm));
       pc=wornAdd(P,{k:'gloves',r:2,pw:60,tr:[{s:'reload',v:0.1},{s:'heal',v:0.05}]}); wornWear(P,pc.id);
       __deploy({kit:[],seed:4242}); g=__state(); p=g.player;
       need(p.wm&&p.wm.reload===0.1&&p.wm.heal===0.05&&p.wm.spd===0,'ONE: worn gloves summed to '+JSON.stringify(p.wm));
       if(window.__newRaid){ a=__newRaid(); need(a&&a.player&&!a.player.wm,'ONE: a bot sim raid carries the gear'); __deploy({kit:[],seed:4242}); g=__state(); p=g.player; }
       ARCADE.on=true; try{ need(raidWornMods()===null,'ONE: the demo reads the career gear'); } finally{ ARCADE.on=false; }
       x0=p.x; y0=p.y;
       // TWO: move speed, in the first direction he can walk
       dirs=['KeyD','KeyA','KeyS','KeyW']; d=null;
       for(i=0;i<dirs.length&&!d;i++){ arm(null); keys[dirs[i]]=true; updatePlayer(0.02); a=Math.hypot(p.x-x0,p.y-y0); if(a>0.5) d=dirs[i]; }
       if(!d) bad.push('TWO: staging: he could not walk any way from the start');
       else{ arm(null); keys[d]=true; updatePlayer(0.02); a=Math.hypot(p.x-x0,p.y-y0);
             arm(M); keys[d]=true; updatePlayer(0.02); b=Math.hypot(p.x-x0,p.y-y0);
             need(near(b,a*1.1,0.01),'TWO: worn +10% speed walked '+b.toFixed(3)+' against '+a.toFixed(3)); }
       // THREE: sprint drain
       if(d){ a=sprintRun(null); b=sprintRun(M);
              if(!a.on||!b.on) bad.push('THREE: staging: he did not sprint ('+a.on+', '+b.on+')');
              else need(a.drain>0&&near(b.drain,a.drain*0.8,0.01),'THREE: sprint drained '+b.drain.toFixed(3)+' with stamina gear against '+a.drain.toFixed(3)); }
       // FOUR: reload on R
       arm(null); p.wep=cloneObj(WEAPONS.rifle); p.drawRef=p.wep; p.drawT=0; p.drawLen=0; p.ammo=2; p.reserve=60; keys={KeyR:true}; updatePlayer(0.001); a=p.reloading;
       arm(M); p.wep=cloneObj(WEAPONS.rifle); p.drawRef=p.wep; p.drawT=0; p.drawLen=0; p.ammo=2; p.reserve=60; keys={KeyR:true}; updatePlayer(0.001); b=p.reloading;
       need(a>0&&near(b,a*0.8,0.01),'FOUR: a reload with reload gear takes '+b+' ms against '+a);
       // FIVE: bandage wind-up
       arm(null); startPrep('heal','bandage'); a=p.prep&&p.prep.max;
       arm(M); startPrep('heal','bandage'); b=p.prep&&p.prep.max;
       need(a>0&&near(b,a*0.8,0.001),'FIVE: a bandage with quick hands takes '+b+' s against '+a);
       // SIX: time on the floor and the bar, and damage taken
       arm(null); p.hp=5; damagePlayer(60,'crawler','crawler'); a=p.downT;
       need(p.downed&&near(a,CFG.downTime,0.001),'SIX: staging: a hit at 5 hp did not down him on the normal clock ('+a+')');
       need(p.downMax===a,'SIX: the bleed bar does not start full ('+p.downMax+' for '+a+')');
       arm(M); p.hp=5; damagePlayer(60,'crawler','crawler'); b=p.downT;
       need(p.downed&&near(b,a*1.25,0.001)&&p.downMax===b,'SIX: with grit he has '+b+' s on the floor against '+a+' (bar from '+p.downMax+')');
       arm(null); damagePlayer(20,'crawler','crawler'); a=100-p.hp;
       arm(M); damagePlayer(20,'crawler','crawler'); b=100-p.hp;
       need(a>0&&near(b,a*0.85,0.02),'SIX: a hit with tough gear took '+b+' against '+a);
       // SEVEN: noise, at the one place all of his noise passes
       seen=[]; listenersHear=function(x,y,s){ seen.push(s); };
       arm(null); ping(p.x,p.y,100,false,true,'player','move'); arm(M); ping(p.x,p.y,100,false,true,'player','move');
       listenersHear=oldLH;
       need(seen.length===2&&near(seen[1],seen[0]*0.8,0.001),'SEVEN: his noise reached '+seen[1]+' with quiet gear against '+seen[0]);
       // EIGHT: how far an enemy sees him
       e=null; for(i=0;i<g.ents.length;i++) if(g.ents[i]&&!g.ents[i].dead&&g.ents[i].hp>0){ e=g.ents[i]; break; }
       if(!e) bad.push('EIGHT: staging: no enemy in the raid');
       else{
         ents0=g.ents; g.ents=[e]; var ex=p.x+120, ey=p.y, ef=Math.PI, es=e.state, eal=e.alert;
         seen=[]; canSee=function(ax,ay,af,bx,by,vs,far){ seen.push(far); return false; };
         arm(null); e.x=ex; e.y=ey; e.face=ef; e.state=es; e.alert=eal; updateEnts(0.001); a=seen[0];
         seen=[]; arm(M); e.x=ex; e.y=ey; e.face=ef; e.state=es; e.alert=eal; updateEnts(0.001); b=seen[0];
         canSee=oldCS; g.ents=ents0;
         need(a>0&&near(b,a*0.8,0.001),'EIGHT: an enemy sees him from '+b+' with hard to spot gear against '+a);
       }
       // NINE: the revive hold
       arm(null); a=netRevNeed(); arm(M); b=netRevNeed();
       need(near(a,NET_REV_T,0.0001)&&near(b,NET_REV_T*0.75,0.0001),'NINE: the revive hold is '+b+' s with medic gear, '+a+' without');
       // TEN: with nothing worn every reader is exactly 0
       arm(null); for(i in M) need(wornM(i)===0,'TEN: '+i+' reads '+wornM(i)+' with nothing worn');
     }catch(e2){ bad.push('threw: '+(e2&&e2.message||e2)); }
     finally{
       listenersHear=oldLH; canSee=oldCS; try{ ARCADE.on=false; }catch(_a){}
       keys=kk; Object.assign(mouse,mm); Object.assign(NET,nk); Object.assign(PAD,pk);
       for(var k in CFG) if(!(k in cp)) delete CFG[k]; Object.assign(CFG,cp);
       try{ P.worn=JSON.parse(w0); P.gear=JSON.parse(gr0); P.gearN=gn0; }catch(_w){}
       try{ if(G&&G.player) G.player.wm=null; }catch(_g){}
       try{ __topClear(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'37.16',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
