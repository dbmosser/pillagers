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

if ($s.Contains("  {v:'23.52',what:")) { throw "check 23.52 is in the fixture already" }

SubRx @'
  {v:'23.51',what:
'@ @'
  {v:'23.52',what:'arcade28, his yes 2026-10-11: waves follow the raid owner, a player 2 that took the arcade raid over (G.netWasJoin, no live peer) gets an arcWave pack when the wave timer runs out, a player 2 still sharing the host world gets none, and the host still gets its waves',
   run:function(){
     var bad=[], g=null, sv={}, fk=['role','waveT','waveN'], i, k, n, had=false, wj, rs=null, ownSay=false;
     function waves(){ var j, c=0; for(j=0;j<g.ents.length;j++) if(g.ents[j]&&g.ents[j].arcWave) c++; return c; }
     function clear(){ g.ents=g.ents.filter(function(e){ return !(e&&e.arcWave); }); }
     function tick(role,join){
       var t, m=0;
       ARCADE.role=role; if(join) g.netWasJoin=1; else delete g.netWasJoin;
       for(t=0;t<12&&!m;t++){ ARCADE.waveT=999; arcadeWaveTick(0.05); m=waves(); }
       return m;
     }
     try{
       __topClear(); __runPrep();
       if(typeof arcadeDeploy!=='function'||typeof arcadeWaveTick!=='function'||typeof ARCADE!=='object') return 'no arcade waves in this build';
       if(ARCADE.on) return 'SKIP: the arcade is on after __topClear';
       if(__state()&&!__state().over) __endRaid('abandon');
       if(!arcadeDeploy({mapIx:0,seed:4242})||!__state()||!__state().arcade) return 'SKIP: arcadeDeploy built no arcade raid';
       try{ attStop(); }catch(_as){}
       g=__state(); keys={};
       for(i=0;i<fk.length;i++) sv[fk[i]]=ARCADE[fk[i]];
       had=true; wj=g.netWasJoin;
       if(netEntsPeer()) return 'SKIP: the fixture has a live co-op peer';
       rs=say; ownSay=true; say=function(){};
       clear();
       n=tick('host',false);
       if(!n) return 'SKIP: the host arm made no wave pack (no floor or a full cap here)';
       clear();
       n=tick('p2',false);
       if(n) bad.push('a player 2 that did not take the raid over spawned a wave pack ('+n+')');
       clear();
       n=tick('p2',true);
       if(!n) bad.push('a player 2 that took the arcade raid over (G.netWasJoin, no live peer) got no wave pack when the timer ran out');
       if(n&&!(ARCADE.waveN>0)) bad.push('the taken-over wave pack did not count a wave');
       clear();
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       try{ if(ownSay) say=rs; }catch(_s){}
       try{ if(had&&typeof ARCADE==='object'){ for(i=0;i<fk.length;i++) ARCADE[fk[i]]=sv[fk[i]]; } }catch(_sv){}
       try{ if(g){ if(wj===undefined) delete g.netWasJoin; else g.netWasJoin=wj; } }catch(_w){}
       try{ if(typeof ARCADE==='object'&&ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       try{ if(typeof ARCADE==='object'){ ARCADE.over=null; ARCADE.mine=0; ARCADE.mate=0; ARCADE.pot=0; ARCADE.holdT=0; ARCADE.waveT=0; ARCADE.ownAt=0; ARCADE.idleSaid=0; ARCADE.wantIn=0; } }catch(_m){}
       try{ for(var kk in keys) keys[kk]=false; }catch(_k){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'23.51',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
