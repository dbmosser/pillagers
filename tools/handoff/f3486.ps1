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

if ($s.Contains("  {v:'34.86',what:")) { throw "check 34.86 is in the fixture already" }

SubRx @'
  {v:'34.85',what:
'@ @'
  {v:'34.86',what:'cw-shdeath, his note of 2026-10-25 ("weird noise lingering", played with Superhot on): with Superhot on and no input at all, a real death (a round puts him down, rounds on the floor finish him) plays its death beat on real frames, ending in its 1.5 s with the outcome card up within 2 s and the world underwater-slow under it as if he acted, as long as with Superhot off; in a shared raid with nobody acting the beat ends the same while the party world stays still, and no death beat counts as acting (the sa flag a teammate reads); alive, Superhot still holds time still with no input and a held key still moves it',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__loop&&window.__keysRef)||typeof lastTs!=='number') return 'SKIP: this fixture cannot step a live raid frame';
     if(typeof damagePlayer!=='function'||typeof killPlayer!=='function'||typeof netUpShared!=='function'||typeof CFG!=='object'||!CFG||typeof CFG.superhot==='undefined') return 'SKIP: no superhot death to stage in this build';
     var bad=[], g=null, p=null, kTs=lastTs, kSH=CFG.superhot, kCap=CFG.fpsCap, kNUS=netUpShared, stubbed=false, r1=null, r2=null, r3=null, t0, m0, mv, i;
     function keysOff(){ var K=__keysRef(), q; for(q in K) K[q]=false; if(typeof mouse!=='undefined'&&mouse) mouse.down=false; }
     // one raid frame of 1/60 s on the real loop; hold is a key nothing else reads
     function frame(hold){ keysOff(); if(hold) __keysRef().KeyK=true; try{ __loop(lastTs+1000/60); } finally{ keysOff(); } }
     function cardOn(){ var oc=document.getElementById('outcome'); return !!(oc&&oc.classList.contains('on')); }
     function live(sh){
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); p=g&&g.player; if(!g||g.over||!p||!g.ents||g.arcade) return false;
       g.paused=false; g.mapFirst=0; g.mapOpen=false; g.bagOpen=false; p.downed=false; p.dying=false; p.roll=0; p.reloading=0; p.prep=null; p.prepA=null;
       CFG.superhot=sh; CFG.fpsCap=0; p.iv=99; frame(false);
       return !g.over&&!(g.deathBeat!==undefined&&g.deathBeat!==null);
     }
     // a real death: a round puts him down, rounds on the floor finish him (each takes 3 s off the bleed), as the game kills him
     function die(){
       var n=0; p.iv=0; damagePlayer(999,'sentry','SENTRY',p.x+120,p.y);
       while(n<40&&!(g.deathBeat>0)){ p.iv=0; damagePlayer(30,'sentry','SENTRY',p.x+120,p.y); n++; }
       return (g.deathBeat>0)&&!!p.dying&&!(p.hp>0);
     }
     // frames with no input at all until the raid is over or the outcome card is up, at most cap
     function beat(cap){
       var o={end:0,t0:g.t,sa:0}, f;
       for(f=1;f<=cap;f++){ frame(false); if(g.shAct&&!g.over) o.sa++; if(g.over||cardOn()){ o.end=f; break; } }
       o.dt=g.t-o.t0; o.db=g.deathBeat; o.over=g.over; o.card=cardOn(); return o;
     }
     function says(o){ return 'the death beat reads '+((typeof o.db==='number')?o.db.toFixed(2)+' s':String(o.db))+', the outcome card is '+(o.card?'up':'not up')+', the raid clock moved '+o.dt.toFixed(3)+' s'; }
     try{
       // ONE (control): alive, Superhot on, no input: time stands still, the raid clock and every body; then a key held moves it
       if(!live(1)) return 'SKIP: no live raid';
       t0=g.t; m0=g.ents.map(function(e){ return {e:e,x:e.x,y:e.y}; });
       for(i=0;i<30;i++) frame(false);
       mv=0; m0.forEach(function(q){ mv+=Math.abs(q.e.x-q.x)+Math.abs(q.e.y-q.y); });
       if(Math.abs(g.t-t0)>1e-9||mv>0.01) bad.push('control: alive with Superhot on and no input, time did not stand still (the raid clock moved '+(g.t-t0).toFixed(3)+' s and the bodies '+mv.toFixed(1)+' px in 0.5 s)');
       if(g.shAct) bad.push('staging: no input is held, yet this window counts as acting');
       t0=g.t; for(i=0;i<30;i++) frame(true);
       if(!(g.t-t0>0.4)) bad.push('control: alive with Superhot on and a key held, the raid clock moved only '+(g.t-t0).toFixed(3)+' s in 0.5 s');
       // TWO (his note): a real death with Superhot on and no input at all
       keysOff(); frame(false);
       if(!die()) return bad.concat(['SKIP: staging: the rounds did not kill him (hp '+p.hp+', downed '+p.downed+', beat '+g.deathBeat+')']).join('; ');
       r1=beat(180);
       if(!r1.end) bad.push('with Superhot on and no input, a death froze: after 180 frames (3 s) '+says(r1));
       else {
         if(r1.end>120) bad.push('with Superhot on and no input, the outcome card came up only after '+r1.end+' frames (over 2 s)');
         if(r1.end<84) bad.push('with Superhot on the death beat was cut short: it ended after '+r1.end+' frames (under 1.4 s)');
         if(r1.over!=='dead'||!r1.card) bad.push('with Superhot on the death beat ended without the dead outcome card (over '+r1.over+', card '+(r1.card?'up':'not up')+')');
         if(!(r1.dt>0.25&&r1.dt<0.5)) bad.push('solo with Superhot on, the world under the death beat did not move underwater-slow as if he acted (the raid clock moved '+r1.dt.toFixed(3)+' s, not about 0.375)');
       }
       if(r1.sa) bad.push('with Superhot on the dying window counted as acting on '+r1.sa+' frames with no input, so its sa flag would run a teammate world');
       // THREE (control): Superhot off, the same death, no input: the beat is as long
       if(!live(0)) return bad.concat(['SKIP: no second live raid']).join('; ');
       if(!die()) return bad.concat(['SKIP: staging: the rounds did not kill him in the second raid']).join('; ');
       r2=beat(180);
       if(!r2.end||r2.over!=='dead'||!r2.card) bad.push('control: with Superhot off the death did not reach the outcome card in 3 s ('+says(r2)+')');
       else if(r1.end&&Math.abs(r1.end-r2.end)>2) bad.push('the death beat ran '+r1.end+' frames with Superhot on and '+r2.end+' with it off');
       // FOUR (two players): a shared raid, nobody acting: the beat ends the same, the party world under it stays still, the sa flag stays 0
       if(!live(1)) return bad.concat(['SKIP: no third live raid']).join('; ');
       if(!die()) return bad.concat(['SKIP: staging: the rounds did not kill him in the third raid']).join('; ');
       netUpShared=function(){ return true; }; stubbed=true;
       r3=beat(180);
       netUpShared=kNUS; stubbed=false;
       if(!r3.end) bad.push('two players: in a shared raid with Superhot on and nobody acting, a death froze: after 180 frames (3 s) '+says(r3));
       else if(r3.end>120||r3.end<84||r3.over!=='dead'||!r3.card) bad.push('two players: in a shared raid with Superhot on and nobody acting, the death beat ran '+r3.end+' frames and ended '+(r3.card?'on':'without')+' the outcome card');
       if(Math.abs(r3.dt)>1e-9) bad.push('two players: in a shared raid with nobody acting, the death beat moved the party world '+r3.dt.toFixed(3)+' s');
       if(r3.sa) bad.push('two players: the dying window counted as acting on '+r3.sa+' frames with no input, so its sa flag would run the teammate world');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       try{ if(stubbed) netUpShared=kNUS; }catch(_n){}
       try{ CFG.superhot=kSH; CFG.fpsCap=kCap; }catch(_c){}
       try{ keysOff(); }catch(_k){}
       try{ lastTs=kTs; }catch(_t){}
       try{ var gb=__state(); if(gb&&!gb.over){ gb.player.iv=0; __endRaid('abandon'); } }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'34.85',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
