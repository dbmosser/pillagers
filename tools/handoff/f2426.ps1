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

if ($s.Contains("  {v:'24.26',what:")) { throw "check 24.26 is in the fixture already" }

SubRx @'
  {v:'24.25',what:
'@ @'
  {v:'24.26',what:'his #39: END RUN in the demo pause box arms first, one press leaves the run up and reads END RUN? PRESS AGAIN, a second press within 3 s ends the run, an old arm or a reopened box starts safe again',
   run:function(){
     if(!(window.__state&&window.__runPrep&&window.__endRaid)) return 'SKIP: this fixture cannot run a raid';
     if(typeof arcadeDeploy!=='function'||typeof arcadeLeave!=='function'||typeof ARCADE!=='object'||typeof togglePauseBox!=='function') return 'SKIP: no arcade here';
     var bad=[], g, b=document.getElementById('arcendbtn'), rs=say, ownS=false, bk=null, hadB=false, BK=(typeof ARCADE_BOARD_KEY==='string')?ARCADE_BOARD_KEY:'';
     if(!b) return 'SKIP: no END RUN button';
     try{
       __topClear(); __runPrep();
       if(ARCADE.on) return 'SKIP: the arcade is on after __topClear';
       if(BK){ try{ bk=localStorage.getItem(BK); hadB=true; }catch(_b){} }
       say=function(){}; ownS=true;
       if(!arcadeDeploy({mapIx:0,seed:4242})) return 'SKIP: arcadeDeploy built no arcade raid';
       g=__state(); keys={}; ARCADE.holdT=0; ARCADE.waveT=0; ARCADE.ownAt=Date.now(); ARCADE.over=null;
       if(!g||!g.arcade) return 'SKIP: no arcade raid';
       togglePauseBox(true);
       b.click();
       if(__state()!==g||ARCADE.over) bad.push('one press of END RUN ended the run (no confirm)');
       else {
         if(String(b.textContent).indexOf('PRESS '+'AGAIN')<0) bad.push('the first press of END RUN reads '+b.textContent);
         togglePauseBox(false); togglePauseBox(true);
         if(String(b.textContent)!=='END RUN') bad.push('a reopened pause box still shows END RUN armed ('+b.textContent+')');
         b.click();
         if(__state()!==g||ARCADE.over) bad.push('after the box was reopened one press of END RUN ended the run');
         if(typeof ARC_END_ARM!=='undefined'){ ARC_END_ARM=Date.now()-3500; b.click(); if(__state()!==g||ARCADE.over) bad.push('a press 3.5 s after the arm ended the run'); }
         b.click();
         if(__state()===g&&!ARCADE.over) bad.push('a second press of END RUN within 3 s did not end the run');
         else if(!ARCADE.over||ARCADE.over.why!=='menu') bad.push('the second press ended it as '+(ARCADE.over?ARCADE.over.why:'nothing'));
         if(String(b.textContent)!=='END RUN') bad.push('END RUN still reads '+b.textContent+' after the run ended');
       }
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       if(ownS) say=rs;
       keys={};
       try{ togglePauseBox(false); }catch(_t){}
       try{ if(typeof arcEndDisarm==='function') arcEndDisarm(); }catch(_d){}
       try{ if(typeof ARCADE==='object'&&ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       try{ ARCADE.mine=0; ARCADE.mate=0; ARCADE.kills=0; ARCADE.holdT=0; ARCADE.waveT=0; ARCADE.over=null; }catch(_m){}
       try{ if(hadB){ if(bk===null) localStorage.removeItem(BK); else localStorage.setItem(BK,bk); } }catch(_b2){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'24.25',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
