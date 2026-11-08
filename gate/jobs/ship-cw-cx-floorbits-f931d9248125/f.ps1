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

if ($s.Contains("  {v:'37.66',what:")) { throw "check 37.66 is in the fixture already" }

SubRx @'
  {v:'37.65',what:
'@ @'
  {v:'37.66',what:'capped loose floor papers, boxes and bolts react to sprint, shots and blasts, settle permanently, and fit a 0.3 ms 4K frame budget',
   run:function(){
     if(typeof floorBitState!=='function') return 'no reactive floor debris';
     var g,s,b,oldFog=fowLive,oldBypass=GFX.bypass,cv,c,i,j,k,t,best=1e9,x,y,oldX,oldY,drawn;
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:['gun_rifle'],safe:null,mapIx:0,seed:4242}); g=__state();
       if(!g||!g.player||g.over) return 'SKIP: no raid';
       s=floorBitState();
       if(!s.list.length||s.list.length>240) return 'bad debris cap or no debris placed';
       for(i=0;i<3;i++) if(!s.list.some(function(q){return q.k===i;})) return 'missing paper, box or bolt';
       x=g.player.x; y=g.player.y; b={x:x+18,y:y,vx:0,vy:0,a:0,k:0}; s.list=[b];
       fowLive=function(){return true;}; GFX.bypass=0;
       wallImpactFx({},x,y,1,0); if(!(b.vx>0)) return 'nearby wall hit did not scatter outward';
       b.vx=b.vy=0; s.frame=-1;
       gfxShot(g.player,g.player.wep,0,true); if(!(b.vx>0)) return 'local shot did not scatter';
       b.vx=b.vy=0; s.frame=-1;
       gfxShotFx(x,y,0,'#fff',1); if(!(b.vx>0)) return 'teammate shot copy did not scatter';
       b.vx=b.vy=0; s.frame=-1;
       gfxBlastScar(x,y,1,true); if(b.vx) return 'roof blast scattered floor';
       gfxBlastScar(x,y,1,false); if(!(b.vx>0)) return 'blast did not scatter';
       b.vx=b.vy=0; s.frame=-1; s.track.p={x:x-24,y:y}; g.sprinting=true; s.sample=0;
       floorBitStep(.08); if(!(b.vx>0)) return 'sprinting body did not scatter';
       g.sprinting=false; s.track={};
       for(i=0;i<120;i++){ g.frameN=(g.frameN||0)+1; floorBitStep(.1); }
       if(b.vx||b.vy||!(b.x>x+18)) return 'debris did not move and settle';
       oldX=b.x; oldY=b.y; for(i=0;i<120;i++) floorBitStep(.1);
       if(s.list[0]!==b||b.x!==oldX||b.y!==oldY) return 'landed debris disappeared or drifted';
       s.frame=-1; for(i=0;i<30;i++) floorBitKick(x,y,500,100);
       if(s.kicks!==12) return 'unbounded impulse workload';
       oldX=b.vx; oldY=b.vy;
       if(floorBitKick(x,y,500,100)!==0||b.vx!==oldX||b.vy!==oldY) return 'exhausted impulse budget still moved debris';
       g.frameN=(g.frameN||0)+1;
       if(floorBitKick(x,y,500,100)!==1||s.kicks!==1) return 'next frame did not reopen impulse budget';
       cv=document.createElement('canvas'); cv.width=3840; cv.height=2160; c=cv.getContext('2d');
       c.setTransform(2,0,0,2,-2*(x-960),-2*(y-540));
       if(floorBitDraw(c,x-960,y-540,1920,1080)!==1) return 'landed scrap was not drawn';
       g.floorBits=null; s=floorBitState(); g.sim=true;
       if(floorBitKick(x,y,100,100)!==0||floorBitDraw({ },0,0,1920,1080)!==0) return 'sim got debris';
       g.sim=false;
       floorBitAtlas();
       x=WORLD_W/2; y=WORLD_H/2; c.setTransform(1,0,0,1,1920-x,1080-y);
       // v28.xx (cw-cx-floorbits): time real update plus clipped sprite submission on a 4K target, with every piece moving.
       for(j=0;j<5;j++){
         t=performance.now();
         for(i=0;i<60;i++){
           for(k=0;k<s.list.length;k++){s.list[k].vx=40;s.list[k].vy=20;}
           floorBitStep(.016); drawn=floorBitDraw(c,x-1920,y-1080,3840,2160);
         }
         best=Math.min(best,(performance.now()-t)/60);
       }
       if(!(drawn>0)) return '4K timing view had no debris';
       s.benchMs=best; if(best>=.3) return '4K debris frame cost '+best.toFixed(3)+' ms (budget <0.3)';
       return null;
     }finally{
       fowLive=oldFog; GFX.bypass=oldBypass; if(g) g.sim=false;
       if(cv){cv.width=1;cv.height=1;}
       try{__endRaid('abandon');}catch(_e){} __topClear();
     }
   }},
  {v:'37.65',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
