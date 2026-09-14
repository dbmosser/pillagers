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
  {v:'13.88',what:
'@ @'
  {v:'13.89',what:'a dropped item never lands inside a wall: pressed against the top face of a solid wall, forty drops all leave a pile the player has a clear line to (searching and loot audit 2026-09-14, finding 4)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     if(typeof dropItem!=='function'||typeof losClear!=='function') return 'SKIP: no drop or sight test in this build';
     var bad=[], X=null, k;
     for(k in ITEMS){ var it=ITEMS[k]; if(it&&k!=='medkit'&&k!=='bandage'&&it.use!=='key'&&it.use!=='gun'&&it.use!=='heal'&&it.use!=='throw'){ X=k; break; } }
     if(!X) return 'SKIP: nothing plain to drop';
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(), p=g.player;
       if(!g||!p||!g.vseg) return 'SKIP: no live raid with sight segments';
       g.ents.length=0; g.hotZone=null; g.hotAssign={}; g.issuedBandages=0;
       p.downed=false; p.iv=99;
       var pr=p.r||11, W=null, i;
       // A solid wall whose top face blocks a pile placed 18 units below a player pressed against it.
       for(i=0;i<g.map.walls.length&&!W;i++){
         var w=g.map.walls[i];
         if(!(w.w>=40&&w.h>=24)) continue;
         var px=w.x+w.w/2, py=w.y-pr;
         if(!losClear(px,py,px,py+18,g.vseg)&&losClear(px,py,px,py-30,g.vseg)) W={px:px,py:py};
       }
       if(!W) return 'SKIP: no solid wall face to press against';
       var inWall=0;
       for(i=0;i<40;i++){
         p.x=W.px; p.y=W.py; g.bag=[X];
         dropItem(0);
         var c=g.containers[g.containers.length-1];
         if(c&&!losClear(p.x,p.y,c.x,c.y,g.vseg)) inWall++;
       }
       if(inWall>0) bad.push(inWall+' of 40 items dropped against a wall landed where no search can reach them');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ var g2=__state(); if(g2){ if(g2.player) g2.player.iv=0; if(!g2.over) __endRaid('abandon'); } }catch(_e){}
       __topClear(); __resetCfg(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'13.88',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
