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

# v12.07 CHECK, inserted before the v12.06 entry. ARM A: a crawler from a spawn
# 600+ units out, holding the standing player's live position as its last
# sighting, with every other machine removed, must bite him within 14 s (on
# v12.06 it gives up on the way and turns to patrol). ARM B: a chase on a point
# nothing can reach must still end within 15 s (the overtime is capped).
SubRx @'
  {v:'12.06',what:'the floor treats the character screen as a modal: hubModalOpen reads open while #title is on, so E, R, F and T no longer reach the stations behind it (2026-09-06 menu audit)',
'@ @'
  {v:'12.07',what:'a crawler still on its way to the last place it saw you keeps the chase until it gets there and bites a man standing still, and a chase on an unreachable point still ends (his note of 2026-09-06)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__ents)) return 'SKIP: this fixture cannot deploy and step';
     var bad=[];
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(), p=g.player, i, e=null, spot=null, best=1e9;
       for(i=0;i<g.ents.length;i++){ if(!e&&g.ents[i].kind==='crawler') e=g.ents[i]; var _d=dist(g.ents[i],p); if(_d>600&&_d<best){ best=_d; spot={x:g.ents[i].x,y:g.ents[i].y}; } }
       if(!e||!spot) return 'SKIP: no crawler, or no spawn 600 units out';
       for(i=g.ents.length-1;i>=0;i--) if(g.ents[i]!==e) g.ents.splice(i,1);   // only the crawler moves in this room
       p.downed=false; var hp0=p.hp;
       // ARM A: his live position is its last sighting; he stands still.
       e.x=spot.x; e.y=spot.y; e.cd=0; e.path=null; e.pathGoal=null; e.chaseHold=0;
       e.state='chase'; e.alert=2.4; e.tx=p.x; e.ty=p.y; e.face=Math.atan2(p.y-e.y,p.x-e.x);
       var f, dmin=1e9;
       for(f=0;f<840&&p.hp>=hp0;f++){ __ents(1/60); var _dd=dist(e,p); if(_dd<dmin) dmin=_dd; }
       if(p.hp>=hp0) bad.push('the crawler never bit a man standing still '+Math.round(best)+' units from its start in 14 s (closest '+Math.round(dmin)+', ended '+e.state+' at '+Math.round(dist(e,p))+')');
       // ARM B: a last sighting nothing can reach still ends the chase.
       e.x=spot.x; e.y=spot.y; e.cd=0; e.path=null; e.pathGoal=null; e.chaseHold=0; p.hp=hp0;
       e.state='chase'; e.alert=2.4; e.tx=-600; e.ty=-600;
       for(f=0;f<900;f++) __ents(1/60);
       if(e.state==='chase') bad.push('a chase on an unreachable point never ended (15 s)');
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{ try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('extract'); } }catch(_e){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'12.06',what:'the floor treats the character screen as a modal: hubModalOpen reads open while #title is on, so E, R, F and T no longer reach the stations behind it (2026-09-06 menu audit)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
