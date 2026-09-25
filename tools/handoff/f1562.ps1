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
  {v:'15.61',what:
'@ @'
  {v:'15.62',what:'ESC and TAB leave the end of raid card through its own button: on the card after a run abandoned with a shot fired, with the Too dark tag chosen and a note typed, a fresh TAB takes the card down, returns to the Undercroft and logs the run once with that tag and that note, exactly as a click on Log run and return does, and ESC on a second card does the same (menus audit finding)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__P&&window.__applyLoaded)) return 'SKIP: this fixture cannot deploy and restore the profile';
     if(typeof endRaid!=='function'||typeof ocCommit!=='function'||typeof togglePauseBox!=='function') return 'SKIP: no end of raid, run commit or pause box in this build';
     if(typeof pendingRun==='undefined'||typeof committedRun==='undefined'||typeof selTags==='undefined') return 'SKIP: no run waiting to be logged in this build';
     if(typeof keys==='undefined'||typeof mouse==='undefined'||typeof state==='undefined') return 'SKIP: no keys, mouse or screen state in this build';
     if(typeof G!=='undefined'&&G&&G.sim) return 'SKIP: a sim is running';
     var oc=document.getElementById('outcome'), ob=document.getElementById('oc_btn'), tw=document.getElementById('tagwrap');
     var nt=document.getElementById('oc_note'), pb=document.getElementById('pausebox');
     if(!oc||!ob||!tw||!nt||!pb) return 'SKIP: this build has no end of raid card, Log run and return button, tags, note box or pause box in the page';
     var bad=[], snap=null, why=null, arm=null, keep={p:pendingRun,c:committedRun,s:selTags};
     var NOTE='zq-tab-probe-7', TAG='Too dark';
     // keys is replaced by a fresh object when the card is left, so it is looked up by name every time.
     function clearKeys(){ try{ for(var kk in keys) keys[kk]=false; mouse.down=false; }catch(_k){} }
     function cardUp(){ return oc.classList.contains('on'); }
     // Left the way the button leaves: card down, the Undercroft up and the raid let go. Stripping the card leaves the page in
     // the raid, so it does not count.
     function left(){ return !cardUp()&&state==='hub'&&!__state(); }
     // A raid at seed 4242, abandoned with one shot on its record so the card comes up instead of the instant quit, then the
     // Too dark tag chosen and the note typed on the card, the way he would leave them.
     function up(){
       __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __P().autoExport=false;   // a check must not start a download
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state();
       if(!g||!g.player||!g.tel||g.over) return 'no live raid';
       if(state!=='raid') return 'the page is not in a raid here';
       if(document.querySelectorAll('.modal.on').length||pb.classList.contains('on')) return 'a window or the pause box is open over the raid here';
       clearKeys();
       g.tel.shots=Math.max(1,g.tel.shots|0);
       var n0=(__P().log||[]).length;
       endRaid('abandon');
       // CONTROL: the card is up over a raid that is over, with a run waiting to be logged and nothing open over it.
       if(g.over!=='abandon'||!cardUp()) return 'abandoning the raid after a shot did not put the card up here';
       if(state!=='raid'||__state()!==g||!pendingRun) return 'the card came up with the page out of the raid or no run waiting to be logged here';
       if(document.querySelectorAll('.modal.on').length||pb.classList.contains('on')) return 'a window or the pause box is open over the card here';
       var tg=null, ts=tw.querySelectorAll('.tag');
       for(var i=0;i<ts.length;i++) if(ts[i].textContent===TAG){ tg=ts[i]; break; }
       if(!tg) return 'the card has no '+TAG+' tag here';
       tg.click();
       // CONTROL: the tag took and the note is typed.
       if(selTags.indexOf(TAG)<0) return 'clicking the '+TAG+' tag on the card did not choose it here';
       nt.value=NOTE;
       arm={rec:pendingRun,n0:n0};
       return null;
     }
     // Logged the way the button logs: nothing waits, the run just played is the committed run, it carries the tag and the note,
     // it is in the log exactly once, and the log holds one row more than before the raid ended.
     function logged(){
       var L=__P().log||[], r=arm.rec, c=0, out=[];
       for(var i=0;i<L.length;i++) if(L[i]===r) c++;
       if(pendingRun!==null) out.push('a run was still waiting to be logged');
       if(committedRun!==r) out.push('the committed run is not the run just played');
       if(!r||r.note!==NOTE) out.push('the run holds the note '+JSON.stringify(r&&r.note)+' rather than the one typed on the card');
       if(!r||(r.tags||[]).indexOf(TAG)<0) out.push('the '+TAG+' tag chosen on the card is not on the run');
       if(c!==1) out.push('the run is in the log '+c+' times');
       if(L.length!==Math.min(arm.n0+1,60)) out.push('the log went from '+arm.n0+' to '+L.length+' rows');
       return out.length?out.join(', '):null;
     }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       snap=JSON.parse(JSON.stringify(__P()));
       // TAB: a fresh press dispatched at window, where the key listener hears it. The main assertion, because a synthetic ESC
       // at window reaches the pause box closer late.
       why=up(); if(why) return 'SKIP: '+why;
       window.dispatchEvent(new KeyboardEvent('keydown',{code:'Tab',key:'Tab',bubbles:true,cancelable:true}));
       clearKeys();
       if(!left()){
         bad.push('TAB on the end of raid card did nothing: the card stayed up, the page stayed in the raid and the run still waited to be logged, so only the mouse or a controller could leave it');
         // CONTROL, only when the key did not leave: the button itself leaves the card and logs the tag and the note.
         ob.click(); clearKeys();
         if(!left()) return 'SKIP: even a plain click on Log run and return did not leave the card here';
         why=logged(); if(why) return 'SKIP: a plain click on Log run and return left the card, but '+why+', so the card cannot log what was chosen on it here';
       } else { why=logged(); if(why) bad.push('TAB left the end of raid card, but '+why); }
       // ESC on a second card, dispatched on the body: the real path, the window capture listener first and then the key listener.
       why=up(); if(why) return 'SKIP: '+why;
       document.body.dispatchEvent(new KeyboardEvent('keydown',{code:'Escape',key:'Escape',bubbles:true,cancelable:true}));
       clearKeys();
       if(!left()){
         bad.push('ESC on the end of raid card did nothing: the card stayed up, the page stayed in the raid and the run still waited to be logged');
         ob.click(); clearKeys();
         if(!left()) return 'SKIP: even a plain click on Log run and return did not leave the second card here';
       } else {
         why=logged(); if(why) bad.push('ESC left the end of raid card, but '+why);
         if(pb.classList.contains('on')) bad.push('ESC on the end of raid card also raised the pause box over the Undercroft');
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       clearKeys();
       try{ if(pb.classList.contains('on')) togglePauseBox(false); }catch(_pb){}
       try{ var gl=__state(); if(gl&&!gl.over) __endRaid('abandon'); }catch(_e){}
       // Back in the Undercroft a first run window may have opened on the return; the next raid would shut it anyway.
       try{ if(snap&&state==='hub'){ var mo=document.querySelectorAll('.modal.on'); for(var mi=0;mi<mo.length;mi++) mo[mi].classList.remove('on'); } }catch(_m){}
       try{ if(snap) __applyLoaded(snap); }catch(_r){}
       try{ pendingRun=keep.p; committedRun=keep.c; selTags=keep.s; }catch(_kr){}
       try{ nt.value=''; }catch(_n){}
       clearKeys();
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'15.61',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
