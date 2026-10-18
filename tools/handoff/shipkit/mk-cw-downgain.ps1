# cw-downgain: his words (2026-10-18) on the downed bar: "the active downed system should show you the increase in time when you hit it successfully,
# e.g. +1 second -- or whatever" and "maybe it should give player a half second back, and players clock should include 2 decimals so that it is shown to run down".
$g=[IO.File]::ReadAllText('C:\claudecode\dark raiders\dark_raiders.html')
function L([string]$rx){ $m=[regex]::Matches($g,$rx); if($m.Count -ne 1){ throw "anchor $rx matched $($m.Count)" }; return $m[0].Value.Replace("`r",'') }
function NoCR([string]$s){ return $s.Replace("`r",'') }
$aVars=L "var DB_ZA=0\.40, DB_ZB=0\.60, DB_PASS=1\.0, DB_STEADY=1\.2, DB_LOCK=0\.3, DB_RATE=0\.5, DB_DRAWS=0;"
$aTick=L "(?s)function downBarTick\(p,dt\)\{\n.*?\n  return true;\n\}\n"
$aSt=L "  f=downBarPos\(p\.dbT\); inz=\(f>=DB_ZA&&f<=DB_ZB\); lk=\(p\.dbLock>0\); st=\(p\.dbSteady>0\);"
$aZone=L "  ctx\.fillStyle=lk\?'rgba\(150,40,32,\.60\)':\(inz\?'rgb\(255,150,138\)':'rgb\(232,58,44\)'\);\n  if\(inz&&!lk\)\{ ctx\.shadowColor='rgba\(255,90,70,\.95\)'; ctx\.shadowBlur=9; \}"
$aSteady=L "  if\(st\)\{ ctx\.font=FS\(TYPE\.label\); ctx\.textAlign='center'; ctx\.fillStyle='#9fe8b0'; ctx\.fillText\('STEADY',cx,y0-10\); \}"
$aBleed=L "  var _ds=\(p\.dbSteady>0\)\?Math\.min\(dt,p\.dbSteady\):0;[^\n]*\n  if\(_ds>0\) p\.dbSteady-=_ds;\n  p\.downT-=\(dt-_ds\)\+_ds\*DB_RATE;"
$aClock=L "    ctx\.font=_fD; ctx\.fillStyle='#ffb0a0';\n    ctx\.fillText\(Math\.max\(0,Math\.ceil\(p\.downT\)\)\+'s',W/2\+130,_barY\+9\);"
$aUp=L "  if\(p\.dbOn\)\{ p\.dbOn=0; p\.dbSteady=0; p\.dbLock=0; \}"

$rVars=NoCR @'
// cw-downgain, HIS WORDS (2026-10-18): "the active downed system should show you the increase in time when you hit it successfully, e.g. +1 second -- or
// whatever" and "maybe it should give player a half second back, and players clock should include 2 decimals so that it is shown to run down". A HIT now
// gives DB_GAIN (half a second) back to the bleed-out clock at once, in place of the slow bleed above, and a green +0.50s rises over the bar for DB_POP
// seconds while the clock flashes green. ONE HIT A PASS: after a hit the spot turns green and is spent until the slider leaves it, so a burst of clicks
// inside one pass gives one half second (a press in a spent spot does nothing, it is not a miss). The slider crosses the spot once a second, so a hit on
// every pass bleeds at half speed, the same best case as the slow bleed it replaces. The clock under DOWN shows two decimals.
var DB_ZA=0.40, DB_ZB=0.60, DB_PASS=1.0, DB_GAIN=0.5, DB_POP=0.8, DB_LOCK=0.3, DB_DRAWS=0;
'@
$rTick=NoCR @'
function downBarTick(p,dt){
  var dn=!!mouse.down, press, f;
  if(!G||G.sim||G.over||!p||!p.downed){ if(p&&p.dbOn) p.dbOn=0; return false; }
  if(p.dbOn!==1){ p.dbOn=1; p.dbT=0; p.dbSpent=0; p.dbLock=0; p.dbFlash=0; p.dbPulse=0; p.dbGain=0; p.dbGainT=0; p.dbPrev=dn; }   // a trigger already held as he fell is not a press
  p.dbT+=dt;
  if(p.dbLock>0) p.dbLock=Math.max(0,p.dbLock-dt);
  if(p.dbFlash>0) p.dbFlash=Math.max(0,p.dbFlash-dt);
  if(p.dbPulse>0) p.dbPulse=Math.max(0,p.dbPulse-dt);
  if(p.dbGainT>0) p.dbGainT=Math.max(0,p.dbGainT-dt);
  f=downBarPos(p.dbT);
  if(f<DB_ZA||f>DB_ZB) p.dbSpent=0;   // cw-downgain: out of the spot, the next pass may score again
  press=dn&&!p.dbPrev; p.dbPrev=dn;
  if(!press||p.dbLock>0) return false;
  if(f<DB_ZA||f>DB_ZB){ p.dbLock=DB_LOCK; p.dbFlash=DB_LOCK; try{ blip('arMiss'); }catch(_dm){} return false; }
  if(p.dbSpent) return false;   // cw-downgain: one hit a pass
  p.dbSpent=1; p.downT+=DB_GAIN; p.dbGain=DB_GAIN; p.dbGainT=DB_POP; p.dbPulse=0.25;
  try{ blip('arHit'); }catch(_dh){}
  return true;
}

