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

if ($s.Contains("  {v:'22.58',what:")) { throw "check 22.58 is in the fixture already" }

SubRx @'
  {v:'22.57',what:
'@ @'
  {v:'22.58',what:'the belt drag lines read like a shooter HUD (his order of 2026-10-09, from the review of the four-gun belt, build 5): an item dropped on key 9, the same key dragged off the belt, a gun no longer in the backpack, a gun drop while rolling, a backpack gun dropped on gun key 3, the gun swap, an item dragged out of the backpack and the plate (full, slotting, already slotting) each say a short ALL CAPS headline with no end punctuation, and the detail goes under it',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__P)) return 'SKIP: this fixture cannot deploy a raid';
     if(typeof hotbarSlots!=='function'||typeof swapGuns!=='function'||typeof useArmor!=='function'||typeof armorCap!=='function'||typeof GUNKEYS==='undefined'||GUNKEYS<4||typeof cv==='undefined'||!cv||typeof mouse!=='object'||!mouse) return 'SKIP: no four gun keys, belt drag or plate here';
     if(!ITEMS.medkit) return 'SKIP: no Medkit here';
     var bad=[], P2=__P(), ha0=P2.hotAssign?JSON.parse(JSON.stringify(P2.hotAssign)):P2.hotAssign, mx0=mouse.x, my0=mouse.y, md0=mouse.down, s0=say, said=[],
         g=null, p=null, ids=[], k, a, b, c, e, ak=null, L, MK=ITEMS.medkit.name.toUpperCase(),
         K1={x:100,y:700,w:40,h:40,i:0}, K2={x:200,y:700,w:40,h:40,i:1}, K3={x:300,y:700,w:40,h:40,i:2}, K9={x:900,y:700,w:40,h:40,i:8};
     function cl(q){ var o={}, f; for(f in WEAPONS[q]) o[f]=WEAPONS[q][f]; o.q='field'; o.qRank=1; return o; }
     function up(C){ if(C){ mouse.x=C.x+20; mouse.y=C.y+20; } else { mouse.x=1500; mouse.y=300; } window.dispatchEvent(new MouseEvent('mouseup',{button:0})); }
     function last(){ return said.length?said[said.length-1]:null; }
     function voice(tag,L,want,wantSub){
       if(!L){ bad.push(tag+': said nothing'); return; }
       if(L.m!==L.m.toUpperCase()||/[.!?]$/.test(L.m)||L.m.length>34) bad.push(tag+': "'+L.m+'" is not a short ALL CAPS headline');
       if(want&&!(want instanceof RegExp)&&L.m!==want) bad.push(tag+': said "'+L.m+'", not "'+want+'"');
       if(want instanceof RegExp&&!want.test(L.m)) bad.push(tag+': said "'+L.m+'"');
       if(wantSub&&String(L.sub||'').indexOf(wantSub)<0) bad.push(tag+': the detail is "'+(L.sub||'')+'", not '+wantSub);
     }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: no live raid';
       p=g.player; g.ents.length=0; p.iv=99; keys={};
       for(k in WEAPONS) if(k!=='fists'&&WEAPONS[k]&&WEAPONS[k].mag>0&&ITEMS['gun_'+k]&&ITEMS['gun_'+k].gk===k) ids.push(k);
       for(k in ITEMS) if(!ak&&ITEMS[k]&&ITEMS[k].use==='armor') ak=k;
       if(ids.length<4) return 'SKIP: staging: fewer than four guns in this build';
       a=ids[0]; b=ids[1]; c=ids[2]; e=ids[3];
       p.wep=cl(a); p.ammo=p.wep.mag; p.wepIssued=false; p.wepFromArmory=false;
       p.sec=cl(b); p.secAmmo=p.sec.mag; p.secIssued=false; p.secFromArmory=false;
       p.swapped=false; p.reloading=0; p.roll=0; p.downed=false; p.dying=false;
       g.bag=['medkit','gun_'+c]; g.hotAssign={0:'gun_'+a,1:'gun_'+b}; g.hotAuto={0:1,1:1}; g.hot=0; g.drag=null; g.hotPruned={};
       g.bagOpen=true; g.bagCells=[]; g.bagPanel=null; g.mapOpen=false; g.trade=null; g.paused=false;
       g.hotCells=[K1,K2,K3,K9];
       say=function(t,kd,o){ said.push({m:String(t),sub:(o&&o.sub)?String(o.sub):''}); };
       // ONE: a Medkit from the backpack dropped on key 9.
       said.length=0; g.drag={key:'medkit',bagIx:0,px:0,py:0}; up(K9); g.drag=null;
       if(g.hotAssign[8]!=='medkit') return 'SKIP: staging: the Medkit did not go on key 9 ('+JSON.stringify(g.hotAssign)+')';
       voice('a Medkit dropped on key 9',last(),MK+' ON KEY 9');
       // TWO: key 9 dragged off the belt.
       said.length=0; g.drag={key:'medkit',fromHot:8,px:K9.x+20,py:K9.y+20}; up(null); g.drag=null;
       if(g.hotAssign[8]!==undefined) return bad.length?bad.join('; '):'SKIP: staging: dragging key 9 off the belt did not take the Medkit off';
       voice('key 9 dragged off the belt',last(),MK+' OFF KEY 9');
       // THREE: a gun he no longer carries dropped on gun key 3.
       said.length=0; g.drag={key:'gun_'+e,bagIx:0,px:0,py:0}; up(K3); g.drag=null;
       voice('a gun no longer in the backpack',last(),'NOT IN BACKPACK');
       // FOUR: a backpack gun dropped on gun key 3 while rolling.
       said.length=0; p.roll=0.3; g.drag={key:'gun_'+c,bagIx:g.bag.indexOf('gun_'+c),px:0,py:0}; up(K3); g.drag=null; p.roll=0;
       if(!(p.wep&&p.wep.id===a)) return bad.length?bad.join('; '):'SKIP: staging: the gun came up while rolling';
       voice('a gun dropped while rolling',last(),'CANNOT EQUIP','ROLLING');
       // FIVE: the same drop standing: the gun comes up and the last line names key 3.
       said.length=0; g.drag={key:'gun_'+c,bagIx:g.bag.indexOf('gun_'+c),px:0,py:0}; up(K3); g.drag=null;
       if(!((p.wep&&p.wep.id===c)||(p.sec&&p.sec.id===c))) return bad.length?bad.join('; '):'SKIP: staging: the backpack gun dropped on key 3 did not come up';
       voice('a backpack gun dropped on gun key 3',last(),/ ON KEY 3$/);
       // SIX: the gun swap.
       said.length=0; p.roll=0; g.paused=false;
       if(swapGuns()) voice('the gun swap',last(),(p.wep.name+' up').toUpperCase());
       // SEVEN: the Medkit dragged out of the open backpack onto the ground.
       said.length=0; g.bagPanel={x:0,y:0,w:50,h:50};
       if(g.bag.indexOf('medkit')>=0){ g.drag={key:'medkit',bagIx:g.bag.indexOf('medkit'),px:10,py:10}; up(null); g.drag=null; if(g.bag.indexOf('medkit')<0) voice('a Medkit dragged out of the backpack',last(),'DROPPED '+MK); }
       g.bagPanel=null;
       // EIGHT: the plate.
       if(ak){
         g.bag.push(ak); p.prepA=null; p.armor=armorCap(); said.length=0; useArmor();
         voice('a plate at full armour',last(),'ARMOUR FULL');
         if(armorCap()>0){
           p.armor=0; said.length=0; useArmor();
           if(p.prepA){
             voice('slotting a plate',last(),('Slotting '+ITEMS[ak].name).toUpperCase());
             g.bag.push(ak); said.length=0; useArmor();
             voice('a second plate while slotting',last(),'ALREADY SLOTTING');
           }
         }
         p.prepA=null;
       }
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       say=s0;
       try{ var g2=__state(); if(g2){ g2.drag=null; g2.bagOpen=false; g2.bagPanel=null; g2.hotCells=null; g2.hotAssign={}; g2.hotAuto={}; if(g2.player){ g2.player.iv=0; g2.player.downed=false; g2.player.roll=0; g2.player.prepA=null; } if(!g2.over) __endRaid('abandon'); } }catch(_e){}
       try{ mouse.x=mx0; mouse.y=my0; mouse.down=md0; keys={}; }catch(_m){}
       if(ha0===undefined) delete P2.hotAssign; else P2.hotAssign=ha0;
       try{ saveProfile(); }catch(_s){}
       __topClear(); __resetCfg(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'22.57',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
