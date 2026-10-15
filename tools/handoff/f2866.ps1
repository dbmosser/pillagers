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

if ($s.Contains("  {v:'28.66',what:")) { throw "check 28.66 is in the fixture already" }

SubRx @'
  {v:'28.65',what:
'@ @'
  {v:'28.66',what:'cloud-robust-fire-wall: a fire that lights on a body beside a wall pushes it out on its own side, never through the wall',
   run:function(){
     if(typeof fireAdd!=='function'||typeof fireKeep!=='function'||typeof losClear!=='function'||!window.__deploy) return 'SKIP: no fires here';
     var bad=[], co=CAREER_ON, ts, p, W, j, w, y, x0, n=0;
     function fr(k){ for(var q=0;q<k;q++){ ts+=50; if(G&&G.player) G.player.hp=Math.max(G.player.hp,90); HID.fromWorker=1; try{ loop(ts); } finally{ HID.fromWorker=0; } } }
     try{
       __topClear(); __runPrep(); CAREER_ON=1; __deploy({kit:[],mapIx:0,seed:7});
       if(!G||!G.player||!G.map||!G.map.walls) return 'SKIP: no CAREER raid was built';
       ts=performance.now()+100000; fr(20); p=G.player;
       if(!G.flow||!G.flow.fires) return 'SKIP: the raid has no fire list';
       W=G.map.walls.filter(function(v){ return v.w<=30&&v.h>220; });
       for(j=0;j<W.length&&n<3;j++){
         w=W[j]; y=w.y+w.h/2; x0=w.x-20;
         if(!spotFree(G.map,x0,y,12)||!spotFree(G.map,w.x+w.w+40,y,12)) continue;
         n++; p.x=x0; p.y=y; p.vx=0; p.vy=0; G.flow.fires.length=0; fireAdd(w.x-60,y,92,55,'fuel',0); fr(1);
         if(!losClear(x0,y,p.x,p.y,G.map.segs)) bad.push('the fire put the player through the wall at x '+w.x+' (from '+x0+' to '+Math.round(p.x)+')');
       }
       if(!n) return 'SKIP: no thin wall with open floor on both sides on this seed';
     } finally {
       try{ if(G&&G.flow&&G.flow.fires) G.flow.fires.length=0; if(G&&!G.over) endRaid('abandon'); }catch(_e){}
       CAREER_ON=co; __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'28.65',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
