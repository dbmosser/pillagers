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

if ($s.Contains("  {v:'27.43',what:")) { throw "check 27.43 is in the fixture already" }

SubRx @'
  {v:'27.42',what:
'@ @'
  {v:'27.43',what:'rvw1, the cloud review (3, 10, 12, 17, 21): no event or fire is placed in a stronghold, a body whose way lies across a fire slides round its edge instead of grinding on it, the 6 CRATES goal counts only the boxes the party opens (player 2 too, no bodies), the bounty is paid for a kill of the party only and not for a down or a death nobody caused, the convoy crew and the bounty pillager are never taken out of the world in view, and the air strike prompts name the key as bound',
   run:function(){
     if(!(window.__state&&window.__endRaid&&window.__runPrep)) return 'SKIP: no raid here';
     if(typeof arcadeDeploy!=='function'||typeof ARCADE!=='object'||typeof flowZoneNear!=='function'||typeof fireKeep!=='function'||typeof goalProg!=='function'||typeof evLaunch!=='function'||typeof evTick!=='function'||typeof airHint!=='function'||typeof flowTick!=='function') return 'SKIP: no arcade, fires, events or goals here';
     var bad=[], g=null, p=null, rs=say, own=false, lines=[], i, j, k, S, ev, e, car, crew, ids=['bounty','convoy','debris','cool'], oShAt, n, f, o, ax, ay, c0=null, ok, a, minD, m0, ct, ct2, ct3, km, hadKm, kv, left, saw, HE;
     function liveIt(v){ v.t=v.warn; evTick(0.01); }
     function has(t){ var q; for(q=0;q<lines.length;q++) if(lines[q].indexOf(t)===0) return true; return false; }
     function fresh(mp,s){
       try{ if(typeof ARCADE==='object'&&ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       __topClear(); __runPrep();
       if(!arcadeDeploy({mapIx:mp,seed:s})) return false;
       g=__state(); if(!g||g.over||!g.player) return false;
       p=g.player; keys={}; lines.length=0; say=function(q,kd,o2){ lines.push(String(q)+'|'+((o2&&o2.sub)||'')); }; own=true;
       return true;
     }
     try{
       // ONE: cloud review 3: no event is placed in a stronghold: with every spot counted as inside one, the pickers of the debris, the convoy, the bounty and the coolant events find no ground
       if(!fresh(0,4242)) return 'SKIP: arcadeDeploy built no arcade raid';
       oShAt=shAt;
       try{
         shAt=function(){ return true; };
         for(i=0;i<ids.length;i++){
           HE=evS(); HE.live=[]; HE.plan=[]; HE.n=0;
           ev=evLaunch(ids[i]);
           if(ev) bad.push('ONE: the '+ids[i]+' event found ground although every spot was in a stronghold');
         }
       }finally{ shAt=oShAt; }
       HE=evS(); HE.live=[]; HE.plan=[]; HE.n=0;
       ev=evLaunch('bounty'); if(!ev) bad.push('ONE: the bounty found no ground when no stronghold was in the way');
       // TWO: cloud review 3: a body that wants to cross a fire slides round the edge, never into it
       if(!fresh(0,4242)) return 'SKIP: arcadeDeploy built no arcade raid';
       for(ax=-500;ax<=500&&!c0;ax+=50) for(ay=-500;ay<=500&&!c0;ay+=50){
         ok=spotFree(g.map,p.x+ax,p.y+ay,12); for(k=0;k<24&&ok;k++){ a=k*0.2618; if(!spotFree(g.map,p.x+ax+Math.cos(a)*105,p.y+ay+Math.sin(a)*105,10)||!spotFree(g.map,p.x+ax+Math.cos(a)*60,p.y+ay+Math.sin(a)*60,10)) ok=false; }
         if(ok&&p.x+ax>300&&p.y+ay>300&&p.x+ax<WORLD_W-300&&p.y+ay<WORLD_H-300) c0={x:p.x+ax,y:p.y+ay};
       }
       if(!c0) return 'SKIP: no open ground for a fire near the drop';
       f=fireAdd(c0.x,c0.y,FIRE.r,FIRE.life,'fuel',0); f.t=1;
       o={x:c0.x-70,y:c0.y+4,id:7}; minD=1e9;
       for(k=0;k<120;k++){ fireKeep(o,12,{x:c0.x+400,y:c0.y},1/60); minD=Math.min(minD,Math.hypot(o.x-c0.x,o.y-c0.y)); o.x+=2.5; }
       if(Math.abs(o.y-c0.y)<60) bad.push('TWO: a body that wanted to cross the fire stood on its edge (it moved '+Math.round(Math.abs(o.y-c0.y))+' sideways in 2 s)');
       if(minD<FIRE.r+11) bad.push('TWO: the body was let into the fire ('+Math.round(minD)+' from the middle)');
       g.flow.fires.length=0;
       // THREE: cloud review 12: the crate goal counts what the party opens
       S=flowS(); S.crates=0;
       ct=null; ct2=null; ct3=null;
       for(i=0;i<g.containers.length;i++){ n=g.containers[i]; if(n&&!n.opened&&n.type==='crate'){ if(!ct) ct=n; else if(!ct2) ct2=n; else if(!ct3) ct3=n; } }
       if(!ct||!ct2||!ct3) return 'SKIP: the raid has too few crates to stage';
       ct2.opened=true;   // a pillager emptied it
       if(goalProg('crate6',S)!==0) bad.push('THREE: a box a pillager opened counted for the party ('+goalProg('crate6',S)+')');
       openContainer(ct);
       if(goalProg('crate6',S)!==1) bad.push('THREE: a box the player opened counted '+goalProg('crate6',S)+', not 1');
       netContOpenHost(ct3,1);
       if(goalProg('crate6',S)!==2) bad.push('THREE: a box player 2 opened did not count ('+goalProg('crate6',S)+')');
       n=mkContainer(p.x+20,p.y,'body'); g.containers.push(n); openContainer(n);
       if(goalProg('crate6',S)!==2) bad.push('THREE: a looted body counted as a crate ('+goalProg('crate6',S)+')');
       // FOUR: cloud review 17: the bounty pays a kill of the party only
       if(!fresh(0,4242)) return 'SKIP: arcadeDeploy built no arcade raid';
       HE=evS(); HE.live=[]; HE.plan=[];
       ev=evLaunch('bounty');
       if(!ev) return 'SKIP: the bounty found no ground';
       liveIt(ev); e=ev.d.e;
       if(!e) return 'SKIP: no bounty pillager';
       m0=ARCADE.mine|0;
       e.downed=1; e.hp=40; flowTick(0.25);
       if((ARCADE.mine|0)!==m0) bad.push('FOUR: the bounty was paid for a DOWN ('+((ARCADE.mine|0)-m0)+')');
       if(ev.d.over) bad.push('FOUR: the hunt ended when he was downed');
       e.downed=0; e.hp=0; e.byPlayer=undefined; e.bySeat=0; flowTick(0.25);
       if((ARCADE.mine|0)!==m0) bad.push('FOUR: the bounty was paid for a death nobody caused ('+((ARCADE.mine|0)-m0)+')');
       HE.live=[]; ev=evLaunch('bounty');
       if(ev){ liveIt(ev); e=ev.d.e; if(e){ e.hp=0; e.byPlayer=false; e.bySeat=1; flowTick(0.25); if((ARCADE.mine|0)!==m0+BOUNTY.pay) bad.push('FOUR: a kill by player 2 did not pay the bounty ('+((ARCADE.mine|0)-m0)+')'); } }
       // FIVE: cloud review 10: nobody is taken out of the world in view
       HE.live=[]; ev=evLaunch('convoy');
       if(ev){
         liveIt(ev); car=ev.d.car; crew=ev.d.crew;
         if(car&&crew){
           for(i=0;i<crew.length;i++) crew[i].seen=true;
           car.x=ev.d.dx-20; car.y=ev.d.dy; lines.length=0; flowTick(0.25);
           left=0; for(i=0;i<crew.length;i++) if(g.ents.indexOf(crew[i])<0) left++;
           if(left) bad.push('FIVE: '+left+' of the convoy crew were taken out of the world in view');
           if(has('CONVOY AWAY')) bad.push('FIVE: it said CONVOY AWAY while they stood there');
           if(!has('CONVOY ARRIVED')) bad.push('FIVE: no CONVOY ARRIVED when they stayed ('+lines.join(' / ')+')');
         }
       }
       HE.live=[]; ev=evLaunch('convoy');
       if(ev){
         liveIt(ev); car=ev.d.car; crew=ev.d.crew;
         if(car&&crew){
           for(i=0;i<crew.length;i++) crew[i].seen=false;
           car.x=ev.d.dx-20; car.y=ev.d.dy; p.x=ev.x+2000; p.y=ev.y; lines.length=0; flowTick(0.25);
           left=0; for(i=0;i<crew.length;i++) if(g.ents.indexOf(crew[i])>=0) left++;
           if(left) bad.push('FIVE: '+left+' of the convoy crew were still in the world after they got away unseen');
           if(!has('CONVOY AWAY')) bad.push('FIVE: no CONVOY AWAY when they left unseen ('+lines.join(' / ')+')');
         }
       }
       HE.live=[]; ev=evLaunch('bounty');
       if(ev){
         liveIt(ev); e=ev.d.e;
         if(e){ e.seen=true; ev.lt=ev.dur-0.1; flowTick(0.25); if(g.ents.indexOf(e)<0) bad.push('FIVE: the bounty pillager was taken out of the world in view'); else if(!has('BOUNTY OVER')) bad.push('FIVE: no BOUNTY OVER when he stayed'); }
       }
       // SIX: cloud review 21: the air strike prompts name the key as it is bound
       km=(typeof keysMap==='function')?keysMap():null;
       if(km&&typeof padOn==='function'&&!padOn()){
         hadKm=Object.prototype.hasOwnProperty.call(km,'KeyG'); kv=km.KeyG;
         km.KeyG='KeyJ';
         try{ if(airHint()!=='PRESS J') bad.push('SIX: the air strike hint says '+airHint()+' with G bound to J'); }finally{ if(hadKm) km.KeyG=kv; else delete km.KeyG; }
         if(airHint()!=='PRESS G') bad.push('SIX: the air strike hint says '+airHint()+' with G on G');
       }
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       if(own) say=rs;
       keys={};
       try{ if(typeof ARCADE==='object'&&ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       try{ if(typeof ARCADE==='object'){ ARCADE.mine=0; ARCADE.waveT=0; ARCADE.holdT=0; } }catch(_h){}
       __topClear();
     }
     return bad.length?bad.slice(0,8).join('; '):null; }},
  {v:'27.42',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