'@
$rSt=NoCR @'
  f=downBarPos(p.dbT); inz=(f>=DB_ZA&&f<=DB_ZB); lk=(p.dbLock>0); st=!!(p.dbSpent&&inz);   // cw-downgain: st is a spot already scored this pass
'@
$rZone=NoCR @'
  ctx.fillStyle=lk?'rgba(150,40,32,.60)':(st?'rgb(110,196,132)':(inz?'rgb(255,150,138)':'rgb(232,58,44)'));
  if(inz&&!lk){ ctx.shadowColor=st?'rgba(110,220,140,.9)':'rgba(255,90,70,.95)'; ctx.shadowBlur=9; }
'@
$rSteady=NoCR @'
  if(p.dbGainT>0){   // cw-downgain: the time a hit gave back rises over the bar and fades
    var _gk=p.dbGainT/DB_POP; ctx.font=FS(TYPE.head); ctx.textAlign='center'; ctx.globalAlpha=Math.min(1,_gk*2); ctx.fillStyle='#9fe8b0';
    ctx.fillText('+'+(+p.dbGain||0).toFixed(2)+'s',cx,Math.round(y0-10-(1-_gk)*14)); ctx.globalAlpha=1;
  }
'@
$rBleed=NoCR @'
  p.downT-=dt;   // cw-downgain: a hit on the downed bar gives time back at once (downBarTick); there is no slow bleed any more
'@
$rClock=NoCR @'
    // cw-downgain, HIS WORDS (2026-10-18): "players clock should include 2 decimals so that it is shown to run down". Left aligned so the digits do not
    // push into the bar as they change, and green while a hit's +0.50s shows.
    ctx.font=_fD; ctx.fillStyle=(p.dbGainT>DB_POP*0.5)?'#9fe8b0':'#ffb0a0'; ctx.textAlign='left';
    ctx.fillText(Math.max(0,p.downT).toFixed(2)+'s',W/2+110,_barY+9); ctx.textAlign='center';
'@
$rUp='  if(p.dbOn){ p.dbOn=0; p.dbSpent=0; p.dbLock=0; p.dbGainT=0; }'

