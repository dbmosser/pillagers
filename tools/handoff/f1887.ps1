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

if ($s.Contains("  {v:'18.87',what:")) { throw "check 18.87 is in the fixture already" }

SubRx @'
  {v:'18.86',what:
'@ @'
  {v:'18.87',what:'a gun on belt key 8 that is already in his hands, dragged onto key 1 in a raid, goes onto key 1 and leaves key 8, says so, and leaves the guns in his hands as they were, while a drag of it onto the empty key 7 still moves it there (his report 2026-10-07: cannot move a gun from slot 8 to slot 1)',
 run:function(){
   if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__P)) return 'SKIP: this fixture cannot deploy a raid';
   if(typeof hotbarSlots!=='function'||typeof setHot!=='function'||typeof gunCell!=='function'||typeof cv==='undefined'||!cv||typeof mouse!=='object'||!mouse) return 'SKIP: this build has no belt drag';
   var bad=[], P2=__P(), ha0=P2.hotAssign?JSON.parse(JSON.stringify(P2.hotAssign)):P2.hotAssign, mx0=mouse.x, my0=mouse.y, md0=mouse.down, s0=say, said=[],
       g=null, p=null, ids=[], k, a, c, sl, K8={x:600,y:700,w:40,h:40,i:7}, K1={x:100,y:700,w:40,h:40,i:0}, K7={x:350,y:700,w:40,h:40,i:6};
   function cl(q){ var o={}, f; for(f in WEAPONS[q]) o[f]=WEAPONS[q][f]; o.q='field'; o.qRank=1; return o; }
   function stage(){
     p.wep=cl(a); p.ammo=p.wep.mag; p.wepIssued=false; p.wepFromArmory=false;
     p.sec=cl(c); p.secAmmo=p.sec.mag; p.secIssued=false; p.secFromArmory=false;
     p.swapped=true; p.reloading=0; p.roll=0; p.downed=false; p.dying=false;
     g.bag=[]; g.hotAssign={7:'gun_'+a}; g.hotAuto={}; g.hot=0; g.drag=null;
     g.bagOpen=true; g.bagCells=[]; g.bagPanel=null; g.mapOpen=false; g.trade=null; g.paused=false;
     g.hotCells=[K8,K1,K7];
   }
   function down(C){ mouse.x=C.x+20; mouse.y=C.y+20; cv.dispatchEvent(new MouseEvent('mousedown',{button:0})); }
   function up(C){ mouse.x=C.x+20; mouse.y=C.y+20; window.dispatchEvent(new MouseEvent('mouseup',{button:0})); }
   try{
     __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
     __deploy({kit:[],safe:null,mapIx:0,seed:4242});
     g=__state(); if(!g||!g.player||g.over) return 'SKIP: no live raid';
     p=g.player; g.ents.length=0; p.iv=99;
     for(k in WEAPONS) if(k!=='fists'&&WEAPONS[k]&&WEAPONS[k].mag>0&&ITEMS['gun_'+k]&&ITEMS['gun_'+k].gk===k) ids.push(k);
     if(ids.length<2) return 'SKIP: staging: fewer than two guns in this build';
     a=ids[0]; c=ids[1];
     say=function(t){ said.push(String(t)); try{ s0(t); }catch(_s){} };
     stage(); sl=hotbarSlots();
     if(!(sl[7]&&sl[7].kind==='gun'&&sl[7].itemKey==='gun_'+a&&sl[7].equipped&&sl[7].inHand)) return 'SKIP: staging: key 8 does not show the gun in his hands';
     if(!(sl[0]&&sl[0].k==='gunA'&&sl[0].icon===c)) return 'SKIP: staging: key 1 does not show the other gun';
     if(!(sl[6]&&sl[6].kind==='empty')) return 'SKIP: staging: key 7 is not empty';
     // CONTROL: key 8 dragged onto the empty key 7 moves there, on either build.
     down(K8);
     if(!g.drag||g.drag.key!=='gun_'+a) return 'SKIP: staging: the press on key 8 did not pick it up';
     up(K7);
     if(g.hotAssign[6]!=='gun_'+a||g.hotAssign[7]!==undefined) return 'SKIP: control: key 8 dragged onto the empty key 7 did not move there ('+JSON.stringify(g.hotAssign)+')';
     // THE FINDING: key 8 dragged onto key 1.
     stage(); down(K8);
     if(!g.drag||g.drag.key!=='gun_'+a) return 'SKIP: staging: the second press on key 8 did not pick it up';
     said.length=0; up(K1); sl=hotbarSlots();
     if(!(sl[0]&&sl[0].kind==='gun'&&sl[0].icon===a)) bad.push('the gun in his hands on key 8 ('+a+'), dragged onto key 1, left key 1 showing '+((sl[0]&&sl[0].icon)||'nothing'));
     if(g.hotAssign[7]!==undefined) bad.push('key 8 still holds the gun after it was dragged onto key 1, so it shows on two keys');
     if(!(p.wep&&p.wep.id===a&&p.sec&&p.sec.id===c)) bad.push('the drop changed the guns in his hands to '+(p.wep&&p.wep.id)+'/'+(p.sec&&p.sec.id)+', not '+a+'/'+c);
     if(!said.length) bad.push('the drop onto key 1 said nothing');
   }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
   finally{
     say=s0;
     try{ var g2=__state(); if(g2){ g2.drag=null; g2.bagOpen=false; g2.hotCells=null; g2.hotAssign={}; if(g2.player){ g2.player.iv=0; g2.player.downed=false; } if(!g2.over) __endRaid('abandon'); } }catch(_e){}
     mouse.x=mx0; mouse.y=my0; mouse.down=md0;
     __topClear(); __resetCfg(); __cleanProfile();
     P2.hotAssign=ha0;
   }
   return bad.length?bad.join('; '):null; }},
  {v:'18.86',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
