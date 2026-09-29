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

if ($s.Contains("  {v:'17.18',what:")) { throw "check 17.18 is in the fixture already" }

SubRx @'
  {v:'17.17',what:
'@ @'
  {v:'17.18',what:'pressing a belt key that holds a backpack gun to drag it (backpack open) leaves both guns in his hands, and dragging it off the belt unbinds it without equipping it, while a plain click on the key still equips it (belt hunt 2026-09-28)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__P)) return 'SKIP: this fixture cannot deploy a raid';
     if(typeof hotbarSlots!=='function'||typeof setHot!=='function'||typeof equipFromBag!=='function'||typeof cv==='undefined'||!cv||typeof mouse!=='object'||!mouse) return 'SKIP: this build has no belt equip path';
     var bad=[], P2=__P(), ha0=P2.hotAssign?JSON.parse(JSON.stringify(P2.hotAssign)):P2.hotAssign, mx0=mouse.x, my0=mouse.y, md0=mouse.down,
         g=null, p=null, ids=[], k, a, b, c, cell={x:600,y:700,w:40,h:40,i:6};
     function cl(q){ var o={}, f; for(f in WEAPONS[q]) o[f]=WEAPONS[q][f]; o.q='field'; o.qRank=1; return o; }
     function stage(){
       p.wep=cl(a); p.ammo=p.wep.mag; p.wepIssued=false; p.wepFromArmory=false;
       p.sec=cl(b); p.secAmmo=p.sec.mag; p.secIssued=false; p.secFromArmory=false;
       p.swapped=false; p.reloading=0; p.roll=0; p.downed=false; p.dying=false;
       g.bag=['gun_'+c]; g.hotAssign={6:'gun_'+c}; g.hotAuto={}; g.hot=0; g.drag=null;
       g.bagOpen=true; g.bagCells=[]; g.bagPanel=null; g.mapOpen=false; g.trade=null; g.paused=false;
       g.hotCells=[cell];
     }
     function down(x,y){ mouse.x=x; mouse.y=y; cv.dispatchEvent(new MouseEvent('mousedown',{button:0})); }
     function up(x,y){ mouse.x=x; mouse.y=y; window.dispatchEvent(new MouseEvent('mouseup',{button:0})); }
     function hands(){ return (p.wep&&p.wep.id)+'/'+(p.sec&&p.sec.id); }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: no live raid';
       p=g.player; g.ents.length=0; p.iv=99;
       for(k in WEAPONS) if(k!=='fists'&&WEAPONS[k]&&WEAPONS[k].mag>0&&ITEMS['gun_'+k]&&ITEMS['gun_'+k].gk===k) ids.push(k);
       if(ids.length<3) return 'SKIP: staging: fewer than three guns in this build';
       a=ids[0]; b=ids[1]; c=ids[2];
       // THE FINDING: press key 7 to drag it off the belt.
       stage();
       var sl=hotbarSlots();
       if(!(sl[6]&&sl[6].kind==='gun'&&sl[6].itemKey==='gun_'+c&&!sl[6].equipped)) return 'SKIP: staging: key 7 does not show the backpack gun';
       down(cell.x+20,cell.y+20);
       if(!g.drag||g.drag.key!=='gun_'+c) return 'SKIP: staging: the press on key 7 did not pick the key up';
       if(hands()!==a+'/'+b) bad.push('pressing key 7 to drag it (backpack open) equipped the backpack gun: hands went from '+a+'/'+b+' to '+hands());
       if(g.bag.indexOf('gun_'+c)<0) bad.push('pressing key 7 to drag it took the gun out of the backpack');
       up(cell.x+20,cell.y-400);
       if(g.hotAssign[6]!==undefined) bad.push('control: dragging key 7 off the belt did not unbind it');
       if(hands()!==a+'/'+b) bad.push('after dragging key 7 off the belt the hands are '+hands()+', not '+a+'/'+b);
       // CONTROL: a plain click on the key still equips it.
       stage();
       down(cell.x+20,cell.y+20); up(cell.x+20,cell.y+20);
       if(!(p.wep.id===c||p.sec.id===c)) bad.push('control: a click on key 7 no longer equips the backpack gun (hands '+hands()+')');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ var g2=__state(); if(g2){ g2.drag=null; g2.bagOpen=false; g2.hotCells=null; g2.hotAssign={}; if(g2.player){ g2.player.iv=0; g2.player.downed=false; } if(!g2.over) __endRaid('abandon'); } }catch(_e){}
       mouse.x=mx0; mouse.y=my0; mouse.down=md0;
       __topClear(); __resetCfg(); __cleanProfile();
       P2.hotAssign=ha0;
     }
     return bad.length?bad.join('; '):null; }},
  {v:'17.17',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
