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

if ($s.Contains("  {v:'37.67',what:")) { throw "check 37.67 is in the fixture already" }

SubRx @'
  {v:'37.66',what:
'@ @'
  {v:'37.67',what:'end run leaves only the pressing seat out, either order, and ends only after both leave',
   run:function(){
     var sv={}, k, post=netSamePost, live=arcadeMateLive, src=ATT.src, tried=ATT.tried, msgs=[], g, id, b=document.getElementById('arcendbtn'), bk;
     function press(){ ARC_END_ARM=Date.now(); b.onclick(); }
     function stage(){
       NET.on=false; NET.same='host'; NET.role='host';
       if(!arcadeDeploy({role:'host',mapIx:0,seed:4242})) throw new Error('no arcade raid');
       g=__state(); ARCADE.role='host'; ARCADE.solo=0; ARCADE.mine=400; ARCADE.mate=200; id=ARCADE.run.id; msgs=[];
     }
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       for(k in NET) if(Object.prototype.hasOwnProperty.call(NET,k)) sv[k]=NET[k];
       bk=localStorage.getItem(ARCADE_BOARD_KEY);
       ATT.src=null; ATT.tried=true; NET.bc={postMessage:function(){},close:function(){}}; NET.pair='endseat';
       netSamePost=function(m){msgs.push(m);return true;}; arcadeMateLive=function(){return true;};
       if(!arcadeEnter('host')) return 'could not enter arcade';
       stage(); press();
       if(__state()!==g||!g.player.specOut||ARCADE.over||msgs.some(function(m){return m.t==='arcend';})) return 'host end run ended the shared raid';
       if(arcadeUnbench()) return 'host could rejoin after end run';
       press(); if(__state()!==g) return 'repeat host end run stopped partner';
       if(arcadeOnMsg({t:'arcquit',run:'stale',s:200})!=='ignored') return 'stale peer exit accepted';
       arcadeOnMsg({t:'arcquit',run:id,s:200,k:0});
       if(__state()||!ARCADE.over||ARCADE.over.team!==300) return 'both exits did not settle once with existing early-end penalty';
       stage(); ARCADE.role='p2'; NET.same='p2'; NET.role='join'; g.netWasJoin=false;
       press();
       var q=msgs.filter(function(m){return m.t==='arcquit';}).pop();
       if(!q||__state()!==g||!g.player.specOut||!g.arcX) return 'peer end run did not leave only peer out';
       press(); if(msgs.filter(function(m){return m.t==='arcquit';}).length!==1) return 'peer exit repeated';
       g.player.specOut=0; g.arcMenuOut=0; g.arcX=0; ARCADE.role='host'; NET.same='host'; NET.role='host';
       arcadeOnMsg(q);
       if(__state()!==g||g.player.specOut||ARCADE.xOut!=='p') return 'peer exit stopped active host';
       if(arcadeOnMsg(q)!=='ignored') return 'duplicate peer exit accepted';
       press(); if(__state()||!ARCADE.over) return 'peer then host did not end run';
       stage(); if(ARCADE.menuMate) return 'new raid kept old exit';
       arcadeOnMsg({t:'arcquit',run:id,s:200,k:0}); arcadeExtractEnd();
       if(g.arcEnd!=='menu'||ARCADE.x2) return 'last extraction counted early exit as team extraction';
       g.arcEnd=0; arcadeRunEnd('menu');
       stage(); ARCADE.solo=1; press(); if(__state()||!ARCADE.over) return 'solo end run no longer ends run';
       return null;
     } finally {
       arcadeMateLive=live;
       try{ arcadeLeave(); }catch(_l){} try{ __endRaid('abandon'); }catch(_e){}
       netSamePost=post; for(k in sv) NET[k]=sv[k]; ATT.src=src; ATT.tried=tried;
       if(bk===null) localStorage.removeItem(ARCADE_BOARD_KEY); else if(bk!==undefined) localStorage.setItem(ARCADE_BOARD_KEY,bk);
       arcEndDisarm(); __topClear();
     }
   }},
  {v:'37.66',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
