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
  {v:'15.57',what:
'@ @'
  {v:'15.58',what:'extracting with the freebie kit keeps the gun he chose in gun 1: on the freebie kit with his own Compact SMG in gun 1 an extraction still keeps the kit Scav Pistol (one more in the stash) and leaves gun 1 on the SMG, a character with nothing in gun 1 stays on fists, and a field Burst Carbine carried out beside the kit pistol still takes gun 1 while gun 2 does not get the kit pistol (first run audit finding)',
   run:function(){
     if(!(window.__startRaid&&window.__state&&window.__endRaid&&window.__P&&window.__applyLoaded)) return 'SKIP: this fixture cannot start a raid, end it and restore the profile';
     if(typeof commitKit!=='function'||typeof carriedGuns!=='function'||typeof FREEKIT_GUN==='undefined'||!WEAPONS[FREEKIT_GUN]||!WEAPONS.smg||!WEAPONS.carbine) return 'SKIP: no freebie kit, kit handoff or the guns this check stages in this build';
     if(!ITEMS['gun_'+FREEKIT_GUN]||!ITEMS.gun_carbine) return 'SKIP: the kit pistol or the Burst Carbine has no stash item in this build';
     if(typeof G!=='undefined'&&G&&G.sim) return 'SKIP: a sim is running';
     var bad=[], snap=null, why=null, PG='gun_'+FREEKIT_GUN;
     // A later control that cannot run keeps a failure already found, so the old build fails rather than skips.
     function skip(m){ return bad.length?(bad.join('; ')+' (then SKIP: '+m+')'):('SKIP: '+m); }
     function count(k){ var st=__P().stash||[], c=0; for(var i=0;i<st.length;i++) if(st[i]===k) c++; return c; }
     // His guns and slots, the freebie kit taken, and a raid at seed 4242 through commitKit and startRaid, as the lift does it.
     function up(weapons,eq,sec){
       __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       var q=__P();
       q.autoExport=false;   // a check must not start a download
       q.weapons=weapons.slice(); q.equipped=eq; q.equippedSec=sec;
       q.stash=[]; q.kit=[]; q.hotAssign={}; q.safe=null; q.dropKit=[]; q.kitChosen=0; q.devKit=0;
       q.kitSaved=null; q.kitBeforeFree=null; q.hotBeforeFree=null; q.gunBeforeFree=null; q.freeKit=1;
       saveProfile();
       commitKit();
       __startRaid({mapIx:0,seed:4242});
       var g=__state();
       if(!g||!g.player||g.over) return 'no live raid';
       // CONTROL: the raid went up on the freebie kit, its own pistol in hand the way an extraction keeps it, and gun 2 empty.
       if(g.freeKit!==1) return 'this raid did not go up on the freebie kit here';
       var p=g.player;
       if(!p.wep||p.wep.id!==FREEKIT_GUN||p.wepIssued||p.wepFromArmory) return 'the freebie kit did not put its own Scav Pistol in hand, not issued and not from the armoury, here';
       if(!p.sec||p.sec.id!=='fists') return 'gun 2 was not empty on the freebie kit here';
       return null;
     }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       snap=JSON.parse(JSON.stringify(__P()));
       // ONE: his own Compact SMG in gun 1, as Equip as your gun leaves it after the welcome pack.
       why=up([FREEKIT_GUN,'smg'],'smg','none');
       if(why) return skip(why);
       var g1=__state(), n1=count(PG);
       __endRaid('extract');
       // CONTROL: the raid ended as an extraction and the kit pistol was kept, one more copy of it in the stash.
       if(g1.over!=='extract') return skip('the first raid did not end as an extraction here');
       if(count(PG)!==n1+1) return skip('the extraction did not keep the kit pistol in the stash here ('+n1+' before, '+count(PG)+' after)');
       var q1=__P();
       if(q1.equipped!=='smg') bad.push('extracting on the freebie kit took his own Compact SMG out of gun 1 and put the '+q1.equipped+' there, so the next raid goes up with his own pistol, where it can be lost');
       if((q1.equippedSec||'none')!=='none') bad.push('extracting on the freebie kit with gun 2 empty filled gun 2 with the '+q1.equippedSec);
       // TWO: nothing in gun 1, the fresh character who goes up with a rolled loaner.
       why=up([FREEKIT_GUN],'fists','none');
       if(why) return skip(why);
       var g2=__state(), n2=count(PG);
       __endRaid('extract');
       // CONTROL: extracted, and the kit pistol kept.
       if(g2.over!=='extract'||count(PG)!==n2+1) return skip('the second raid did not extract and keep the kit pistol here');
       var q2=__P();
       if(q2.equipped!=='fists') bad.push('extracting on the freebie kit with nothing in gun 1 put the '+q2.equipped+' in gun 1, so the rolled loaner is gone and his own pistol goes up to be lost');
       // THREE: his own SMG in gun 1 and his own Burst Carbine in gun 2, and a field Burst Carbine picked up into the empty hand.
       why=up([FREEKIT_GUN,'smg','carbine'],'smg','carbine');
       if(why) return skip(why);
       var g3=__state(), p3=g3.player, n3=count('gun_carbine');
       p3.sec=WEAPONS.carbine; p3.secAmmo=WEAPONS.carbine.mag; p3.secIssued=false; p3.secFromArmory=false;
       __endRaid('extract');
       var q3=__P();
       // CONTROL: extracted with the field Carbine kept as a second copy, and a gun found in the raid still takes gun 1 on a
       // freebie raid, so the two slots collided and the gun 2 repair ran.
       if(g3.over!=='extract'||count('gun_carbine')!==n3+1) return skip('the third raid did not extract and keep the field Burst Carbine here');
       if(q3.equipped!=='carbine') return skip('a field Burst Carbine carried out on the freebie kit did not take gun 1 here (gun 1 is '+q3.equipped+'), so gun 2 did not collide with it');
       if(q3.equippedSec===FREEKIT_GUN) bad.push('with a field Burst Carbine carried out beside the kit pistol, the gun 2 repair put the kit pistol in gun 2');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ var gl=__state(); if(gl&&!gl.over) __endRaid('abandon'); }catch(_e){}
       try{ if(snap) __applyLoaded(snap); }catch(_r){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'15.57',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
