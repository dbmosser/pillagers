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

if ($s.Contains("  {v:'17.19',what:")) { throw "check 17.19 is in the fixture already" }

SubRx @'
  {v:'17.18',what:
'@ @'
  {v:'17.19',what:'in a raid, ESC or TAB on the Settings window opened from the pause box shuts only Settings: the box stays up behind it and the raid stays paused, P over Settings leaves the box up, in the player 2 window the same ESC shuts Settings and is not handed to player 1, and with nothing over it a fresh ESC still shuts the box',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     if(typeof togglePauseBox!=='function'||typeof raidKey!=='function'||typeof openSettings!=='function'||typeof escCloseTopModal!=='function') return 'SKIP: no pause box, raid keys or Settings window in this build';
     if(typeof keys==='undefined'||typeof mouse==='undefined'||typeof KeyboardEvent==='undefined') return 'SKIP: no keys, mouse or keyboard events in this build';
     if(typeof G!=='undefined'&&G&&G.sim) return 'SKIP: a sim is running';
     var pb=document.getElementById('pausebox'), sm=document.getElementById('settingsmodal'), sb=document.getElementById('pausesetbtn');
     if(!pb||!sm||!sb||!document.body) return 'SKIP: this build has no pause box, Settings window or Settings button on the box';
     var bad=[], g=null, k0=keys, md0=mouse.down, codes=['Escape','Tab'], i, c, w, sent=[];
     var hasNet=(typeof NET==='object'&&NET&&typeof netSamePost==='function'&&typeof netKeyFwd==='function');
     var keepNet=hasNet?{same:NET.same,pair:NET.pair}:null, oPost=hasNet?netSamePost:null;
     var kh0=(typeof netKeyHeld==='object'&&netKeyHeld)?JSON.parse(JSON.stringify(netKeyHeld)):null;
     // A later control that cannot run keeps a failure already found, so the old build fails rather than skips.
     var skip=function(m){ return bad.length?(bad.join('; ')+' (then SKIP: '+m+')'):('SKIP: '+m); };
     function clearKeys(){ try{ for(var kk in keys) keys[kk]=false; mouse.down=false; }catch(_k){} }
     function on(el){ return !!(el&&el.classList.contains('on')); }
     // A real key lands on the body, so the box listener on window runs first in the capture phase, then the window listener.
     function press(code){ clearKeys(); document.body.dispatchEvent(new KeyboardEvent('keydown',{code:code,key:code,bubbles:true,cancelable:true})); clearKeys(); }
     function shut(){ clearKeys(); sm.classList.remove('on'); if(on(pb)) togglePauseBox(false); clearKeys(); }
     // The pause box, then the Settings button on it, the way he reaches Settings in a raid.
     function stage(){
       shut(); togglePauseBox(true);
       if(!on(pb)) return 'the pause box did not open in the raid';
       sb.click();
       if(!on(sm)||!on(pb)) return 'the Settings button on the pause box did not put Settings over the open box';
       if(!g.paused) return 'the raid was not paused under the pause box and Settings';
       return null;
     }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: no live raid';
       if(typeof state==='undefined'||state!=='raid') return 'SKIP: the page is not in a raid here';
       g.mapOpen=false; g.bagOpen=false; g.emoteBar=false; g.trade=null; g.drag=null;
       // No window left over from an earlier check sits over the raid, so the only window in play is the Settings opened here.
       [].forEach.call(document.querySelectorAll('.modal.on'),function(m){ m.classList.remove('on'); });
       // CONTROL: with nothing over it, a fresh ESC sent through the page shuts the open box, on either build.
       shut(); togglePauseBox(true);
       if(!on(pb)) return 'SKIP: the pause box did not open here';
       press('Escape');
       if(on(pb)) return 'SKIP: a fresh ESC sent through the page did not shut the open pause box here, so the key path cannot be read';
       // THE FINDING: ESC and TAB on Settings over the pause box.
       for(i=0;i<codes.length;i++){
         c=codes[i];
         w=stage(); if(w) return skip(w);
         press(c);
         if(on(sm)) bad.push(c+' on Settings over the pause box left Settings up'+(on(pb)?'':' and shut the pause box behind it, so the raid ran on under Settings'));
         else if(!on(pb)) bad.push(c+' on Settings shut the pause box as well as Settings');
         if(!g.paused) bad.push(c+' on Settings over the pause box unpaused the raid');
       }
       // P over Settings leaves the box as it was.
       w=stage(); if(w) return skip(w);
       clearKeys(); raidKey('KeyP',false,null); clearKeys();
       if(!on(pb)) bad.push('P with Settings over the pause box shut the box behind Settings and unpaused the raid');
       // In the player 2 window the same ESC shuts Settings there and is not handed to player 1.
       if(hasNet){
         w=stage(); if(w) return skip(w);
         netSamePost=function(m){ sent.push(m); return true; };
         NET.same='p2'; NET.pair='zqxsetesc'; sent.length=0;
         press('Escape');
         NET.same=keepNet.same; NET.pair=keepNet.pair; netSamePost=oPost;
         var hd=sent.filter(function(m){ return m&&m.t==='key'&&m.ty==='keydown'&&m.code==='Escape'; }).length;
         if(on(sm)||!on(pb)) bad.push('in the player 2 window ESC on Settings over the pause box left Settings '+(on(sm)?'up':'shut')+' and the box '+(on(pb)?'up':'shut'));
         if(hd) bad.push('in the player 2 window ESC on Settings was handed to player 1');
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       if(hasNet){ try{ netSamePost=oPost; NET.same=keepNet.same; NET.pair=keepNet.pair; if(kh0) netKeyHeld=kh0; }catch(_n){} }
       try{ sm.classList.remove('on'); }catch(_s){}
       try{ if(on(pb)) togglePauseBox(false); }catch(_p){}
       try{ var gl=__state(); if(gl&&!gl.over) __endRaid('abandon'); }catch(_e){}
       keys=k0||{}; mouse.down=md0;
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'17.18',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
