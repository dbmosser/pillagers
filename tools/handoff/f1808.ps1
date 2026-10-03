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

if ($s.Contains("  {v:'18.08',what:")) { throw "check 18.08 is in the fixture already" }

SubRx @'
  {v:'18.07',what:
'@ @'
  {v:'18.08',what:'kid firing turns player 2 toward his target before it is in gun range: with an enemy in sight range to the east and a clear line, and the cursor west, the auto-fire step puts the cursor east of him without pressing the trigger',
   run:function(){
     if(typeof afLook!=='function'||typeof netAutoFire!=='function') return 'kid firing turns him only once a machine is in gun range';
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     var bad=[], keep={on:NET.on,role:NET.role,p2:P.p2Auto,aim:PAD.aiming,rs:PAD.afRsT,af:PAD.afire,mx:mouse.x,my:mouse.y,md:mouse.down,mi:mouse.init,fire:PAD.firing}, g, p, e=null, i, j, offs=[0,80,-80,160,-160,240,-240], ok=false, D, pz, sx, r;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); p=g.player; keys={}; g.mapOpen=false; g.bagOpen=false;
       for(i=0;i<g.ents.length;i++){ if((g.ents[i].kind==='sentry'||g.ents[i].kind==='crawler')&&g.ents[i].hp>0){ e=g.ents[i]; break; } }
       if(!e) return 'SKIP: no machine';
       // THE GUN IS EMPTY FOR THIS, so the firing path (16.83) cannot answer and only the turn is measured; the enemy stands in sight range.
       D=Math.min(VF()-60,420);
       if(p.wep){ keep.mag=p.wep.mag; p.wep.mag=0; }
       for(j=0;j<offs.length&&!ok;j++){ e.x=p.x+D; e.y=p.y+offs[j]; if(losClear(p.x,p.y,e.x,e.y,g.vseg)) ok=true; }
       if(!ok) return 'SKIP: no clear line here';
       for(i=0;i<g.ents.length;i++){ if(g.ents[i]!==e&&g.ents[i].hp>0&&dist(p,g.ents[i])<VF()+50) g.ents[i].hp=0; }   // nothing nearer than him
       NET.on=true; NET.role='join'; P.p2Auto=1; PAD.aiming=false; PAD.afRsT=null; PAD.afire=0; PAD.firing=false;
       pz=ZOOM(); sx=(p.x-(g.camX===undefined?p.x-W/(2*pz):g.camX))*pz;
       mouse.x=sx-200; mouse.y=(p.y-(g.camY===undefined?p.y-H/pz*0.54:g.camY))*pz; mouse.down=false; mouse.init=true;
       r=netAutoFire(p);
       if(r) bad.push('a machine out of gun range was fired on');
       if(!(mouse.x>sx+40)) bad.push('the cursor stayed west of him (x '+Math.round(mouse.x)+' against him at '+Math.round(sx)+')');
       if(mouse.down) bad.push('the trigger was pressed with nothing in gun range');
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       NET.on=keep.on; NET.role=keep.role; P.p2Auto=keep.p2; PAD.aiming=keep.aim; PAD.afRsT=keep.rs; PAD.afire=keep.af; PAD.firing=keep.fire; mouse.x=keep.mx; mouse.y=keep.my; mouse.down=keep.md; mouse.init=keep.mi; keys={};
       try{ if(keep.mag!==undefined&&p&&p.wep) p.wep.mag=keep.mag; }catch(_mg){}
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'18.07',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
