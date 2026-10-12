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

if ($s.Contains("  {v:'23.93',what:")) { throw "check 23.93 is in the fixture already" }

SubRx @'
  {v:'23.92',what:
'@ @'
  {v:'23.93',what:'his answers 1 and 4 (2026-10-12): in the 1 PLAYER DEMO a death ends the run (RUN OVER with the score he had, no card, nothing settled); in the 2 PLAYER DEMO he drops back in but loses all his score and kills (SCORE LOST, and the new score goes to the other window at once)',
   run:function(){
     if(!(window.__state&&window.__runPrep&&window.__loop&&window.__endRaid)) return 'SKIP: this fixture cannot step a raid';
     if(typeof arcadeDeploy!=='function'||typeof arcadeLeave!=='function'||typeof ARCADE!=='object'||typeof killPlayer!=='function') return 'SKIP: no arcade here';
     var bad=[], g, f, oc, bk=null, hadB=false, BK=(typeof ARCADE_BOARD_KEY==='string')?ARCADE_BOARD_KEY:'', rs=say, lines=[], nsp=null, posts=[], ownS=false, ownN=false;
     function die(){ killPlayer('sentry'); for(f=0;f<200;f++){ __loop(performance.now()+f*16.7); if(__state()!==g||g.deathBeat==null) break; } }
     try{
       __topClear(); __runPrep();
       if(ARCADE.on) return 'SKIP: the arcade is on after __topClear';
       if(BK){ try{ bk=localStorage.getItem(BK); hadB=true; }catch(_b){} }
       say=function(m){ lines.push(String(m)); }; ownS=true;
       // THE 1 PLAYER DEMO
       if(!arcadeDeploy({mapIx:0,seed:4242})) return 'SKIP: arcadeDeploy built no arcade raid';
       g=__state(); keys={}; ARCADE.holdT=0; ARCADE.waveT=0; ARCADE.ownAt=Date.now();
       if(!g||!g.arcade) return 'SKIP: no arcade raid';
       ARCADE.solo=1; ARCADE.mine=900; ARCADE.mate=0; ARCADE.over=null;
       die();
       if(__state()===g) bad.push('a death in the 1 player demo dropped him back into the raid (deaths '+ARCADE.deaths+', score '+ARCADE.mine+')');
       else {
         if(__state()&&__state().arcade) bad.push('a death in the 1 player demo built another raid');
         if(!ARCADE.over||ARCADE.over.why!=='dead') bad.push('a death in the 1 player demo did not end the run (over '+JSON.stringify(ARCADE.over&&ARCADE.over.why)+')');
         else if(ARCADE.over.team!==900) bad.push('the 1 player run ended with the score '+ARCADE.over.team+', not the 900 he had');
         if(!ARCADE.on) bad.push('the death left the arcade altogether');
         oc=document.getElementById('outcome');
         if(oc&&oc.classList.contains('on')) bad.push('the outcome card is on after a demo death');
       }
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e1){}
       // THE 2 PLAYER DEMO
       ARCADE.solo=0; ARCADE.over=null;
       if(!arcadeDeploy({mapIx:0,seed:4242})) return bad.concat(['SKIP: arcadeDeploy built no second arcade raid']).join('; ');
       g=__state(); keys={}; ARCADE.holdT=0; ARCADE.waveT=0; ARCADE.ownAt=Date.now();
       if(!g||!g.arcade) return bad.concat(['SKIP: no second arcade raid']).join('; ');
       nsp=netSamePost; netSamePost=function(m){ posts.push(m); return true; }; ownN=true;
       ARCADE.run={id:'tfeat0f'}; ARCADE.mine=900; ARCADE.kills=4; ARCADE.mate=300; lines.length=0; posts.length=0;
       die();
       if(__state()!==g) bad.push('a death in the 2 player demo ended or replaced the raid');
       else {
         if(!(ARCADE.holdT>0)) bad.push('the 2 player demo death did not drop him back in (hold '+ARCADE.holdT+')');
         if(ARCADE.mine!==0) bad.push('after a death in the 2 player demo his score is '+ARCADE.mine+', not 0');
         if(ARCADE.kills!==0) bad.push('after a death in the 2 player demo his kills are '+ARCADE.kills+', not 0');
         if(ARCADE.mate!==300) bad.push('his death changed the teammate score to '+ARCADE.mate);
         if(!lines.some(function(s){ return s.indexOf('SCORE '+'LOST')===0; })) bad.push('no SCORE LOST line was said ('+JSON.stringify(lines.slice(0,4))+')');
         if(!posts.some(function(m){ return m&&m.t==='arcsc'&&m.s===0&&m.k===0; })) bad.push('the score of 0 was not sent to the other window at once');
       }
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       if(ownS) say=rs;
       if(ownN) netSamePost=nsp;
       keys={};
       try{ if(typeof ARCADE==='object'&&ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       try{ ARCADE.solo=0; ARCADE.mine=0; ARCADE.mate=0; ARCADE.kills=0; ARCADE.holdT=0; ARCADE.waveT=0; ARCADE.over=null; ARCADE.run=null; }catch(_m){}
       try{ if(hadB){ if(bk===null) localStorage.removeItem(BK); else localStorage.setItem(BK,bk); } }catch(_b2){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'23.92',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
