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

SubRx @'
  {v:'13.67',what:
'@ @'
  {v:'13.68',what:'your hire shoots the pillagers, not you: with the hire, a hostile pillager and you in a line, his rounds hit the pillager and none of them hurts you, while the pillager firing the same way still hits you (hire and peddler audit 2026-09-14, finding 1)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     if(typeof fireWeapon!=='function'||typeof updateBullets!=='function'||typeof mkRaider!=='function') return 'SKIP: no pillagers or rounds in this build';
     var bad=[], i;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(), p=g.player;
       if(!g.zones||!g.zones.length) return 'SKIP: no open ground to stage on';
       var Z=null, dx=0, dy=0, dirs=[[1,0],[-1,0],[0,1],[0,-1]];
       for(var zi=0;zi<g.zones.length&&!Z;zi++) for(i=0;i<dirs.length&&!Z;i++)
         if(losClear(g.zones[zi].x,g.zones[zi].y,g.zones[zi].x+dirs[i][0]*420,g.zones[zi].y+dirs[i][1]*420,g.map.segs)){ Z=g.zones[zi]; dx=dirs[i][0]; dy=dirs[i][1]; }
       if(!Z) return 'SKIP: no clear line to stage the three of them on';
       var M=mkRaider(Z.x,Z.y,null,false); M.merc=1; M.hostile=false; M.grudge=false; M.friendly=1;
       var R=mkRaider(Z.x+dx*150,Z.y+dy*150,null,false); R.hostile=true;
       g.ents.length=0; g.ents.push(M); g.ents.push(R);
       function stage(){
         M.x=Z.x; M.y=Z.y; M.hp=1000; M.maxhp=1000; M.cd=0;
         R.x=Z.x+dx*150; R.y=Z.y+dy*150; R.hp=1000; R.maxhp=1000; R.hitT=0; R.downed=false;
         p.x=Z.x+dx*215; p.y=Z.y+dy*215; p.iv=0; p.armor=0; p.hp=100; p.maxhp=100; p.downed=false;
         g.bullets.length=0;
       }
       // THE FINDING: ten rounds from the hire at the pillager, with you behind him.
       stage();
       for(var s1=0;s1<10;s1++){ fireWeapon(M,M.wep,R.x,R.y,false); for(var f1=0;f1<30;f1++) updateBullets(0.016); R.hp=Math.max(R.hp,1); }
       if(!(R.hp<1000)) bad.push('ten rounds from the hire at a hostile pillager 150 away never hurt him');
       if(p.hp<100||p.downed) bad.push('the hire shooting at a pillager in front of you took you to '+Math.round(p.hp)+' health');
       // CONTROL: the pillager firing at you on the same path still hits you.
       stage();
       for(var s2=0;s2<10;s2++){ fireWeapon(R,R.wep,p.x,p.y,false); for(var f2=0;f2<30;f2++) updateBullets(0.016); if(p.downed) break; p.iv=0; }
       if(!(p.hp<100||p.downed)) bad.push('control: ten rounds from a hostile pillager at you never hit you, so this check cannot see a hit');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ var g2=__state(); if(g2&&g2.player){ g2.player.downed=false; g2.player.hp=100; g2.bullets.length=0; } if(g2&&!g2.over) __endRaid('abandon'); }catch(_e){}
       __topClear(); __resetCfg(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'13.67',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
