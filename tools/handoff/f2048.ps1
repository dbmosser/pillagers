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

if ($s.Contains("  {v:'20.48',what:")) { throw "check 20.48 is in the fixture already" }

SubRx @'
  {v:'20.47',what:
'@ @'
  {v:'20.48',what:'the Choir stands on its cache box where the box ends up: with the reach pass moving the first landmark cache box, the pillbox stands on the box and not on the spot the box left',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof mkContainer!=='function'||typeof navReachable!=='function'||typeof spotFree!=='function') return 'SKIP: no raid build here';
     var bad=[], oMk=mkContainer, oNR=navReachable, made=[], hit=null, g, ch=null, i, d;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       // Every cache box the build makes is noted, and the reach pass is told once that the first landmark cache box cannot be
       // walked to, so it moves that box as it moves any stranded box.
       mkContainer=function(x,y,type,dd){ var c=oMk.apply(this,arguments); if(type==='cache'&&c) made.push(c); return c; };
       navReachable=function(map,x,y){
         if(!hit||hit.map!==map){
           var lt=(map&&map.landmarks&&map.landmarks[0])?String(map.landmarks[0].name).toUpperCase()+' CACHE':null, j, c;
           for(j=made.length-1;lt&&j>=0;j--){ c=made[j]; if(c.tag===lt&&c.x===x&&c.y===y){ hit={map:map,c:c,x:x,y:y}; return false; } }
         }
         return oNR.apply(this,arguments);
       };
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       mkContainer=oMk; navReachable=oNR;
       g=__state(); if(!g||g.over) return 'SKIP: no live raid';
       if(!hit||hit.map!==g.map) return 'SKIP: staging: the reach pass never weighed the landmark cache box';
       if(g.containers.indexOf(hit.c)<0) return 'SKIP: staging: the landmark cache box is not in this raid';
       if(hit.c.x===hit.x&&hit.c.y===hit.y) return 'SKIP: staging: the reach pass did not move the landmark cache box';
       for(i=0;i<g.ents.length;i++) if(g.ents[i].kind==='choir'){ ch=g.ents[i]; break; }
       if(!ch) return 'SKIP: no Choir in this raid';
       d=Math.sqrt((ch.x-hit.c.x)*(ch.x-hit.c.x)+(ch.y-hit.c.y)*(ch.y-hit.c.y));
       if(d>1) bad.push('the Choir stands '+Math.round(d)+' from its cache box'+((Math.abs(ch.x-hit.x)<1&&Math.abs(ch.y-hit.y)<1)?', on the spot the box was moved off':''));
       if(Math.abs(ch.homeX-ch.x)>1||Math.abs(ch.homeY-ch.y)>1) bad.push('the Choir home is not where it stands');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       mkContainer=oMk; navReachable=oNR;
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'20.47',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
