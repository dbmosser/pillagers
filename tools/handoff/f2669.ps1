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

if ($s.Contains("  {v:'26.69',what:")) { throw "check 26.69 is in the fixture already" }

SubRx @'
  {v:'26.68',what:
'@ @'
  {v:'26.69',what:'flow1, his yes to the Raid Director: a hard hit puts the raid in a breather (no wave), a long quiet ends in an ambush pack on the side he faces away from (called with AMBUSH BEHIND YOU), the breather ends and the waves come back, and no pack lands within the ring of an extraction point',
   run:function(){
     if(!(window.__state&&window.__endRaid&&window.__runPrep)) return 'SKIP: no raid here';
     if(typeof arcadeDeploy!=='function'||typeof ARCADE!=='object'||typeof arcadeWaveTick!=='function') return 'SKIP: no arcade here';
     var bad=[], g=null, p, rs=say, own=false, lines=[], n0, i, j, e, ang, fcs=[0,1.5708,3.1416,4.7124], f, got=0, nb, lev, D, z, okp=0, anyAmb, sawA, needle='AMB'+'USH';
     function nearCut(){ g.ents=g.ents.filter(function(q){ return !(q&&!q.neutral&&q.kind!=='peddler'&&q.kind!=='stray'&&(q.kind!=='raider'||q.hostile)&&dist(q,p)<1500); }); }
     function wavesOf(){ var c=0, k; for(k=0;k<g.ents.length;k++) if(g.ents[k]&&g.ents[k].arcWave) c++; return c; }
     function dropWaves(){ g.ents=g.ents.filter(function(q){ return !(q&&q.arcWave); }); }
     try{
       __topClear(); __runPrep();
       if(ARCADE.on) return 'SKIP: the arcade is on after __topClear';
       if(!arcadeDeploy({mapIx:0,seed:4242})) return 'SKIP: arcadeDeploy built no arcade raid';
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       p=g.player; keys={};
       say=function(m,kd,o){ lines.push(String(m)+'|'+((o&&o.sub)||'')); }; own=true;
       ARCADE.mine=8000; ARCADE.mate=0; ARCADE.holdT=0; lev=g.t; g.t=300; p.hurtAt=-999;
       // A: calm for 40 s, two waves in: the next one is an ambush from behind
       for(i=0;i<fcs.length&&!got;i++){
         f=fcs[i]; nearCut(); dropWaves(); p.face=f; lines.length=0;
         g.flow={dir:{st:0,hp:p.hp,quiet:40,ph:'build',phT:0,waves:2,amb:0,lastAmb:-999,pace:1}};
         ARCADE.waveT=999; n0=g.ents.length; arcadeWaveTick(0.05);
         nb=0; anyAmb=0;
         for(j=n0;j<g.ents.length;j++){ e=g.ents[j]; if(!e||!e.arcWave) continue; nb++; if(e.dirAmb) anyAmb++; }
         if(!anyAmb) continue;
         got=1;
         if(nb<4) bad.push('A: the ambush added '+nb+' bodies');
         for(j=n0;j<g.ents.length;j++){
           e=g.ents[j]; if(!e||!e.arcWave) continue;
           ang=Math.atan2(e.y-p.y,e.x-p.x);
           if(Math.abs(angDiff(ang,f+Math.PI))>0.8) bad.push('A: an ambush '+e.kind+' stands '+Math.round(Math.abs(angDiff(ang,f+Math.PI))*57.3)+' degrees off the side behind him');
           if(!e.dirAmb) bad.push('A: a body of the ambush is not flagged');
         }
         sawA=0; for(j=0;j<lines.length;j++) if(lines[j].indexOf(needle)>=0) sawA=1;
         if(!sawA) bad.push('A: no AMBUSH callout (said: '+lines.slice(-3).join(' / ')+')');
         if(!(g.flow.dir.lastAmb>0)) bad.push('A: the Director did not note the ambush');
       }
       if(!got) bad.push('A: no ambush on any of four facings after 40 quiet seconds and two waves');
       // B: a 70 point hit since the last read: the raid goes to a breather and no wave comes
       nearCut(); dropWaves();
       g.flow={dir:{st:0.2,hp:p.hp+70,quiet:0,ph:'build',phT:0,waves:2,amb:0,lastAmb:-999,pace:1}};
       ARCADE.waveT=999; n0=wavesOf(); arcadeWaveTick(0.05);
       if(wavesOf()>n0) bad.push('B: a wave came straight after a 70 point hit');
       D=g.flow.dir; if(D.ph!=='breather') bad.push('B: the phase is '+D.ph+', not breather');
       // C: the breather ends (30 s on) and the waves are back
       ARCADE.waveT=999; n0=wavesOf(); arcadeWaveTick(30);
       if(wavesOf()<=n0) bad.push('C: no wave after the breather had run out');
       if(g.flow.dir.ph==='breather') bad.push('C: still in the breather after 30 s');
       // D: no spot within the ring of an open extraction point
       if(g.zones&&g.zones.length){
         z=g.zones[0];
         for(i=-300;i<=300&&!okp;i+=25) for(j=-300;j<=300;j+=25){
           if(Math.hypot(i,j)>350) continue;
           if(spotFree(g.map,z.x+i,z.y+j,22)&&navReachable(g.map,z.x+i,z.y+j)&&!shutRoomAt(g.map,z.x+i,z.y+j)){
             okp=1;
             if(arcadeWaveOk([],{x:z.x+i+900,y:z.y+j},z.x+i,z.y+j,0,5000)) bad.push('D: a pack may land '+Math.round(Math.hypot(i,j))+' from an extraction ring');
             break;
           }
         }
       }
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       if(own) say=rs;
       keys={};
       try{ if(g&&lev!==undefined) g.t=lev; }catch(_t){}
       try{ if(typeof ARCADE==='object'&&ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       try{ if(typeof ARCADE==='object'){ ARCADE.mine=0; ARCADE.waveT=0; ARCADE.holdT=0; } }catch(_m){}
       __topClear();
     }
     return bad.length?bad.slice(0,8).join('; '):null; }},
  {v:'26.68',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
