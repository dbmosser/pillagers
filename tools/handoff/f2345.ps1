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

if ($s.Contains("  {v:'23.45',what:")) { throw "check 23.45 is in the fixture already" }

SubRx @'
  {v:'23.44',what:
'@ @'
  {v:'23.45',what:'arcade22, his yes 2026-10-11: initials at the first qualifying extraction, an extraction under tonights 10th score opens no card, the first one over it opens the initials card on the HUD, holds the drop with no DROPPING IN count, takes the keys (a movement key is a letter, not a step) and the pad, Enter writes the initials to the run row, the drop then counts down, a later extraction asks no more, and a normal raid never opens it',
   run:function(){
     var bad=[], K='', bk=null, ownBk=false, g=null, g2=null, id, t0=Date.now(), rw=[], i, r, tr, base, f, gt0, nE='ENTER '+'INITIALS', nD='DROPPING '+'IN',
         NG=navigator.getGamepads, ownNG=Object.prototype.hasOwnProperty.call(navigator,'getGamepads'), padK={}, pk, ownPad=false, down12=false, kW=null;
     function kd(code,key){ window.dispatchEvent(new KeyboardEvent('keydown',{code:code,key:key,bubbles:true,cancelable:true})); window.dispatchEvent(new KeyboardEvent('keyup',{code:code,key:key,bubbles:true})); }
     function row(rn){ var a=arcadeBoardLoad(), q; for(q=0;q<a.length;q++) if(a[q].run===rn) return a[q]; return null; }
     function has(list,s){ var j; for(j=0;j<list.length;j++) if(list[j].t.indexOf(s)>=0) return true; return false; }
     function eq(list,s){ var j; for(j=0;j<list.length;j++) if(list[j].t===s) return true; return false; }
     function frame(ts){ return __textTrace(function(){ __loop(ts); }); }
     function pad(){ var b=[], q; for(q=0;q<17;q++) b.push({pressed:(q===12&&down12),value:(q===12&&down12)?1:0,touched:false}); return [{connected:true,id:'check pad',index:0,mapping:'standard',timestamp:Date.now(),buttons:b,axes:[0,0,0,0]}]; }
     try{
       __topClear(); __runPrep();
       if(typeof arcadeDeploy!=='function'||typeof arcadeExtracted!=='function'||typeof arcadeBoardLoad!=='function'||typeof ARCADE!=='object') return 'no arcade board in this build';
       if(ARCADE.on) return 'SKIP: the arcade is on after __topClear';
       if(__state()&&!__state().over) __endRaid('abandon');
       K=ARCADE_BOARD_KEY; bk=localStorage.getItem(K); ownBk=true;
       for(i=0;i<10;i++) rw.push({run:'q'+i,i:'ZZZ',s:20000+i*1000,x:1,k:1,t:t0-60000-i});
       localStorage.setItem(K,JSON.stringify({v:1,rows:rw}));
       if(!arcadeDeploy({mapIx:0,seed:4242})||!__state()||!__state().arcade) return 'SKIP: arcadeDeploy built no arcade raid';
       try{ attStop(); }catch(_as){}
       g=__state(); keys={}; ARCADE.ownAt=Date.now(); ARCADE.waveT=0; ARCADE.mine=0; ARCADE.mate=0; ARCADE.pot=0;
       id=ARCADE.run&&ARCADE.run.id;
       if(!id) return 'SKIP: the arcade raid has no run id';
       // under tonights 10th score: the row is written, no card
       arcadeExtracted();
       r=row(id);
       if(!r||!(r.s>0&&r.s<20000)) bad.push('the first extraction did not write a row under the 10th score ('+JSON.stringify(r)+')');
       if(ARCADE.ini) bad.push('an extraction under tonights 10th score opened the initials card');
       // over it: the card opens on the run
       ARCADE.holdT=0; ARCADE.mine=30000; ARCADE.ownAt=Date.now();
       arcadeExtracted();
       r=row(id);
       if(!r||!(r.s>=30000)) bad.push('the second extraction did not write the row over the 10th score ('+JSON.stringify(r)+')');
       if(!ARCADE.ini||ARCADE.ini.run!==id||ARCADE.ini.mirror) return bad.concat(['the first extraction into tonights top 10 did not open the initials card']).join('; ');
       if(__state()!==g||g.over) return bad.concat(['the arcade raid ended at the extraction']).join('; ');
       base=performance.now()+1000;
       tr=frame(base);
       if(!has(tr,nE)) bad.push('no initials card drawn at the extraction');
       if(has(tr,nD)) bad.push('DROPPING IN counts while the initials card is up');
       gt0=+g.t||0;
       for(f=1;f<=150&&__state()===g&&!g.over;f++){ ARCADE.ownAt=Date.now(); __loop(base+f*100); }
       if(__state()!==g||g.over) return bad.concat(['the arcade raid ended during the frames']).join('; ');
       if(!((+g.t||0)-gt0>=6.5)) return bad.length?bad.join('; '):'SKIP: the frames advanced game time by only '+((+g.t||0)-gt0).toFixed(2)+' s';
       if(!ARCADE.ini) bad.push('the card closed by itself within 7 s of game time');
       if(!((+ARCADE.holdT||0)>=2.9)) bad.push('the card did not hold the drop (holdT '+ARCADE.holdT+')');
       // the keyboard: a letter, then a movement key is a letter and not a step
       kd('KeyQ','q');
       if(!ARCADE.ini||ARCADE.ini.l[0]!=='Q'||ARCADE.ini.pos!==1) bad.push('Q did not set the 1st letter ('+(ARCADE.ini?ARCADE.ini.l.join('')+ARCADE.ini.pos:'no card')+')');
       keys['KeyW']=false; if(PAD.held) PAD.held['KeyW']=0;
       document.body.dispatchEvent(new KeyboardEvent('keydown',{code:'KeyW',key:'w',bubbles:true,cancelable:true}));
       kW=keys['KeyW'];
       document.body.dispatchEvent(new KeyboardEvent('keyup',{code:'KeyW',key:'w',bubbles:true}));
       if(kW) bad.push('W on the card also pressed the movement key');
       if(!ARCADE.ini||ARCADE.ini.l[1]!=='W'||ARCADE.ini.pos!==2) bad.push('W did not set the 2nd letter ('+(ARCADE.ini?ARCADE.ini.l.join('')+ARCADE.ini.pos:'no card')+')');
       // this window pad: D-pad up on the 3rd letter
       for(pk in PAD) if(Object.prototype.hasOwnProperty.call(PAD,pk)) padK[pk]=PAD[pk];
       padK.prev=(PAD.prev||[]).slice(); if(PAD.held){ padK.held={}; for(pk in PAD.held) padK.held[pk]=PAD.held[pk]; }
       ownPad=true; PAD.announced=true; PAD.prev=[]; PAD.held={};
       navigator.getGamepads=pad;
       down12=false; pollPad(); down12=true; pollPad(); down12=false; pollPad();
       if(!ARCADE.ini||ARCADE.ini.l[2]!=='B'||ARCADE.ini.pos!==2) bad.push('pad D-UP did not change the 3rd letter to B ('+(ARCADE.ini?ARCADE.ini.l.join('')+ARCADE.ini.pos:'no card')+')');
       tr=frame(base+151*100);
       if(!has(tr,nE)||!eq(tr,'Q')||!eq(tr,'W')||!eq(tr,'B')) bad.push('the card does not draw the letters QWB');
       kd('Enter','Enter');
       if(ARCADE.ini) bad.push('Enter did not finish the card');
       r=row(id);
       if(!r||r.i!=='QWB') bad.push('the run row does not carry the initials QWB ('+(r?r.i:'no row')+')');
       for(f=152;f<=175&&__state()===g&&!g.over;f++){ ARCADE.ownAt=Date.now(); __loop(base+f*100); }
       if(!((+ARCADE.holdT||0)<2.9)) bad.push('the drop did not count down after the card ('+ARCADE.holdT+')');
       tr=frame(base+176*100);
       if(has(tr,nE)) bad.push('the card is still drawn after Enter');
       // a later extraction asks no more
       ARCADE.mine=(ARCADE.mine|0)+5000; ARCADE.ownAt=Date.now();
       arcadeExtracted();
       if(ARCADE.ini) bad.push('a later extraction opened the card again');
       r=row(id);
       if(!r||r.i!=='QWB') bad.push('a later extraction lost the initials ('+(r?r.i:'no row')+')');
       try{ arcadeLeave(); }catch(_lv){}
       // a normal raid never opens it
       __topClear(); __runPrep();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g2=__state();
       if(!g2) return bad.length?bad.join('; '):'SKIP: __deploy built no raid';
       if(g2.arcade) bad.push('a normal raid is flagged arcade');
       if(typeof arcadeIniExtract==='function'&&arcadeIniExtract()) bad.push('a normal raid opened the initials card');
       if(ARCADE.ini) bad.push('a normal raid has an initials card');
       tr=frame(performance.now()+20000);
       if(has(tr,nE)) bad.push('a normal raid draws the initials card');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       try{ if(ownNG) navigator.getGamepads=NG; else { try{ delete navigator.getGamepads; }catch(_d){} if(navigator.getGamepads!==NG) navigator.getGamepads=NG; } }catch(_n){}
       if(ownPad){
         try{ pollPad(); }catch(_p){}
         try{ for(pk in PAD) if(Object.prototype.hasOwnProperty.call(PAD,pk)&&!Object.prototype.hasOwnProperty.call(padK,pk)) delete PAD[pk]; for(pk in padK) PAD[pk]=padK[pk]; }catch(_pk){}
       }
       try{ if(typeof ARCADE==='object') ARCADE.ini=null; }catch(_i){}
       try{ if(typeof ARCADE==='object'&&ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       try{ if(ownBk){ if(bk===null) localStorage.removeItem(K); else localStorage.setItem(K,bk); } }catch(_b){}
       try{ if(typeof ARCADE==='object'){ ARCADE.over=null; ARCADE.mine=0; ARCADE.mate=0; ARCADE.pot=0; ARCADE.holdT=0; ARCADE.waveT=0; ARCADE.iniX=''; ARCADE.ownAt=0; ARCADE.idleSaid=0; } }catch(_m){}
       try{ for(var kk in keys) keys[kk]=false; }catch(_k){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'23.44',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
