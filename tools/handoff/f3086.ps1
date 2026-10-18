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

if ($s.Contains("  {v:'30.86',what:")) { throw "check 30.86 is in the fixture already" }

SubRx @'
  {v:'30.85',what:
'@ @'
  {v:'30.86',what:'the player 2 window arrives on the Undercroft floor beside the lamp and not on the very spot player 1 arrives on, so the two bodies never stand on top of each other (his order of 2026-10-18: players 1 and 2 should be able to see each other in the undercroft): player 1 still arrives at the lamp, 140,390; player 2 arrives at least 30 units away from it, inside the lamp light and clear of the walls',
   run:function(){
     if(typeof NETP2==='undefined'||typeof showScreen!=='function'||!window.__hubEnter||!window.__topClear) return 'SKIP: this fixture cannot reach the Undercroft floor as a player 2 window';
     if(typeof G!=='undefined'&&G&&!G.over) return 'SKIP: a raid is running, and the floor is not up';
     var o2=NETP2, bad=[], a=null, b=null, c=null, d=0;
     try{
       __topClear();
       NETP2=false; __hubEnter();
       if(typeof state==='undefined'||state!=='hub'||!HB||!HB.player) return 'SKIP: the Undercroft floor is not up here';
       a={x:HB.player.x,y:HB.player.y};
       NETP2=true; __hubEnter();
       b={x:HB.player.x,y:HB.player.y};
       d=Math.sqrt((b.x-a.x)*(b.x-a.x)+(b.y-a.y)*(b.y-a.y));
       if(Math.abs(a.x-140)>0.5||Math.abs(a.y-390)>0.5) bad.push('control: player 1 no longer arrives at the lamp, 140,390 ('+a.x+','+a.y+')');
       if(d<30) bad.push('the player 2 window arrives '+d.toFixed(1)+' units from player 1, on top of him');
       if(d>=30){
         if(Math.sqrt((b.x-140)*(b.x-140)+(b.y-390)*(b.y-390))>110) bad.push('the player 2 window arrives outside the lamp light ('+b.x.toFixed(1)+','+b.y.toFixed(1)+')');
         c={x:HB.player.x,y:HB.player.y}; collide(HB.player,HB.dwalls);
         if(Math.abs(HB.player.x-c.x)>0.5||Math.abs(HB.player.y-c.y)>0.5) bad.push('the player 2 window arrives inside a wall and is pushed out ('+c.x.toFixed(1)+','+c.y.toFixed(1)+')');
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ NETP2=o2; }catch(_n){}
       try{ [].forEach.call(document.querySelectorAll('.modal.on'),function(m){ m.classList.remove('on'); }); }catch(_m){}
       try{ __hubEnter(); }catch(_h){}
       try{ __topClear(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'30.85',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
