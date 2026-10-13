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

if ($s.Contains("  {v:'25.90',what:")) { throw "check 25.90 is in the fixture already" }

SubRx @'
  {v:'25.89',what:
'@ @'
  {v:'25.90',what:'a click on a key past the gun keys that still holds a backpack gun (a plan from before) brings that gun up, while a drag of that key onto another key past the gun keys is refused with GUNS GO ON KEYS 1 TO 4',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__P)) return 'SKIP: this fixture cannot deploy a raid';
     if(typeof hotbarSlots!=='function'||typeof GUNKEYS==='undefined'||GUNKEYS<4||typeof cv==='undefined'||!cv||typeof mouse!=='object'||!mouse) return 'SKIP: no belt drag here';
     var bad=[], P2=__P(), ha0=P2.hotAssign?JSON.parse(JSON.stringify(P2.hotAssign)):P2.hotAssign, mx0=mouse.x, my0=mouse.y, md0=mouse.down, s0=say, said=[],
         g=null, p=null, sl, K8={x:600,y:700,w:40,h:40,i:7}, K9={x:700,y:700,w:40,h:40,i:8};
     function cl(q){ var o={}, f; for(f in WEAPONS[q]) o[f]=WEAPONS[q][f]; o.q='field'; o.qRank=1; return o; }
     function down(C){ mouse.x=C.x+20; mouse.y=C.y+20; cv.dispatchEvent(new MouseEvent('mousedown',{button:0})); }
     function up(C){ mouse.x=C.x+20; mouse.y=C.y+20; window.dispatchEvent(new MouseEvent('mouseup',{button:0})); }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: no live raid';
       p=g.player; g.ents.length=0; p.iv=99; keys={};
       p.wep=cl('rifle'); p.ammo=p.wep.mag; p.wepIssued=false; p.wepFromArmory=false;
       p.sec=cl('smg'); p.secAmmo=p.sec.mag; p.secIssued=false; p.secFromArmory=false;
       p.swapped=false; p.reloading=0; p.roll=0; p.downed=false; p.dying=false;
       g.bag=[]; g.hotAssign={7:'gun_smg'}; g.hotAuto={}; g.hot=0; g.drag=null; g.hotPruned={};
       g.bagOpen=true; g.bagCells=[]; g.bagPanel=null; g.mapOpen=false; g.trade=null; g.paused=false;
       g.hotCells=[K8,K9];
       say=function(t){ said.push(String(t)); };
       sl=hotbarSlots();
       if(!(sl[7]&&sl[7].kind==='gun'&&sl[7].itemKey==='gun_smg'&&sl[7].equipped&&!sl[7].inHand)) return 'SKIP: staging: key 8 does not show his stowed gun';
       down(K8); up(K8); g.drag=null;
       if(!(p.wep&&p.wep.id==='smg')) bad.push('a click on key 8, which holds his stowed gun, did not bring it up (in hand: '+(p.wep&&p.wep.id)+'; said '+said.join(' / ')+')');
       // a drag of that key onto key 9 (also past the gun keys) is a refusal and moves nothing
       said.length=0; g.hotAssign={7:'gun_rifle'}; g.hotAuto={}; g.hot=0; g.drag=null;
       sl=hotbarSlots();
       if(!(sl[7]&&sl[7].kind==='gun'&&sl[7].itemKey==='gun_rifle')) return bad.length?bad.join('; '):'SKIP: staging: key 8 does not show the rifle';
       down(K8); up(K9); g.drag=null;
       if(g.hotAssign[8]!==undefined||g.hotAssign[7]!=='gun_rifle') bad.push('a gun key dragged onto key 9 moved or was bound there (keys '+JSON.stringify(g.hotAssign)+')');
       if(!said.some(function(t){ return t==='GUNS GO ON KEYS 1 TO '+GUNKEYS; })) bad.push('that drag did not say GUNS GO ON KEYS 1 TO '+GUNKEYS+' (said '+said.join(' / ')+')');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       say=s0;
       try{ var g2=__state(); if(g2){ g2.drag=null; g2.bagOpen=false; g2.hotCells=null; g2.hotAssign={}; if(g2.player){ g2.player.iv=0; g2.player.downed=false; } if(!g2.over) __endRaid('abandon'); } }catch(_e){}
       try{ mouse.x=mx0; mouse.y=my0; mouse.down=md0; keys={}; }catch(_m){}
       __topClear(); __resetCfg(); __cleanProfile();
       P2.hotAssign=ha0;
     }
     return bad.length?bad.join('; '):null; }},
  {v:'25.89',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
