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

if ($s.Contains("  {v:'22.52',what:")) { throw "check 22.52 is in the fixture already" }

SubRx @'
  {v:'22.51',what:
'@ @'
  {v:'22.52',what:'any gun on any key in a raid (the four-gun belt, build 5): gun 1 in his hands dragged from key 1 onto key 6 is bound there as his key and key 1 shows the fill; gun 2 dragged from key 2 onto key 8 is bound there and the Bandage he had on key 8 goes to key 2; and a Medkit from the backpack dropped on the vacant gun key 3 takes it (decision D2)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__P)) return 'SKIP: this fixture cannot deploy a raid';
     if(typeof hotbarSlots!=='function'||typeof gunCell!=='function'||typeof GUNKEYS==='undefined'||GUNKEYS<4||typeof cv==='undefined'||!cv||typeof mouse!=='object'||!mouse) return 'SKIP: no four gun keys or belt drag here';
     if(!ITEMS.medkit||!ITEMS.bandage) return 'SKIP: no Medkit or Bandage here';
     var bad=[], P2=__P(), ha0=P2.hotAssign?JSON.parse(JSON.stringify(P2.hotAssign)):P2.hotAssign, mx0=mouse.x, my0=mouse.y, md0=mouse.down, s0=say, said=[],
         g=null, p=null, ids=[], k, a, b, sl, pa,
         K1={x:100,y:700,w:40,h:40,i:0}, K2={x:200,y:700,w:40,h:40,i:1}, K3={x:300,y:700,w:40,h:40,i:2}, K6={x:600,y:700,w:40,h:40,i:5}, K8={x:800,y:700,w:40,h:40,i:7};
     function cl(q){ var o={}, f; for(f in WEAPONS[q]) o[f]=WEAPONS[q][f]; o.q='field'; o.qRank=1; return o; }
     function down(C){ mouse.x=C.x+20; mouse.y=C.y+20; cv.dispatchEvent(new MouseEvent('mousedown',{button:0})); }
     function up(C){ mouse.x=C.x+20; mouse.y=C.y+20; window.dispatchEvent(new MouseEvent('mouseup',{button:0})); }
     function gid(c){ return (c&&c.kind==='gun'&&!c.vacant)?String(c.icon||'').replace(/^gun_/,''):''; }
     function desc(c){ if(!c) return 'nothing'; return (c.itemKey&&!/^gun_/.test(c.itemKey))?c.itemKey:((gid(c)||c.k||c.kind)+(c.vacant?' (vacant)':(c.inHand?' in hand':''))); }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: no live raid';
       p=g.player; g.ents.length=0; p.iv=99; keys={};
       for(k in WEAPONS) if(k!=='fists'&&WEAPONS[k]&&WEAPONS[k].mag>0&&ITEMS['gun_'+k]&&ITEMS['gun_'+k].gk===k) ids.push(k);
       if(ids.length<2) return 'SKIP: staging: fewer than two guns in this build';
       a=ids[0]; b=ids[1];
       p.wep=cl(a); p.ammo=p.wep.mag; p.wepIssued=false; p.wepFromArmory=false;
       p.sec=cl(b); p.secAmmo=p.sec.mag; p.secIssued=false; p.secFromArmory=false;
       p.swapped=false; p.reloading=0; p.roll=0; p.downed=false; p.dying=false;
       g.bag=['medkit','bandage']; g.hotAssign={0:'gun_'+a,1:'gun_'+b,7:'bandage'}; g.hotAuto={0:1,1:1}; g.hot=0; g.drag=null; g.hotPruned={};
       g.bagOpen=true; g.bagCells=[]; g.bagPanel=null; g.mapOpen=false; g.trade=null; g.paused=false;
       g.hotCells=[K1,K2,K3,K6,K8];
       say=function(t){ said.push(String(t)); };
       sl=hotbarSlots();
       if(!(gid(sl[0])===a&&sl[0].inHand&&gid(sl[1])===b&&!sl[1].inHand&&sl[2]&&sl[2].vacant&&sl[7]&&sl[7].itemKey==='bandage')) return 'SKIP: staging: the belt is not gun 1 in hand on key 1, gun 2 on key 2, a vacant key 3 and the Bandage on key 8 ('+desc(sl[0])+' / '+desc(sl[1])+' / '+desc(sl[2])+' / '+desc(sl[7])+')';
       // ONE: gun 1 from key 1 onto key 6.
       down(K1);
       if(!(g.drag&&g.drag.gunSlot)) return 'SKIP: staging: pressing key 1 did not pick up its gun';
       up(K6); g.drag=null; sl=hotbarSlots(); pa=__P().hotAssign||{};
       if(g.hotAssign[5]!=='gun_'+a||g.hotAuto[5]) bad.push('gun 1 dragged from key 1 onto key 6 was not bound there as his key (keys '+JSON.stringify(g.hotAssign)+', automatic '+JSON.stringify(g.hotAuto)+'; said '+said.join(' / ')+')');
       if(pa[5]!=='gun_'+a) bad.push('gun 1 on key 6 did not reach his belt plan (plan '+JSON.stringify(pa)+')');
       if(!(gid(sl[5])===a&&sl[5].inHand)) bad.push('after that drag key 6 shows '+desc(sl[5])+', not gun 1 in hand');
       if(!(p.wep&&p.wep.id===a&&p.sec&&p.sec.id===b)) bad.push('the drag changed the guns in his hands to '+(p.wep&&p.wep.id)+'/'+(p.sec&&p.sec.id));
       if(!sl[0]||sl[0].kind!=='gun'||sl[0].assigned) bad.push('key 1, which gun 1 left, shows '+desc(sl[0])+', not the fill of a gun key');
       if(g.hotAssign[0]!==undefined) bad.push('gun 1 still holds a pin on key 1 ('+g.hotAssign[0]+')');
       var l1=said.join(' / ');
       if(said.length&&!/ON KEY 6/.test(l1)) bad.push('the line for that drag names no key 6 in the shooter voice: '+l1);
       // TWO: a Medkit from the backpack onto the vacant gun key 3 (decision D2).
       said.length=0; sl=hotbarSlots();
       if(!(sl[2]&&sl[2].vacant)) return bad.length?bad.join('; '):'SKIP: staging: key 3 is not vacant before the Medkit drop ('+desc(sl[2])+')';
       g.drag={key:'medkit',bagIx:0,px:0,py:0};
       up(K3); g.drag=null; sl=hotbarSlots(); pa=__P().hotAssign||{};
       if(g.hotAssign[2]!=='medkit') bad.push('a Medkit dropped on the vacant gun key 3 did not take it (keys '+JSON.stringify(g.hotAssign)+'; said '+said.join(' / ')+')');
       if(!(sl[2]&&sl[2].itemKey==='medkit')) bad.push('after the Medkit drop key 3 shows '+desc(sl[2]));
       if(pa[2]!=='medkit') bad.push('the Medkit on key 3 did not reach his belt plan (plan '+JSON.stringify(pa)+')');
       // THREE: gun 2 from key 2 onto key 8, where his Bandage is.
       said.length=0;
       down(K2);
       if(!(g.drag&&g.drag.gunSlot)) return bad.length?bad.join('; '):'SKIP: staging: pressing key 2 did not pick up its gun';
       up(K8); g.drag=null; sl=hotbarSlots(); pa=__P().hotAssign||{};
       if(g.hotAssign[7]!=='gun_'+b||g.hotAuto[7]) bad.push('gun 2 dragged from key 2 onto key 8 was not bound there as his key (keys '+JSON.stringify(g.hotAssign)+')');
       if(g.hotAssign[1]!=='bandage') bad.push('the Bandage he had on key 8 did not go to key 2, where gun 2 came from (keys '+JSON.stringify(g.hotAssign)+')');
       if(!(gid(sl[7])===b&&!sl[7].inHand)) bad.push('after that drag key 8 shows '+desc(sl[7])+', not gun 2 stowed');
       if(pa[7]!=='gun_'+b||pa[1]!=='bandage') bad.push('the plan did not keep gun 2 on key 8 and the Bandage on key 2 (plan '+JSON.stringify(pa)+')');
       if(g.hotAssign[2]!=='medkit') bad.push('the Medkit left key 3 when gun 2 moved (keys '+JSON.stringify(g.hotAssign)+')');
       if(!(p.wep&&p.wep.id===a&&p.sec&&p.sec.id===b)) bad.push('the second drag changed the guns in his hands to '+(p.wep&&p.wep.id)+'/'+(p.sec&&p.sec.id));
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       say=s0;
       try{ var g2=__state(); if(g2){ g2.drag=null; g2.bagOpen=false; g2.hotCells=null; g2.hotAssign={}; g2.hotAuto={}; if(g2.player){ g2.player.iv=0; g2.player.downed=false; } if(!g2.over) __endRaid('abandon'); } }catch(_e){}
       try{ mouse.x=mx0; mouse.y=my0; mouse.down=md0; keys={}; }catch(_m){}
       if(ha0===undefined) delete P2.hotAssign; else P2.hotAssign=ha0;
       try{ saveProfile(); }catch(_s){}
       __topClear(); __resetCfg(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'22.51',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
