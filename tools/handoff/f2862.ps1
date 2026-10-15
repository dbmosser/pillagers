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

if ($s.Contains("  {v:'28.62',what:")) { throw "check 28.62 is in the fixture already" }

SubRx @'
  {v:'28.61',what:
'@ @'
  {v:'28.62',what:'cloud-raid-pwrdeath: in the two player DEMO a player who dies with power-ups running comes back from the respawn with none',
   run:function(){
     if(!(window.__state&&window.__runPrep&&window.__loop)) return 'SKIP: no raid here';
     if(typeof arcadeDeploy!=='function'||typeof pwrS!=='function'||typeof killPlayer!=='function'||typeof ARCADE!=='object') return 'SKIP: no arcade or power-ups in this fixture';
     var g=null, p=null, rs=say, own=false, S, i, t0, k, left=[];
     try{
       __topClear(); __runPrep();
       if(!arcadeDeploy({mapIx:0,seed:4242})) return 'SKIP: arcadeDeploy built no arcade raid';
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       if(ARCADE.solo) return 'SKIP: staging: this arcade raid is the 1 player DEMO';
       p=g.player; keys={}; say=function(){}; own=true;
       t0=performance.now()+1000;
       for(i=0;i<5;i++){ t0+=16.7; __loop(t0); }
       ARCADE.holdT=0; p.arcSh=0;
       S=pwrS(); S.act={dmg:15,mag:20,rapid:15};
       for(i=0;i<3;i++){ t0+=16.7; __loop(t0); }
       if(!(S.act.dmg>0)) return 'SKIP: staging: the power-ups did not run';
       killPlayer('test');
       for(i=0;i<130;i++){ t0+=16.7; __loop(t0); if(G!==g) break; }
       if(G!==g) return 'SKIP: staging: the death ended the raid';
       if(p.dying||p.downed||!(p.hp>0)) return 'SKIP: staging: the player did not respawn';
       for(k in G.pwr.act) if(G.pwr.act[k]>0) left.push(k+' '+(+G.pwr.act[k]).toFixed(1));
       return left.length?'after the death and the respawn the power-ups still run: '+left.join(', '):null;
     }catch(x){ return 'threw: '+(x&&x.stack||x); }
     finally{ if(own) say=rs; try{ __endRaid('abandon'); }catch(_e){} try{ __topClear(); }catch(_t){} }
   }},
  {v:'28.61',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
