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

if ($s.Contains("  {v:'25.91',what:")) { throw "check 25.91 is in the fixture already" }

SubRx @'
  {v:'25.90',what:
'@ @'
  {v:'25.91',what:'his order (grenades their own class, 2 slots; heals and stims their own class, 2 slots): keys 1-4 are guns, 5-6 throwables, 7-8 medical, 9 armour. With nothing bound the belt fills each class in order (frag then smoke; bandage then medkit; the plate), hotbarSlots writes no state and does not read a pin of the wrong class, a heal found takes the lowest vacant medical key and a third kind waits with no key and no gun key is borrowed, a drop on a key of the wrong class is refused in words (a medkit on a gun key, on key 5; a grenade key on key 7) while a medkit on key 7 is taken, and a saved plan is re-homed to the class keys once (beltV 4)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__P&&window.__applyLoaded)) return 'SKIP: this fixture cannot deploy a raid or load a profile';
     if(typeof hotbarSlots!=='function'||typeof autoBelt!=='function'||typeof GUNKEYS==='undefined'||GUNKEYS<4||typeof cv==='undefined'||!cv||typeof mouse!=='object'||!mouse) return 'SKIP: no four gun keys or belt drag here';
     if(!ITEMS.bandage||!ITEMS.medkit||!ITEMS.stim||!ITEMS.plate||!ITEMS.frag||!ITEMS.smoke||!ITEMS.decoy||!WEAPONS.rifle||!WEAPONS.smg) return 'SKIP: a belt item is missing in this build';
     if(typeof G!=='undefined'&&G&&(G.sim||!G.over)) return 'SKIP: a raid or a sim is live';
     var bad=[], snap=null, mx0=mouse.x, my0=mouse.y, s0=say, said=[], g=null, p=null, sl, before, after, old, ha, i,
         K3={x:300,y:700,w:40,h:40,i:2}, K5={x:500,y:700,w:40,h:40,i:4}, K7={x:700,y:700,w:40,h:40,i:6};
     function cl(q){ var o={}, f; for(f in WEAPONS[q]) o[f]=WEAPONS[q][f]; o.q='field'; o.qRank=1; return o; }
     function up(C){ mouse.x=C.x+20; mouse.y=C.y+20; window.dispatchEvent(new MouseEvent('mouseup',{button:0})); }
     function told(t){ return said.some(function(x){ return x===t; }); }
     function desc(c){ return c?(c.k+(c.itemKey?'/'+c.itemKey:'')+'x'+c.count):'-'; }
     function stage(bag,pouch,pins,auto){
       p.wep=cl('rifle'); p.ammo=p.wep.mag; p.wepIssued=false; p.wepFromArmory=false;
       p.sec=cl('smg'); p.secAmmo=p.sec.mag; p.secIssued=false; p.secFromArmory=false;
       p.swapped=false; p.reloading=0; p.roll=0; p.downed=false; p.dying=false;
       g.bag=bag.slice(); g.pouch=pouch; g.hotAssign=pins; g.hotAuto=auto; g.hot=0; g.drag=null; g.hotPruned={}; g.stowQ={}; g.stowAmmo={};
       g.bagOpen=true; g.bagCells=[]; g.bagPanel=null; g.mapOpen=false; g.trade=null; g.paused=false; said.length=0;
     }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       snap=JSON.parse(JSON.stringify(__P()));
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: no live raid';
       p=g.player; g.ents.length=0; p.iv=99; keys={};
       say=function(t){ said.push(String(t)); };
       // ONE: nothing bound, a full pack: the fill by class, in order
       stage(['bandage','bandage','medkit','stim','plate'],{frag:2,smoke:1,decoy:1,trip:1},{},{});
       sl=hotbarSlots();
       if(sl.length!==9) bad.push('ONE: the belt has '+sl.length+' keys, not 9');
       if(!(sl[4]&&sl[4].k==='throw:frag'&&sl[4].count===2&&sl[5]&&sl[5].k==='throw:smoke'&&sl[5].count===1)) bad.push('ONE: keys 5 and 6 are '+desc(sl[4])+' and '+desc(sl[5])+', not frag x2 and smoke x1');
       if(!(sl[6]&&sl[6].itemKey==='bandage'&&sl[6].count===2&&sl[7]&&sl[7].itemKey==='medkit'&&sl[7].count===1)) bad.push('ONE: keys 7 and 8 are '+desc(sl[6])+' and '+desc(sl[7])+', not bandage x2 and medkit x1');
       if(!(sl[8]&&sl[8].k==='plate'&&sl[8].count===1)) bad.push('ONE: key 9 is '+desc(sl[8])+', not the plate x1');
       // TWO: hotbarSlots writes nothing, and a pin of the wrong class is not read
       stage(['bandage','stim'],{frag:1,smoke:0,decoy:0,trip:0},{4:'stim',2:'bandage'},{4:1,2:1});
       before=JSON.stringify([g.hotAssign,g.hotAuto]);
       sl=hotbarSlots(); hotbarSlots(); hotbarSlots();
       after=JSON.stringify([g.hotAssign,g.hotAuto]);
       if(before!==after) bad.push('TWO: hotbarSlots changed the belt plan ('+before+' became '+after+')');
       if(!(sl[4]&&sl[4].k==='throw:frag')) bad.push('TWO: a Stim pinned to key 5 showed as '+desc(sl[4])+', not the frag the key is for');
       if(!(sl[2]&&sl[2].kind==='gun')) bad.push('TWO: a Bandage pinned to gun key 3 showed as '+desc(sl[2]));
       // THREE: a pickup takes the lowest vacant key of its class; a third kind has no key, and no gun key is borrowed
       stage(['bandage'],{frag:0,smoke:0,decoy:0,trip:0},{},{});
       if(typeof classKeysSettle==='function') classKeysSettle({deploy:1}); else bad.push('THREE: no classKeysSettle');
       if(g.hotAssign[6]!=='bandage') bad.push('THREE: the raid start did not pin the Bandage the belt shows on key 7 ('+JSON.stringify(g.hotAssign)+')');
       g.bag.push('medkit'); autoBelt('medkit',true);
       if(g.hotAssign[7]!=='medkit'||BELTAT!==7) bad.push('THREE: a Medkit found did not take the vacant key 8 (keys '+JSON.stringify(g.hotAssign)+', BELTAT '+BELTAT+')');
       g.bag.push('stim'); autoBelt('stim',true);
       if(g.hotAssign[2]==='stim'||g.hotAssign[3]==='stim') bad.push('THREE: a third medical kind borrowed a gun key (keys '+JSON.stringify(g.hotAssign)+')');
       if(BELTAT!==-2) bad.push('THREE: a third medical kind with no key left BELTAT '+BELTAT+', not -2 (the backpack)');
       g.pouch.frag=1; autoBelt('frag',true);
       if(g.hotAssign[4]!=='frag') bad.push('THREE: a Frag found did not take throwable key 5 (keys '+JSON.stringify(g.hotAssign)+')');
       g.pouch.smoke=1; autoBelt('smoke',true);
       if(g.hotAssign[5]!=='smoke') bad.push('THREE: a Smoke found did not take throwable key 6 (keys '+JSON.stringify(g.hotAssign)+')');
       g.pouch.decoy=1; autoBelt('decoy',true);
       if(g.hotAssign[2]==='decoy'||g.hotAssign[3]==='decoy'||g.hotAssign[8]==='decoy') bad.push('THREE: a third grenade kind took another key (keys '+JSON.stringify(g.hotAssign)+')');
       // FOUR: drops are gated by class
       stage(['medkit','bandage'],{frag:1,smoke:0,decoy:0,trip:0},{},{});
       g.hotCells=[K3,K5,K7];
       g.drag={key:'medkit',bagIx:0,px:0,py:0}; up(K3); g.drag=null;
       if(g.hotAssign[2]!==undefined||!told('SLOT 3 TAKES GUNS ONLY')) bad.push('FOUR: a Medkit dropped on gun key 3 was not refused (keys '+JSON.stringify(g.hotAssign)+'; said '+said.join(' / ')+')');
       said.length=0;
       g.drag={key:'medkit',bagIx:0,px:0,py:0}; up(K5); g.drag=null;
       if(g.hotAssign[4]!==undefined||!told('MEDICAL GOES ON KEYS 7 AND 8')) bad.push('FOUR: a Medkit dropped on key 5 was not refused with MEDICAL GOES ON KEYS 7 AND 8 (keys '+JSON.stringify(g.hotAssign)+'; said '+said.join(' / ')+')');
       said.length=0;
       g.drag={key:'frag',fromHot:4,px:0,py:0}; up(K7); g.drag=null;
       if(g.hotAssign[6]!==undefined||!told('THROWABLES GO ON KEYS 5 AND 6')) bad.push('FOUR: the Frag key dropped on key 7 was not refused with THROWABLES GO ON KEYS 5 AND 6 (keys '+JSON.stringify(g.hotAssign)+'; said '+said.join(' / ')+')');
       said.length=0;
       g.drag={key:'medkit',bagIx:0,px:0,py:0}; up(K7); g.drag=null;
       if(g.hotAssign[6]!=='medkit') bad.push('FOUR: a Medkit dropped on key 7 was not taken (keys '+JSON.stringify(g.hotAssign)+'; said '+said.join(' / ')+')');
       // FIVE: the saved plan is re-homed once
       old=JSON.parse(JSON.stringify(__P())); old.beltV=3;
       old.hotAssign={0:'gun_rifle',1:'medkit',3:'wire',4:'smoke',5:'frag',6:'bandage',7:'stim',8:'plate'};
       old.kitSaved={kit:[],hot:{2:'frag',3:'bandage'}}; old.hotBeforeFree={1:'plate',6:'decoy'};
       __applyLoaded(old); ha=__P().hotAssign||{};
       if(JSON.stringify(ha)!==JSON.stringify({0:'gun_rifle',4:'smoke',5:'frag',6:'bandage',7:'stim',8:'plate'})) bad.push('FIVE: the plan loaded as '+JSON.stringify(ha)+' (the Medkit has no free medical key, the valuable has no key)');
       if(!((__P().beltV|0)>=4)) bad.push('FIVE: the loaded plan is stamped '+__P().beltV+', not 4');
       if(__P().kitSaved&&__P().kitSaved.hot&&JSON.stringify(__P().kitSaved.hot)!==JSON.stringify({4:'frag',6:'bandage'})) bad.push('FIVE: the plan set aside for the freebie kit is '+JSON.stringify(__P().kitSaved.hot));
       if(__P().hotBeforeFree&&JSON.stringify(__P().hotBeforeFree)!==JSON.stringify({4:'decoy',8:'plate'})) bad.push('FIVE: the plan kept from before the freebie kit is '+JSON.stringify(__P().hotBeforeFree));
       old=JSON.parse(JSON.stringify(__P())); old.beltV=4; old.hotAssign={4:'frag',7:'medkit'};
       __applyLoaded(old); ha=__P().hotAssign||{};
       if(ha[4]!=='frag'||ha[7]!=='medkit') bad.push('FIVE: a plan stamped 4 loaded as '+JSON.stringify(ha)+' (it was re-homed again)');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       say=s0; mouse.x=mx0; mouse.y=my0; mouse.down=false;
       try{ var g2=__state(); if(g2){ g2.drag=null; g2.hotCells=null; g2.hotAssign={}; g2.hotAuto={}; if(g2.player){ g2.player.iv=0; g2.player.downed=false; } if(!g2.over) __endRaid('abandon'); } }catch(_e){}
       try{ keys={}; if(snap) __applyLoaded(snap); }catch(_r){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'25.90',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
