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

if ($s.Contains("  {v:'36.16',what:")) { throw "check 36.16 is in the fixture already" }

SubRx @'
  {v:'36.15',what:
'@ @'
  {v:'36.16',what:'the breach label is inside the doorway, away from the outside players, for idle and progress labels at all four gate orientations',
   run:function(){
     var g=null, text=hudText, vx=VX, vy=VY, on=NET.on, ss, s, gp, gs, rec=[], dirs=[[1,0],[-1,0],[0,1],[0,-1]], i,j,dx,dy;
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:['gun_carbine'],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'no raid for breach label placement';
       NET.on=false; g.t=4; keys={}; shTick(0); ss=shS();
       if(!ss.sites||!ss.sites.length) return 'no real gate for breach label placement';
       s=ss.sites[0]; ss.sites=[s]; gp=shGatePt(s); s.open=0;
       VX=gp.x-W/(2*ZOOM()); VY=gp.y-H/(2*ZOOM()); gs=w2s(gp.x,0,gp.y);
       hudText=function(t,x,y){rec.push({t:String(t).toLowerCase().replace(/\s+/g,' '),x:x,y:y});};
       for(i=0;i<dirs.length;i++){
         s.nx=dirs[i][0];s.ny=dirs[i][1];g.player.x=gp.x+s.nx*55;g.player.y=gp.y+s.ny*55;
         for(j=0;j<2;j++){
           s.prog=j?0.42:0;rec=[];shDraw(ctx);
           if(rec.length!==1) return 'expected one gate label at orientation '+i+', got '+rec.length;
           if(j?rec[0].t!=='breaching 42%':!/^hold .+ to breach$/.test(rec[0].t)) return 'gate wording changed: '+rec[0].t;
           dx=rec[0].x-gs.x;dy=rec[0].y-gs.y;
           if(!isFinite(dx+dy)||(dx*s.nx+dy*s.ny)>-30*ZOOM()) return 'label remains on the outside players at orientation '+i+' progress '+j;
         }
       }
       return null;
     }finally{
       hudText=text;VX=vx;VY=vy;NET.on=on;keys={};
       try{__endRaid('abandon');}catch(e){}__topClear();
     }
   }},
  {v:'36.15',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
