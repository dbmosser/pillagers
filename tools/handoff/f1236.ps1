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

# v12.36 CHECK, inserted before the v12.35 entry. He is put down by a real
# round, killed by a second, and then a third lands on the body INSIDE the
# death beat, through the real frame loop, from a machine given a name no map
# ever uses so nothing can pass by agreeing with a real killer who happened to
# be standing there. Everything he would see is then read back: the downs
# figure, the downed flag, the toast, the last-hit name, and the line on the
# card itself.
SubRx @'
  {v:'12.35',what:'the safe pocket is gone from the screen, the code and the profile, a death pays out and lists the loss with no pocket line, and the secure cases in the world, which share the word, are untouched (his order of 2026-09-08)',
'@ @'
  {v:'12.36',what:'a round landing on the body during the death fade does not re-down a dead man, does not add another down, does not throw a second toast, and does not put its own name on the KILLED IN ACTION card in place of the machine that actually killed him (2026-09-07 audit, corpse-redown)',
   run:function(){
     var bad=[];
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__P&&window.__loop)) return 'SKIP: this fixture cannot deploy and drive a live raid';
     if(typeof updateBullets!=='function'||typeof damagePlayer!=='function'||typeof killPlayer!=='function') return 'SKIP: this build has no bullet or player damage path';
     var sub=document.getElementById('oc_sub');
     if(!sub) return 'SKIP: this build has no run report subtitle to read';
     var realSay=(typeof say==='function')?say:null;
     if(!realSay) return 'SKIP: no say to listen to';
     var P2=__P(), ck;
     var keepCfg={}; for(ck in CFG) keepCfg[ck]=CFG[ck];
     var keepTs=lastTs, said=[];
     // Two names no machine on any map is ever called.
     var KILLER='DUSTMAN ALPHA NINE', ROBBER='CORPSE ROBBER SEVEN';
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       try{ __pinDPR(1); __forceSize(1920,1080); }catch(_fs){}
       __deploy({kit:[],mapIx:0,seed:4242});
       var g=__state();
       if(!g||!g.player) return 'SKIP: no live raid to kill anyone in';
       if(g.sim) return 'SKIP: the death beat never runs under the bot';
       var p=g.player;
       say=function(m){ said.push(String(m)); return realSay.apply(null,arguments); };
       function shoot(kind,name,dmg){
         var b={x:p.x-2,y:p.y,vx:60,vy:0,dmg:dmg,life:2,player:false,owner:{kind:kind,name:name}};
         g.bullets.push(b); return b;
       }
       // ONE: he goes down, on the real bullet path.
       p.iv=0; p.armor=0; p.hp=30; p.downed=false; p.downT=0; p.revived=false; p.cooking=0;
       shoot('sentry',KILLER,999); updateBullets(0.016);
       if(!p.downed) return 'SKIP: the staged round did not put him on the floor';
       // TWO: and then he dies, which is what opens the beat.
       p.downT=1;
       shoot('sentry',KILLER,9); updateBullets(0.016);
       if(!(g.deathBeat>0)) return 'SKIP: the second round did not open the death beat';
       var downs0=g.tel.downs, killer0=g.tel.deathKiller, name0=g.tel.lastHitName, said0=said.length;
       if(killer0!=='sentry') bad.push('control: the death is recorded against '+killer0+' rather than sentry, so this is not the death it staged');
       if(name0!==KILLER) bad.push('control: at the moment of death the last hit names '+name0+' rather than '+KILLER);
       // THREE: a round lands on the body inside the beat, through the real frame.
       // The first loop call is a warm-up so the frame clock cannot come out zero
       // or negative from whatever the previous check left behind.
       var t0=(lastTs||0)+1000;
       __loop(t0);
       var cb=shoot('howler',ROBBER,12);
       __loop(t0+16.7);
       if(g.bullets.indexOf(cb)>=0) return 'SKIP: the round aimed at the body never reached it';
       if(!(g.deathBeat>0)) return 'SKIP: the death beat ran out before the body was hit';
       // WHAT HE WOULD SEE.
       if(g.tel.downs!==downs0) bad.push('a hit on the body during the death fade counts another DOWN: the report goes from '+downs0+' to '+g.tel.downs+' on a man who is already dead');
       if(p.downed) bad.push('a hit on the body during the death fade puts the dead man back into the downed state');
       var newSaid=said.slice(said0).join(' | ');
       if(newSaid.indexOf('DOWN. ')>=0) bad.push('a hit on the body during the death fade throws a toast over the death fade: '+newSaid);
       if(g.tel.lastHitName!==name0) bad.push('a hit on the body during the death fade renames the killer: it was '+name0+' and is now '+g.tel.lastHitName);
       // FOUR: and the card itself, which is where he reads the name.
       __endRaid('dead');
       var line=String(sub.textContent||'');
       if(line.indexOf(ROBBER)>=0) bad.push('the KILLED IN ACTION card reads "'+line+'", naming the machine that shot the corpse');
       if(line.indexOf(KILLER)<0) bad.push('the KILLED IN ACTION card reads "'+line+'", and does not name '+KILLER+', who actually killed him');
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       try{ say=realSay; }catch(_s){}
       try{ var gg=__state(); if(gg&&gg.bullets) gg.bullets.length=0; }catch(_b){}
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       for(ck in keepCfg) CFG[ck]=keepCfg[ck];
       lastTs=keepTs;
       try{ saveProfile(); }catch(_p){}
       __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'12.35',what:'the safe pocket is gone from the screen, the code and the profile, a death pays out and lists the loss with no pocket line, and the secure cases in the world, which share the word, are untouched (his order of 2026-09-08)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
