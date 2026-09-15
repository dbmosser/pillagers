$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

SubRx @'
  {v:'15.08',what:
'@ @'
  {v:'15.09',what:'an abandon that costs XP says so on the outcome card and in the run report: walked out five minutes in with 5,000 XP, the card shows the fee the confirm took, and the run record and the report row carry it (quit audit finding 7)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__P&&window.__applyLoaded)) return 'SKIP: this fixture cannot deploy';
     if(typeof abandonRepCost!=='function'||typeof elapsed!=='function'||typeof pendingRun==='undefined') return 'SKIP: this build has no walk-out fee';
     var cb=document.getElementById('confirmabandon'), ab=document.getElementById('abandonbtn'), man=document.getElementById('oc_manifest');
     if(!cb||!ab||!man||typeof cb.onclick!=='function') return 'SKIP: this build has no abandon confirm or outcome card in the page';
     var bad=[], g=null, snap=null, _say=say, said='';
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       snap=JSON.parse(JSON.stringify(__P()));
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player) return 'SKIP: no live raid';
       if(CFG.raidSec>0) g.timeLeft=(g.raidLen===undefined?CFG.raidSec:g.raidLen)-300; else g.t=300;
       var Q=__P(); Q.xp=5000;
       var fee=Math.min(abandonRepCost(elapsed()),Q.xp);
       // CONTROL: the raid is past the free first minute, so the confirm takes a fee.
       if(elapsed()<=60||!(fee>0)) return 'SKIP: this raid could not be aged past the free first minute here';
       say=function(m){ said=String(m); };
       cb.onclick.call(cb);
       say=_say;
       var needle='XP -'+String(fee);
       // CONTROL: the click ended the run, the game's own line names the fee it took, and an abandon was recorded.
       if(!g.over) return 'SKIP: the confirm did not end the run here';
       if(said.indexOf(needle)<0) return 'SKIP: the confirm took no fee here ('+said.slice(0,60)+')';
       if(!pendingRun||pendingRun.outcome!=='abandon') return 'SKIP: no abandoned run was recorded here';
       var txt=String(man.textContent||'');
       if(!txt) return 'SKIP: the outcome card was not filled here';
       if(txt.indexOf(needle)<0) bad.push('walked out five minutes in with 5,000 XP, the outcome card never shows the '+fee+' XP the confirm took, so its XP total reads '+fee+' below the start plus the XP it prints');
       if(pendingRun.abandonFee!==fee) bad.push('the run record carries no abandon fee ('+pendingRun.abandonFee+' where '+fee+' was taken)');
       if(typeof buildExport==='function'){
         var ex=null; try{ ex=String(buildExport()); }catch(_x){ ex=null; }
         if(ex!==null&&ex.indexOf(' abandon'+'Fee:'+String(fee))<0) bad.push('the run report row does not say the walk-out cost '+fee+' XP');
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       say=_say;
       try{ cb.style.display='none'; ab.textContent='Abandon run'; }catch(_b){}
       try{ if(g&&!g.over) __endRaid('abandon'); }catch(_e){}
       try{ if(snap) __applyLoaded(snap); }catch(_r){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'15.08',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
