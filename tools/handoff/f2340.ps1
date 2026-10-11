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

if ($s.Contains("  {v:'23.40',what:")) { throw "check 23.40 is in the fixture already" }

SubRx @'
  {v:'23.39',what:
'@ @'
  {v:'23.40',what:'arcade17, his order 2026-10-11: the attract loop, the arcade attract cycles VIDEO, TONIGHTS BEST and HOW TO PLAY (board and HOW TO PLAY with no clip), the RUN OVER card hands on to the board, HAPPY HALLOWEEN is on it, a live run shows JOIN YOUR TEAM with the team score and LINKING while player 2 waits, a mousemove starts no raid and a key drops in, and leaving takes it all off the title attract',
   run:function(){
     var bad=[], sv=null, src0, tried0, d, a, pg, bo, sp, ap, ph, tx, role0='host', ownRole=false;
     function kd(code,key){ window.dispatchEvent(new KeyboardEvent('keydown',{code:code,key:key,bubbles:true,cancelable:true})); window.dispatchEvent(new KeyboardEvent('keyup',{code:code,key:key,bubbles:true})); }
     function q(c){ return ATT.el?ATT.el.querySelector('.'+c):null; }
     function on(e){ return !!e&&e.style.display!=='none'; }
     function step(t){ ARCADE.att.t=t; arcadeAttShow(); return ARCADE.att.ph; }
     try{
       __topClear(); __runPrep();
       if(typeof arcadeAttStart!=='function'||typeof arcadeAttPhase!=='function'||typeof ARCADE!=='object') return 'no arcade attract loop in this build';
       if(ARCADE.on) return 'SKIP: the arcade is on after __topClear';
       if(__state()&&!__state().over) __endRaid('abandon');
       if(__state()) return 'SKIP: a raid is still up after __topClear';
       if(NET.on) return 'SKIP: a party link is up in the fixture';
       sv={bc:NET.bc,same:NET.same,pair:NET.pair};
       NET.bc={postMessage:function(){},close:function(){}}; NET.same='host'; NET.pair='tp';
       src0=ATT.src; tried0=ATT.tried; ATT.src=null; ATT.tried=true;   // no clip, and no clip probe
       if(arcadeAttPhase(5,true)!=='video'||arcadeAttPhase(41,true)!=='board'||arcadeAttPhase(51,true)!=='howto'||arcadeAttPhase(61,true)!=='video') bad.push('with a clip the loop is not VIDEO 40, BOARD 10, HOW TO PLAY 10');
       if(!arcadeEnter('host')) return 'arcadeEnter(host) failed';
       arcadeAttStart();
       a=ARCADE.att; d=attEl();
       if(!a||!(a.t<1)) bad.push('the loop clock did not start at 0 ('+(a&&a.t)+')');
       if(d.style.display!=='block') bad.push('the arcade attract is not up');
       ap=q('attpress');
       if(!ap||ap.textContent!=='PRESS ANY '+'BUTTON') bad.push('the host attract reads '+(ap?ap.textContent:'nothing'));
       bo=q('arcboo');
       if(!on(bo)||bo.textContent!=='HAPPY '+'HALLOWEEN') bad.push('no HAPPY HALLOWEEN banner on the attract');
       sp=q('arcstrip');
       if(on(sp)) bad.push('with no run the attract shows the team strip ('+sp.textContent+')');
       ph=step(41); pg=q('arcpage'); tx=pg?pg.textContent:'';
       if(ph!=='board') bad.push('past 40 s with no clip the loop is on '+ph+', not board');
       if(!on(pg)||tx.indexOf('TONIGHT')<0||tx.indexOf('BEST')<0) bad.push('the board page is not shown ('+tx+')');
       ph=step(51); tx=pg?pg.textContent:'';
       if(ph!=='howto') bad.push('10 s later the loop is on '+ph+', not howto');
       if(!on(pg)||tx.indexOf('HOW TO '+'PLAY')<0||tx.indexOf('KEYBOARD')<0||tx.indexOf('CONTROLLER')<0||tx.indexOf('MOVE')<0) bad.push('the HOW TO PLAY page is not shown ('+tx+')');
       ph=step(61);
       if(ph!=='board') bad.push('10 s after that the loop is on '+ph+', not board again');
       // the RUN OVER card first, then the board with the last run
       ARCADE.over={at:Date.now(),why:'t',team:4321,p1:{s:4321,k:3,x:1,d:0},p2:null};
       ph=step(15);
       if(ph!=='over') bad.push('with the RUN OVER card up the loop is on '+ph);
       if(on(pg)) bad.push('a loop page shows over the RUN OVER card');
       ARCADE.over.at=Date.now()-13000;
       ph=step(15); tx=pg?pg.textContent:'';
       if(ph!=='board') bad.push('after the RUN OVER card the loop went to '+ph+', not the board');
       if(tx.indexOf('4,321')<0) bad.push('the board after a run does not show the last run ('+tx+')');
       ARCADE.over=null;
       // player 2: the live team strip and LINKING
       role0=ARCADE.role; ownRole=true; ARCADE.role='p2'; ARCADE.wantIn=0; ARCADE.mine=0;
       arcadeScTake({t:'arcsc',pair:'tp',run:'tstrun',s:2500,k:2,x:0});
       arcadeAttShow(); sp=q('arcstrip'); ap=q('attpress');
       if(!ap||ap.textContent!=='PLAYER 2: PRESS'+' A') bad.push('the player 2 attract reads '+(ap?ap.textContent:'nothing'));
       if(!on(sp)||sp.textContent.indexOf('JOIN YOUR '+'TEAM')<0||sp.textContent.indexOf('2,500')<0) bad.push('player 2 out of a live run has no JOIN YOUR TEAM strip ('+(sp?sp.textContent:'')+')');
       ARCADE.wantIn=1; arcadeAttShow();
       if(!on(sp)||sp.textContent.indexOf('LINKING')<0) bad.push('player 2 waiting to get in does not read LINKING ('+(sp?sp.textContent:'')+')');
       ARCADE.scSeen=0; ARCADE.wantIn=0; arcadeAttShow();
       if(on(sp)) bad.push('the team strip stayed with no live run ('+sp.textContent+')');
       ARCADE.role=role0; ownRole=false; ARCADE.mate=0; ARCADE.mateK=0; ARCADE.run=null; arcadeAttShow();
       // a mousemove starts nothing, a key drops in
       window.dispatchEvent(new MouseEvent('mousemove',{clientX:300,clientY:300,bubbles:true}));
       window.dispatchEvent(new MouseEvent('mousemove',{clientX:640,clientY:480,bubbles:true}));
       if(__state()) bad.push('a mousemove started a raid');
       kd('KeyJ','j');
       if(!__state()||!__state().arcade) bad.push('a key on the arcade attract did not drop in');
       else {
         if(ATT.on||d.style.display!=='none') bad.push('the attract stayed up over the arcade raid');
         // a benched player 1 sees the attract from the top with the team strip
         ARCADE.att.t=33; __state().player.specOut=1; ARCADE.mine=1234; ARCADE.mate=0;
         arcadeAttShow(); sp=q('arcstrip');
         if(!(ARCADE.att.t<1)) bad.push('the loop did not start again when the attract came back ('+ARCADE.att.t+')');
         if(!on(sp)||sp.textContent.indexOf('JOIN YOUR '+'TEAM')<0||sp.textContent.indexOf('1,234')<0) bad.push('a benched player 1 has no team strip ('+(sp?sp.textContent:'')+')');
         __state().player.specOut=0; attStop();
       }
       arcadeLeave();
       if(ARCADE.on) bad.push('arcadeLeave left the arcade on');
       if(on(q('arcpage'))||on(q('arcboo'))||on(q('arcstrip'))) bad.push('leaving the arcade left its pages on the title attract');
       if(ARCADE.att) bad.push('leaving the arcade kept the loop clock');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       try{ if(ownRole) ARCADE.role=role0; ARCADE.wantIn=0; ARCADE.scSeen=0; ARCADE.over=null; ARCADE.mine=0; ARCADE.mate=0; ARCADE.mateK=0; }catch(_r){}
       try{ if(typeof ARCADE==='object'&&ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       try{ if(sv){ NET.bc=sv.bc; NET.same=sv.same; NET.pair=sv.pair; } }catch(_n){}
       try{ if(sv){ ATT.src=src0; ATT.tried=tried0; } }catch(_a){}
       try{ for(var k in keys) keys[k]=false; }catch(_k){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'23.39',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
