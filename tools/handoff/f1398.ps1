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
  {v:'13.97',what:
'@ @'
  {v:'13.98',what:'a crew pick-up clears your kill credit: a pillager you downed and his crewmate picked up no longer carries your kill flag, the way your own revive clears it (machine and pillager AI audit 2026-09-14, finding 3)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     if(typeof mkRaider!=='function'||typeof updateEnts!=='function') return 'SKIP: no pillagers in this build';
     var bad=[];
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(), p=g.player;
       if(!g||!p) return 'SKIP: no live raid';
       var Z=null, zi;
       for(zi=0;zi<g.zones.length&&!Z;zi++) if(losClear(g.zones[zi].x,g.zones[zi].y,g.zones[zi].x+40,g.zones[zi].y,g.map.segs)) Z=g.zones[zi];
       if(!Z) return 'SKIP: no clear ground to stage the pick-up on';
       var A=mkRaider(Z.x,Z.y,null,false), B=mkRaider(Z.x+30,Z.y,null,false);
       B.crew=A.crew; A.hostile=true; B.hostile=true;
       A.downed=1; A.downT=10; A.hp=1; A.state='down'; A.byPlayer=true;
       B.state='loot'; B.reviving=A; B.revProg=3.19; B.alert=0; B.goal=null;
       g.ents.length=0; g.ents.push(A); g.ents.push(B);
       p.x=Z.x+2000; p.y=Z.y+2000; p.iv=99;
       for(var f=0;f<3&&A.downed;f++) updateEnts(0.02);
       if(A.downed) return 'SKIP: the crewmate did not pick him up in the staged frames, so nothing here can be measured';
       if(A.byPlayer) bad.push('a pillager you downed and his crewmate picked up still carries your kill credit, so a later Howler or bleed-out death is billed to you');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ var g2=__state(); if(g2){ if(g2.player) g2.player.iv=0; if(!g2.over) __endRaid('abandon'); } }catch(_e){}
       __topClear(); __resetCfg(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'13.97',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
