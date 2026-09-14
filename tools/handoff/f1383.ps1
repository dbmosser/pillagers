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
  {v:'13.82',what:
'@ @'
  {v:'13.83',what:'a roll does not freeze the reload: an Auto Rifle reload keeps counting down through four frames of a roll, as it does standing, and going down lets it go (combat and player state audit 2026-09-14, finding 4)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     if(typeof updatePlayer!=='function'||typeof damagePlayer!=='function'||!WEAPONS.rifle) return 'SKIP: no player update or rifle in this build';
     var bad=[];
     function copyW(id){ var w={},k; for(k in WEAPONS[id]) w[k]=WEAPONS[id][k]; return w; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(), p=g.player;
       if(!g||!p) return 'SKIP: no live raid';
       g.ents.length=0;
       var K=__keysRef(); for(var k0 in K) K[k0]=false;
       var Z=null, zi;
       for(zi=0;zi<g.zones.length&&!Z;zi++) if(losClear(g.zones[zi].x,g.zones[zi].y,g.zones[zi].x+260,g.zones[zi].y,g.map.segs)) Z=g.zones[zi];
       if(!Z) return 'SKIP: no clear ground to roll along';
       function arm(roll){
         p.x=Z.x; p.y=Z.y; p.downed=false; p.dying=false; p.iv=99; p.hp=100;
         p.wep=copyW('rifle'); p.ammo=0; p.reserve=50; p.reloading=2050; p.jam=0;
         p.roll=roll?0.38:0; p.rollDir={x:1,y:0}; p.rollCd=0;
       }
       // THE FINDING: a reload running through a roll.
       arm(true);
       for(var f=0;f<4;f++) updatePlayer(0.09);
       if(!(p.reloading<1800)) bad.push('four frames of a roll left the reload at '+Math.round(p.reloading)+' of 2050 ms');
       // CONTROL: the same four frames standing.
       arm(false);
       for(var f2=0;f2<4;f2++) updatePlayer(0.09);
       if(!(p.reloading<1800)) bad.push('control: four frames standing left the reload at '+Math.round(p.reloading)+', so this check cannot see the clock');
       // AND: going down lets the reload go.
       arm(false); p.iv=0; p.armor=0; p.hp=20; p.revived=false;
       damagePlayer(999,'sentry','PROBE UNIT NINE',p.x-2,p.y);
       if(p.downed&&p.reloading>0) bad.push('going down kept a reload of '+Math.round(p.reloading)+' ms to finish after he stands');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ var K3=__keysRef(); for(var k3 in K3) K3[k3]=false; }catch(_k){}
       try{ var g2=__state(); if(g2&&g2.player){ g2.player.iv=0; g2.player.downed=false; g2.player.roll=0; g2.player.hp=100; } if(g2&&!g2.over) __endRaid('abandon'); }catch(_e){}
       __topClear(); __resetCfg(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'13.82',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
