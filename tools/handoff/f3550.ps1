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

if ($s.Contains("  {v:'35.50',what:")) { throw "check 35.50 is in the fixture already" }

SubRx @'
  {v:'35.49',what:
'@ @'
  {v:'35.50',what:'cw-extpill, his ask 2026-10-27 (the hud messaging is a clusterfuck, make it AAA), the research rule for the top centre: the extract pill under the clock carries the state of its exit, teal while open, amber inside the two minute warning with a countdown in its last minute, red once shut, and one pulse on each change; an open exit just off the screen draws an edge arrow with its letter and distance (c 152m) clear of the corner panels and the pickup stack column, and no longer the line under the pill; the sky (weather, else time of day) is a small icon beside the clock',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     if(typeof drawHUD!=='function'||!window.__textTrace||typeof w2s!=='function'||typeof zoneBadge!=='function') return 'SKIP: no hud here';
     var bad=[], g, p, Z=null, kz=null, s, sx=null, d, i, tr, o, L, oTL, lab, ox, oy, near=[], all=null, oW;
     function find(re){ var r=[]; for(var j=0;j<tr.length;j++) if(re.test(String(tr[j].t))) r.push(tr[j]); return r; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       try{ __pinDPR(1); __forceSize(1920,1080); }catch(_fs){}
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player||g.sim) return 'SKIP: staging: no raid';
       p=g.player; keys={}; g.mapOpen=false; g.bagOpen=false; g.paused=false; all=g.ents.slice(); g.ents=[]; g.waypoint=null;
       if(typeof extPillState!=='function'||typeof extEdgeArrow!=='function'||typeof wxIconDraw!=='function') return 'no extraction state on the pill, edge arrow or sky icon (extPillState, extEdgeArrow, wxIconDraw)';
       for(i=0;i<g.zones.length;i++) if(g.zones[i].open!==false){ Z=g.zones[i]; break; }
       if(!Z) return 'SKIP: no open exit here';
       kz={x:Z.x,y:Z.y,b:Z.beaconT,h:Z.hold,o:Z.open,c:Z.closeAt,w:Z.warned}; oTL=g.timeLeft; ox=p.x; oy=p.y;
       for(i=0;i<g.zones.length;i++) if(g.zones[i]!==Z) near.push({z:g.zones[i],o:g.zones[i].open});
       for(i=0;i<near.length;i++) near[i].z.open=false;   // only Z is open, so the compass and the pill name it
       Z.beaconT=null; Z.hold=null; Z.open=true; Z.closeAt=undefined; Z.x=p.x+700; Z.y=p.y;
       // ONE: the pill state, teal open, amber closing with the last minute counted, red once shut, one pulse on a change
       drawHUD(); if(EXTPILL.st!=='open') bad.push('an open exit reads '+EXTPILL.st+' on the pill');
       Z.closeAt=g.timeLeft-90; drawHUD();
       if(EXTPILL.st!=='closing'||EXTPILL.col!==HUDC.warn||!(/closing/).test(EXTPILL.txt)) bad.push('an exit 90 s from closing reads '+EXTPILL.st+' "'+EXTPILL.txt+'" in '+EXTPILL.col+', not amber closing');
       if(!(extPillPulse(EXTPS)>0)) bad.push('the pill does not pulse when its exit starts closing');
       Z.closeAt=g.timeLeft-42; tr=__textTrace(function(){ drawHUD(); });
       if(!find(/0:42$/).filter(function(q){ return Math.abs(q.x-W/2)<4&&q.y<H*0.2; }).length) bad.push('the pill does not count the last minute (0:42) under the clock');
       G.xpAt=-1e9; drawHUD(); if(extPillPulse(EXTPS)>0) bad.push('the pill pulses on with no change');
       Z.closeAt=undefined; drawHUD(); if(EXTPILL.st!=='open'||!(extPillPulse(EXTPS)>0)) bad.push('the pill does not turn back and pulse when the exit opens again');
       // TWO: the exit just off the right edge is an edge arrow with its letter and distance, and not the line under the pill
       g.xpAt=-1e9; Z.closeAt=undefined; try{ render2D(0); }catch(_r0){}
       for(d=200;d<4000;d+=10){ Z.x=p.x+d; Z.y=p.y; s=w2s(Z.x,Z.r+18,Z.y); if(s&&s.x>W+30){ sx=s; break; } }
       if(!sx||sx.x>W+80||sx.y<40||sx.y>H-40) bad.push('control: could not stand an exit just off the right edge');
       else {
         drawHUD(); tr=__textTrace(function(){ drawHUD(); });
         lab=extLetter(Z).toLowerCase()+' '+metres(dist(p,Z))+'m';
         o=find(new RegExp('^'+lab+'$','i'));
         if(!EXTARROW.on||!o.length) bad.push('no edge arrow "'+lab+'" for an exit just off the right edge');
         else {
           if(!(o[0].x>W*0.6&&o[0].x<W-20&&o[0].y>H*0.1&&o[0].y<H*0.9)) bad.push('the edge arrow is not inside the right edge ('+Math.round(o[0].x)+','+Math.round(o[0].y)+')');
           if(EXTARROW.x+EXTARROW.w>W-LH(250)&&EXTARROW.y+EXTARROW.h>H*0.5) bad.push('the edge arrow sits in the pickup stack column');
           for(var k in HUDBOX){ var B=HUDBOX[k]; if(B&&B.w>0&&EXTARROW.x<B.x+B.w&&EXTARROW.x+EXTARROW.w>B.x&&EXTARROW.y<B.y+B.h&&EXTARROW.y+EXTARROW.h>B.y) bad.push('the edge arrow lands on the '+k+' panel'); }
         }
         L=find(/extraction \w available/i); if(L.length) bad.push('the line "'+L[0].t+'" still draws ('+Math.round(L[0].x)+','+Math.round(L[0].y)+')');
         Z.open=false; drawHUD(); if(EXTARROW.on) bad.push('a closed exit gets an edge arrow'); Z.open=true;
       }
       // THREE: the sky icon beside the clock
       oW=g.wx; for(i=0;i<WEATHER.length;i++) if(WEATHER[i].id==='fog'){ g.wx=WEATHER[i]; g.wxNext=null; }
       drawHUD();
       if(WXICON.id!=='fog') bad.push('the sky icon reads '+WXICON.id+' under fog');
       if(!(Math.abs(WXICON.x-W/2)<W*0.15&&WXICON.y<H*0.12)) bad.push('the sky icon is not beside the clock ('+Math.round(WXICON.x)+','+Math.round(WXICON.y)+')');
       for(i=0;i<WEATHER.length;i++) if(WEATHER[i].id==='clear') g.wx=WEATHER[i];
       drawHUD(); if(!(/^(sun|low|night)$/).test(WXICON.id)) bad.push('a clear sky does not show the time of day ('+WXICON.id+')');
       g.wx=oW;
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       try{ if(Z&&kz){ Z.x=kz.x; Z.y=kz.y; Z.beaconT=kz.b; Z.hold=kz.h; Z.open=kz.o; Z.closeAt=kz.c; Z.warned=kz.w; } for(i=0;i<near.length;i++) near[i].z.open=near[i].o; if(g){ g.timeLeft=oTL; if(all) g.ents=all; } if(p){ p.x=ox; p.y=oy; } }catch(_z){}
       keys={};
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'35.49',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
