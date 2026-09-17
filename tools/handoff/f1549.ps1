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
  {v:'15.48',what:
'@ @'
  {v:'15.49',what:'holding ESC or P does not flicker the pause box: in a raid a fresh P opens the box and five held repeats of P leave it open without a flip, four held repeats of the ESC that closed the map leave the box shut without a flip, four held ESC repeats sent through the page to the open box leave it open while a fresh ESC sent the same way still closes it, and fresh presses of TAB still open and close it (pause audit finding 9)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     if(typeof togglePauseBox!=='function'||typeof raidKey!=='function') return 'SKIP: no pause box or raid keys in this build';
     if(typeof keys==='undefined'||typeof mouse==='undefined'||typeof KeyboardEvent==='undefined') return 'SKIP: no keys, mouse or keyboard events in this build';
     if(typeof G!=='undefined'&&G&&G.sim) return 'SKIP: a sim is running';
     var pb=document.getElementById('pausebox');
     if(!pb||!document.body) return 'SKIP: this build has no pause box in the page';
     var bad=[], g=null, keep=null;
     // A later control that cannot run keeps a failure already found, so the old build fails rather than skips.
     var skip=function(m){ return bad.length?(bad.join('; ')+' (then SKIP: '+m+')'):('SKIP: '+m); };
     function clearKeys(){ try{ for(var kk in keys) keys[kk]=false; mouse.down=false; }catch(_k){} }
     function up(){ return pb.classList.contains('on'); }
     function shut(){ clearKeys(); if(up()) togglePauseBox(false); clearKeys(); }
     // One raid key the way the keydown listener hands it over; rep marks a key repeat.
     function key(c,rep){ clearKeys(); raidKey(c,!!rep,null); clearKeys(); }
     // A real key lands on the body, so the box listener on window runs first in the capture phase and the raid keys after.
     function press(c,rep){
       clearKeys();
       document.body.dispatchEvent(new KeyboardEvent('keydown',{code:c,key:c,repeat:!!rep,bubbles:true,cancelable:true}));
       clearKeys();
     }
     // Held: n key repeats of one key, counting how often the box flipped and where it came to rest.
     function hold(c,cnt,viaPage){
       var was=up(), flips=0;
       for(var i=0;i<cnt;i++){ if(viaPage) press(c,true); else key(c,true); var now=up(); if(now!==was) flips++; was=now; }
       return {flips:flips,open:was};
     }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: no live raid';
       keep={mapOpen:g.mapOpen,bagOpen:g.bagOpen,emoteBar:g.emoteBar,trade:g.trade,drag:g.drag};
       g.mapOpen=false; g.bagOpen=false; g.emoteBar=false; g.trade=null; g.drag=null;
       shut();
       if(up()) return 'SKIP: the pause box would not shut here';
       // CONTROL: fresh presses of P open and then close the box, so the toggle can be read.
       key('KeyP'); var o1=up(); key('KeyP'); var c1=!up();
       if(!o1||!c1) return 'SKIP: a fresh P did not open and then close the pause box here';
       // HELD P: the fresh press opens the box and five key repeats follow.
       key('KeyP');
       if(!up()) return 'SKIP: a fresh P did not open the pause box here';
       var hp=hold('KeyP',5,false);
       // THE FIX, ONE: a held P leaves the box as its first press left it.
       if(hp.flips>0||!hp.open) bad.push('holding P in a raid, five key repeats after the press that opened the pause box flipped it '+hp.flips+' times and it came to rest '+(hp.open?'open':'shut'));
       shut();
       if(up()) return skip('the pause box would not shut after the held P here');
       // HELD ESC OVER THE MAP: the fresh ESC closes the map, and four key repeats follow.
       g.mapOpen=true;
       key('Escape');
       // CONTROL: the fresh ESC closed the map and left the box shut, so ESC went to what was in front.
       if(g.mapOpen||up()) return skip('a fresh ESC over the open map did not close only the map here (map '+(g.mapOpen?'open':'shut')+', box '+(up()?'open':'shut')+')');
       var he=hold('Escape',4,false);
       // THE FIX, TWO: holding on after the map closed leaves the box shut.
       if(he.flips>0||he.open) bad.push('holding the ESC that closed the map, four key repeats flipped the pause box '+he.flips+' times and it came to rest '+(he.open?'open':'shut'));
       shut(); g.mapOpen=false;
       if(up()) return skip('the pause box would not shut after the held ESC here');
       // THE BOX LISTENER, on the path a real key takes through the page.
       if(typeof state==='undefined'||state!=='raid') return skip('the page is not in a raid here, so a key sent through the page cannot reach the raid keys');
       key('KeyP');
       if(!up()) return skip('a fresh P did not open the pause box for the page arm here');
       // CONTROL: a fresh ESC sent through the page closes the open box, so the page path reaches the box listener.
       press('Escape',false);
       if(up()) return skip('a fresh ESC sent through the page did not close the open pause box here, so the box listener cannot be read');
       key('KeyP');
       if(!up()) return skip('a fresh P did not reopen the pause box here');
       var hb=hold('Escape',4,true);
       // THE FIX, THREE: held ESC repeats reaching the open box leave it open.
       if(hb.flips>0||!hb.open) bad.push('holding ESC with the pause box open, four key repeats sent through the page flipped it '+hb.flips+' times and it came to rest '+(hb.open?'open':'shut'));
       shut();
       if(up()) return skip('the pause box would not shut after the page arm here');
       // TAB keeps its toggle on a fresh press.
       key('Tab'); var ot=up(); key('Tab'); var ct=!up();
       if(!ot) bad.push('a fresh TAB in a raid with nothing open no longer opens the pause box');
       else if(!ct) bad.push('a fresh TAB in a raid no longer closes the pause box it opened');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       clearKeys();
       try{ if(up()) togglePauseBox(false); }catch(_pb){}
       clearKeys();
       try{ if(g&&keep){ g.mapOpen=keep.mapOpen; g.bagOpen=keep.bagOpen; g.emoteBar=keep.emoteBar; g.trade=keep.trade; g.drag=keep.drag; } }catch(_g){}
       try{ if(g&&!g.over) __endRaid('abandon'); }catch(_e){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'15.48',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
