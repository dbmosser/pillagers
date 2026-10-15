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

if ($s.Contains("  {v:'27.95',what:")) { throw "check 27.95 is in the fixture already" }

SubRx @'
  {v:'27.94',what:
'@ @'
  {v:'27.95',what:'his order (add the sounds): the gun moments have sounds: a press in the active reload sweet spot plays arHit and one outside it arMiss (the press that starts a reload and a reload with no press play neither), the Support MG spin plays lmgSpinUp once when the trigger starts it and keeps a handle lmgWhirrStop cuts, letting go plays lmgWindDown once, and the finisher plays finishBlow',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__sim)) return 'SKIP: no raid here';
     if(typeof spkPlay!=='function') return 'the sound pack is not in this build (no spkPlay)';
     var bad=[], g, p, all, oWep, oAmmo, oRes, oIv, rb=blip, rx=sfx, rk=spkPlay, rbm=blipMine, own=false, heard=[], spk=[], stops=0, tot, up, wd, cr, i;
     function cnt(n){ return heard.filter(function(h){ return h===n; }).length; }
     function sp(n){ return spk.filter(function(s){ return s[0]===n; }); }
     function press(){ keys['KeyR']=true; __sim(0.016); keys['KeyR']=false; __sim(0.001); }
     function start(){ p.ammo=2; p.reserve=60; p.reloading=0; p.arBonus=0; p.rlTot=0; p.hand=false; press(); }
     function runTo(fr){ var q=0; while(p.reloading>0&&(1-p.reloading/tot)<fr&&q<400){ __sim(0.016); q++; } }
     function arm(w,a){ mouse.down=false; p.wep=w; p.ammo=a; p.reserve=300; p.reloading=0; p.hand=false; p.jam=0; p.fired=false; p.spin=0; g.t+=0.016; __sim(0.016); for(var q=0;q<260&&p.drawT>0;q++){ g.t+=0.016; __sim(0.016); } p.fired=false; p.spin=0; }
     function step(n){ for(var q=0;q<n;q++){ g.t+=0.016; __sim(0.016); } }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       if(g.sim) return 'SKIP: the fixture raid is a sim raid';
       p=g.player; all=g.ents.slice(); g.ents=[]; oWep=p.wep; oAmmo=p.ammo; oRes=p.reserve; oIv=p.iv; p.iv=99; keys['KeyR']=false;
       blip=function(t){ heard.push(String(t)); }; sfx=function(t){ heard.push('s:'+String(t)); }; blipMine=function(){}; own=true;
       spkPlay=function(nm,o){ spk.push([nm,o&&o.wid]); return {g:{gain:{value:1,cancelScheduledValues:function(){},setValueAtTime:function(){},linearRampToValueAtTime:function(){}}},o:{stop:function(){ stops++; }}}; };
       // ONE: the active reload
       p.wep=cloneObj(WEAPONS.pistol); tot=p.wep.reload*buzzSlow();
       heard.length=0; start(); if(!(p.reloading>0)) return 'SKIP: staging: R did not start a reload';
       if(cnt('arMiss')||cnt('arHit')) bad.push('ONE: the press that starts a reload played an active reload sound');
       runTo(0.5);
       if(!(p.reloading>0)) bad.push('ONE: the reload ended before the sweet spot');
       if(cnt('arMiss')||cnt('arHit')) bad.push('ONE: a reload with no press played an active reload sound');
       keys['KeyR']=true; __sim(0.016); keys['KeyR']=false;
       if(cnt('arHit')!==1) bad.push('ONE: R inside the sweet spot played arHit '+cnt('arHit')+' times, not once');
       if(cnt('arMiss')) bad.push('ONE: a hit also played arMiss');
       // TWO: a press before the window, a press after it: arMiss each time, the reload goes on
       i=0; while(p.reloading>0&&i<400){ __sim(0.016); i++; }
       heard.length=0; start(); runTo(0.12); heard.length=0; press();
       if(cnt('arMiss')!==1||cnt('arHit')) bad.push('TWO: R before the window played arMiss '+cnt('arMiss')+' and arHit '+cnt('arHit'));
       runTo(0.8); heard.length=0; press();
       if(cnt('arMiss')!==1||cnt('arHit')) bad.push('TWO: R after the window played arMiss '+cnt('arMiss')+' and arHit '+cnt('arHit'));
       i=0; while(p.reloading>0&&i<400){ __sim(0.016); i++; }
       // THREE: the Support MG spin
       spk.length=0; stops=0; arm(cloneObj(WEAPONS.lmg),60); p.iv=99;
       mouse.down=true; step(8);
       up=sp('lmgSpinUp');
       if(up.length!==1) bad.push('THREE: the spin up played lmgSpinUp '+up.length+' times, not once');
       else if(!(up[0][1]>=0&&up[0][1]<0.35)) bad.push('THREE: the spin up starts from spin '+up[0][1]);
       if(!(LMGSPIN.hum&&LMGSPIN.hum.g&&LMGSPIN.hum.g.gain&&LMGSPIN.hum.o&&typeof LMGSPIN.hum.o.stop==='function')) bad.push('THREE: the spin sound handle is not kept for lmgWhirrStop');
       if(sp('lmgWindDown').length) bad.push('THREE: the wind down played while the trigger was held');
       step(50);
       if(sp('lmgSpinUp').length!==1) bad.push('THREE: the spin up played again while the trigger was held ('+sp('lmgSpinUp').length+')');
       mouse.down=false; step(3);
       wd=sp('lmgWindDown');
       if(wd.length!==1) bad.push('THREE: letting go played lmgWindDown '+wd.length+' times, not once');
       else if(!(wd[0][1]>0.7)) bad.push('THREE: the wind down starts from spin '+wd[0][1]+', not from the full spin it was let go at');
       if(stops<1) bad.push('THREE: letting go did not cut the spin sound (lmgWhirrStop)');
       if(LMGSPIN.hum) bad.push('THREE: the spin handle is kept after the trigger is let go');
       step(60);
       if(sp('lmgWindDown').length!==1) bad.push('THREE: the wind down played again after it ('+sp('lmgWindDown').length+')');
       // FOUR: the finisher
       cr=mkCrawler(p.x+40,p.y); g.ents=[cr]; heard.length=0; finishHim(p,cr);
       if(cnt('s:finishBlow')!==1) bad.push('FOUR: the finisher played finishBlow '+cnt('s:finishBlow')+' times, not once ('+heard.join(',')+')');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       if(own){ blip=rb; sfx=rx; spkPlay=rk; blipMine=rbm; }
       try{ mouse.down=false; keys['KeyR']=false; if(p){ p.wep=oWep; p.ammo=oAmmo; p.reserve=oRes; p.spin=0; p.fired=false; p.iv=oIv; p.reloading=0; p.arBonus=0; } if(g&&all) g.ents=all.slice(); if(g) g.bullets.length=0; if(typeof lmgWhirrStop==='function') lmgWhirrStop(); }catch(_h){}
       try{ var g2=__state(); if(g2&&!g2.over) __endRaid('abandon'); }catch(_e){}
       __topClear();
     }
     return bad.length?bad.slice(0,8).join('; '):null; }},
  {v:'27.94',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
