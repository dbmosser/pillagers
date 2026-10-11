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

if ($s.Contains("  {v:'22.55',what:")) { throw "check 22.55 is in the fixture already" }

SubRx @'
  {v:'22.54',what:
'@ @'
  {v:'22.55',what:'a gun he put on key 6 drags back onto key 1 (from the review of the four-gun belt, build 5): gun 1 dragged from key 1 onto key 6 still shows on key 1 too (his v15.25 note), and dragging it from key 6 back onto key 1 takes it off key 6, pins it on key 1, keeps it out of his belt plan on key 6 and says the key, instead of doing nothing in silence',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__P)) return 'SKIP: this fixture cannot deploy a raid';
     if(typeof hotbarSlots!=='function'||typeof gunCell!=='function'||typeof GUNKEYS==='undefined'||GUNKEYS<4||typeof cv==='undefined'||!cv||typeof mouse!=='object'||!mouse) return 'SKIP: no four gun keys or belt drag here';
     var bad=[], P2=__P(), ha0=P2.hotAssign?JSON.parse(JSON.stringify(P2.hotAssign)):P2.hotAssign, mx0=mouse.x, my0=mouse.y, md0=mouse.down, s0=say, said=[],
         g=null, p=null, ids=[], k, a, b, sl, pa,
         K1={x:100,y:700,w:40,h:40,i:0}, K2={x:200,y:700,w:40,h:40,i:1}, K6={x:600,y:700,w:40,h:40,i:5};
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
       g.bag=['medkit']; g.hotAssign={0:'gun_'+a,1:'gun_'+b}; g.hotAuto={0:1,1:1}; g.hot=0; g.drag=null; g.hotPruned={};
       g.bagOpen=true; g.bagCells=[]; g.bagPanel=null; g.mapOpen=false; g.trade=null; g.paused=false;
       g.hotCells=[K1,K2,K6];
       say=function(t){ said.push(String(t)); };
       // STAGING: gun 1 from key 1 onto key 6 (the v22.52 drag).
       down(K1);
       if(!(g.drag&&g.drag.gunSlot)) return 'SKIP: staging: pressing key 1 did not pick up its gun';
       up(K6); g.drag=null; sl=hotbarSlots();
       if(g.hotAssign[5]!=='gun_'+a) return 'SKIP: staging: gun 1 did not go on key 6 ('+JSON.stringify(g.hotAssign)+')';
       if(!(gid(sl[0])===a&&sl[0].inHand)) return 'SKIP: staging: key 1 does not show gun 1 in his hands after it went to key 6 ('+desc(sl[0])+')';
       // THE DRAG BACK: from key 6 onto key 1.
       said.length=0;
       down(K6);
       if(!(g.drag&&g.drag.key==='gun_'+a)) return 'SKIP: staging: pressing key 6 did not pick up gun 1';
       up(K1); g.drag=null; sl=hotbarSlots(); pa=__P().hotAssign||{};
       if(g.hotAssign[5]==='gun_'+a) bad.push('gun 1 dragged from key 6 back onto key 1 is still bound to key 6 (keys '+JSON.stringify(g.hotAssign)+'; said '+(said.join(' / ')||'nothing')+')');
       if(g.hotAssign[0]!=='gun_'+a) bad.push('gun 1 dragged back onto key 1 is not pinned there (keys '+JSON.stringify(g.hotAssign)+')');
       if(pa[5]==='gun_'+a) bad.push('his belt plan still has gun 1 on key 6 (plan '+JSON.stringify(pa)+')');
       if(gid(sl[5])===a) bad.push('key 6 still shows gun 1 after it was dragged back to key 1');
       if(!(gid(sl[0])===a&&sl[0].inHand)) bad.push('key 1 shows '+desc(sl[0])+', not gun 1 in hand');
       if(!said.length||!/(slot|key) 1\b/i.test(said.join(' / '))) bad.push('the drag back said no line naming key 1 (said '+(said.join(' / ')||'nothing')+')');
       if(!(p.wep&&p.wep.id===a&&p.sec&&p.sec.id===b)) bad.push('the drag back changed the guns in his hands to '+(p.wep&&p.wep.id)+'/'+(p.sec&&p.sec.id));
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
  {v:'22.54',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
