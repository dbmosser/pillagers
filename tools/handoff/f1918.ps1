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

if ($s.Contains("  {v:'19.18',what:")) { throw "check 19.18 is in the fixture already" }

SubRx @'
  {v:'19.17',what:
'@ @'
  {v:'19.18',what:'a gun swap names the key the gun really lands on: with the gun in his hands also bound to key 8, dragging key 1 onto the other gun on key 9 says a key that shows that gun',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__P)) return 'SKIP: this fixture cannot deploy a raid';
     if(typeof hotbarSlots!=='function'||typeof gunCell!=='function'||typeof cv==='undefined'||!cv||typeof mouse!=='object'||!mouse) return 'SKIP: no belt drag here';
     var bad=[], P2=__P(), ha0=P2.hotAssign?JSON.parse(JSON.stringify(P2.hotAssign)):P2.hotAssign, mx0=mouse.x, my0=mouse.y, s0=say, said=[], g=null, p=null, ids=[], k, a, c, sl, m, n, K1={x:100,y:700,w:40,h:40,i:0}, K8={x:600,y:700,w:40,h:40,i:7}, K9={x:700,y:700,w:40,h:40,i:8};
     function cl(q){ var o={}, f; for(f in WEAPONS[q]) o[f]=WEAPONS[q][f]; o.q='field'; o.qRank=1; return o; }
     function down(C){ mouse.x=C.x+20; mouse.y=C.y+20; cv.dispatchEvent(new MouseEvent('mousedown',{button:0})); }
     function up(C){ mouse.x=C.x+20; mouse.y=C.y+20; window.dispatchEvent(new MouseEvent('mouseup',{button:0})); }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: no live raid';
       p=g.player; g.ents.length=0;
       for(k in WEAPONS) if(k!=='fists'&&WEAPONS[k]&&WEAPONS[k].mag>0&&ITEMS['gun_'+k]&&ITEMS['gun_'+k].gk===k) ids.push(k);
       if(ids.length<2) return 'SKIP: fewer than two guns';
       a=ids[0]; c=ids[1];
       say=function(t){ said.push(String(t)); try{ s0(t); }catch(_s){} };
       p.wep=cl(a); p.ammo=p.wep.mag; p.wepIssued=false; p.wepFromArmory=false;
       p.sec=cl(c); p.secAmmo=p.sec.mag; p.secIssued=false; p.secFromArmory=false;
       p.swapped=false; p.reloading=0; p.roll=0; p.downed=false; p.dying=false;
       g.bag=['medkit']; g.hotAssign={1:'medkit',7:'gun_'+a}; g.hotAuto={}; g.hot=0; g.drag=null;
       g.bagOpen=true; g.bagCells=[]; g.bagPanel=null; g.mapOpen=false; g.trade=null; g.paused=false;
       g.hotCells=[K1,K8,K9];
       sl=hotbarSlots();
       if(!(sl[0]&&sl[0].kind==='gun'&&sl[0].k==='gunA'&&sl[0].icon===a)) return 'SKIP: staging: key 1 is not the gun in his hands';
       if(!(sl[8]&&sl[8].kind==='gun'&&sl[8].k==='gunB'&&sl[8].icon===c)) return 'SKIP: staging: key 9 does not show the other gun moved down';
       down(K1);
       if(!(g.drag&&g.drag.gunSlot==='gunA')) return 'SKIP: staging: pressing key 1 did not pick up its gun';
       up(K9);
       sl=hotbarSlots();
       m=null; for(n=0;n<said.length;n++){ m=(/(?:to slot|is on key) (\d+)/).exec(said[n]); if(m) break; }
       if(!m) bad.push('the drop named no key: '+said.join(' / '));
       else{ n=parseInt(m[1],10)-1; if(!(sl[n]&&sl[n].kind==='gun'&&sl[n].icon===a)) bad.push('the words put the gun on key '+(n+1)+', which shows '+(sl[n]?(sl[n].name||sl[n].icon||sl[n].kind):'nothing')); }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ say=s0; mouse.x=mx0; mouse.y=my0; if(ha0===undefined) delete P2.hotAssign; else P2.hotAssign=ha0; try{ if(g){ g.drag=null; g.bagOpen=false; } var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'19.17',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
