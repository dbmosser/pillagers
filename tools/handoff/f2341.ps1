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

if ($s.Contains("  {v:'23.41',what:")) { throw "check 23.41 is in the fixture already" }

SubRx @'
  {v:'23.40',what:
'@ @'
  {v:'23.41',what:'arcade18, his order 2026-10-11: the party scoreboard, initials and NEW HIGH SCORE, the board keeps one row per run under its own key, tonight is the top 10 of the last 12 hours and BEST EVER the overall best, a top 10 run end asks for 3 initials on the RUN OVER card (an op, a player 2 op, the pad and the keyboard, 20 s untouched keeps ???), player 2 mirrors the card and sends its pad, an extraction checkpoints the row, NEW HIGH SCORE is said once when the team passes tonights best, his save is never written and a normal raid writes nothing',
   run:function(){
     var bad=[], sv=null, src0, tried0, K='', bk=null, ownBk=false, sk=null, t0=Date.now(), rows, r, c, tx, posted=[], said=[], rs=null, own=false, role0='', ownRole=false, id, b1, g2, n, j;
     function kd(code,key){ window.dispatchEvent(new KeyboardEvent('keydown',{code:code,key:key,bubbles:true,cancelable:true})); window.dispatchEvent(new KeyboardEvent('keyup',{code:code,key:key,bubbles:true})); }
     function row(rn){ var a=arcadeBoardLoad(), q; for(q=0;q<a.length;q++) if(a[q].run===rn) return a[q]; return null; }
     function card(){ var e=ATT.el?ATT.el.querySelector('.arcover'):null; return (e&&e.style.display!=='none')?e.textContent:''; }
     function sent(t){ for(var q=0;q<posted.length;q++) if(posted[q]&&posted[q].t===t) return posted[q]; return null; }
     try{
       __topClear(); __runPrep();
       if(typeof arcadeBoardTonight!=='function'||typeof arcadeIniStart!=='function'||typeof arcadeIniOp!=='function'||typeof ARCADE!=='object') return 'no party board or initials in this build';
       if(ARCADE.on) return 'SKIP: the arcade is on after __topClear';
       if(__state()&&!__state().over) __endRaid('abandon');
       if(__state()) return 'SKIP: a raid is still up after __topClear';
       if(NET.on) return 'SKIP: a party link is up in the fixture';
       K=ARCADE_BOARD_KEY;
       if(K!=='pillagers:arcade:'+'board') bad.push('the board key is '+K);
       bk=localStorage.getItem(K); ownBk=true;
       sv={bc:NET.bc,same:NET.same,pair:NET.pair};
       NET.bc={postMessage:function(m){ posted.push(m); },close:function(){}}; NET.same='host'; NET.pair='tp';
       src0=ATT.src; tried0=ATT.tried; ATT.src=null; ATT.tried=true;
       rs=say; own=true; say=function(m,k){ said.push(String(m)+'|'+String(k||'')); };
       localStorage.removeItem(K);
       if(arcadeBoardTonight().length!==0||arcadeBoardBest()!==0) bad.push('an empty board is not empty');
       localStorage.setItem(K,JSON.stringify({v:1,rows:[{run:'a',s:500,t:t0-1000},{run:'b',s:900,t:t0-2000},{run:'a',s:1200,i:'AAA',t:t0-500},{run:'old',s:99999,i:'ZZZ',t:t0-13*3600000}]}));
       rows=arcadeBoardTonight();
       if(rows.length!==2||rows[0].run!=='a'||rows[0].s!==1200||rows[0].i!=='AAA'||rows[1].run!=='b'||rows[1].s!==900) bad.push('tonight is not one row per run from the last 12 hours, best first ('+JSON.stringify(rows)+')');
       if(arcadeBoardBest()!==99999) bad.push('BEST EVER is '+arcadeBoardBest()+', not 99999');
       if(!arcadeBoardQual('b')||arcadeBoardQual('a')||arcadeBoardQual('old')) bad.push('the initials rule is wrong (only b is in tonights top 10 with no initials)');
       if(!arcadeEnter('host')) return bad.concat(['arcadeEnter(host) failed']).join('; ');
       sk=localStorage.getItem(SKEY);
       // the card: an op, a player 2 op, the pad, then the keyboard finishes it
       if(!arcadeIniStart('b')) bad.push('arcadeIniStart did not start');
       arcadeAttShow();
       tx=card();
       if(tx.indexOf('INITIALS')<0) bad.push('no initials card on the attract ('+tx+')');
       if(!ARCADE.att||ARCADE.att.ph!=='over') bad.push('the loop pages show over the initials card ('+(ARCADE.att&&ARCADE.att.ph)+')');
       if(!sent('arcinis')) bad.push('the host did not send the card to player 2');
       arcadeIniOp('up');
       if(!ARCADE.ini||ARCADE.ini.l[0]!=='B') bad.push('up did not give B ('+(ARCADE.ini?ARCADE.ini.l.join(''):'no card')+')');
       arcadeOnMsg({t:'arcini',pair:'tp',op:'next'});
       if(!ARCADE.ini||ARCADE.ini.pos!==1) bad.push('the player 2 op next did not move to the 2nd letter');
       arcadePadIni([13],[0,0]);
       if(!ARCADE.ini||ARCADE.ini.l[1]!=='Z') bad.push('pad DOWN did not give Z');
       arcadePadIni([0],[0,0]);
       if(!ARCADE.ini||ARCADE.ini.pos!==2) bad.push('pad A did not move to the 3rd letter');
       if(card().indexOf('BZA')<0) bad.push('the card does not show the letters ('+card()+')');
       kd('KeyK','k');
       if(__state()) bad.push('a key on the initials card dropped into a raid');
       if(ARCADE.ini) bad.push('the 3rd letter did not finish the initials');
       r=row('b');
       if(!r||r.i!=='BZK') bad.push('the initials did not reach the board ('+(r?r.i:'no row')+')');
       if(card()) bad.push('the initials card stayed up ('+card()+')');
       // a run end over tonights scores asks for initials; 20 s untouched keeps ???
       if(!arcadeDeploy({mapIx:0,seed:4242})||!__state()||!__state().arcade) return bad.concat(['no arcade drop']).join('; ');
       try{ attStop(); }catch(_as){}
       id=ARCADE.run&&ARCADE.run.id; ARCADE.mine=5000; ARCADE.mate=0; ARCADE.ownAt=Date.now();
       arcadeRunEnd('menu');
       r=row(id);
       if(!r||r.s!==5000) bad.push('the run end did not write the board row ('+JSON.stringify(r)+')');
       if(!ARCADE.ini||ARCADE.ini.run!==id) bad.push('a top 10 run end did not ask for initials');
       tx=card();
       if(tx.indexOf('RUN '+'OVER')<0||tx.indexOf('INITIALS')<0) bad.push('the RUN OVER card has no initials card ('+tx+')');
       if(ARCADE.ini) ARCADE.ini.at=Date.now()-21000;
       arcadeIniTick(Date.now());
       r=row(id);
       if(ARCADE.ini||!r||r.i!=='???') bad.push('20 s untouched did not keep ??? ('+(r?r.i:'no row')+')');
       // NEW HIGH SCORE once, and an extraction checkpoints the row
       if(!arcadeDeploy({mapIx:0,seed:4242})||!__state()||!__state().arcade) return bad.concat(['no second arcade drop']).join('; ');
       try{ attStop(); }catch(_as2){}
       id=ARCADE.run.id; ARCADE.ownAt=Date.now(); said.length=0; posted.length=0;
       ARCADE.mine=4000; arcadeHiTick();
       if(said.join(',').indexOf('NEW HIGH')>=0) bad.push('NEW HIGH SCORE under tonights best');
       ARCADE.mine=6000; arcadeHiTick(); arcadeHiTick();
       for(n=0,j=0;j<said.length;j++) if(said[j]==='NEW HIGH SCORE|ext') n++;
       if(n!==1) bad.push('NEW HIGH SCORE was said '+n+' times over tonights best ('+said.join(',')+')');
       if(!sent('archi')) bad.push('player 2 was not told of the high score');
       arcadeExtracted();
       r=row(id);
       if(!r||r.s!==8500) bad.push('the extraction did not checkpoint the row ('+JSON.stringify(r)+')');
       if(localStorage.getItem(SKEY)!==sk) bad.push('the arcade wrote his save');
       arcadeRaidStop('end');
       // player 2 shows the host card and sends its pad
       role0=ARCADE.role; ownRole=true; ARCADE.role='p2'; NET.same='p2'; posted.length=0;
       if(arcadeOnMsg({t:'arcinis',pair:'tp',run:'zz',l:'QRS',pos:1,on:1})!=='arcinis'||!ARCADE.ini||!ARCADE.ini.mirror) bad.push('player 2 did not take the card');
       arcadeAttShow();
       if(card().indexOf('QRS')<0) bad.push('player 2 does not show the card ('+card()+')');
       arcadePadIni([12],[0,0]);
       c=sent('arcini');
       if(!c||c.op!=='up') bad.push('the player 2 pad did not send up');
       if(ARCADE.ini&&ARCADE.ini.l[0]!=='Q') bad.push('player 2 changed the card itself');
       arcadeOnMsg({t:'arcinis',pair:'tp',run:'zz',on:0});
       if(ARCADE.ini) bad.push('player 2 kept the card after the host closed it');
       if(row('zz')) bad.push('player 2 wrote the board');
       NET.same='host'; ARCADE.role=role0; ownRole=false;
       arcadeLeave();
       // a normal raid writes nothing
       __topClear(); __runPrep();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g2=__state();
       if(!g2) return bad.length?bad.join('; '):'SKIP: __deploy built no raid';
       b1=localStorage.getItem(K);
       if(arcadeBoardPut()||arcadeHiTick()||arcadeIniStart('b')) bad.push('a normal raid ran the board');
       if(localStorage.getItem(K)!==b1) bad.push('a normal raid wrote the board');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       if(own) say=rs;
       try{ if(ownRole) ARCADE.role=role0; if(sv) NET.same=sv.same; }catch(_r){}
       try{ if(typeof ARCADE==='object') ARCADE.ini=null; }catch(_i){}
       try{ if(typeof ARCADE==='object'&&ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       try{ if(sv){ NET.bc=sv.bc; NET.same=sv.same; NET.pair=sv.pair; } }catch(_n){}
       try{ if(sv){ ATT.src=src0; ATT.tried=tried0; } }catch(_a){}
       try{ if(ownBk){ if(bk===null) localStorage.removeItem(K); else localStorage.setItem(K,bk); } }catch(_b){}
       try{ if(typeof ARCADE==='object'){ ARCADE.over=null; ARCADE.mine=0; ARCADE.mate=0; ARCADE.holdT=0; ARCADE.waveT=0; ARCADE.hiRun=''; ARCADE.hiSaid=0; ARCADE.ownAt=0; ARCADE.idleSaid=0; } }catch(_m){}
       try{ for(var kk in keys) keys[kk]=false; }catch(_k){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'23.40',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
