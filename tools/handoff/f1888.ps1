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

if ($s.Contains("  {v:'18.88',what:")) { throw "check 18.88 is in the fixture already" }

SubRx @'
  {v:'18.87',what:
'@ @'
  {v:'18.88',what:'a backpack gun on belt key 8 dragged onto key 1 in a raid, with Bare Hands on key 2, goes onto key 1 (not key 2), leaves key 8 and keeps the gun he had in his hands, while with both gun slots full it still replaces the gun on key 1 (his report 2026-10-07: cannot move a gun from slot 8 to slot 1)',
 run:function(){
   if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__P)) return 'SKIP: this fixture cannot deploy a raid';
   if(typeof hotbarSlots!=='function'||typeof equipFromBag!=='function'||typeof gunCell!=='function'||typeof cv==='undefined'||!cv||typeof mouse!=='object'||!mouse||!WEAPONS.fists) return 'SKIP: this build has no belt equip path';
   var bad=[], P2=__P(), ha0=P2.hotAssign?JSON.parse(JSON.stringify(P2.hotAssign)):P2.hotAssign, mx0=mouse.x, my0=mouse.y, md0=mouse.down,
       g=null, p=null, ids=[], k, a, b, c, sl, K8={x:600,y:700,w:40,h:40,i:7}, K1={x:100,y:700,w:40,h:40,i:0};
   function cl(q){ var o={}, f; for(f in WEAPONS[q]) o[f]=WEAPONS[q][f]; o.q='field'; o.qRank=1; return o; }
   function stage(full){
     p.wep=cl(a); p.ammo=p.wep.mag; p.wepIssued=false; p.wepFromArmory=false;
     if(full){ p.sec=cl(b); p.secAmmo=p.sec.mag; } else { p.sec=WEAPONS.fists; p.secAmmo=0; }
     p.secIssued=false; p.secFromArmory=false;
     p.swapped=false; p.reloading=0; p.roll=0; p.downed=false; p.dying=false;
     g.bag=['gun_'+c]; g.hotAssign={7:'gun_'+c}; g.hotAuto={}; g.hot=0; g.drag=null; g.stowAmmo={};
     g.bagOpen=true; g.bagCells=[]; g.bagPanel=null; g.mapOpen=false; g.trade=null; g.paused=false;
     g.hotCells=[K8,K1];
   }
   function down(C){ mouse.x=C.x+20; mouse.y=C.y+20; cv.dispatchEvent(new MouseEvent('mousedown',{button:0})); }
   function up(C){ mouse.x=C.x+20; mouse.y=C.y+20; window.dispatchEvent(new MouseEvent('mouseup',{button:0})); }
   try{
     __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
     __deploy({kit:[],safe:null,mapIx:0,seed:4242});
     g=__state(); if(!g||!g.player||g.over) return 'SKIP: no live raid';
     p=g.player; g.ents.length=0; p.iv=99;
     for(k in WEAPONS) if(k!=='fists'&&WEAPONS[k]&&WEAPONS[k].mag>0&&ITEMS['gun_'+k]&&ITEMS['gun_'+k].gk===k) ids.push(k);
     if(ids.length<3) return 'SKIP: staging: fewer than three guns in this build';
     a=ids[0]; b=ids[1]; c=ids[2];
     // CONTROL: with both gun slots full the backpack gun dropped on key 1 replaces the gun there, on either build.
     stage(true); sl=hotbarSlots();
     if(!(sl[7]&&sl[7].kind==='gun'&&sl[7].itemKey==='gun_'+c&&!sl[7].equipped)) return 'SKIP: staging: key 8 does not show the backpack gun';
     down(K8); if(!g.drag||g.drag.key!=='gun_'+c) return 'SKIP: staging: the press on key 8 did not pick it up';
     up(K1); sl=hotbarSlots();
     if(!(sl[0]&&sl[0].icon===c)) return 'SKIP: control: with both gun slots full the backpack gun dropped on key 1 did not replace the gun there (key 1 shows '+((sl[0]&&sl[0].icon)||'nothing')+')';
     // THE FINDING: Bare Hands on key 2.
     stage(false); sl=hotbarSlots();
     if(!(sl[1]&&sl[1].k==='gunB'&&sl[1].icon==='fists')) return 'SKIP: staging: key 2 does not show Bare Hands';
     down(K8); if(!g.drag||g.drag.key!=='gun_'+c) return 'SKIP: staging: the second press on key 8 did not pick it up';
     up(K1); sl=hotbarSlots();
     if(g.bag.indexOf('gun_'+c)>=0) return 'SKIP: the drop did not equip the backpack gun at all, so where it went cannot be read';
     if(!(sl[0]&&sl[0].icon===c)) bad.push('the backpack gun ('+c+') on key 8, dropped on key 1 with Bare Hands on key 2, did not land on key 1: key 1 shows '+((sl[0]&&sl[0].icon)||'nothing')+' and key 2 shows '+((sl[1]&&sl[1].icon)||'nothing'));
     if(g.hotAssign[7]!==undefined) bad.push('key 8 still holds the gun after it was dropped on key 1, so the next try finds it out of the backpack');
     if(!(p.wep&&p.wep.id===a)) bad.push('the drop changed the gun in his hands from '+a+' to '+(p.wep&&p.wep.id));
   }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
   finally{
     try{ var g2=__state(); if(g2){ g2.drag=null; g2.bagOpen=false; g2.hotCells=null; g2.hotAssign={}; if(g2.player){ g2.player.iv=0; g2.player.downed=false; } if(!g2.over) __endRaid('abandon'); } }catch(_e){}
     mouse.x=mx0; mouse.y=my0; mouse.down=md0;
     __topClear(); __resetCfg(); __cleanProfile();
     P2.hotAssign=ha0;
   }
   return bad.length?bad.join('; '):null; }},
  {v:'18.87',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
