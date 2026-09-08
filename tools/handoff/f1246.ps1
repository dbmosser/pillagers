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

# v12.46 CHECK, inserted before the v12.45 entry. Three arms on one staging.
# The flag is armed the way the player arms it, from a standstill; the down is
# a real hit through the real damage path; and the ten frames afterwards touch
# no key at all. The FIRST control is the one that matters: an armed auto-jog
# with no down must still walk him, or a zero in the finding arm proves nothing
# more than a check that cannot see walking.
SubRx @'
  {v:'12.45',what:'cutting the seal no longer stops the world: through the whole hold his health recovers as it does standing anywhere else and a ship already called keeps coming, while the cut itself still advances at the same rate (2026-09-07 audit, the same fault as v12.34 one door along)',
'@ @'
  {v:'12.46',what:'auto-jog stops when he goes down: a man stood back up with no key held stays where he is instead of walking off toward the cursor at 40 health, while an armed auto-jog that never went down still walks him (2026-09-07 audit)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__loop&&window.__keys)) return 'SKIP: this fixture cannot deploy and drive the player';
     if(typeof damagePlayer!=='function'||typeof selfRevive!=='function'||typeof updatePlayer!=='function') return 'SKIP: this build has no down or revive path';
     var bad=[], keepTs=lastTs;
     // One staging, three ways through it. down: he is put on the floor by a real
     // hit and stood back up. armed: whether the auto-jog is on at all.
     function walk(armed,down){
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],mapIx:0,seed:4242});
       var g=__state(); if(!g||!g.player) return null;
       var p=g.player, K=__keys(), k, i;
       for(k in K) delete K[k];
       g.ents.length=0;                       // nobody to shoot him mid-walk
       p.downed=false; p.roll=0; p.revived=false; p.healLock=false;
       p.hp=100; p.armor=0; p.iv=0; p.stam=100; p.stamLock=0; p.stamRelease=0;
       p.cooking=0; p.cookT=0; p.cookKind=null; p.face=0;   // due east, so a walk is +x
       p.autoJog=!!armed;
       var clk=Math.max((typeof performance!=='undefined'&&performance.now)?performance.now():0,(lastTs||0)+100);
       if(down){
         p.hp=30;
         damagePlayer(240,null,'crawler',p.x-20,p.y);
         if(!p.downed) return {none:'a 240 hit on 30 health did not put him on the floor'};
         p.downT=CFG.downTime; p.giveT=0;
         selfRevive();
         if(p.downed) return {none:'the revive did not stand him back up'};
       }
       p.iv=99; p.face=0;
       var x0=p.x, y0=p.y;
       for(i=0;i<10;i++){ p.iv=99; clk+=16.7; __loop(clk); }
       for(k in K) delete K[k];
       return {moved:Math.sqrt((p.x-x0)*(p.x-x0)+(p.y-y0)*(p.y-y0)),jog:!!p.autoJog,hp:Math.round(p.hp)};
     }
     try{
       // CONTROL ONE FIRST: armed, never downed. He MUST walk, or nothing below
       // means anything: a zero would only say this check cannot see a walk.
       var C=walk(true,false);
       if(!C) return 'SKIP: no live raid to walk in';
       if(C.none) return 'SKIP: '+C.none;
       if(!(C.moved>1)) return 'SKIP: an armed auto-jog with no key held moved him '+Math.round(C.moved)+' units in ten frames, so this check cannot see a walk and proves nothing';
       // THE FINDING: armed, then put down and stood back up, no key touched.
       var A=walk(true,true);
       if(A.none) return 'SKIP: '+A.none;
       if(A.moved>1)
         bad.push('the auto-jog survived the down: stood back up on '+A.hp+' health with no key held he walked '+Math.round(A.moved)+' units by himself, toward whatever the cursor was pointing at, which is the character walking off on his own');
       if(A.jog) bad.push('the auto-jog is still armed after a down, so he will walk off again on the next standing frame');
       // CONTROL TWO: nothing armed at all, same room, same down. He stands still,
       // so the zero above is the flag being cleared and not the room being stuck.
       var B=walk(false,true);
       if(B.none) return 'SKIP: '+B.none;
       if(B.moved>1) bad.push('control: with no auto-jog armed at all he still walked '+Math.round(B.moved)+' units after the revive, so something other than the auto-jog is moving him and this check is measuring the wrong thing');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ var K3=__keys(); for(var k3 in K3) delete K3[k3]; }catch(_k){}
       try{ lastTs=keepTs; }catch(_t){}
       try{ var gz=__state(); if(gz&&gz.player){ gz.player.autoJog=false; gz.player.iv=0; gz.player.downed=false; gz.player.revived=false; } }catch(_a){}
       try{ var g2=__state(); if(g2&&!g2.over) __endRaid('abandon'); }catch(_e){}
       __topClear(); __resetCfg(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'12.45',what:'cutting the seal no longer stops the world: through the whole hold his health recovers as it does standing anywhere else and a ship already called keeps coming, while the cut itself still advances at the same rate (2026-09-07 audit, the same fault as v12.34 one door along)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
