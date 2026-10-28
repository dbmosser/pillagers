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

if ($s.Contains("  {v:'35.80',what:")) { throw "check 35.80 is in the fixture already" }

SubRx @'
  {v:'35.79',what:
'@ @'
  {v:'35.80',what:'cw-clockcard, his HUD orders of 2026-10-28 morning (pictures in the HUD Improver chat): in a career raid the clock draws in its own card above a separate score card, in bigger type than the score; the extraction pill and arrow name the nearest open ring even while a far ring is called; earning sp (a finisher, a kill) floats no figure; the band above the belt shows an extraction in progress only within 250 m of it; the gun card draws no item count or value; an old drag no longer keeps the run info panel out of the top right corner and the notes row sits under it; the board title reads current pillagers, never pillager bots; the air strike plate stands on the gun card with its right edge flush; the downed card bottom stands above the player at the screen centre',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__runPrep&&window.__resetCfg&&window.__pinDefaults&&window.__cleanProfile)) return 'SKIP: this fixture cannot deploy';
     if(typeof arcadeScoreHud!=='function'||typeof drawHUD!=='function'||typeof scoreBonus!=='function'||typeof airPlateAt!=='function'||typeof downPlateRect!=='function'||typeof downPlateDraw!=='function'||typeof careerKill!=='function') return 'SKIP: no raid HUD here';
     var bad=[], g, p, c0=(typeof CAREER_ON==='number')?CAREER_ON:0, rec=[], CP=CanvasRenderingContext2D.prototype, oF=CP.fillText, dpS=null, i, j, zs, zN=null, zF=null, sv=[], oA, oB, oSH, oX, oY, oWP, ck, sc, R, z, gb, nl, lb, oHud=null, oCT, hasP=(typeof P==='object'&&P);
     function spy(){ rec=[]; CP.fillText=function(s,x,y){ try{ var m=/([\d.]+)px/.exec(this.font), T=this.getTransform?this.getTransform():null; rec.push({s:String(s),px:m?+m[1]:0,x:T?T.a*x+T.c*y+T.e:x,y:T?T.b*x+T.d*y+T.f:y}); }catch(_e){} return oF.apply(this,arguments); }; }
     function unspy(){ CP.fillText=oF; }
     function drawn(re,f){ for(var q=0;q<rec.length;q++) if(re.test(rec[q].s)&&(!f||f(rec[q]))) return rec[q]; return null; }
     function frame(){ spy(); try{ drawHUD(); }catch(e){ bad.push('drawHUD threw '+(e&&e.message||e)); } unspy(); }
     function onBand(r){ return r.x>=0&&r.x<=W&&r.y>=H*0.55&&r.y<=H; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       CAREER_ON=1; __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: staging: no raid';
       if(!g.career||!g.cs) return 'SKIP: staging: not a career raid';
       p=g.player; keys={}; g.mapOpen=false; g.bagOpen=false; g.paused=false; p.hp=100; p.downed=false; g.bag=['scrap','board'];
       // ONE: the clock card above the score card, bigger type
       g.timeLeft=300; spy(); try{ arcadeScoreHud(30,hudRes()); }catch(e1){ bad.push('arcadeScoreHud threw '+e1.message); } unspy();
       ck=drawn(/^\d+:\d\d$/); sc=drawn(/^[\d,]+ sp$/i);
       if(!ck||!sc) bad.push('the clock or the score was not drawn ('+!!ck+', '+!!sc+')');
       else { if(!(ck.y<sc.y)) bad.push('the clock ('+Math.round(ck.y)+') is not above the score ('+Math.round(sc.y)+')'); if(!(ck.px>sc.px)) bad.push('the clock type ('+ck.px+' px) is not bigger than the score ('+sc.px+' px)'); }
       if(!(typeof CLOCKBOX==='object'&&CLOCKBOX&&CLOCKBOX.g===g&&SCOREBOX.g===g&&CLOCKBOX.h>0&&CLOCKBOX.y+CLOCKBOX.h<=SCOREBOX.y)) bad.push('the clock has no card of its own over the score card');
       // TWO: the pill names the nearest open ring while a far ring is called
       zs=g.zones||[];
       oA=g.active; oB=g.beaconT; oSH=g.shipHold; oX=p.x; oY=p.y; oWP=g.waypoint;
       for(i=0;i<zs.length;i++) sv.push({z:zs[i],o:zs[i].open,b:zs[i].beaconT,h:zs[i].hold});
       if(zs.length<2) bad.push('staging: fewer than two rings');
       else {
         g.waypoint=null; for(i=0;i<zs.length;i++){ zs[i].open=true; zs[i].beaconT=null; zs[i].hold=null; }
         zN=zs[0]; p.x=zN.x+400; p.y=zN.y;
         for(i=0;i<zs.length;i++){ if(zs[i]!==zN&&dist(p,zs[i])<dist(p,zN)) zN=zs[i]; }
         for(i=0;i<zs.length;i++){ if(zs[i]!==zN&&(!zF||dist(p,zs[i])>dist(p,zF))) zF=zs[i]; }
         if(!(dist(p,zF)>dist(p,zN)+1000)) bad.push('staging: the far ring is only '+Math.round(dist(p,zF))+' away');
         zF.beaconT=20; g.active=zF; g.beaconT=20; g.shipHold=null;
         frame();
         if(String(EXTPILL.txt||'').toLowerCase().indexOf(' '+metres(dist(p,zN))+'m')<0) bad.push('with a far ring called the pill reads '+JSON.stringify(EXTPILL.txt)+', not the nearest ring at '+metres(dist(p,zN))+'m');
         // THREE: the band above the belt only within 250 m of the ring in progress
         zF.beaconT=0; zF.hold=30; g.beaconT=0; g.shipHold=30;
         p.x=zF.x+3000; p.y=zF.y; frame();
         if(drawn(/extract in progress/i,onBand)) bad.push('an extraction in progress 300 m away still draws on the band');
         if(drawn(/^\d+m$/,onBand)) bad.push('an extraction 300 m away still draws its metres on the band');
         zF.beaconT=20; zF.hold=null; g.beaconT=20; g.shipHold=null; frame();
         if(drawn(/inbound/i,onBand)) bad.push('an extraction inbound 300 m away still draws on the band');
         zF.beaconT=0; zF.hold=30; g.beaconT=0; g.shipHold=30;
         p.x=zF.x+2000; p.y=zF.y; frame();
         if(!drawn(/extract in progress/i,onBand)) bad.push('control: an extraction in progress 200 m away no longer draws on the band');
         for(i=0;i<sv.length;i++){ sv[i].z.open=sv[i].o; sv[i].z.beaconT=sv[i].b; sv[i].z.hold=sv[i].h; }
         g.active=oA; g.beaconT=null; g.shipHold=oSH; g.waypoint=oWP; p.x=oX; p.y=oY;
       }
       // FOUR: earning sp floats no figure
       nl=(g.labels||[]).length; scoreBonus(100,p.x,p.y-30,'FINISHER'); careerKill('crawler',null,false,p.x+120,p.y,null);
       lb=(g.labels||[]).slice(nl);
       for(i=0;i<lb.length;i++) if(/\bsp\b/i.test(String(lb[i].txt))) bad.push('earning sp floats '+JSON.stringify(lb[i].txt));
       if(!(g.cs.s>0)) bad.push('control: the score did not count the sp');
       // FIVE: the gun card draws no item count or value; the backpack key stays
       frame();
       if(drawn(/^\d+ items?\b/i)) bad.push('the gun card still draws '+JSON.stringify(drawn(/^\d+ items?\b/i).s));
       if(!drawn(/backpack/i)) bad.push('control: the backpack key is gone from the gun card');
       // SIX: the run info panel in the top right corner (an old drag is undone once), the notes row under it
       if(hasP){ oHud=P.hud?JSON.parse(JSON.stringify(P.hud)):null; oCT=P.condTop1; }
       if(typeof condTopMove!=='function') bad.push('an old drag still keeps the run info panel where it was put');
       else if(hasP){ P.hud=P.hud||{}; P.hud.cond={dx:-300,dy:400}; P.condTop1=0; condTopMove(); }
       if(G.tel){ G.tel.notes=G.tel.notes||[]; G.tel.notes.push({t:'zq note'}); }
       frame(); frame();
       gb=HUDBOX.cond;
       if(!gb||!(gb.h>0)) bad.push('staging: the run info panel was not drawn');
       else {
         var _top=(typeof MMAP==='object'&&MMAP&&MMAP.box)?(MMAP.box.y+MMAP.box.h+Math.round(TRG.gp*TRG.z)):TRG.y0*TRG.z;   // under the minimap when that is on
         if(Math.abs(gb.y-_top)>3) bad.push('the run info panel starts at '+Math.round(gb.y)+', not at the top of the corner ('+Math.round(_top)+')');
         if(!(typeof EDGEBOX==='object'&&EDGEBOX.notes&&EDGEBOX.notes.y>=gb.y+gb.h-1)) bad.push('the notes row is not under the run info panel');
       }
       if(drawn(/^contracts \d+\/\d+/i)) bad.push('the run info title still counts contracts');
       // SEVEN: the board reads current pillagers
       if(drawn(/pillager bots/i)) bad.push('the HUD still says '+JSON.stringify(drawn(/pillager bots/i).s));
       // EIGHT: the air strike plate stands on the gun card, right edges flush
       z=hudRes(); gb=(typeof GUNCARD==='object'&&GUNCARD&&GUNCARD.g===g)?GUNCARD:HUDBOX.gear;
       if(!gb||!(gb.w>0)) bad.push('staging: no gun card box');
       else { R=airPlateAt(Math.round(200*z),Math.round(28*z),z); if(!(R.y+Math.round(28*z)<=gb.y)||gb.y-(R.y+Math.round(28*z))>Math.round(16*z)) bad.push('the air strike plate does not stand on the gun card ('+R.y+' vs '+Math.round(gb.y)+')'); if(Math.abs(R.x+Math.round(200*z)-(gb.x+gb.w))>2) bad.push('the air strike plate is not flush with the gun card right edge'); }
       // NINE: the downed card stands above the player at the screen centre (its bottom row, the self-revive line, over the centre)
       p.downed=true; p.downT=(CFG.downTime||30)*0.8; p.revived=false; frame(); p.downed=false;
       dpS=drawn(/self-revive/i); ck=drawn(/^down$/i);
       if(!dpS||!ck) bad.push('staging: the downed card was not drawn ('+!!dpS+', '+!!ck+')');
       else { if(!(dpS.y+16*z<=H/2-40*z)) bad.push('the downed card reaches '+Math.round(dpS.y+16*z)+', over the player at '+Math.round(H/2)); if(!(ck.y>=0)) bad.push('the downed card goes off the top'); }
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       CP.fillText=oF; CAREER_ON=c0; keys={};
       try{ if(hasP){ if(oHud) P.hud=oHud; else delete P.hud; P.condTop1=oCT; } }catch(_e1){}
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'35.79',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
