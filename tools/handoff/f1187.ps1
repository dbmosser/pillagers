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

# v11.87 CHECK, inserted before the v11.86 entry. A helped survivor is set
# down 260 units from the nearest open ring with the player far off on the
# other side, and the real entity update is stepped for up to forty seconds.
SubRx @'
  {v:'11.86',what:'meeting the survivor request pays 900 or more, puts a piece of salvage in your hands at once, and the card names the gift without saying already banked (his notes of 2026-09-06)',
'@ @'
  {v:'11.87',what:'a helped survivor walks to the nearest open extraction on his own instead of following you, and leaves when he reaches the ring (his note of 2026-09-06)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__runPrep)) return 'SKIP: this fixture cannot deploy';
     if(typeof updateEnts!=='function'||typeof mkStray!=='function') return 'SKIP: no survivor or entity update in this build';
     var bad=[], i;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(), p=g.player;
       var Z=null; for(i=0;i<(g.zones||[]).length&&!Z;i++) if(g.zones[i].open) Z=g.zones[i];
       if(!Z) return 'SKIP: no open extraction ring';
       var dirs=[[1,0],[-1,0],[0,1],[0,-1]], dir=null;
       for(i=0;i<dirs.length&&!dir;i++) if(losClear(Z.x,Z.y,Z.x+dirs[i][0]*280,Z.y+dirs[i][1]*280,g.map.segs)) dir=dirs[i];
       if(!dir) return 'SKIP: no clear approach to the ring';
       var e=null; for(i=0;i<g.ents.length&&!e;i++) if(g.ents[i].kind==='stray') e=g.ents[i];
       if(!e){ e=mkStray(Z.x,Z.y); g.ents.push(e); }
       e.x=Z.x+dir[0]*260; e.y=Z.y+dir[1]*260; e.helped=1; e.hostile=false; e.downed=false; e.gone=0; e.found=1; e.hp=e.maxhp||70;
       p.x=clamp(Z.x+dir[1]*1400,100,WORLD_W-100); p.y=clamp(Z.y-dir[0]*1400,100,WORLD_H-100); p.downed=false;   // off to the side, so the walk to the ring is not a walk toward him
       var d0=dist(e,Z), dp0=dist(e,p), minDp=dp0, reached=false, t=0;
       for(i=0;i<400&&!reached;i++){
         updateEnts(0.1); t+=0.1;
         if(e.gone){ reached=true; break; }
         var dp=dist(e,p); if(dp<minDp) minDp=dp;
       }
       if(!reached) bad.push('after '+t.toFixed(0)+' s the survivor never reached the ring and left (he is '+dist(e,Z).toFixed(0)+' from it, was '+d0.toFixed(0)+')');
       if(minDp<dp0-120) bad.push('control: he closed on the player by '+(dp0-minDp).toFixed(0)+' units, which is following, not walking out');
       if(reached&&!(g.tel&&g.tel.strayOut)) bad.push('the run report does not count the survivor as out');
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{ __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'11.86',what:'meeting the survivor request pays 900 or more, puts a piece of salvage in your hands at once, and the card names the gift without saying already banked (his notes of 2026-09-06)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
