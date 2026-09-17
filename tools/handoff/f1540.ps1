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

SubRx @'
  {v:'15.39',what:
'@ @'
  {v:'15.40',what:'the incoming heal shows only the health that will arrive: a Bandage landing at 80 draws the green block on the health bar out to 85 and not 100, says it is healing him for the seconds to 85, writes those seconds over his head and fills the ring there with the health that has arrived, and a Bandage over the last of a Medkit draws its block only to where it stops, while from 50 a Bandage still draws its whole amount and with the heal ceilings off a Bandage from 80 still runs to 100 (hud audit finding)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     if(typeof applyHeal!=='function'||typeof tickHeal!=='function'||typeof tickPrepSlot!=='function'||typeof healReach!=='function'||typeof healCeil!=='function'||typeof healAmt!=='function'||typeof fmtMS!=='function'||!ITEMS.bandage||!ITEMS.medkit) return 'SKIP: no heal over time or heal reach in this build';
     if(typeof drawHUD!=='function'||typeof render2D!=='function'||typeof ctx==='undefined'||typeof wc==='undefined') return 'SKIP: no HUD or world draw in this build';
     var bad=[], g=null, p=null, keep=null, keepCaps=CFG.healCaps, rects=[], texts=[], arcs=[], i;
     var OWN=Object.prototype.hasOwnProperty, realFR=null, realFT=null, realArc=null, ownFR=false, ownFT=false, ownArc=false;
     // A later control that cannot run keeps a failure already found, so the old build fails rather than skips.
     var skip=function(m){ return bad.length?(bad.join('; ')+' (then SKIP: '+m+')'):('SKIP: '+m); };
     function fresh(hp){ p.hp=hp; p.hpGhost=hp; p.healQ=0; p.healRate=0; p.healCap=undefined; p.healHi=0; p.healLo=undefined; p.healAmt0=0; p.prep=null; p.prepA=null; }
     function drain(left){ for(var k=0;k<4000&&p.healQ>left;k++) tickHeal(0.05); return p.hp; }
     // A Bandage finishing its application the way F and the belt land one: the line it said, or null when nothing was said.
     function land(){
       p.prep={t:9,max:1,kind:'heal',key:'bandage'}; window.__lastSay=null;
       tickPrepSlot(p,'prep',0.016);
       return (window.__lastSay===null||window.__lastSay===undefined)?null:String(window.__lastSay);
     }
     // How wide one drawn HUD paints the green incoming heal block, where the whole bar is 360 wide; null on a throw or no block.
     function block(){ rects.length=0; try{ drawHUD(); }catch(_h){ return null; } return rects.length?rects[0]:null; }
     // One drawn world frame: the seconds written over his head and how full the heal ring there is, 0 to 1; null on a throw.
     function world(){ texts.length=0; arcs.length=0; try{ render2D(0.016); }catch(_w){ return null; } return {t:texts.slice(),a:arcs.slice()}; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.sim) return 'SKIP: no live raid';
       if(!ctx||!wc||ctx===wc) return 'SKIP: the HUD and the world do not draw on two canvases here';
       p=g.player;
       keep={hp:p.hp,hpGhost:p.hpGhost,healQ:p.healQ,healRate:p.healRate,healCap:p.healCap,healHi:p.healHi,healLo:p.healLo,healAmt0:p.healAmt0,prep:p.prep,prepA:p.prepA,downed:p.downed,roll:p.roll};
       p.downed=false; p.roll=0;
       var top=p.maxhp, lo=healCeil(ITEMS.bandage), aB=healAmt(ITEMS.bandage), nm=ITEMS.bandage.name;
       // CONTROL: full health is 100, a Bandage stops at 85 and a Medkit does not, and a whole Bandage fits below 85 from 50.
       if(top!==100||lo!==85||healCeil(ITEMS.medkit)!==top) return 'SKIP: full health is '+top+', the Bandage ceiling '+lo+' and the Medkit ceiling '+healCeil(ITEMS.medkit)+' here';
       if(!(aB>=10&&aB<=35)) return 'SKIP: a Bandage heals '+aB+' here';
       ownFR=OWN.call(ctx,'fillRect'); realFR=ctx.fillRect;
       ctx.fillRect=function(x,y,w,h){ if((/^rgba\(111,\s*224,\s*160,/).test(String(this.fillStyle))) rects.push(w); return realFR.apply(this,arguments); };
       ownFT=OWN.call(wc,'fillText'); realFT=wc.fillText;
       wc.fillText=function(t){ if(String(this.fillStyle)==='#dff3e8') texts.push(String(t)); return realFT.apply(this,arguments); };
       ownArc=OWN.call(wc,'arc'); realArc=wc.arc;
       wc.arc=function(x,y,r,a0,a1){ if(r===9&&a0===-1.5708&&String(this.strokeStyle)==='#7fc4a0'&&this.lineWidth===3) arcs.push((a1-a0)/6.2832); return realArc.apply(this,arguments); };
       // CONTROL, FROM 50: the whole Bandage fits below 85, so on either build the block, the line, the seconds over his head and
       // an empty ring all count the whole Bandage, and the heal ends at 50 plus the Bandage.
       fresh(50);
       var s50=land();
       if(!(p.healQ>0)) return 'SKIP: a Bandage landed at once rather than over time here';
       var r50=healReach(p), sec50=(r50-50)/p.healRate;
       if(Math.abs(r50-(50+aB))>0.01) return 'SKIP: from 50 a Bandage reaches '+r50+' here, not '+(50+aB);
       var b50=block();
       if(b50===null) return 'SKIP: the drawn HUD painted no incoming heal block from 50 here, so the block cannot be read';
       if(Math.abs(b50-360*aB/top)>0.05) return 'SKIP: from 50 the incoming heal block is '+b50+' wide, not '+(360*aB/top)+', so the bar cannot be read here';
       if(s50!==nm+' is healing you, '+fmtMS(sec50)) return 'SKIP: a Bandage landing at 50 said ['+s50+'], so the line cannot be read here';
       var w50=world();
       if(w50===null) return 'SKIP: drawing a world frame threw here';
       if(w50.t.indexOf(Math.ceil(sec50)+'s')<0||!w50.a.length||Math.abs(w50.a[0])>0.01) return 'SKIP: a Bandage landing at 50 wrote ['+w50.t.join(',')+'] over his head with the ring ['+w50.a.join(',')+'] full, so the ring cannot be read here';
       if(Math.abs(drain(0)-r50)>0.01) return 'SKIP: a Bandage from 50 ended at '+p.hp+', not '+r50;
       // THE FIX, FROM 80: the whole Bandage is queued, but the heal stops at 85.
       fresh(80);
       var s80=land(), q80=p.healQ, r80=healReach(p), rate=p.healRate;
       // CONTROL: the whole Bandage is queued and it reaches 85, on either build.
       if(!(Math.abs(q80-aB)<0.01&&Math.abs(r80-lo)<0.01&&rate>0)) return skip('from 80 a Bandage queued '+q80+' reaching '+r80+' here, not '+aB+' reaching '+lo);
       var sec80=(r80-80)/rate, b80=block();
       if(b80===null) return skip('the drawn HUD painted no incoming heal block from 80 here');
       if(Math.abs(b80-360*(r80-80)/top)>0.05) bad.push('a Bandage landing at 80 drew the green incoming heal block out to '+(80+b80*top/360).toFixed(1)+' health, while the heal stops at '+r80);
       var lineWant=nm+' is healing you, '+fmtMS(sec80);
       if(s80!==lineWant) bad.push('a Bandage landing at 80 said ['+s80+'] and not ['+lineWant+'], though the heal stops at '+r80+' in '+sec80.toFixed(2)+' seconds');
       var w80=world();
       if(w80===null) return skip('drawing a world frame from 80 threw here');
       if(!w80.t.length) return skip('no seconds were written over his head for a Bandage landing at 80 here');
       if(w80.t.indexOf(Math.ceil(sec80)+'s')<0) bad.push('a Bandage landing at 80 wrote ['+w80.t.join(',')+'] over his head and not '+Math.ceil(sec80)+'s, though the heal stops at '+r80+' in '+sec80.toFixed(2)+' seconds');
       // A second into it, the ring over his head is as full as the part of the heal that has arrived.
       for(i=0;i<20&&p.healQ>0;i++) tickHeal(0.05);
       if(!(p.hp>80.5&&p.hp<r80-0.5&&p.healQ>0)) return skip('a second into the Bandage from 80 he was at '+p.hp+' with '+p.healQ+' queued here');
       var fillWant=(p.hp-80)/(r80-80), w81=world();
       if(w81===null||!w81.a.length) return skip('no heal ring was drawn over his head a second into the Bandage from 80 here');
       if(Math.abs(w81.a[0]-fillWant)>0.02) bad.push('a second into a Bandage from 80, at '+p.hp.toFixed(2)+' health, the ring over his head was '+Math.round(w81.a[0]*100)+' percent full and not the '+Math.round(fillWant*100)+' percent of the heal that has arrived');
       // CONTROL: the heal really stops at the reach the block, the line and the ring were measured against.
       if(Math.abs(drain(0)-r80)>0.01) return skip('the Bandage from 80 ended at '+p.hp+', not at its reach of '+r80);
       // A Bandage over the last of a Medkit: the block ends at 85 plus what the Medkit had left, where the heal stops.
       fresh(30); applyHeal('medkit'); drain(1.5);
       var mr=p.healQ, mh=p.hp;
       if(!(mr>0&&mr<=1.5&&mh>lo-aB+1&&mh<lo-1)) return skip('the Medkit from 30 did not leave a little of itself between '+(lo-aB+1)+' and '+(lo-1)+' here (left '+mr+' at '+mh+')');
       land();
       var rm=healReach(p), bm=block();
       if(!(rm<mh+p.healQ-0.5)) return skip('a Bandage over the last of a Medkit reaches '+rm+' here, all that is queued, so there is nothing to overdraw');
       if(bm===null) return skip('the drawn HUD painted no incoming heal block for a Bandage over a Medkit here');
       if(Math.abs(bm-360*(rm-mh)/top)>0.05) bad.push('a Bandage put on with '+mr.toFixed(2)+' of a Medkit left at '+mh.toFixed(2)+' health drew the green block out to '+(mh+bm*top/360).toFixed(1)+', while the heal stops at '+rm.toFixed(2));
       if(Math.abs(drain(0)-rm)>0.01) return skip('the Bandage over the last of a Medkit ended at '+p.hp+', not at its reach of '+rm);
       // CONTROL, HEAL CEILINGS OFF: a Bandage from 80 still draws its whole amount and runs to 80 plus the Bandage.
       CFG.healCaps=0;
       fresh(80); land();
       var r0=healReach(p), b0=block();
       if(Math.abs(r0-Math.min(top,80+aB))>0.01) return skip('with the heal ceilings off a Bandage from 80 reaches '+r0+' here');
       if(b0===null||Math.abs(b0-360*(r0-80)/top)>0.05) bad.push('with the heal ceilings off a Bandage landing at 80 drew the green block '+b0+' wide and not '+(360*(r0-80)/top));
       if(Math.abs(drain(0)-r0)>0.01) bad.push('with the heal ceilings off a Bandage from 80 ended at '+p.hp.toFixed(2)+' and not '+r0);
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       CFG.healCaps=keepCaps;
       try{ if(realFR){ if(ownFR) ctx.fillRect=realFR; else delete ctx.fillRect; } }catch(_r){}
       try{ if(realFT){ if(ownFT) wc.fillText=realFT; else delete wc.fillText; } }catch(_t){}
       try{ if(realArc){ if(ownArc) wc.arc=realArc; else delete wc.arc; } }catch(_a){}
       try{ if(p&&keep){ for(var kk in keep) p[kk]=keep[kk]; } }catch(_k){}
       try{ window.__lastSay=null; }catch(_s){}
       try{ if(g&&!g.over) __endRaid('abandon'); }catch(_e){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'15.39',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