$chk=@'
  {v:'VER',what:'cw-downgain, his words on the downed bar: a hit gives half a second back at once with +0.50s shown, one hit a pass, the clock shows two decimals, a miss locks the trigger, a held trigger and a standing player do nothing',
   run:function(){
     if(typeof downBarTick!=='function'||typeof downBarPos!=='function') return 'no downed bar in this build (downBarTick is missing)';
     var bad=[], g, p, md=mouse.down, a, d, i, txt, proto=CanvasRenderingContext2D.prototype, oFt=proto.fillText;
     function stage(){ __resetCfg(); __pinDefaults(0); __deploy({kit:[],safe:null,mapIx:0,seed:4242}); g=__state(); p=g.player; g.ents.length=0;
       p.hp=0; p.downed=true; p.downT=60; p.revived=1; p.iv=99; p.pendKiller=null; p.dbOn=0; p.dbLock=0; mouse.down=false; }
     function step(down,at){ if(at!==undefined) p.dbT=at-0.1; mouse.down=down; a=p.downT; __sim(0.1); return p.downT-a; }   // the change of the clock over 0.1 s
     function near(x,y){ return Math.abs(x-y)<0.03; }
     try{
       stage();
       d=step(false);
       if(!near(d,-0.1)) return 'a downed player does not bleed 0.1 s in 0.1 s ('+d.toFixed(3)+')';
       // ONE: a HIT gives half a second back at once and shows it
       d=step(true,0.45);
       if(!near(d,0.4)) bad.push('ONE: a hit moved the clock by '+d.toFixed(3)+' s in 0.1 s, not +0.4 (half a second back less the 0.1 s bled)');
       if(!(p.dbGainT>0)) bad.push('ONE: a hit shows no +0.50s');
       for(i=0;i<3;i++){ d=step(false); if(!near(d,-0.1)) { bad.push('ONE: after the hit the clock ran '+d.toFixed(3)+' s in 0.1 s, not -0.1 (no slow bleed)'); break; } }
       // TWO: one hit a pass; out of the spot and back it scores again
       stage(); step(false); step(true,0.45); step(false,0.5);
       d=step(true,0.55);
       if(!near(d,-0.1)) bad.push('TWO: a second press inside the same pass moved the clock by '+d.toFixed(3)+', it should give nothing');
       if(p.dbLock>0) bad.push('TWO: a second press inside a scored spot counted as a miss');
       step(false,0.85); d=step(true,0.45);
       if(!near(d,0.4)) bad.push('TWO: the next pass did not score again ('+d.toFixed(3)+')');
       // THREE: a MISS gives nothing and locks the trigger for a moment
       stage(); step(false);
       d=step(true,0.15);
       if(!near(d,-0.1)) bad.push('THREE: a press outside the middle moved the clock by '+d.toFixed(3));
       if(!(p.dbLock>0)) bad.push('THREE: a miss did not lock the trigger');
       step(false); d=step(true,0.45);
       if(!near(d,-0.1)) bad.push('THREE: a press in the middle during the lockout still counted');
       step(false); d=step(true,0.45);
       if(!near(d,0.4)) bad.push('THREE: the trigger stayed dead after the lockout');
       // FOUR: a HELD trigger as he fell is not a press
       stage(); mouse.down=true; step(true);
       d=step(true,0.45);
       if(!near(d,-0.1)||p.dbLock>0) bad.push('FOUR: a trigger held down as he fell counted as a press');
       step(false); d=step(true,0.45);
       if(!near(d,0.4)) bad.push('FOUR: letting go and pulling again did not count');
       // FIVE: on his feet the bar goes, and a press while standing does nothing
       step(false); p.downed=false; p.hp=40; __sim(0.1);
       if(p.dbOn) bad.push('FIVE: the bar state outlived the revive');
       stage(); p.downed=false; p.hp=100; p.dbT=0.45; mouse.down=true; a=p.downT;
       downBarTick(p,0.1);
       if(p.dbOn===1||p.dbLock>0||p.downT!==a) bad.push('FIVE: a press while standing woke the downed bar');
       // SIX: on a real frame the clock under DOWN has two decimals and a fresh hit draws +0.50s
       if(typeof __vpAlive!=='function'||__vpAlive()){
         stage(); step(false); step(true,0.45); mouse.down=false; txt=[];
         proto.fillText=function(){ txt.push(String(arguments[0])); return oFt.apply(this,arguments); };
         try{ for(i=0;i<3;i++) __loop(performance.now()+i*17); } finally { proto.fillText=oFt; }
         if(!txt.some(function(s){ return /^\d+\.\d\ds$/.test(s); })) bad.push('SIX: the downed clock does not show two decimals ('+txt.filter(function(s){ return /\ds$/.test(s); }).slice(0,4).join(', ')+')');
         if(txt.indexOf('+0.50s')<0) bad.push('SIX: a hit did not draw +0.50s');
       }
       return bad.length?bad.join('; '):null;
     } finally { proto.fillText=oFt; mouse.down=md; try{ __endRaid('abandon'); }catch(_e){} __topClear(); } }},
'@.Replace("`r",'')
$d=[ordered]@{
  title='the downed bar gives half a second back per hit and shows it; the bleed clock has two decimals'
  why='His words (2026-10-18): "the active downed system should show you the increase in time when you hit it successfully, e.g. +1 second -- or whatever" and "maybe it should give player a half second back, and players clock should include 2 decimals so that it is shown to run down". A hit on the downed bar used to halve the bleed for 1.2 s, which showed nothing but a STEADY tag. Now a hit adds half a second to the clock at once and a green +0.50s rises over the bar while the clock flashes green. One hit a pass (the spot turns green until the slider leaves it), so spamming clicks inside the spot gives one half second; a hit on every pass is the same best case as before (half speed). The clock under DOWN reads like 14.37s.'
  now='Downed: a good hit on the bar gives half a second back and shows +0.50s. The bleed clock counts down in hundredths.'
  edits=@(
    [ordered]@{ anchor=$aVars; replacement=$rVars.TrimEnd("`n") },
    [ordered]@{ anchor=$aTick; replacement=$rTick },
    [ordered]@{ anchor=$aSt; replacement=$rSt.TrimEnd("`n") },
    [ordered]@{ anchor=$aZone; replacement=$rZone.TrimEnd("`n") },
    [ordered]@{ anchor=$aSteady; replacement=$rSteady.TrimEnd("`n") },
    [ordered]@{ anchor=$aBleed; replacement=$rBleed.TrimEnd("`n") },
    [ordered]@{ anchor=$aClock; replacement=$rClock.TrimEnd("`n") },
    [ordered]@{ anchor=$aUp; replacement=$rUp }
  )
  check=$chk
}
[IO.File]::WriteAllText('C:\claudecode\dark raiders\tools\handoff\drafts\draft-cw-downgain.json',($d | ConvertTo-Json -Depth 6),(New-Object Text.UTF8Encoding $false))
'written'
