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
  {v:'15.14',what:
'@ @'
  {v:'15.15',what:'the backquote Superhot key redraws an open Settings window: with Settings open the key turns Superhot on and the Superhot row reads On, a click on that row then turns it off and changes the word, and the key turning it off leaves the row reading Off (dials audit finding 7)',
   run:function(){
     if(!(window.__P&&window.__applyLoaded&&window.__resetCfg&&window.__cleanProfile&&window.__runPrep&&window.__topClear)) return 'SKIP: this fixture cannot stage and restore the profile';
     if(typeof openSettings!=='function'||typeof renderSettings!=='function'||typeof gameOptLive!=='function'||typeof applyGameOpts!=='function'||typeof GAMEOPTS==='undefined') return 'SKIP: this build has no Settings rows that read the dials';
     var sm=document.getElementById('settingsmodal');
     if(!sm) return 'SKIP: this build has no Settings window in the page';
     if(window.__state&&__state()&&!__state().over) return 'SKIP: a raid is live, and this check reads Settings in the Undercroft';
     var ROW=null, i, k;
     for(i=0;i<GAMEOPTS.length;i++) if(GAMEOPTS[i].k==='superhot') ROW=GAMEOPTS[i];
     if(!ROW||ROW.opts.length!==2||ROW.opts[0].cfg.superhot!==0||ROW.opts[1].cfg.superhot!==1) return 'SKIP: this build has no two-word Superhot row';
     var OFF=ROW.opts[0].n, ON=ROW.opts[1].n;
     var bad=[], snap=null, cfg0={}, said=[], mods=[], smWasOn=sm.classList.contains('on');
     var _say=say, has2=(typeof say2==='function'), _s2=has2?say2:null;
     var open0=document.querySelectorAll('.modal.on');
     for(i=0;i<open0.length;i++) mods.push(open0[i]);
     for(k in CFG) cfg0[k]=CFG[k];
     // A later control that cannot run keeps a failure already found, so the old build fails rather than skips.
     var skip=function(m){ return bad.length?(bad.join('; ')+' (then SKIP: '+m+')'):('SKIP: '+m); };
     var rowTxt=function(){ var b=document.getElementById('go_superhot'); return b?String(b.textContent||'').trim():''; };
     var clickRow=function(){ var b=document.getElementById('go_superhot'); if(b) b.click(); };
     // One press of the backquote key, dispatched on window only, with both of the game's message paths read and put back.
     var press=function(){
       said.length=0;
       say=function(m){ said.push(String(m)); }; if(has2) say2=function(m){ said.push(String(m)); };
       try{ window.dispatchEvent(new KeyboardEvent('keydown',{code:'Backquote',bubbles:true,cancelable:true})); }
       finally{ say=_say; if(has2) say2=_s2; }
       return said.join(' | ');
     };
     try{
       __topClear(); __runPrep(); __resetCfg(); __cleanProfile();
       snap=JSON.parse(JSON.stringify(__P()));
       // Superhot off in the saved choice and on the dial, and the word editor off, so a click on a row is a click on it.
       var q=__P(); q.gameOpts=q.gameOpts||{}; q.gameOpts.superhot=0; q.gameOpts.textEdit=0;
       applyGameOpts();
       // CONTROL: the dials took the staged choice.
       if(CFG.superhot!==0||CFG.textEdit===1) return 'SKIP: Superhot or the word editor did not go off here (superhot '+CFG.superhot+', textEdit '+CFG.textEdit+')';
       openSettings('display');
       // CONTROL: Settings is open through its own opener, and its Superhot row reads the dial, Off.
       if(!sm.classList.contains('on')) return 'SKIP: Settings did not open here';
       if(!document.getElementById('go_superhot')) return 'SKIP: Settings has no Superhot row here';
       if(rowTxt()!==OFF) return 'SKIP: the Superhot row did not start at '+OFF+' here (it reads '+rowTxt()+')';
       // CONTROL: the row itself steps the dial and redraws both ways, so the id read and the redraw are live.
       clickRow();
       if(CFG.superhot!==1||rowTxt()!==ON) return 'SKIP: a click on the Superhot row did not turn it on and read '+ON+' here ('+rowTxt()+', dial '+CFG.superhot+')';
       clickRow();
       if(CFG.superhot!==0||rowTxt()!==OFF) return 'SKIP: a second click did not turn it off and read '+OFF+' here ('+rowTxt()+', dial '+CFG.superhot+')';
       // ONE: with Settings open, the backquote key turns Superhot on. The row he is looking at must say so.
       var s1=press();
       // CONTROL: the key reached the game: the dial is on, it said so, and Settings is still open.
       if(CFG.superhot!==1||(has2&&s1.indexOf('SUPERHOT ON')<0)) return skip('the backquote key did not turn Superhot on here (dial '+CFG.superhot+', said '+s1.slice(0,40)+')');
       if(!sm.classList.contains('on')) return skip('the key closed Settings here');
       var t1=rowTxt();
       if(t1!==ON) bad.push('with Settings open, the backquote key turned Superhot on and the Superhot row still reads '+t1);
       // TWO: he clicks the row, going by the word it shows.
       clickRow();
       var t2=rowTxt();
       // CONTROL: the click stepped the live dial off and the row redrew from it.
       if(CFG.superhot!==0||t2!==OFF) return skip('a click on the row after the key did not turn Superhot off here ('+t2+', dial '+CFG.superhot+')');
       if(t1===t2) bad.push('a click on the Superhot row after the key left it reading '+t2+', so the click looked like it did nothing while it turned Superhot off');
       // THREE: the other way. The row turns Superhot on, then the key turns it off; the row must read Off.
       clickRow();
       if(CFG.superhot!==1||rowTxt()!==ON) return skip('a click did not turn Superhot back on here ('+rowTxt()+', dial '+CFG.superhot+')');
       var s3=press();
       // CONTROL: the key turned the dial off and said so.
       if(CFG.superhot!==0||(has2&&s3.indexOf('SUPERHOT OFF')<0)) return skip('the backquote key did not turn Superhot off here (dial '+CFG.superhot+', said '+s3.slice(0,40)+')');
       var t3=rowTxt();
       if(t3!==OFF) bad.push('with Settings open, the backquote key turned Superhot off and the Superhot row still reads '+t3);
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       say=_say; if(has2) say2=_s2;
       try{ if(!smWasOn) sm.classList.remove('on'); for(i=0;i<mods.length;i++) mods[i].classList.add('on'); }catch(_m){}
       try{ for(k in CFG) if(!(k in cfg0)) delete CFG[k]; for(k in cfg0) CFG[k]=cfg0[k]; }catch(_k){}
       try{ if(snap) __applyLoaded(snap); }catch(_r){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'15.14',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
