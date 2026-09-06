$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# v11.84 CHECK, inserted before the v11.83 entry. Two crawlers on one clear
# line east of the player, faced toward him so no shot is a back shot; the
# real lance fired through fireWeapon and the real bullet update stepped.
# Then the same with a rifle, which must stop at the first.
SubRx @'
  {v:'11.83',what:'a stim is ten seconds of unlimited stamina and a fifth more speed, used through the belt key: the bar stays full through a sprint and the same sprint covers 1.2x the ground (his spec of 2026-09-06)',
'@ @'
  {v:'11.84',what:'a Meridian Lance round travels through crawlers, hitting each one on the line once with its full damage, while a rifle round still stops at the first (his note of 2026-09-06)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__runPrep)) return 'SKIP: this fixture cannot deploy';
     if(typeof fireWeapon!=='function'||typeof updateBullets!=='function'||typeof WEAPONS==='undefined'||!WEAPONS.lance) return 'SKIP: no lance in this build';
     var bad=[], i;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(), p=g.player;
       if(!g.zones||!g.zones.length) return 'SKIP: no open ground to stage on';
       var Z=g.zones[0], ok=false, dx=0, dy=0;
       var dirs=[[1,0],[-1,0],[0,1],[0,-1]];
       for(i=0;i<dirs.length&&!ok;i++) if(losClear(Z.x,Z.y,Z.x+dirs[i][0]*260,Z.y+dirs[i][1]*260,g.map.segs)){ ok=true; dx=dirs[i][0]; dy=dirs[i][1]; }
       if(!ok) return 'SKIP: no clear line from the ring to shoot along';
       // TWO CRAWLERS ON THE LINE, both facing the shooter.
       var cs=[]; for(i=0;i<g.ents.length&&cs.length<2;i++) if(g.ents[i].kind==='crawler'&&!g.ents[i].downed&&!g.ents[i].finished) cs.push(g.ents[i]);
       if(cs.length<2) return 'SKIP: fewer than two crawlers on this map';
       function stage(){
         p.x=Z.x; p.y=Z.y; p.downed=false; p.face=Math.atan2(dy,dx);
         for(var c=0;c<2;c++){ var e=cs[c]; e.x=Z.x+dx*(110+c*70); e.y=Z.y+dy*(110+c*70); e.hp=1000; e.maxhp=1000; e.face=Math.atan2(-dy,-dx); e.hitT=0; }
         for(var o=0;o<g.ents.length;o++){ var oe=g.ents[o]; if(cs.indexOf(oe)<0&&Math.abs(oe.x-Z.x)<400&&Math.abs(oe.y-Z.y)<400){ oe.x=Z.x-dx*900-dy*900; oe.y=Z.y-dy*900+dx*900; } }
         g.bullets.length=0;
       }
       function shoot(wep){
         p.wep=wep; p.ammo=wep.mag; p.reloading=0; p.jam=0;
         fireWeapon(p,wep,Z.x+dx*300,Z.y+dy*300,true);
         if(!g.bullets.length) return 'no round left the muzzle';
         for(var f=0;f<40;f++) updateBullets(0.016);
         return null;
       }
       // THE LANCE.
       stage(); var err=shoot(WEAPONS.lance);
       if(err) bad.push('control: the lance fired nothing ('+err+')');
       var l1=1000-cs[0].hp, l2=1000-cs[1].hp;
       if(!(l1>=60)) bad.push('control: the lance did not hit the first crawler (loss '+l1.toFixed(0)+')');
       if(!(l2>=60)) bad.push('the lance round stopped at the first crawler; the second took '+l2.toFixed(0));
       if(l1>150||l2>150) bad.push('a crawler was hit more than once by one round (losses '+l1.toFixed(0)+' and '+l2.toFixed(0)+')');
       // A RIFLE STOPS AT THE FIRST.
       stage(); err=shoot(WEAPONS.rifle||WEAPONS.pistol);
       if(err) bad.push('control: the rifle fired nothing ('+err+')');
       var r1=1000-cs[0].hp, r2=1000-cs[1].hp;
       if(!(r1>=10)) bad.push('control: the rifle did not hit the first crawler (loss '+r1.toFixed(0)+')');
       if(r2>0) bad.push('control: a rifle round went through the first crawler too (second took '+r2.toFixed(0)+')');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'11.83',what:'a stim is ten seconds of unlimited stamina and a fifth more speed, used through the belt key: the bar stays full through a sprint and the same sprint covers 1.2x the ground (his spec of 2026-09-06)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
