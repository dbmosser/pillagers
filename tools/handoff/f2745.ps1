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

if ($s.Contains("  {v:'27.45',what:")) { throw "check 27.45 is in the fixture already" }

SubRx @'
  {v:'27.44',what:
'@ @'
  {v:'27.45',what:'rvw3, the cloud review (9): the magnet power-up does not pull the reward box of an event (stronghold cache, convoy crate, golden hoard) and moves no box at all in a party, but still pulls a plain body when playing alone',
   run:function(){
     if(!(window.__state&&window.__endRaid&&window.__runPrep)) return 'SKIP: no raid here';
     if(typeof arcadeDeploy!=='function'||typeof ARCADE!=='object'||typeof pwrMagnet!=='function'||typeof pwrS!=='function'||typeof mkContainer!=='function') return 'SKIP: no arcade or magnet here';
     var bad=[], g=null, p=null, S, c1, c2, c3, k, a, spots=[], NKon, NKrole, d0, i, loot, box, p3;
     try{
       __topClear(); __runPrep();
       if(ARCADE.on) return 'SKIP: the arcade is on after __topClear';
       if(!arcadeDeploy({mapIx:0,seed:4242})) return 'SKIP: arcadeDeploy built no arcade raid';
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       p=g.player; keys={};
       for(k=0;k<48&&spots.length<3;k++){ a=k*0.5236+0.3; if(spotFree(g.map,p.x+Math.cos(a)*210,p.y+Math.sin(a)*210,20)&&spotFree(g.map,p.x+Math.cos(a)*120,p.y+Math.sin(a)*120,14)&&spotFree(g.map,p.x+Math.cos(a)*60,p.y+Math.sin(a)*60,14)&&(!spots.length||Math.abs(a-spots[spots.length-1].a)>1.2)) spots.push({a:a,x:p.x+Math.cos(a)*210,y:p.y+Math.sin(a)*210}); }
       if(spots.length<3) return 'SKIP: no open ground for three boxes next to the player';
       box=function(sp,type,tag){ var c=mkContainer(sp.x,sp.y,type); if(!c.loot||!c.loot.length) c.loot=[rollLoot(LOOT.cache)]; if(tag) c.tag=tag; c.opened=false; g.containers.push(c); return c; };
       c1=box(spots[0],'cache','STRONGHOLD CACHE'); c2=box(spots[1],'body',null); c3=box(spots[2],'body',null);
       S=pwrS();
       // ONE: alone: the plain body comes in, the stronghold cache does not
       d0=Math.hypot(c2.x-p.x,c2.y-p.y); pwrMagnet(p,0.5,S);
       if(!(Math.hypot(c2.x-p.x,c2.y-p.y)<d0-5)) bad.push('ONE: the magnet no longer pulls a plain body when playing alone');
       if(Math.hypot(c1.x-spots[0].x,c1.y-spots[0].y)>0.5) bad.push('ONE: the magnet pulled the stronghold cache');
       // TWO: in a party it moves no box at all
       p3={x:c3.x,y:c3.y}; NKon=NET.on; NKrole=NET.role; NET.on=true; NET.role='host';
       try{ d0=Math.hypot(c3.x-p.x,c3.y-p.y); pwrMagnet(p,0.5,S); if(Math.hypot(c3.x-p3.x,c3.y-p3.y)>0.5) bad.push('TWO: the magnet moved a box in a party'); }
       finally{ NET.on=NKon; NET.role=NKrole; }
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       keys={};
       try{ if(typeof ARCADE==='object'&&ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       try{ if(typeof ARCADE==='object'){ ARCADE.mine=0; ARCADE.waveT=0; ARCADE.holdT=0; } }catch(_h){}
       __topClear();
     }
     return bad.length?bad.slice(0,8).join('; '):null; }},
  {v:'27.44',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
