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

if ($s.Contains("  {v:'25.36',what:")) { throw "check 25.36 is in the fixture already" }

SubRx @'
  {v:'25.35',what:
'@ @'
  {v:'25.36',what:'his answer 8 a: an enemy round spreads wider at long range, a close one and the player gun as before',
   run:function(){
     var bad=[], g, p, sh, w, i, b, n0, near=0, far=0, mine=0, mineN=0, dv;
     function dev(tx,ty,fp,who){ var mx=0, k, a0=Math.atan2(ty-who.y,tx-who.x), d;
       for(k=0;k<300;k++){ n0=g.bullets.length; fireWeapon(who,w,tx,ty,fp); b=g.bullets[g.bullets.length-1]; if(g.bullets.length>n0&&b){ d=Math.abs(Math.atan2(Math.sin(Math.atan2(b.vy,b.vx)-a0),Math.cos(Math.atan2(b.vy,b.vx)-a0))); if(d>mx) mx=d; } g.bullets.length=0; g.shells.length=0; }
       return mx; }
     try{
       __topClear(); __runPrep(); __resetCfg();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); p=g.player; if(!g||g.over) return 'SKIP: no live raid';
       w={dmg:1,spread:0.1,rng:2400,noise:1,tint:'#ffffff'};
       sh={x:p.x+50,y:p.y,kind:'sentry',name:'T',hp:100,r:12,face:0};
       near=dev(sh.x+200,sh.y,false,sh); far=dev(sh.x+1000,sh.y,false,sh);
       if(!(near>0.07&&near<=0.1001)) bad.push('a close enemy round spread '+near.toFixed(3)+', not about 0.10 as before');
       if(!(far>0.15)) bad.push('an enemy round at 1000 spread only '+far.toFixed(3)+' (close '+near.toFixed(3)+')');
       if(far>0.1801) bad.push('an enemy round at 1000 spread '+far.toFixed(3)+', more than 1.8 times');
       p.ads=false; mine=dev(p.x+1000,p.y,true,p);
       if(mine>0.1001) bad.push('the player gun at range spread '+mine.toFixed(3)+', wider than its 0.10');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       keys={};
       try{ var g2=__state(); if(g2){ g2.bullets.length=0; } }catch(_b){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'25.35',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
