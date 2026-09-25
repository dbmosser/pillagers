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
  {v:'15.56',what:
'@ @'
  {v:'15.57',what:'the end-of-raid card can be left with a controller: on a faked controller that shuts the pause box with B, B on the card after an extraction and A on the card after a death each press Log run and return and go back to the Undercroft, and an A still held from the raid does not press the death card (first run audit finding)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__P&&window.__applyLoaded)) return 'SKIP: this fixture cannot deploy, end a raid and restore the profile';
     if(typeof pollPad!=='function'||typeof padMenu!=='function'||typeof padFocusables!=='function'||typeof togglePauseBox!=='function'||typeof PAD==='undefined') return 'SKIP: no pad poll, pad menu or pause box in this build';
     if(typeof keys==='undefined'||typeof mouse==='undefined'||typeof state==='undefined') return 'SKIP: no keys, mouse or screen state in this build';
     if(typeof G!=='undefined'&&G&&G.sim) return 'SKIP: a sim is running';
     var oc=document.getElementById('outcome'), ob=document.getElementById('oc_btn'), pb=document.getElementById('pausebox');
     if(!oc||!ob||!pb) return 'SKIP: this build has no end-of-raid card, Log run and return button or pause box in the page';
     var NG=navigator.getGamepads;
     if(typeof NG!=='function') return 'SKIP: this browser has no pad interface to fake';
     var bad=[], stubbed=false, snap=null, keepPad=null, why=null;
     try{ navigator.getGamepads=function(){ return []; }; stubbed=(navigator.getGamepads!==NG); }catch(_s){}
     if(!stubbed){ try{ navigator.getGamepads=NG; }catch(_r0){} return 'SKIP: this browser will not let the pad be faked'; }
     function padWith(down){
       var bts=[],i;
       for(i=0;i<17;i++) bts.push({pressed:(i===down),value:(i===down)?1:0,touched:(i===down)});
       var fake={connected:true,id:'probe pad',index:0,mapping:'standard',timestamp:1,axes:[0,0,0,0],buttons:bts};
       navigator.getGamepads=function(){ return [fake]; };
     }
     // keys is replaced by a fresh object when the card is left, so it is looked up by name every time.
     function clearKeys(){ try{ for(var kk in keys) keys[kk]=false; mouse.down=false; }catch(_k){} }
     function cardUp(){ return oc.classList.contains('on'); }
     // Left the way the button leaves: card down, the Undercroft up and the raid let go. The blunt way out takes the card
     // down and nothing else, so it does not count.
     function left(){ return !cardUp()&&state==='hub'&&!__state(); }
     // A raid at seed 4242, the faked controller shown to reach a panel, then the raid ended as how, with A held first if asked.
     function up(how,holdA){
       __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __P().autoExport=false;   // a check must not start a download
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state();
       if(!g||!g.player||g.over) return 'no live raid';
       if(state!=='raid') return 'the page is not in a raid here';
       if(document.querySelectorAll('.modal.on').length) return 'a window is open over the raid here, and it would own the pad';
       clearKeys(); PAD.aSpent=0; PAD.xAfterTrade=0;
       padWith(-1); pollPad(); pollPad();
       if(pb.classList.contains('on')||cardUp()) return 'an idle faked controller opened the pause box or the card here';
       // CONTROL: the faked controller reaches a panel. B on the open pause box resumes the run.
       togglePauseBox(true);
       if(!pb.classList.contains('on')) return 'the pause box would not open in this raid';
       pollPad(); padWith(1); pollPad(); padWith(-1); pollPad();
       if(pb.classList.contains('on')) return 'B on the faked controller did not shut the pause box, so the pad does not reach a panel here';
       if(holdA){
         // A held with its click spent, as after the ascent: recorded by the raid frame, and no shot.
         PAD.aSpent=1; padWith(0); pollPad();
         if(PAD.firing||!PAD.prev[0]) return 'an A held with its click spent fired the gun or was not recorded by the raid here';
       }
       __endRaid(how);
       // CONTROL: the card is up over a raid that is over, and nothing else is open over it.
       if(g.over!==how||!cardUp()) return 'ending the raid as '+how+' did not put the card up here';
       if(state!=='raid'||__state()!==g) return 'the page left the raid as the card came up here, so the pad route cannot be read';
       if(document.querySelectorAll('.modal.on').length||pb.classList.contains('on')) return 'a window or the pause box is open over the card here';
       // CONTROL: Log run and return is drawn where the pad can reach it.
       if(padFocusables(oc).indexOf(ob)<0) return 'Log run and return is not a control the pad can reach on the card here';
       return null;
     }
     // CONTROL, only when the pad did not leave: the button itself leaves the card, so only the pad route is missing.
     function byHand(what){
       ob.click();
       if(!left()) return 'SKIP: even a plain click on Log run and return did not leave the '+what+' card here';
       return null;
     }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       snap=JSON.parse(JSON.stringify(__P()));
       keepPad={aSpent:PAD.aSpent,xAfterTrade:PAD.xAfterTrade,announced:PAD.announced};
       // AFTER AN EXTRACTION: B.
       why=up('extract',false);
       if(why) return 'SKIP: '+why;
       padWith(-1); pollPad();
       if(!cardUp()) return 'SKIP: an idle poll on the faked controller took the extraction card down here';
       padWith(1); pollPad();
       if(!left()){
         bad.push('on a controller B on the card after an extraction did not press Log run and return: the card stayed up and the page stayed in the raid, so a pad player was stuck on it until he picked up the mouse');
         why=byHand('extraction'); if(why) return why;
       }
       padWith(-1);
       // AFTER A DEATH: A, with the A held from the raid first.
       why=up('dead',true);
       if(why) return 'SKIP: '+why;
       pollPad();
       if(!cardUp()) bad.push('an A still held from the raid pressed Log run and return the moment the death card came up, so the card went by unread');
       else {
         padWith(-1); pollPad();
         if(!cardUp()) return 'SKIP: letting go of A took the death card down here';
         padWith(0); pollPad();
         if(!left()){
           bad.push('on a controller A on the card after a death did not press Log run and return: the card stayed up and the page stayed in the raid, so a pad player was stuck on it until he picked up the mouse');
           why=byHand('death'); if(why) return why;
         }
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       clearKeys();
       try{ if(pb.classList.contains('on')) togglePauseBox(false); }catch(_pb){}
       try{ navigator.getGamepads=function(){ return []; }; pollPad(); }catch(_p0){}
       try{ padSetFocus(null); PAD.focus=null; PAD.focusIx=-1; PAD.focusMd=null; padRelease(); }catch(_pr){}
       try{ navigator.getGamepads=NG; }catch(_p){}
       try{ if(keepPad){ PAD.aSpent=keepPad.aSpent; PAD.xAfterTrade=keepPad.xAfterTrade; PAD.announced=keepPad.announced; } }catch(_kp){}
       try{ var gl=__state(); if(gl&&!gl.over) __endRaid('abandon'); }catch(_e){}
       // Back in the Undercroft a first run window may have opened on the return; the next raid would shut it anyway.
       try{ if(snap&&state==='hub'){ var mo=document.querySelectorAll('.modal.on'); for(var mi=0;mi<mo.length;mi++) mo[mi].classList.remove('on'); } }catch(_m){}
       try{ if(snap) __applyLoaded(snap); }catch(_r){}
       clearKeys();
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'15.56',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
