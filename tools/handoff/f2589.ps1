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

if ($s.Contains("  {v:'25.89',what:")) { throw "check 25.89 is in the fixture already" }

SubRx @'
  {v:'25.88',what:
'@ @'
  {v:'25.89',what:'his order (so player can only carry 4 guns max): a gun belongs on keys 1 to 4. A gun in his hands dragged onto key 6, a backpack gun dropped on key 8, and a gun put on key 6 on the Stash plan row are refused with GUNS GO ON KEYS 1 TO 4 and nothing moves, while a gun still goes onto key 3; an old saved plan loses its gun bindings on keys 5 to 9 once (the rest stays) and a plan stamped 3 is not slid again',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__P&&window.__applyLoaded)) return 'SKIP: this fixture cannot deploy a raid or load a profile';
     if(typeof hotbarSlots!=='function'||typeof rackPut!=='function'||typeof planPut!=='function'||typeof GUNKEYS==='undefined'||GUNKEYS<4||typeof cv==='undefined'||!cv||typeof mouse!=='object'||!mouse) return 'SKIP: no four gun keys or belt drag here';
     if(!WEAPONS.rifle||!WEAPONS.smg||!WEAPONS.carbine||!ITEMS.gun_carbine||!ITEMS.bandage||!ITEMS.medkit||!ITEMS.smoke) return 'SKIP: no rifle, smg, carbine, bandage, medkit or smoke here';
     if(typeof G!=='undefined'&&G&&(G.sim||!G.over)) return 'SKIP: a raid or a sim is live';
     var bad=[], snap=null, mx0=mouse.x, my0=mouse.y, s0=say, said=[], g=null, p=null, ha, pa, sl, old, cur, r, why,
         K1={x:100,y:700,w:40,h:40,i:0}, K3={x:300,y:700,w:40,h:40,i:2}, K6={x:600,y:700,w:40,h:40,i:5}, K8={x:800,y:700,w:40,h:40,i:7};
     var REF='GUNS GO ON KEYS 1 TO '+GUNKEYS;
     function cl(q){ var o={}, f; for(f in WEAPONS[q]) o[f]=WEAPONS[q][f]; o.q='field'; o.qRank=1; return o; }
     function down(C){ mouse.x=C.x+20; mouse.y=C.y+20; cv.dispatchEvent(new MouseEvent('mousedown',{button:0})); }
     function up(C){ mouse.x=C.x+20; mouse.y=C.y+20; window.dispatchEvent(new MouseEvent('mouseup',{button:0})); }
     function pinOf(id){ var k; for(k in g.hotAssign) if(g.hotAssign[k]==='gun_'+id) return +k; return -1; }
     function toldRef(){ return said.some(function(t){ return t===REF; }); }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       snap=JSON.parse(JSON.stringify(__P()));
       // ONE: an old saved plan (stamped 2) loses its gun bindings on keys 5 to 9, once, and keeps the rest
       old=JSON.parse(JSON.stringify(__P())); old.beltV=2; old.hotAssign={1:'gun_smg',5:'gun_rifle',6:'medkit',7:'bandage'};
       old.kitSaved={kit:[],hot:{6:'gun_rifle',2:'gun_smg'}}; old.hotBeforeFree={7:'gun_carbine',0:'gun_rifle'};
       __applyLoaded(old);
       ha=__P().hotAssign||{};
       if(ha[5]!==undefined) bad.push('ONE: the gun bound to key 6 stayed on the loaded plan ('+JSON.stringify(ha)+')');
       if(ha[1]!=='gun_smg'||ha[6]!=='medkit'||ha[7]!=='bandage') bad.push('ONE: the load changed the rest of the plan ('+JSON.stringify(ha)+')');
       if(!((__P().beltV|0)>=3)) bad.push('ONE: the loaded plan is stamped '+__P().beltV+', not 3 or later');
       if(__P().kitSaved&&__P().kitSaved.hot&&(__P().kitSaved.hot[6]!==undefined||__P().kitSaved.hot[2]!=='gun_smg')) bad.push('ONE: the plan set aside for the freebie kit is '+JSON.stringify(__P().kitSaved.hot));
       if(__P().hotBeforeFree&&(__P().hotBeforeFree[7]!==undefined||__P().hotBeforeFree[0]!=='gun_rifle')) bad.push('ONE: the plan kept from before the freebie kit is '+JSON.stringify(__P().hotBeforeFree));
       // TWO: a plan stamped 3 is not slid again
       cur=JSON.parse(JSON.stringify(__P())); cur.beltV=3; cur.hotAssign={4:'smoke'};
       __applyLoaded(cur);
       ha=__P().hotAssign||{};
       if(ha[4]!=='smoke'||ha[6]!==undefined) bad.push('TWO: a plan stamped 3 with Smoke on key 5 loaded as '+JSON.stringify(ha)+' (it was slid again)');
       // THREE: the raid belt refuses a gun past the gun keys and still takes one on key 3
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return bad.length?bad.join('; '):'SKIP: no live raid';
       p=g.player; g.ents.length=0; p.iv=99; keys={};
       p.wep=cl('rifle'); p.ammo=p.wep.mag; p.wepIssued=false; p.wepFromArmory=false;
       p.sec=cl('smg'); p.secAmmo=p.sec.mag; p.secIssued=false; p.secFromArmory=false;
       p.swapped=false; p.reloading=0; p.roll=0; p.downed=false; p.dying=false;
       g.bag=['gun_carbine','bandage']; g.hotAssign={0:'gun_rifle',1:'gun_smg',7:'bandage'}; g.hotAuto={0:1,1:1}; g.hot=0; g.drag=null; g.hotPruned={};
       g.bagOpen=true; g.bagCells=[]; g.bagPanel=null; g.mapOpen=false; g.trade=null; g.paused=false;
       g.hotCells=[K1,K3,K6,K8];
       say=function(t){ said.push(String(t)); };
       sl=hotbarSlots();
       if(!(sl[0]&&sl[0].inHand&&sl[0].icon==='rifle'&&sl[7]&&sl[7].itemKey==='bandage')) return bad.length?bad.join('; '):'SKIP: staging: key 1 is not the rifle in hand and key 8 the Bandage';
       down(K1);
       if(!(g.drag&&g.drag.gunSlot)) return bad.length?bad.join('; '):'SKIP: staging: pressing key 1 did not pick up its gun';
       up(K6); g.drag=null; sl=hotbarSlots(); pa=__P().hotAssign||{};
       if(g.hotAssign[5]!==undefined||pa[5]!==undefined) bad.push('THREE: the rifle dragged onto key 6 was bound there (keys '+JSON.stringify(g.hotAssign)+', plan '+JSON.stringify(pa)+')');
       if(!toldRef()) bad.push('THREE: the drag onto key 6 did not say '+REF+' (said '+said.join(' / ')+')');
       if(!(sl[0]&&sl[0].inHand&&sl[0].icon==='rifle')||g.hotAssign[0]!=='gun_rifle') bad.push('THREE: the refused drag moved the rifle off key 1 (keys '+JSON.stringify(g.hotAssign)+')');
       said.length=0;
       g.drag={key:'gun_carbine',bagIx:0,px:0,py:0};
       up(K8); g.drag=null; pa=__P().hotAssign||{};
       if(pinOf('carbine')>=0||g.hotAssign[7]!=='bandage') bad.push('THREE: the carbine dropped on key 8 was bound or covered the Bandage (keys '+JSON.stringify(g.hotAssign)+')');
       if(g.bag.indexOf('gun_carbine')<0) bad.push('THREE: the refused carbine left the backpack');
       if(!toldRef()) bad.push('THREE: the drop on key 8 did not say '+REF+' (said '+said.join(' / ')+')');
       // FOUR: the Stash plan row
       P.weapons=['rifle','smg']; P.equipped='rifle'; P.equippedSec='smg'; P.hotAssign={}; P.stash=['gun_carbine']; P.kit=[];
       r=rackPut(5,'gun_rifle');
       if(r!==REF||(P.hotAssign||{})[5]!==undefined) bad.push('FOUR: the rifle put on plan key 6 answered '+JSON.stringify(r)+' (plan '+JSON.stringify(P.hotAssign)+')');
       why=planPut(7,'gun_carbine');
       if(why!==REF||(P.hotAssign||{})[7]!==undefined) bad.push('FOUR: a stash gun put on plan key 8 answered '+JSON.stringify(why)+' (plan '+JSON.stringify(P.hotAssign)+')');
       r=rackPut(2,'gun_rifle');
       if(r!==null||(P.hotAssign||{})[2]!=='gun_rifle') bad.push('FOUR: the rifle put on plan key 3 answered '+JSON.stringify(r)+' (plan '+JSON.stringify(P.hotAssign)+')');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       say=s0; mouse.x=mx0; mouse.y=my0; mouse.down=false;
       try{ var g2=__state(); if(g2){ g2.drag=null; g2.hotAssign={}; g2.hotAuto={}; if(g2.player){ g2.player.iv=0; g2.player.downed=false; } if(!g2.over) __endRaid('abandon'); } }catch(_e){}
       try{ keys={}; if(snap) __applyLoaded(snap); }catch(_r){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'25.88',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
