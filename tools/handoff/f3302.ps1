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

if ($s.Contains("  {v:'33.02',what:")) { throw "check 33.02 is in the fixture already" }

SubRx @'
  {v:'33.01',what:
'@ @'
  {v:'33.02',what:'the experimental page switches warden armour, explosive barrels, waves grow, aim lanes and search rings: each runs with its switch on and stops with it off',
   run:function(){
     if(typeof brlPlace!=='function'||typeof waveTier!=='function'||typeof telegraphLane!=='function'||typeof searchCone!=='function'||typeof searchAdvance!=='function'||typeof mkWarden!=='function'||typeof arcadeDeploy!=='function'||typeof xfSnap!=='function') return 'SKIP: these features are not all here';
     var bad=[], i, g, p, ks=['xfWarden','xfBarrel','xfRamp','xfTell','xfSearch'], fe, n, pos, a, q, x, y, w, j, dm={}, PR=CanvasRenderingContext2D.prototype, oe=PR.ellipse, hits;
     function setK(key,v){ CFG[key]=v; xfSnap(); }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       SETSUB='exp'; renderSettings();
       ks.forEach(function(k){ var b=document.getElementById('go_'+k); if(!b) bad.push('ONE: no row for '+k); else if(String(b.textContent).toLowerCase()!=='on'||CFG[k]!==1) bad.push('ONE: '+k+' does not start on'); });
       SETSUB=''; renderSettings();
       if(ARCADE.on) return 'SKIP: the arcade is on after __topClear';
       if(!arcadeDeploy({mapIx:0,seed:4242})) return 'SKIP: no arcade raid';
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       p=g.player; keys={}; ARCADE.holdT=0; g.t=4;
       // BARRELS: the placement
       [1,0].forEach(function(v){
         setK('xfBarrel',v); brlPlace(g); n=g.brl.length;
         if(v===1&&n<1) bad.push('BARREL on: no barrel was placed');
         if(v===0&&n!==0) bad.push('BARREL off: '+n+' barrels were placed');
       });
       setK('xfBarrel',1); brlPlace(g);
       // WAVES GROW: ten minutes in, score zero
       g.t=600; if(typeof g.timeLeft==='number') g.timeLeft=(g.raidLen===undefined?CFG.raidSec:g.raidLen)-600;
       setK('xfRamp',1); if(waveTier(0)!==4) bad.push('RAMP on: the wave tier at ten minutes and no score is '+waveTier(0)+', not 4');
       setK('xfRamp',0); if(waveTier(0)!==0) bad.push('RAMP off: the wave tier at ten minutes and no score is '+waveTier(0)+', not 0');
       setK('xfRamp',1); g.t=4;
       // AIM LANES: a winding sentry, and the howler shell circle
       fe={kind:'sentry',hp:50,windup:0.2,rng:300,face:0,x:p.x+100,y:p.y};
       setK('xfTell',1); if(!telegraphLane(fe)) bad.push('TELL on: a winding sentry painted no lane');
       setK('xfTell',0); if(telegraphLane(fe)!==null) bad.push('TELL off: a winding sentry still painted a lane');
       setK('xfTell',1);
       if(typeof __frame==='function'){
         [1,0].forEach(function(v){
           setK('xfTell',v); hits=0;
           g.shells=[{mortar:1,fx:1,x0:p.x+40,y0:p.y+40,tx:p.x+97,ty:p.y+53,t:0.5,air:100,dmg:0}];
           PR.ellipse=function(ex,ey,rx){ if(ex===g.shells[0].tx&&ey===g.shells[0].ty&&rx===(CFG.howlerR===undefined?90:CFG.howlerR)) hits++; return oe.apply(this,arguments); };
           try{ __frame(0.016); }finally{ PR.ellipse=oe; }
           if(v===1&&hits<1) bad.push('TELL on: the howler shell circle did not mark its full size');
           if(v===0&&hits>0) bad.push('TELL off: the howler shell circle still marked its full size');
         });
         g.shells=[];
       }
       setK('xfTell',1);
       // SEARCH RINGS: the cone and the next ring
       [1,0].forEach(function(v){
         setK('xfSearch',v);
         fe={kind:'sentry',hp:50,state:'chase',searchX:100,searchY:100,x:p.x+50,y:p.y,face:0,rng:340,searchLvl:0};
         var cone=searchCone(fe), adv=searchAdvance(fe);
         if(v===1&&(!cone||adv!==true||fe.searchLvl!==1)) bad.push('SEARCH on: no scan cone or no next ring');
         if(v===0&&(cone||adv!==false||fe.searchLvl!==0)) bad.push('SEARCH off: a scan cone or a next ring remained');
       });
       setK('xfSearch',1);
       // WARDEN ARMOUR: the same round from the front, armour on and off
       for(q=0;q<32&&!pos;q++){ a=q/32*6.2832; x=p.x+Math.cos(a)*240; y=p.y+Math.sin(a)*240; if(spotFree(g.map,x,y,40)&&spotFree(g.map,x,y+70,12)&&losClear(x,y,x,y+70,G.vseg)) pos={x:x,y:y}; }
       if(!pos) bad.push('WARDEN: no open ground for a warden');
       else {
         [1,0].forEach(function(v){
           setK('xfWarden',v); w=mkWarden(pos.x,pos.y); w.face=Math.PI/2; w.state='patrol'; w.hp=w.maxhp=900; g.ents=[w]; g.bullets.length=0;
           g.bullets.push({x:pos.x+16,y:pos.y+60,vx:0,vy:-1180,dmg:100,life:0.3,player:true,owner:p,tint:'#ffffff',el:'',thru:0});
           for(j=0;j<8;j++) updateBullets(1/60);
           dm[v]=900-w.hp;
         });
         if(!(dm[0]>0)) bad.push('WARDEN: the round did no damage with the armour off');
         else if(!(dm[1]<dm[0]*0.7)) bad.push('WARDEN on: a front round did '+dm[1]+' against '+dm[0]+' with the armour off');
       }
     } catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       PR.ellipse=oe; SETSUB='';
       for(i=0;i<ks.length;i++){ try{ if(P.gameOpts) delete P.gameOpts[ks[i]]; }catch(_d){} }
       try{ if(typeof ARCADE==='object'&&ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       __topClear(); __resetCfg(); xfSnap(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'33.01',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
