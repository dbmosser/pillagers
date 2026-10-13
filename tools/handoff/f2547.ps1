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

if ($s.Contains("  {v:'25.47',what:")) { throw "check 25.47 is in the fixture already" }

SubRx @'
  {v:'25.46',what:
'@ @'
  {v:'25.47',what:'his answer 9 a: a lone pillager flanks at 1.6 rad, and finds cover out to 900 and two steps away',
   run:function(){
     var bad=[], g, sv, e, p, s, ang;
     try{
       __topClear(); __runPrep(); __resetCfg();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over) return 'SKIP: no live raid';
       e={x:0,y:0,flank:1}; ang=raiderFlankAng(e,0.3);
       if(Math.abs(ang-(0.3+1.6))>1e-9) bad.push('a lone man flanks at '+(ang-0.3).toFixed(3)+' rad, not 1.6');
       e.crewArc=-0.7; if(Math.abs(raiderFlankAng(e,0.3)-(0.3-0.7))>1e-9) bad.push('a crew station was not kept');
       sv=g.vseg;
       e={x:9000,y:9000}; p={x:9000-750,y:9000};
       g.vseg=[{x1:9000-40,y1:9000-30,x2:9000-40,y2:9000+30}];
       s=raiderCoverSpot(e,p,750);
       if(!s) bad.push('no cover found at 750 behind a wall 40 off');
       else if(losClear(p.x,p.y,s.x,s.y,g.vseg)) bad.push('the cover spot is in the open');
       g.vseg=[{x1:9000+120,y1:9000-300,x2:9000+120,y2:9000+300},{x1:9000+140,y1:9000-300,x2:9000+140,y2:9000+300}];
       s=raiderCoverSpot(e,p,750);
       if(s&&losClear(p.x,p.y,s.x,s.y,g.vseg)) bad.push('a spot in the open was taken for cover');
       g.vseg=[];
       if(raiderCoverSpot(e,p,750)) bad.push('cover found on open ground');
       if(raiderCoverSpot(e,p,950)) bad.push('cover searched beyond 900');
       g.vseg=sv;
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       keys={};
       try{ var g2=__state(); if(g2&&g2.map) g2.vseg=g2.map.segs; }catch(_v){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'25.46',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
