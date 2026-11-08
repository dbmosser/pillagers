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

if ($s.Contains("  {v:'37.58',what:")) { throw "check 37.58 is in the fixture already" }

SubRx @'
  {v:'37.57',what:
'@ @'
  {v:'37.58',what:'three outdoor machines follow four fixed reachable stops in order, pause, and resume after an interruption',
   run:function(){
     var oldCareer=CAREER_ON, oldBoss=bossTick, g, a, seen=[], i, j;
     function expect(ok,msg){ if(!ok) throw Error(msg); }
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       CAREER_ON=1; __deploy({kit:[],safe:null,mapIx:0,seed:4242}); g=__state();
       a=g.ents.filter(function(e){ return !!e.route; });
       expect(a.length===3,'expected three patrollers, got '+a.length);
       for(i=0;i<a.length;i++){
         var e=a[i]; expect(e.route.length===4&&e.ri===0,'four stops and initial index');
         expect(!e.camp&&!e.elite&&!e.boss&&!e.sleep&&!buildingAtPt(g.map,e.x,e.y),'ineligible patroller');
         for(j=0;j<4;j++){
           var p=e.route[j], d=dist(p,e.route[(j+1)%4]);
           expect(d>=400&&d<=1200,'leg outside 400 to 1200');
           expect(!buildingAtPt(g.map,p.x,p.y)&&navReachable(g.map,p.x,p.y),'blocked stop');
         }
         seen.push(0);
       }
       // v28.xx (cw-cx-patrolroutes): real map and spawn positions; remove combat and noise sources only.
       g.ents=a; g.prints=[]; g.pings=[]; g.sim=true; g.reinfT=1e9; bossTick=function(){};
       g.player.x=-10000; g.player.y=-10000; g.player.iv=999;
       for(var f=0;f<2400;f++){
         g.t+=.05; __ents(.05);
         for(i=0;i<a.length;i++) if(seen[i]<4&&dist(a[i],a[i].route[seen[i]])<40) seen[i]++;
       }
       for(i=0;i<a.length;i++) expect(seen[i]===4,'patroller '+i+' visited '+seen[i]+' of four stops in 120 seconds');
       var e=a[0], p=e.route[2]; e.x=p.x; e.y=p.y; e.state='investigate';
       __ents(0); e.state='patrol'; e.heardT=0; e.alert=0; e.cd=5;
       __ents(0); expect(e.ri===2&&e.routeHold===2,'nearest stop did not resume with two second hold');
       var x=e.x,y=e.y;
       for(i=0;i<39;i++) __ents(.05);
       expect(e.ri===2&&dist(e,{x:x,y:y})<1,'patroller moved during hold');
       for(i=0;i<2;i++) __ents(.05);
       expect(e.ri===3,'patroller did not advance after hold');
       return null;
     }catch(err){ return String(err.message||err); }
     finally{ bossTick=oldBoss; CAREER_ON=oldCareer; try{__endRaid('abandon');}catch(_e){} __topClear(); }
   }},
  {v:'37.57',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
