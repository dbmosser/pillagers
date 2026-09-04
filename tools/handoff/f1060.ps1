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
  {v:'10.59',what:'seen through a wall in a raid, the operator is painted in his own colours, faded, and not as a light-blue cutout',
'@ @'
  {v:'10.60',what:'every Undercroft body has a radius and none of them is ever inside a wall while the room runs for a minute',
   run:function(){
     var bad=[];
     if(!(window.__hubEnter&&window.__hubStep)) return 'SKIP: this build cannot step the floor';
     if(!(W>0&&H>0)) return 'SKIP: the pane is 0x0';
     __hubEnter(); if(!HB||!HB.crowd||!HB.walls) return 'the Undercroft did not build';
     var _open=[]; Array.prototype.forEach.call(document.querySelectorAll('.modal.on,#hub.on,#pausebox.on,#outcome.on'),function(el){ _open.push(el); el.classList.remove('on'); });
     for(var k in keys) keys[k]=false;
     var noR=0; for(var i=0;i<HB.crowd.length;i++) if(!(HB.crowd[i].r>0)) noR++;
     if(noR) bad.push(noR+' of '+HB.crowd.length+' bodies have no radius, so the wall push cannot move them');
     // A body is in a wall when the wall's rect comes closer than half its radius:
     // the push keeps a body r clear, so half r is well inside the fault.
     function inWall(c){ var r=(c.r||12)*0.5; for(var j=0;j<HB.walls.length;j++){ var w=HB.walls[j]; var cx=Math.max(w.x,Math.min(c.x,w.x+w.w)), cy=Math.max(w.y,Math.min(c.y,w.y+w.h)); if(Math.hypot(c.x-cx,c.y-cy)<r) return w; } return null; }
     var hits=0, worst=null, steps=1200;
     try{
       for(var s=0;s<steps;s++){
         __hubStep(0.05);
         for(i=0;i<HB.crowd.length;i++){ var c=HB.crowd[i]; if(c.away>0) continue; var w=inWall(c); if(w){ hits++; if(!worst) worst={i:i,x:Math.round(c.x),y:Math.round(c.y),w:w,step:s}; } }
       }
     } finally { for(var o=0;o<_open.length;o++) _open[o].classList.add('on'); }
     if(hits) bad.push('over '+steps+' steps of the room, bodies were inside a wall '+hits+' times; first at step '+worst.step+': body '+worst.i+' at '+worst.x+','+worst.y+' inside the wall at '+worst.w.x+','+worst.w.y+' '+worst.w.w+'x'+worst.w.h);
     return bad.length?bad.join('; '):null; }},
  {v:'10.59',what:'seen through a wall in a raid, the operator is painted in his own colours, faded, and not as a light-blue cutout',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
