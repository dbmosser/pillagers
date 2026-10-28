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

if ($s.Contains("  {v:'35.78',what:")) { throw "check 35.78 is in the fixture already" }

SubRx @'
  {v:'35.77',what:
'@ @'
  {v:'35.78',what:'cw-skybolt: a landed lightning strike leaves a render only sky bolt: a jagged white line from the top edge of the view down to the strike point with side forks, the same shape for the same strike, no game random draw, gone in about a third of a second, none at effects reduced, none off screen, none in the sim',
   run:function(){
     if(typeof boltMark!=='function'||typeof drawBolts!=='function'||typeof boltShape!=='function') return 'no sky bolt in this build';
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'this fixture cannot deploy';
     var storm=null, i; for(i=0;i<WEATHER.length;i++) if(WEATHER[i].lightning){ storm=WEATHER[i]; break; }
     if(!storm) return 'no lightning weather';
     var bad=[], g0=null, wx0=null, sim0=false, _dp=damagePlayer, _rr=rr, c0=JSON.stringify(CFG);
     function stub(){ var o={ops:[],strokes:0,fills:0}; ['save','restore','beginPath','arc'].forEach(function(k){ o[k]=function(){}; });
       o.moveTo=function(x,y){ o.ops.push(['m',x,y]); }; o.lineTo=function(x,y){ o.ops.push(['l',x,y]); };
       o.stroke=function(){ o.strokes++; }; o.fill=function(){ o.fills++; };
       o.createLinearGradient=function(){ return {addColorStop:function(){}}; }; o.createRadialGradient=o.createLinearGradient; return o; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(), p=g&&g.player; if(!g||!p) return 'no live raid';
       g0=g; wx0=g.wx; sim0=g.sim; g.ents.length=0; g.wx=storm; g.wxNext=null; g.strikeAt=999; g.bolts=[];
       damagePlayer=function(){};
       var sx=p.x+300, sy=p.y+60;
       g.strikes=[{x:sx,y:sy,t:0.001,hit:0,id:77}]; strikeTick(0.016);
       var b=g.bolts&&g.bolts[0];
       if(!b||g.bolts.length!==1) bad.push('a landed strike left no sky bolt: '+JSON.stringify(g.bolts));
       else if(Math.abs(b.x-sx)>0.01||Math.abs(b.y-sy)>0.01) bad.push('the bolt is not at the strike point');
       var calls=0; rr=function(){ calls++; return _rr.apply(this,arguments); };
       CFG.fxLevel=1; CFG.flashRed=0;
       var s1=stub(), drew=drawBolts(s1,0.016,1,sx-960,sy-700,1920,1080), seed=b?b.s:1;
       var j1=JSON.stringify(boltShape(seed)), j2=JSON.stringify(boltShape(seed)), j3=JSON.stringify(boltShape((seed+12345)>>>0));
       rr=_rr;
       if(calls) bad.push('the bolt drew '+calls+' numbers from the game random stream');
       if(!drew||!s1.strokes) bad.push('an on screen bolt drew no stroke');
       if(j1!==j2) bad.push('the same strike gave two shapes');
       if(j1===j3) bad.push('two strikes gave the same shape');
       var runs=[], cur=null;
       s1.ops.forEach(function(o){ if(o[0]==='m'){ cur=[[o[1],o[2]]]; runs.push(cur); } else if(cur) cur.push([o[1],o[2]]); });
       var main=runs.filter(function(r){ var e=r[r.length-1]; return r[0][1]<=0&&Math.abs(e[0]-960)<0.5&&Math.abs(e[1]-700)<0.5; })[0];
       if(!main) bad.push('no line runs from the top edge to the strike on screen: '+runs.length+' lines');
       else{
         if(main.length<11) bad.push('the bolt has only '+(main.length-1)+' segments');
         var ax=main[0][0], ay=main[0][1], dx=960-ax, dy=700-ay, ln=Math.sqrt(dx*dx+dy*dy), dev=0, turns=0, last=0;
         for(i=1;i<main.length;i++){ var px=main[i][0], py=main[i][1]; dev=Math.max(dev,Math.abs((px-ax)*dy-(py-ay)*dx)/ln); var sxs=px-main[i-1][0]; var sg=sxs>0?1:(sxs<0?-1:0); if(sg&&last&&sg!==last) turns++; if(sg) last=sg; }
         if(dev<12) bad.push('the bolt is close to a straight line: '+dev.toFixed(1)+' px off it at most');
         if(turns<3) bad.push('the bolt does not zigzag: '+turns+' turns');
       }
       var forks=runs.filter(function(r){ return r[0][1]>0; }).length;
       if(forks<2) bad.push('the bolt has '+forks+' side forks');
       CFG.fxLevel=0; var s3=stub(); drawBolts(s3,0,1,sx-960,sy-700,1920,1080); if(s3.strokes) bad.push('effects reduced still draws the bolt');
       CFG.fxLevel=1; var s4=stub(); drawBolts(s4,0,1,sx+5000,sy-700,1920,1080); if(s4.strokes) bad.push('a strike off screen still draws a bolt');
       for(i=0;i<4;i++) drawBolts(stub(),0.1,1,sx-960,sy-700,1920,1080);
       if(g.bolts.length) bad.push('the bolt is still up after 0.4 s');
       g.sim=true; boltMark({x:sx,y:sy,id:5}); g.sim=sim0;
       if(g.bolts.length) bad.push('the sim made a sky bolt');
       if(String(render2D).indexOf('drawBolts(wc,')<0) bad.push('the raid frame does not draw the sky bolt');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       damagePlayer=_dp; rr=_rr;
       try{ var cs=JSON.parse(c0), kk; for(kk in CFG) if(!(kk in cs)) delete CFG[kk]; for(kk in cs) CFG[kk]=cs[kk]; }catch(_c0){}
       try{ if(g0){ g0.sim=sim0; g0.strikes=[]; g0.bolts=[]; g0.wx=wx0; g0.lightning=0; if(!g0.over) __endRaid('abandon'); } }catch(_e){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'35.77',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
