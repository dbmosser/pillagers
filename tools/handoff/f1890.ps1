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

if ($s.Contains("  {v:'18.90',what:")) { throw "check 18.90 is in the fixture already" }

SubRx @'
  {v:'18.89',what:
'@ @'
  {v:'18.90',what:'in a raid, pressing belt key 8 to drag it when it holds his stowed gun does not swap that gun up, and dragging it off the belt unbinds it with the gun he was holding still up, while a plain click on key 8 still brings it up (his report 2026-10-07: cannot move a gun from slot 8 to slot 1)',
 run:function(){
   if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__P)) return 'SKIP: this fixture cannot deploy a raid';
   if(typeof hotbarSlots!=='function'||typeof setHot!=='function'||typeof swapGuns!=='function'||typeof cv==='undefined'||!cv||typeof mouse!=='object'||!mouse) return 'SKIP: this build has no belt drag';
   var bad=[], P2=__P(), ha0=P2.hotAssign?JSON.parse(JSON.stringify(P2.hotAssign)):P2.hotAssign, mx0=mouse.x, my0=mouse.y, md0=mouse.down,
       g=null, p=null, ids=[], k, a, c, sl, K8={x:600,y:700,w:40,h:40,i:7};
   function cl(q){ var o={}, f; for(f in WEAPONS[q]) o[f]=WEAPONS[q][f]; o.q='field'; o.qRank=1; return o; }
   function stage(){
     p.wep=cl(a); p.ammo=p.wep.mag; p.wepIssued=false; p.wepFromArmory=false;
     p.sec=cl(c); p.secAmmo=p.sec.mag; p.secIssued=false; p.secFromArmory=false;
     p.swapped=false; p.reloading=0; p.roll=0; p.downed=false; p.dying=false;
     g.bag=[]; g.hotAssign={7:'gun_'+c}; g.hotAuto={}; g.hot=0; g.drag=null;
     g.bagOpen=true; g.bagCells=[]; g.bagPanel=null; g.mapOpen=false; g.trade=null; g.paused=false;
     g.hotCells=[K8];
   }
   function down(x,y){ mouse.x=x; mouse.y=y; cv.dispatchEvent(new MouseEvent('mousedown',{button:0})); }
   function up(x,y){ mouse.x=x; mouse.y=y; window.dispatchEvent(new MouseEvent('mouseup',{button:0})); }
   try{
     __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
     __deploy({kit:[],safe:null,mapIx:0,seed:4242});
     g=__state(); if(!g||!g.player||g.over) return 'SKIP: no live raid';
     p=g.player; g.ents.length=0; p.iv=99;
     for(k in WEAPONS) if(k!=='fists'&&WEAPONS[k]&&WEAPONS[k].mag>0&&ITEMS['gun_'+k]&&ITEMS['gun_'+k].gk===k) ids.push(k);
     if(ids.length<2) return 'SKIP: staging: fewer than two guns in this build';
     a=ids[0]; c=ids[1];
     stage(); sl=hotbarSlots();
     if(!(sl[7]&&sl[7].kind==='gun'&&sl[7].itemKey==='gun_'+c&&sl[7].equipped&&!sl[7].inHand)) return 'SKIP: staging: key 8 does not show his stowed gun';
     // CONTROL: a plain click on key 8 brings the stowed gun up, on either build.
     down(K8.x+20,K8.y+20); up(K8.x+20,K8.y+20);
     if(!(p.wep&&p.wep.id===c)) return 'SKIP: control: a click on key 8 did not bring the stowed gun up (in hand: '+(p.wep&&p.wep.id)+')';
     // THE FINDING: a press on key 8 to drag it.
     stage();
     down(K8.x+20,K8.y+20);
     if(!g.drag||g.drag.key!=='gun_'+c) return 'SKIP: staging: the press on key 8 did not pick it up';
     if(!(p.wep&&p.wep.id===a)) bad.push('pressing key 8 to drag it swapped '+c+' up before anything was dropped (in hand: '+(p.wep&&p.wep.id)+')');
     up(K8.x+20,K8.y-380);
     if(g.hotAssign[7]!==undefined) bad.push('control: dragging key 8 off the belt did not unbind it');
     if(!(p.wep&&p.wep.id===a)) bad.push('after dragging key 8 off the belt the gun up is '+(p.wep&&p.wep.id)+', not '+a);
   }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
   finally{
     try{ var g2=__state(); if(g2){ g2.drag=null; g2.bagOpen=false; g2.hotCells=null; g2.hotAssign={}; if(g2.player){ g2.player.iv=0; g2.player.downed=false; } if(!g2.over) __endRaid('abandon'); } }catch(_e){}
     mouse.x=mx0; mouse.y=my0; mouse.down=md0;
     __topClear(); __resetCfg(); __cleanProfile();
     P2.hotAssign=ha0;
   }
   return bad.length?bad.join('; '):null; }},
  {v:'18.89',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
