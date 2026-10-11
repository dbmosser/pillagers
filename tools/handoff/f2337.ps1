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

if ($s.Contains("  {v:'23.37',what:")) { throw "check 23.37 is in the fixture already" }

SubRx @'
  {v:'23.36',what:
'@ @'
  {v:'23.37',what:'arcade14, his order 2026-10-11: action comes to you, the arcade wave director drops a pack of hunters 700 to 1200 from the player and calls WAVE n, the main loop runs it, and a normal raid never gets one',
   run:function(){
     var bad=[], g=null, g2=null, i, e, n0, d, k, t0, f, rs=say, own=false, lines=[], nW='WA'+'VE ', hasW=false;
     function nearCut(gg){ var p=gg.player; gg.ents=gg.ents.filter(function(q){ return !(q&&!q.neutral&&q.kind!=='peddler'&&q.kind!=='stray'&&(q.kind!=='raider'||q.hostile)&&dist(q,p)<1500); }); }
     function waves(gg){ var c=0, j; for(j=0;j<gg.ents.length;j++) if(gg.ents[j]&&gg.ents[j].arcWave) c++; return c; }
     try{
       __topClear(); __runPrep();
       if(typeof arcadeDeploy!=='function'||typeof ARCADE!=='object') return 'no arcadeDeploy in this build';
       if(typeof arcadeWaveTick!=='function') return 'no arcadeWaveTick in this build';
       if(ARCADE.on) return 'SKIP: the arcade is on after __topClear';
       if(!arcadeDeploy({mapIx:0,seed:4242})) return 'SKIP: arcadeDeploy built no arcade raid';
       g=__state(); keys={};
       say=function(m){ lines.push(String(m)); }; own=true;
       if(ARCADE.waveT!==0) bad.push('arcadeDeploy does not start the wave clock at 0 ('+ARCADE.waveT+')');
       ARCADE.mine=8000; ARCADE.mate=0; ARCADE.waveT=999; ARCADE.holdT=0;
       nearCut(g); n0=g.ents.length;
       arcadeWaveTick(0.05);
       if(g.ents.length-n0<2) bad.push('a tier 2 wave added '+(g.ents.length-n0)+' bodies, not at least 2');
       for(i=n0;i<g.ents.length;i++){
         e=g.ents[i];
         if(!e.arcWave) bad.push('a new body ('+e.kind+') is not flagged arcWave');
         d=dist(e,g.player);
         if(d<700||d>1200) bad.push('a wave '+e.kind+' landed '+Math.round(d)+' from the player');
         if(e.state!=='investigate') bad.push('a wave '+e.kind+' is in state '+e.state);
         if(!(e.alert>=3)) bad.push('a wave '+e.kind+' has alert '+e.alert);
         if(dist({x:e.tx,y:e.ty},g.player)>90) bad.push('a wave '+e.kind+' heads somewhere else');
         if(e.kind==='raider'&&!e.hostile) bad.push('a wave pillager is not hostile');
       }
       for(i=0;i<lines.length;i++) if(lines[i]===nW+'1') hasW=true;
       if(!hasW) bad.push('no WAVE 1 callout (said: '+lines.slice(-3).join(' | ')+')');
       if(ARCADE.waveT!==0) bad.push('the wave clock is not reset after a wave ('+ARCADE.waveT+')');
       n0=g.ents.length; arcadeWaveTick(0.05);
       if(g.ents.length!==n0) bad.push('a second wave came 0.05 s after the first');
       // the main loop runs it
       ARCADE.waveT=999; k=waves(g); t0=g.t;
       for(f=1;f<=6;f++) __loop(performance.now()+f*20);
       if(__state()===g&&!g.over&&g.t>t0&&waves(g)<=k) bad.push('the main loop never ran the wave director ('+k+' wave bodies before and after)');
       say=rs; own=false;
       try{ if(ARCADE.on) arcadeLeave(); }catch(_l1){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e1){}
       // a normal raid never gets a wave
       __topClear(); __runPrep();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g2=__state();
       if(!g2) return bad.length?bad.join('; '):'SKIP: __deploy built no raid';
       if(g2.arcade) bad.push('a normal raid is flagged arcade');
       ARCADE.waveT=999; ARCADE.mine=8000;
       arcadeWaveTick(0.05);
       if(waves(g2)) bad.push('arcadeWaveTick spawned a wave in a normal raid');
       for(f=1;f<=6;f++) __loop(performance.now()+f*20);
       for(k=0;k<300;k++){ if(__state()!==g2||g2.over) break; __sim(0.1); }
       if(waves(g2)) bad.push('a normal raid has '+waves(g2)+' arcWave bodies after 30 s');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       if(own) say=rs;
       keys={};
       try{ if(typeof ARCADE==='object'){ ARCADE.waveT=0; ARCADE.holdT=0; } }catch(_h){}
       try{ if(typeof ARCADE==='object'&&ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       try{ if(typeof ARCADE==='object'){ ARCADE.mine=0; ARCADE.waveT=0; } }catch(_m){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'23.36',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
