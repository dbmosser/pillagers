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

if ($s.Contains("  {v:'35.36',what:")) { throw "check 35.36 is in the fixture already" }

SubRx @'
  {v:'35.35',what:
'@ @'
  {v:'35.36',what:'cw-quiethud (his order of 10-27, build the quiet hud, changes 2 3 4): in a raid the corner wallet card is gone and the backpack value draws once, the posture word shows only crouched, the stamina bar only below full and it fades, run info folds to its count and opens when a contract moves (its arrow opens it for good), and the belt caption is gone while the ammo card names the gun',
   run:function(){
     var bad=[], g, p, PR=CanvasRenderingContext2D.prototype, ot=PR.fillText, rec=[], oldC=P.contracts, oldHud=P.hud?JSON.parse(JSON.stringify(P.hud)):null, rb=drawRaiderBoard, v, vs, hits, t, k, tg, CRAWL='destroy 5 crawlers';
     function grab(){ rec=[]; PR.fillText=function(s,x,y){ rec.push({s:String(s),lo:String(s).toLowerCase(),a:this.globalAlpha}); return ot.apply(this,arguments); }; try{ __frame(0.016); } finally { PR.fillText=ot; } }
     function has(lo){ return rec.some(function(r){ return r.lo===lo; }); }
     function hasIn(sub){ return rec.filter(function(r){ return r.lo.indexOf(sub)>=0; }); }
     function spin(ms){ var t0=performance.now(); while(performance.now()-t0<ms){} }
     function tap(b){ mouse.x=b.x+b.w/2; mouse.y=b.y+b.h/2; cv.dispatchEvent(new MouseEvent('mousedown',{button:0,bubbles:true})); window.dispatchEvent(new MouseEvent('mouseup',{button:0,bubbles:true})); mouse.down=false; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:['gun_carbine','medkit','medkit','bandage'],safe:null,mapIx:0,seed:4242});
       g=__state();
       if(state!=='raid'||!g||g.over) throw new Error('no live raid to test on');
       g.mapFirst=0; g.mapOpen=false; g.bagOpen=false; if(pauseOpen) togglePauseBox(false);
       p=g.player; keys={}; mouse.down=false; p.hand=null; g.wheel=null; g.drag=null; p.ads=false; p.reloading=0; p.jam=0; p.stam=100; p.stamLock=0; p.stimT=0; g.pCrouch=false; g.sprinting=false;
       P.contracts=[{type:'kill',tgt:'crawler',n:5,prog:1,reward:450,desc:CRAWL,tier:'std'},{type:'conduct',ck:'elite',n:1,prog:0,reward:450,desc:'kill an elite',tier:'std'},{type:'kill',tgt:'sentry',n:2,prog:2,reward:450,desc:'destroy 2 sentries',tier:'std'}];
       P.hud=P.hud||{}; P.hud.cond={};
       drawRaiderBoard=function(){};   // the pillager board is a ranking and keeps its own copy of the backpack value and its status words: left out of the counts
       syncTopRight(); grab(); spin(30); grab();
       // ONE: the corner wallet card draws nothing in a raid, and its page copy stays clipped away
       ['cash','stash','xp'].forEach(function(w){ if(has(w)) bad.push('ONE: the corner card still draws '+w); });
       trHide(); if(!document.body.classList.contains('trcol')) bad.push('ONE: the page copy of the wallet shows in the raid');
       // TWO: the backpack value draws once, on the ammo card
       v=bagValue(); if(!(v>0)) throw new Error('staging: an empty backpack');
       vs='$'+v.toLocaleString(); hits=hasIn(vs.toLowerCase());
       if(hits.length!==1) bad.push('TWO: the backpack value '+vs+' drew '+hits.length+' times: '+hits.map(function(r){ return JSON.stringify(r.s); }).join(', '));
       // THREE: standing still at full stamina, no posture word and no stamina bar
       if(has('standing')) bad.push('THREE: standing still the posture word still shows');
       if(has('stamina')||has('winded')) bad.push('THREE: at full stamina the stamina bar still shows');
       // FOUR: below full the bar fades in; full again it fades out and is gone
       p.stam=40; grab(); spin(40); grab();
       t=rec.filter(function(r){ return r.lo==='stamina'; })[0];
       if(!t||!(t.a>0)) bad.push('FOUR: below full the stamina bar does not show');
       p.stam=100; spin(60); grab();
       t=rec.filter(function(r){ return r.lo==='stamina'; })[0];
       if(!t||!(t.a>0&&t.a<1)) bad.push('FOUR: the stamina bar did not fade out (alpha '+(t?t.a:'none')+' just after it filled)');
       for(k=0;k<8;k++){ spin(90); grab(); }
       if(has('stamina')) bad.push('FOUR: the stamina bar stayed after it filled');
       // FIVE: crouched, the posture word shows
       g.pCrouch=true; grab();
       if(!has('crouched')) bad.push('FIVE: crouched, the posture word does not show');
       g.pCrouch=false;
       // SIX: run info at rest is one line, its count; a contract that moves opens it, and it folds again
       grab();
       if(!hasIn('contracts 1/3').length) bad.push('SIX: folded, the run info line is not its count (contracts 1/3)');
       if(hasIn(CRAWL).length) bad.push('SIX: at rest run info still lists its contracts');
       P.contracts[0].prog=2; grab();
       if(!hasIn(CRAWL).length) bad.push('SIX: a contract moved and run info did not open');
       if(hasIn('elite killed yet').length) bad.push('SIX: the open panel still prints the at-rest elite line');
       RIF.until=riNow()-1; grab();   // its few seconds pass
       if(hasIn(CRAWL).length) bad.push('SIX: run info did not fold again after its few seconds');
       // SEVEN: the arrow opens it for good, and folds it again
       tg=HUDBOX.cond&&HUDBOX.cond.tg; if(!tg) throw new Error('run info has no arrow');
       tap(tg); grab(); RIF.until=0; grab();
       if(!hasIn(CRAWL).length) bad.push('SEVEN: opened by its arrow, run info did not stay open');
       tg=HUDBOX.cond&&HUDBOX.cond.tg; if(tg){ tap(tg); grab(); if(hasIn(CRAWL).length) bad.push('SEVEN: its arrow did not fold it again'); }
       // EIGHT: no caption over the belt; the ammo card names the gun
       if(hasIn('[fire] use').length) bad.push('EIGHT: the caption over the belt still draws');
       if(!p.wep||!has(String(p.wep.name).toLowerCase())) bad.push('EIGHT: the ammo card does not name the gun '+(p.wep&&p.wep.name));
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       PR.fillText=ot; drawRaiderBoard=rb; P.contracts=oldC; if(oldHud) P.hud=oldHud; else delete P.hud;
       try{ if(G){ G.pCrouch=false; if(G.player){ G.player.stam=100; G.player.hand=null; } } mouse.down=false; }catch(_d){}
       try{ if(pauseOpen) togglePauseBox(false); }catch(_p){}
       try{ var K2=__keys(); for(var q2 in K2) delete K2[q2]; }catch(_k){}
       try{ if(state==='raid'&&G&&!G.over) __endRaid('abandon'); }catch(_e){}
       try{ __topClear(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'35.35',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
