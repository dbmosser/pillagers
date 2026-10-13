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

if ($s.Contains("  {v:'25.85',what:")) { throw "check 25.85 is in the fixture already" }

SubRx @'
  {v:'25.84',what:
'@ @'
  {v:'25.85',what:'his order: END RUN in the DEMO shows RUN OVER and then the high score board before the next run starts: finishing the initials shows the board, a press on the RUN OVER card shows it, a press on the board starts the next run after a short hold',
   run:function(){
     if(!(window.__state&&window.__runPrep&&window.__endRaid)) return 'SKIP: this fixture cannot run a raid';
     if(typeof arcadeDeploy!=='function'||typeof arcadeLeave!=='function'||typeof ARCADE!=='object'||typeof arcadeKeyAtt!=='function'||typeof arcadeRunEnd!=='function'||typeof arcadeIniOp!=='function'||typeof attEl!=='function'||typeof arcadeAttShow!=='function') return 'SKIP: no arcade here';
     var bad=[], g, rs=say, ownS=false, bk=null, hadB=false, BK=(typeof ARCADE_BOARD_KEY==='string')?ARCADE_BOARD_KEY:'', b=document.getElementById('arcendbtn'), tx;
     function ev(code){ return {type:'keydown',code:code,key:code,repeat:false,ctrlKey:false,altKey:false,metaKey:false,shiftKey:false,preventDefault:function(){},stopImmediatePropagation:function(){}}; }
     function up(){ var s=__state(); return !!(s&&s.arcade&&!s.over); }
     function pg(){ return attEl().querySelector('.arcpage'); }
     function pageOn(){ var p=pg(); return !!p&&p.style.display==='block'&&p.getAttribute('data-ph')==='board'; }
     function cardOn(){ var c=attEl().querySelector('.arcover'); return !!c&&c.style.display==='block'; }
     if(!b||!BK) return 'SKIP: no END RUN button or no board key';
     try{
       __topClear(); __runPrep();
       if(ARCADE.on) return 'SKIP: the arcade is on after __topClear';
       try{ bk=localStorage.getItem(BK); hadB=true; localStorage.removeItem(BK); }catch(_b){}
       say=function(){}; ownS=true;
       if(!arcadeDeploy({mapIx:0,seed:4242})) return 'SKIP: arcadeDeploy built no arcade raid';
       g=__state(); keys={}; ARCADE.holdT=0; ARCADE.waveT=0; ARCADE.ownAt=Date.now(); ARCADE.over=null;
       if(!g||!g.arcade) return 'SKIP: no arcade raid';
       if(ARCADE.role!=='host') return 'SKIP: this window is not the arcade host';
       // PART 1: a score that makes the board, END RUN pressed and confirmed
       ARCADE.mine=12345; ARCADE.kills=3;
       togglePauseBox(true); b.click(); b.click();
       if(up()) return 'SKIP: END RUN left the raid up';
       if(!ARCADE.over||ARCADE.over.why!=='menu') return 'SKIP: END RUN did not end the run ('+(ARCADE.over?ARCADE.over.why:'no card')+')';
       arcadeAttShow();
       if(!ARCADE.on) bad.push('END RUN left the arcade');
       if(!cardOn()) bad.push('after END RUN the RUN OVER card is not up');
       if(!arcadeIniLive()) return bad.length?bad.join('; '):'SKIP: staging: the run did not make the board, so no initials card';
       arcadeIniOp('done'); arcadeAttShow();
       if(!pageOn()) bad.push('after the initials the high score board is not shown');
       else { tx=pg().textContent; if(tx.indexOf(arcadeCr(12345))<0) bad.push('the board does not list the run ('+tx.slice(0,80)+')'); }
       if(cardOn()) bad.push('the RUN OVER card is still up over the board');
       if(up()) bad.push('a new run started before the board');
       // a press the moment the board is up is held, a later press starts the next run
       if(ARCADE.over) ARCADE.over.at-=2000;
       arcadeKeyAtt(ev('KeyW'));
       if(up()) bad.push('a press the moment the board appeared started the next run');
       if(ARCADE.over) ARCADE.over.bat-=2000;
       arcadeKeyAtt(ev('KeyW'));
       if(!up()) bad.push('a press on the board did not start the next run');
       // PART 2: a run with no score (no initials): a press on the RUN OVER card shows the board, the next press starts the run
       if(up()){
         keys={}; ARCADE.holdT=0; ARCADE.waveT=0; ARCADE.ownAt=Date.now(); ARCADE.mine=0; ARCADE.mate=0;
         arcadeRunEnd('menu'); arcadeAttShow();
         if(up()) return bad.length?bad.join('; '):'SKIP: arcadeRunEnd left the raid up';
         if(arcadeIniLive()) return bad.length?bad.join('; '):'SKIP: staging: a run with no score asked for initials';
         if(!cardOn()) bad.push('after a second run end the RUN OVER card is not up');
         if(ARCADE.over) ARCADE.over.at-=2000;
         arcadeKeyAtt(ev('KeyW')); arcadeAttShow();
         if(up()) bad.push('a press on the RUN OVER card started the next run, not the board');
         if(!pageOn()) bad.push('a press on the RUN OVER card did not show the board');
         if(ARCADE.over) ARCADE.over.bat-=2000;
         arcadeKeyAtt(ev('KeyW'));
         if(!up()) bad.push('a press on the board (after the card) did not start the next run');
       }
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       if(ownS) say=rs;
       keys={};
       try{ togglePauseBox(false); }catch(_t){}
       try{ if(typeof arcEndDisarm==='function') arcEndDisarm(); }catch(_d){}
       try{ if(typeof ARCADE==='object'&&ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       try{ ARCADE.mine=0; ARCADE.mate=0; ARCADE.kills=0; ARCADE.holdT=0; ARCADE.waveT=0; ARCADE.over=null; ARCADE.ini=null; }catch(_m){}
       try{ if(hadB){ if(bk===null) localStorage.removeItem(BK); else localStorage.setItem(BK,bk); } }catch(_b2){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'25.84',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
