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

# v12.37 CHECK, inserted before the v12.36 entry. He is put on the floor by a
# real damagePlayer hit with the strike key genuinely held, proved held by the
# strike it swings, and must STAY on the floor with the revive unspent. Two
# controls then prove the latch delays the press rather than eating it: nothing
# held at all still revives on a real press, and a hand that let go after the
# down and pressed again still revives.
SubRx @'
  {v:'12.36',what:'a round landing on the body during the death fade does not re-down a dead man, does not add another down, does not throw a second toast, and does not put its own name on the KILLED IN ACTION card in place of the machine that actually killed him (2026-09-07 audit, corpse-redown)',
'@ @'
  {v:'12.37',what:'F already held when the hit lands does not spend the one self-revive: put down with the strike key held he stays on the floor with the revive unspent, letting go and pressing F still stands him up, and a down with nothing held still revives on the first real press (2026-09-07 audit, f-held-revive)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__loop&&window.__endRaid)) return 'SKIP: this fixture cannot deploy and press keys in a raid';
     if(typeof damagePlayer!=='function'||typeof updatePlayer!=='function'||typeof selfRevive!=='function') return 'SKIP: no down or revive path in this build';
     var bad=[];
     function press(code,key){ window.dispatchEvent(new KeyboardEvent('keydown',{code:code,key:key,bubbles:true,cancelable:true})); }
     function release(code,key){ window.dispatchEvent(new KeyboardEvent('keyup',{code:code,key:key,bubbles:true,cancelable:true})); }
     // The frame clock starts AHEAD of whatever the last check left in lastTs, so
     // a stamp lower than the last one cannot clamp every dt in here to zero.
     var clk=Math.max((typeof performance!=='undefined'&&performance.now)?performance.now():0,(lastTs||0)+100);
     function frames(n){ for(var i=0;i<n;i++){ clk+=16.7; __loop(clk); } }
     var keepTs=lastTs;
     // One staged down, distinctive on purpose: 88 health, no plate, the latch
     // explicitly CLEAR before the hit, so a pass can never come from a stale latch.
     function putDown(g,p){
       var en=null; for(var i=0;i<g.ents.length&&!en;i++) if(g.ents[i].kind==='crawler'&&!g.ents[i].downed) en=g.ents[i];
       p.hp=88; p.armor=0; p.iv=0; p.roll=0; p.downed=false; p.revived=false; p.healLock=false;
       p.cooking=0; p.cookT=0; p.cookKind=null; p.giveT=0;
       damagePlayer(240,en,en?en.kind:'crawler',p.x+20,p.y);
       return en;
     }
     try{
       // THE FINDING. F is the melee strike, so a hand on it when the hit lands is ordinary play.
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],mapIx:0,seed:4242});
       var g=__state(), p=g.player;
       keys={}; p.hp=88; p.armor=0; p.iv=0; p.roll=0; p.downed=false; p.revived=false; p.healLock=false;
       var mel0=(g.tel&&g.tel.melee)||0, rev0=(g.tel&&g.tel.revives)||0;
       press('KeyF','f'); frames(3);
       // Without these two the whole check is a silent probe: a synthetic key that
       // never reached the game would make the finding arm pass for nothing.
       if(!keys['KeyF']) bad.push('setup: the held F never reached the game, so nothing below proves anything');
       if(!(((g.tel&&g.tel.melee)||0)>mel0)) bad.push('setup: the held F swung no strike (melee '+mel0+' to '+((g.tel&&g.tel.melee)||0)+'), so the key is not really down');
       if(p.downed) bad.push('setup: the strike put him on the floor by itself');
       putDown(g,p);
       if(!p.downed) bad.push('setup: a 240 hit on 88 health did not put him down (health '+Math.round(p.hp)+')');
       frames(2);
       if(!p.downed||p.revived)
         bad.push('F already held when the hit landed spent the one self-revive with no press meant for it: on the first downed frame he is '+(p.downed?'down but':'back on his feet on '+Math.round(p.hp)+' health and')+' revived '+p.revived+', the revive ledger went '+rev0+' to '+((g.tel&&g.tel.revives)||0)+', and the toast reads "'+(g.msg||'')+'"');
       release('KeyF','f'); frames(1);
       // CONTROL ONE: nothing held at all. He stays on the floor, and a REAL press
       // still stands him up on the revive health, so the fix has not killed F.
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0);
       __deploy({kit:[],mapIx:0,seed:4242});
       g=__state(); p=g.player; keys={};
       var rev1=(g.tel&&g.tel.revives)||0;
       putDown(g,p);
       if(!p.downed) bad.push('control one: the hit did not put him down');
       frames(6);
       if(!p.downed||p.revived) bad.push('control one: he came off the floor with no key held at all (downed '+p.downed+', revived '+p.revived+')');
       press('KeyF','f'); frames(2); release('KeyF','f'); frames(1);
       if(p.downed||!p.revived||!(p.hp>0&&p.hp<=40)) bad.push('control one: a real press of F no longer revives (downed '+p.downed+', revived '+p.revived+', health '+Math.round(p.hp)+', wanted up on 40)');
       if(((g.tel&&g.tel.revives)||0)!==rev1+1) bad.push('control one: the revive ledger did not move on the real press ('+rev1+' to '+((g.tel&&g.tel.revives)||0)+')');
       // CONTROL TWO: held through the down, then let go and press again. The one
       // revive is still there, so the latch delays the press, it does not eat it.
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0);
       __deploy({kit:[],mapIx:0,seed:4242});
       g=__state(); p=g.player; keys={};
       press('KeyF','f'); frames(2);
       putDown(g,p); frames(2);
       release('KeyF','f'); frames(2);
       press('KeyF','f'); frames(2);
       if(p.downed||!p.revived) bad.push('control two: after the hand let go and pressed F again the revive did not fire (downed '+p.downed+', revived '+p.revived+', health '+Math.round(p.hp)+')');
       release('KeyF','f'); frames(1);
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       try{ release('KeyF','f'); release('Space',' '); }catch(_k){}
       try{ keys={}; mouse.down=false; }catch(_k2){}
       try{ var g2=__state(); if(g2&&g2.player){ var p2=g2.player;
         p2.downed=false; p2.revived=false; p2.healLock=false; p2.hp=100; p2.armor=0;
         p2.downT=0; p2.giveT=0; p2.pendKiller=null; p2.iv=0;
         p2.cooking=0; p2.cookT=0; p2.cookKind=null;
         if(!g2.over) __endRaid('extract'); } }catch(_e){}
       lastTs=keepTs;
       try{ saveProfile(); }catch(_p){}
       __topClear(); __resetCfg(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'12.36',what:'a round landing on the body during the death fade does not re-down a dead man, does not add another down, does not throw a second toast, and does not put its own name on the KILLED IN ACTION card in place of the machine that actually killed him (2026-09-07 audit, corpse-redown)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
