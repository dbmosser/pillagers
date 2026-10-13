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

if ($s.Contains("  {v:'25.55',what:")) { throw "check 25.55 is in the fixture already" }

SubRx @'
  {v:'25.54',what:
'@ @'
  {v:'25.55',what:'his order: a gun on the belt with an empty magazine and ammo to load is HALF grey; fully grey only with no ammo at all; full colour when loaded',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)||typeof drawHUD!=='function'||typeof drawIconSprite!=='function'||typeof hotbarSlots!=='function') return 'SKIP: this fixture cannot deploy or draw the belt';
     if(!WEAPONS.rifle||!WEAPONS.smg||!WEAPONS.fists||!ITEMS.gun_dmr||!ITEMS.ammobox) return 'SKIP: a staged gun or the ammo box is gone';
     var bad=[], g, p, sv=null, oIcon=drawIconSprite, proto=CanvasRenderingContext2D.prototype, oFT=proto.fillText, rec=[], txt=[];
     function draw(){
       rec=[]; txt=[];
       drawIconSprite=function(c,key,cx,cy,S){ rec.push({k:String(key),x:cx,y:cy,a:c.globalAlpha}); return oIcon.apply(this,arguments); };
       proto.fillText=function(t,x,y){ try{ txt.push({t:String(t),x:x,y:y,f:String(this.fillStyle).toLowerCase()}); }catch(_t){} return oFT.apply(this,arguments); };
       try{ drawHUD(); } finally { drawIconSprite=oIcon; proto.fillText=oFT; }
     }
     function cellOf(icon){ var s=hotbarSlots(), i; for(i=0;i<s.length;i++) if(s[i]&&s[i].kind==='gun'&&String(s[i].icon)===icon) return i; return -1; }
     function inC(C,x,y){ return C&&x>=C.x&&x<=C.x+C.w&&y>=C.y&&y<=C.y+C.h; }
     function alphaOf(icon){ var i=cellOf(icon), C=(g.hotCells||[])[i], j; if(i<0||!C) return null; for(j=0;j<rec.length;j++) if(inC(C,rec[j].x,rec[j].y)) return rec[j].a; return null; }
     function zeroCol(icon){ var i=cellOf(icon), C=(g.hotCells||[])[i], j; if(i<0||!C) return null; for(j=0;j<txt.length;j++) if(txt[j].t==='0'&&inC(C,txt[j].x,txt[j].y)) return txt[j].f; return null; }
     function r2(v){ return v===null?'none':(Math.round(v*100)/100); }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); p=g&&g.player; if(!g||g.over||!p) return 'SKIP: staging: no raid';
       sv={wep:p.wep,sec:p.sec,ammo:p.ammo,secAmmo:p.secAmmo,reserve:p.reserve,sw:p.swapped,bag:g.bag.slice(),ha:g.hotAssign,hu:g.hotAuto,st:g.stowAmmo,hot:g.hot};
       p.iv=99; g.ents.length=0; g.bagOpen=false; g.mapOpen=false; g.drag=null; p.reloading=0; p.jam=0;
       // THREE GUNS: the rifle in hand with 10 rounds, the SMG stowed with an empty magazine, a Marksman Rifle in the backpack on key 3
       // coming back empty (its stowed rounds 0).
       p.swapped=false; p.wep=Object.assign({},WEAPONS.rifle); p.sec=Object.assign({},WEAPONS.smg); p.ammo=10; p.secAmmo=0;
       g.bag=['gun_dmr']; g.hotAssign={2:'gun_dmr'}; g.hotAuto={2:1}; g.stowAmmo={dmr:[0]}; g.hot=0;
       if(cellOf('rifle')<0||cellOf('smg')<0||cellOf('gun_dmr')<0) return 'SKIP: staging: the three guns are not all on the belt';
       // 1. Ammo in the shared pool: the rifle loaded, the SMG one reload from firing.
       p.reserve=40; draw();
       var aL=alphaOf('rifle'), aH=alphaOf('smg'), zH=zeroCol('smg');
       // 2. No ammo anywhere: the SMG and the Marksman Rifle are out.
       p.reserve=0; draw();
       var aF=alphaOf('smg'), aF3=alphaOf('gun_dmr'), zF=zeroCol('smg');
       if(aL===null||aH===null||aF===null||aF3===null) return 'SKIP: the belt gun icons were not drawn (loaded '+r2(aL)+', half '+r2(aH)+', out '+r2(aF)+')';
       if(!(aL>=0.95)) bad.push('the loaded gun is not full colour (alpha '+r2(aL)+')');
       if(!(aF<=0.35)) bad.push('a gun with no ammo at all is not fully grey (alpha '+r2(aF)+')');
       if(!(aH>aF+0.15&&aH<aL-0.15)) bad.push('an empty magazine with ammo to load is not half grey: loaded '+r2(aL)+', reloadable '+r2(aH)+', out '+r2(aF));
       if(zH===null) bad.push('the reloadable gun shows no 0');
       else if(zH===zF) bad.push('the reloadable 0 is the same colour as the dead 0 ('+zH+')');
       // 3. Ammo for the third: an Ammo Box worth of rounds into the pool, and key 3 goes to half.
       p.reserve=(ITEMS.ammobox.amt||40); draw();
       var aH3=alphaOf('gun_dmr');
       if(aH3===null||!(aH3>aF3+0.15&&aH3<aL-0.15)) bad.push('picking up ammo did not take the backpack gun to half grey ('+r2(aF3)+' to '+r2(aH3)+')');
       // 4. An Ammo Box carried in the backpack counts as ammo it can load.
       p.reserve=0; g.bag=['gun_dmr','ammobox']; draw();
       var aB=alphaOf('smg');
       if(aB===null||!(aB>aF+0.15)) bad.push('an Ammo Box in the backpack did not make the empty SMG half grey (alpha '+r2(aB)+')');
       // 5. Melee never greys.
       g.bag=['gun_dmr']; p.wep=Object.assign({},WEAPONS.fists); p.ammo=0; p.reserve=0; draw();
       var aM=alphaOf('fists');
       if(aM!==null&&!(aM>=0.95)) bad.push('bare hands greyed (alpha '+r2(aM)+')');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       drawIconSprite=oIcon; proto.fillText=oFT;
       try{ var g2=__state(); if(g2&&sv){ var p2=g2.player; p2.wep=sv.wep; p2.sec=sv.sec; p2.ammo=sv.ammo; p2.secAmmo=sv.secAmmo; p2.reserve=sv.reserve; p2.swapped=sv.sw; g2.bag=sv.bag; g2.hotAssign=sv.ha; g2.hotAuto=sv.hu; g2.stowAmmo=sv.st; g2.hot=sv.hot; }
         if(g2&&!g2.over){ g2.player.iv=0; g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'25.54',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
