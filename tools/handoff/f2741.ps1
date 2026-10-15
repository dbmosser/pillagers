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

if ($s.Contains("  {v:'27.41',what:")) { throw "check 27.41 is in the fixture already" }

SubRx @'
  {v:'27.40',what:
'@ @'
  {v:'27.41',what:'the cloud review (finding 22), the Overseer is not an endless crawler farm: it calls three crawlers at a time and twelve in all, however long the fight goes on',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)||typeof overseerSummon!=='function'||typeof spotFree!=='function') return 'SKIP: no raid here';
     var bad=[], g=null, p=null, all=null, e, k, a, x, y, q, n, made, total=0, calls=0, ok=false, free, cx=0, cy=0;
     function inW(x2,y2){ return x2>200&&y2>200&&x2<WORLD_W-200&&y2<WORLD_H-200; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over) return 'SKIP: no live raid';
       p=g.player; p.iv=99; p.hp=100000; p.downed=false; all=g.ents.slice();
       // open ground all round (every ring point the summon may pick is free)
       var bf=-1, bx=0, by=0; for(q=0;q<900;q++){
         cx=300+((q*397)%(WORLD_W-600)); cy=300+((q*613)%(WORLD_H-600)); free=0;
         for(a=0;a<24;a++){ x=cx+Math.cos(a*0.2618)*124; y=cy+Math.sin(a*0.2618)*124; if(inW(x,y)&&spotFree(g.map,x,y,18)) free++; }
         if(free>bf&&spotFree(g.map,cx,cy,30)){ bf=free; bx=cx; by=cy; }
       }
       ok=bf>=18; cx=bx; cy=by; if(!ok) return 'SKIP: no open ground for the Overseer ring';
       e={kind:'warden',boss:1,x:cx,y:cy,r:44,hp:900,maxhp:900,state:'patrol',face:0};
       for(n=0;n<8;n++){
         g.ents=g.ents.filter(function(o){ return !o.summoned; });
         made=overseerSummon(e); calls++; total+=made;
         if(n===0&&made!==3) bad.push('the first call made '+made+' crawlers, not 3');
       }
       if(total!==12) bad.push('eight calls made '+total+' crawlers, not the twelve it may call in all');
       if((e.sumN|0)!==total) bad.push('the running total reads '+e.sumN+' for '+total+' made');
       g.ents=g.ents.filter(function(o){ return !o.summoned; });
       if(overseerSummon(e)!==0) bad.push('a ninth call still made crawlers');
     }catch(x2){ bad.push('threw: '+(x2&&x2.message||x2)); }
     finally{
       try{ var g2=__state(); if(g2){ if(all) g2.ents=all; if(!g2.over){ g2.player.iv=0; g2.player.hp=100; g2.player.downed=false; __endRaid('abandon'); } } }catch(_e3){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'27.40',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
