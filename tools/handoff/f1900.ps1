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

if ($s.Contains("  {v:'19.00',what:")) { throw "check 19.00 is in the fixture already" }

SubRx @'
  {v:'18.99',what:
'@ @'
  {v:'19.00',what:'the status effects sit down the left side, his notes of 2026-10-07: with nothing running no status ring is drawn there; a Stim with 6 of its 10 seconds left draws a STIM icon on the left with its ring 60 percent lit and 6s beside it; a Bandage put on at 50 draws a HEALING icon on the left, clear of the pillager board and the controls, its ring lit for the share of the heal still to come and its seconds beside it, and from 80 the same counts to the Bandage stop at 85; the green heal ring over his head is gone, and the dial that keeps it for the older check still brings it back',
 run:function(){
   if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__frame)) return 'SKIP: this fixture cannot deploy';
   if(typeof tickPrepSlot!=='function'||typeof tickHeal!=='function'||typeof healReach!=='function'||typeof healCeil!=='function'||!ITEMS.bandage||typeof STIM_SEC!=='number') return 'SKIP: no heal over time or Stim in this build';
   if(typeof ctx==='undefined'||typeof wc==='undefined'||!ctx||!wc||ctx===wc) return 'SKIP: the HUD and the world do not draw on two canvases here';
   if(!(W>400&&H>300)) return 'SKIP: the pane has no layout';
   var bad=[], g=null, p=null, keep=null, keepBuzz, hadBuzz=false, buzzTaken=false, hooked=false, i, k, left, tot, sec, A, T, LB, RB, yMax=H;
   var OWN=Object.prototype.hasOwnProperty, realFT=ctx.fillText, realArc=ctx.arc, realWArc=wc.arc, ownFT=OWN.call(ctx,'fillText'), ownArc=OWN.call(ctx,'arc'), ownWArc=OWN.call(wc,'arc');
   var texts=[], rings=[], head=0, HEALC='#6fe0a0', STIMC='#ffd25a';
   // A later control that cannot run keeps a failure already found, so the old build fails rather than skips.
   var skip=function(m){ return bad.length?(bad.join('; ')+' (then SKIP: '+m+')'):('SKIP: '+m); };
   // Where a call lands on the screen in CSS pixels, through whatever transform the HUD had on when it was made.
   function scr(c,x,y){ var m=null, d=(typeof DPR==='number'&&DPR>0)?DPR:1; try{ m=c.getTransform(); }catch(_m){ m=null; } if(!m) return {x:x,y:y}; return {x:(m.a*x+m.c*y+m.e)/d,y:(m.b*x+m.d*y+m.f)/d}; }
   // The left quarter of the screen from 35 percent of its height down to the vitals: where the column goes, and not the posture chip.
   function inCol(q){ return q.x>=0&&q.x<W*0.25&&q.y>H*0.35&&q.y<yMax; }
   function frame(){ texts.length=0; rings.length=0; head=0; try{ __frame(0.001); }catch(_f){ return false; } return true; }
   function ring(c){ for(var q=0;q<rings.length;q++) if(rings[q].c===c) return rings[q]; return null; }
   function textAt(s){ for(var q=0;q<texts.length;q++) if(texts[q].s===s) return texts[q]; return null; }
   function fresh(hp){ p.hp=hp; p.hpGhost=hp; p.healQ=0; p.healRate=0; p.healCap=undefined; p.healHi=0; p.healLo=undefined; p.healAmt0=0; p.prep=null; p.prepA=null; p.stimT=0; p.combatT=0; }
   // A Bandage finishing its application the way F and the belt land one.
   function land(){ p.prep={t:9,max:1,kind:'heal',key:'bandage'}; tickPrepSlot(p,'prep',0.016); }
   try{
     __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
     delete CFG.healRingHead;
     __deploy({kit:[],safe:null,mapIx:0,seed:4242});
     g=__state(); if(!g||!g.player||g.sim) return 'SKIP: no live raid';
     p=g.player; g.bagOpen=false; g.mapOpen=false;
     keep={hp:p.hp,hpGhost:p.hpGhost,healQ:p.healQ,healRate:p.healRate,healCap:p.healCap,healHi:p.healHi,healLo:p.healLo,healAmt0:p.healAmt0,prep:p.prep,prepA:p.prepA,downed:p.downed,roll:p.roll,stimT:p.stimT,stam:p.stam,stamLock:p.stamLock,stamRelease:p.stamRelease,combatT:p.combatT};
     // OWN PRECONDITIONS: a drink left in the profile is not this check's to inherit.
     if(P){ hadBuzz=OWN.call(P,'buzz'); keepBuzz=P.buzz; buzzTaken=true; P.buzz=[]; }
     p.downed=false; p.roll=0; p.stam=100; p.stamLock=0; p.stamRelease=0;
     hooked=true;
     ctx.fillText=function(s,x,y){ var q=scr(this,x,y); if(inCol(q)) texts.push({s:String(s),x:q.x,y:q.y}); return realFT.apply(this,arguments); };
     ctx.arc=function(x,y,r,a0,a1){ if(a0===-1.5708){ var q=scr(this,x,y); if(inCol(q)) rings.push({c:String(this.strokeStyle).toLowerCase(),x:q.x,y:q.y,f:(a1-a0)/6.2832}); } return realArc.apply(this,arguments); };
     wc.arc=function(x,y,r,a0,a1){ if(r===9&&a0===-1.5708&&String(this.strokeStyle).toLowerCase()==='#7fc4a0') head++; return realWArc.apply(this,arguments); };
     // CONTROL, NOTHING RUNNING: no Stim and no heal ring on the left, on either build.
     fresh(100);
     if(!frame()) return 'SKIP: drawing a frame threw here';
     if(ring(STIMC)||ring(HEALC)) bad.push('control: with no Stim and no heal running a status ring was drawn on the left');
     if(typeof HUDBOX!=='undefined'&&HUDBOX.body&&HUDBOX.body.y>H*0.5) yMax=HUDBOX.body.y;   // the posture chip and the vitals are not the column
     // A STIM WITH 6 OF ITS SECONDS LEFT.
     fresh(100); p.stimT=6;
     if(!frame()) return skip('drawing a frame with a Stim running threw here');
     A=ring(STIMC);
     if(!A) bad.push('a Stim with 6 of its '+STIM_SEC+' seconds left drew no STIM ring on the left of the HUD');
     else if(Math.abs(A.f-6/STIM_SEC)>0.02) bad.push('the STIM ring was '+Math.round(A.f*100)+' percent lit with 6 of '+STIM_SEC+' seconds left');
     if(!textAt('STIM')) bad.push('no STIM name was written beside the Stim icon on the left');
     if(!textAt('6s')) bad.push('the Stim icon on the left did not say 6s with six seconds left');
     // A BANDAGE FROM 50, A SECOND IN: the whole Bandage fits below 85.
     fresh(50); land();
     if(!(p.healQ>0&&p.healRate>0)) return skip('a Bandage landed at once rather than over time here');
     for(i=0;i<20&&p.healQ>0;i++) tickHeal(0.05);
     left=Math.max(0,healReach(p)-p.hp); tot=p.healAmt0||0;
     if(!(left>0.5&&tot>0&&left<tot-0.5)) return skip('a second into a Bandage from 50 he had '+left+' of '+tot+' still to come here');
     sec=Math.ceil(left/p.healRate); p.combatT=0;
     if(!frame()) return skip('drawing a frame with a Bandage running threw here');
     A=ring(HEALC); T=textAt(sec+'s');
     if(!A) bad.push('a Bandage healing him ('+left.toFixed(1)+' of '+tot+' still to come) drew no HEALING ring on the left of the HUD');
     else if(Math.abs(A.f-left/tot)>0.02) bad.push('the HEALING ring was '+Math.round(A.f*100)+' percent lit with '+Math.round(left/tot*100)+' percent of the heal still to come');
     if(!T) bad.push('the healing icon on the left did not say '+sec+'s with '+(left/p.healRate).toFixed(2)+' seconds of heal left');
     LB=(typeof HUDBOX!=='undefined')?HUDBOX.legend:null; RB=(typeof HUDBOX!=='undefined')?HUDBOX.raiders:null;
     if(A&&LB&&A.x>=LB.x&&A.x<=LB.x+LB.w&&A.y>=LB.y&&A.y<=LB.y+LB.h) bad.push('the HEALING icon is drawn on the controls legend');
     if(A&&RB&&A.x>=RB.x&&A.x<=RB.x+RB.w&&A.y>=RB.y&&A.y<=RB.y+RB.h) bad.push('the HEALING icon is drawn on the pillager board');
     if(head) bad.push('the green heal ring is still drawn over his head ('+head+' arcs), where his note moves it to the left');
     // CONTROL FOR THE RING READ: the dial that check 15.40 sets brings the old ring back, so a zero above is the ring gone, not a blind hook.
     CFG.healRingHead=1;
     if(!frame()) return skip('drawing a frame with the head ring dial on threw here');
     if(!head) bad.push('with CFG.healRingHead 1 no heal ring was drawn over his head, so check 15.40 cannot read it');
     delete CFG.healRingHead;
     // FROM 80 THE BANDAGE STOPS AT 85 (his ruling of 2026-09-16): the ring and the seconds count to 85, not to 80 plus the Bandage.
     fresh(80); land();
     if(!(p.healQ>0&&p.healRate>0)) return skip('a Bandage from 80 landed at once rather than over time here');
     for(i=0;i<4&&p.healQ>0;i++) tickHeal(0.05);
     left=Math.max(0,healReach(p)-p.hp); tot=p.healAmt0||0;
     if(!(Math.abs(healReach(p)-healCeil(ITEMS.bandage))<0.01&&left>0.2&&tot>0&&left<tot-0.2)) return skip('a Bandage from 80 reaches '+healReach(p)+' with '+left+' of '+tot+' still to come here, not a part run to the Bandage ceiling');
     sec=Math.ceil(left/p.healRate); p.combatT=0;
     if(!frame()) return skip('drawing a frame with a Bandage from 80 running threw here');
     A=ring(HEALC);
     if(!A) bad.push('a Bandage from 80 drew no HEALING ring on the left');
     else if(Math.abs(A.f-left/tot)>0.02) bad.push('a Bandage from 80 lit its HEALING ring '+Math.round(A.f*100)+' percent, not the '+Math.round(left/tot*100)+' percent still to come up to '+Math.round(healReach(p)));
     if(!textAt(sec+'s')) bad.push('a Bandage from 80 did not say '+sec+'s on the left, the seconds to its stop at '+Math.round(healReach(p)));
   }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
   finally{
     try{ if(hooked){ if(ownFT) ctx.fillText=realFT; else delete ctx.fillText; if(ctx.fillText!==realFT) ctx.fillText=realFT; } }catch(_t){}
     try{ if(hooked){ if(ownArc) ctx.arc=realArc; else delete ctx.arc; if(ctx.arc!==realArc) ctx.arc=realArc; } }catch(_a){}
     try{ if(hooked){ if(ownWArc) wc.arc=realWArc; else delete wc.arc; if(wc.arc!==realWArc) wc.arc=realWArc; } }catch(_w){}
     try{ delete CFG.healRingHead; }catch(_d){}
     try{ if(P&&buzzTaken){ if(hadBuzz) P.buzz=keepBuzz; else delete P.buzz; } }catch(_b){}
     try{ if(p&&keep){ for(k in keep) p[k]=keep[k]; } }catch(_p){}
     try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
     try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
   }
   return bad.length?bad.join('; '):null; }},
  {v:'18.99',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
