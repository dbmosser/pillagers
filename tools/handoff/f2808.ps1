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

if ($s.Contains("  {v:'28.08',what:")) { throw "check 28.08 is in the fixture already" }

SubRx @'
  {v:'28.07',what:
'@ @'
  {v:'28.08',what:'his order 2026-10-15 (career leaderboard): the pause box on the Undercroft floor has a LEADERBOARD button in its row that opens the same board in a window, ESC and CLOSE close it, and a raid pause box does not offer it',
   run:function(){
     if(!window.__deploy||!window.__endRaid||!window.__state||typeof togglePauseBox!=='function') return 'SKIP: no pause box here';
     if(typeof lbOpen!=='function') return 'the Undercroft has no LEADERBOARD window (cboard4)';
     var bad=[], b=document.getElementById('lbbtn'), m=document.getElementById('lbmodal'), h=document.getElementById('lbhost'), box=document.getElementById('pausebox'), kG=G, kS=state, was=pauseOpen,
         b0=P.careerBoard, hb=('careerBoard' in P), r0=P.careerRuns, hr=('careerRuns' in P), a0=P.careerAll, ha=('careerAll' in P), tx;
     try{
       if(!b||!m||!h||!box||!box.contains(b)) return 'the pause box has no LEADERBOARD button or window';
       P.careerBoard=[{s:900,k:3,m:0,t:Date.now()-86400000,n:'X',o:'x',d:300},{s:400,k:1,m:1,t:Date.now(),n:'X',o:'k',d:95}]; P.careerRuns=2; P.careerAll=[900,400];
       G=null; state='hub';
       togglePauseBox(true);
       if(!box.classList.contains('on')) bad.push('staging: the pause box did not open on the floor');
       if(getComputedStyle(b).display==='none') bad.push('the LEADERBOARD button is hidden on the floor');
       if(b.textContent!=='LEADERBOARD') bad.push('the button reads "'+b.textContent+'"');
       b.click();
       if(!m.classList.contains('on')) bad.push('the button did not open the LEADERBOARD window');
       tx=h.textContent||'';
       if(h.querySelectorAll('.lbp .apr').length!==3) bad.push('the window draws '+h.querySelectorAll('.lbp .apr').length+' lines, not a header and 2 runs');
       if(h.querySelector('.hl')) bad.push('the Undercroft board highlights a row');
       if(tx.indexOf('CAREER LEADERBOARD')<0||tx.indexOf('2 RUNS')<0||tx.indexOf('KIA')<0||tx.indexOf('EXTRACTED')<0||tx.indexOf('$900')<0) bad.push('the board reads wrong ('+tx.slice(0,90)+')');
       if(typeof escCloseTopModal==='function'){ escCloseTopModal(); if(m.classList.contains('on')) bad.push('ESC did not close the LEADERBOARD window'); }
       b.click();
       document.getElementById('lbclose').click();
       if(m.classList.contains('on')) bad.push('CLOSE did not close the LEADERBOARD window');
       togglePauseBox(false);
       G=kG; state=kS;
       // a raid pause box does not offer it
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0);
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       if(!__state()||__state().over) return bad.concat(['SKIP: no live raid']).join('; ');
       togglePauseBox(true);
       if(getComputedStyle(b).display!=='none') bad.push('a raid pause box offers the LEADERBOARD button');
       togglePauseBox(false);
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       try{ var mm=document.getElementById('lbmodal'); if(mm) mm.classList.remove('on'); }catch(_m){}
       try{ if(!G) state=kS; }catch(_st){}
       try{ if(hb) P.careerBoard=b0; else delete P.careerBoard; if(hr) P.careerRuns=r0; else delete P.careerRuns; if(ha) P.careerAll=a0; else delete P.careerAll; }catch(_b){}
       try{ if(pauseOpen&&!was) togglePauseBox(false); }catch(_p){}
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.iv=0; __endRaid('abandon'); } }catch(_e){}
       __topClear(); }
     return bad.length?bad.join('; '):null; }},
  {v:'28.07',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
