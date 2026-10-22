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

if ($s.Contains("  {v:'34.05',what:")) { throw "check 34.05 is in the fixture already" }

SubRx @'
  {v:'34.04',what:
'@ @'
  {v:'34.05',what:'minimap colours have static shapes for sides, downed allies, pings, doors, extraction states, seals and edge objectives',
   run:function(){
     if(typeof mmExtractRing!=='function')return 'extraction states have no static shape backup';
     var g,p,oldGlyph=colourCueGlyph,oldShown=netUpShown,oldVis=VIS,oldUp=NET.up,oldPings=NET.pings,oldWps=NET.wps,seen=[],rings=[],oldRing=mmExtractRing,cv2=document.createElement('canvas'),c,states=['open','closing','inbound','live','closed'],sigs=[],i,j,bytes,sig,d;
     try{
       __runPrep();__topClear();__resetCfg();__pinDefaults(0);__cleanProfile();__deploy({kit:['gun_rifle'],seed:4242,mapIx:0});g=__state();p=g.player;
       cv2.width=90;cv2.height=90;c=cv2.getContext('2d');
       mmDoorMark({x:45,y:45},1,true,c);d=c.getImageData(45,45,1,1).data;if(d[0]>40)return 'open door has no hollow centre';
       mmDoorMark({x:45,y:45},1,false,c);d=c.getImageData(45,45,1,1).data;if(d[0]<80)return 'locked door has no filled centre';
       c.clearRect(0,0,90,90);mmSealMark({x:45,y:45},1,false,'#efe9dc',c);d=c.getImageData(45,45,1,1).data;if(d[0]>40)return 'pending seal has no hollow centre';
       mmSealMark({x:45,y:45},1,true,'#efe9dc',c);d=c.getImageData(45,45,1,1).data;if(d[0]<200)return 'broken seal has no filled centre';
       for(i=0;i<states.length;i++){
         c.clearRect(0,0,90,90);mmExtractRing({x:45,y:45},1,'#efe9dc',18,states[i],c);bytes=c.getImageData(0,0,90,90).data;sig='';
         for(j=3;j<bytes.length;j+=4)sig+=bytes[j]>180?'1':'0';
         if(sigs.indexOf(sig)>=0)return 'two extraction states have the same static shape';sigs.push(sig);
       }
       colourCueGlyph=function(c,k,x,y,R,col){seen.push(k);return oldGlyph.apply(this,arguments);};
       mmExtractRing=function(s,R,col,rad,st,c){rings.push(st);return oldRing.apply(this,arguments);};
       netUpShown=function(q){return !!q.cueTest;};
       NET.up=[{cueTest:1,x:p.x+100,y:p.y+80,f:0,dn:0},{cueTest:1,x:p.x-100,y:p.y+80,f:0,dn:1}];
       NET.pings=[{x:p.x,y:p.y+100,dg:1},{x:p.x+60,y:p.y+100,w:'sentry'},{x:p.x-60,y:p.y+100},{x:p.x-120,y:p.y+100,pl:1,w:'scrap'}];
       NET.wps={1:{x:p.x+3000,y:p.y}};g.waypoint={x:p.x+3000,y:p.y+50};
       g.seal={x:p.x+3000,y:p.y+100,done:false};g.forge={x:p.x+3000,y:p.y+150};
       g.zones=states.map(function(st,i){return {x:p.x+3000,y:p.y-200+i*50,r:30,open:st!=='closed',beaconT:st==='inbound'?12:st==='live'?0:null,hold:st==='live'?5:null,closeAt:st==='closing'?g.timeLeft-10:undefined};});
       g.map.locked=[{x:p.x-100,y:p.y,w:40,h:40,open:false},{x:p.x+100,y:p.y,w:40,h:40,open:true}];
       VIS=[{kind:'sentry',hp:100,x:p.x+150,y:p.y-80},{kind:'raider',hp:100,x:p.x+120,y:p.y-60,merc:true}];
       mmMarks({x:200,y:200,w:300,h:300},.3,1);
       for(i=0;i<10;i++)if(seen.indexOf(['ally','down','danger','target','place','loot','partywaypoint','waypoint','seal','forge'][i])<0)return 'missing glyph '+['ally','down','danger','target','place','loot','partywaypoint','waypoint','seal','forge'][i];
       if(MMAP.got.foes.length!==1||MMAP.got.foes[0]!==VIS[0])return 'the minimap changed its hostile visibility filter';
       if(MMAP.got.doors!==2||MMAP.got.mates!==2)return 'doors or teammates were lost';
       for(i=1;i<4;i++)if(rings.indexOf(states[i])<0)return 'missing offscreen extraction state '+states[i];
       seen=[];netWpMapDraw(0,0,.1);for(i=0;i<4;i++)if(seen.indexOf(['danger','target','place','loot'][i])<0)return 'sector map ping shape missing';
       return null;
     }finally{colourCueGlyph=oldGlyph;mmExtractRing=oldRing;netUpShown=oldShown;VIS=oldVis;NET.up=oldUp;NET.pings=oldPings;NET.wps=oldWps;try{__endRaid('abandon');}catch(_e){}__topClear();}
   }},
  {v:'34.04',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
