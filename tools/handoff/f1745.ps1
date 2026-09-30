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

if ($s.Contains("  {v:'17.45',what:")) { throw "check 17.45 is in the fixture already" }

SubRx @'
  {v:'17.44',what:
'@ @'
  {v:'17.45',what:'THE OVERSEER: no boss at the build, one comes up two seconds in at the open ground nearest the map centre with 4000 health (times the dial), never a second one, and down it leaves the OVERSEER HOARD',
   run:function(){
     if(typeof bossTick!=='function'||typeof bossLair!=='function') return 'this build has no boss';
     if(!window.__deploy||!window.__endRaid) return 'SKIP: no raid in this fixture';
     var bad=[], e, n, cx, cy, gr, nw, i, w, inWall=false, oSay=say, ents0;
     try{
       __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       if(!G||G.over) return 'SKIP: staging: no raid';
       say=function(){};
       ents0=G.ents.length; G.t=0.5; bossTick();
       if(G.ents.length!==ents0) bad.push('a boss came up before two seconds');
       G.t=2.5; e=bossTick();
       if(!e||G.ents.indexOf(e)<0||e.name!=='THE OVERSEER') bad.push('no OVERSEER came up at two seconds');
       else{
         cx=WORLD_W/2; cy=WORLD_H/2;
         if(Math.hypot(e.x-cx,e.y-cy)>1700) bad.push('the boss came up '+Math.round(Math.hypot(e.x-cx,e.y-cy))+' from the map centre');
         gr=buildWallGrid(G.map.walls,WORLD_W,WORLD_H); nw=wallsNear(gr,e.x,e.y,20);
         for(i=0;i<nw.length;i++){ w=nw[i]; if(e.x>w.x&&e.x<w.x+w.w&&e.y>w.y&&e.y<w.y+w.h) inWall=true; }
         if(inWall) bad.push('the boss came up inside a wall');
         if(e.maxhp!==Math.round(4000*(CFG.eHp||1))) bad.push('the boss has '+e.maxhp+' health, not 4000 times the dial');
         n=G.ents.length; G.t=5; bossTick(); if(G.ents.length!==n) bad.push('a second boss came up');
         e.hp=0; updateEnts(0.05);
         if(!G.containers.some(function(c){ return c&&c.tag==='OVERSEER HOARD'; })) bad.push('the boss went down and left no OVERSEER HOARD');
       }
     }catch(ex){ bad.push('threw: '+(ex&&ex.message||ex)); }
     finally{
       say=oSay;
       try{ __endRaid('abandon'); __topClear(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'17.44',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
