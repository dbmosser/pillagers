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
  {v:'15.49',what:
'@ @'
  {v:'15.50',what:'the controller Menu button pauses at the Peddler stall: on a faked controller a fresh Menu in a raid with the stall shut opens the pause box and keyboard P at the open stall opens it, and a fresh Menu at the open stall now opens it too, with the stall still open behind it and the same Menu still held on the next poll leaving it open (pause audit finding 10)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     if(typeof pollPad!=='function'||typeof togglePauseBox!=='function'||typeof raidKey!=='function'||typeof mkPeddler!=='function'||typeof PAD==='undefined') return 'SKIP: no pad poll, pause box, raid keys or Peddler in this build';
     if(typeof keys==='undefined'||typeof mouse==='undefined') return 'SKIP: no keys or mouse in this build';
     if(typeof G!=='undefined'&&G&&G.sim) return 'SKIP: a sim is running';
     var pb=document.getElementById('pausebox');
     if(!pb) return 'SKIP: this build has no pause box in the page';
     var NG=navigator.getGamepads;
     if(typeof NG!=='function') return 'SKIP: this browser has no pad interface to fake';
     var bad=[], stubbed=false, g=null, keep=null, keepPad=null;
     try{ navigator.getGamepads=function(){ return []; }; stubbed=(navigator.getGamepads!==NG); }catch(_s){}
     if(!stubbed){ try{ navigator.getGamepads=NG; }catch(_r0){} return 'SKIP: this browser will not let the pad be faked'; }
     function padWith(down){
       var bts=[],i;
       for(i=0;i<17;i++) bts.push({pressed:(i===down),value:(i===down)?1:0,touched:(i===down)});
       var fake={connected:true,id:'probe pad',index:0,mapping:'standard',timestamp:1,axes:[0,0,0,0],buttons:bts};
       navigator.getGamepads=function(){ return [fake]; };
     }
     // keys is replaced by a fresh object each time the box opens, so it is looked up by name every time.
     function clearKeys(){ try{ for(var kk in keys) keys[kk]=false; mouse.down=false; }catch(_k){} }
     function up(){ return pb.classList.contains('on'); }
     function shut(){ clearKeys(); if(up()) togglePauseBox(false); clearKeys(); }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: no live raid';
       if(typeof state==='undefined'||state!=='raid') return 'SKIP: the page is not in a raid here, so the pad cannot reach the raid branch';
       keep={mapOpen:g.mapOpen,bagOpen:g.bagOpen,emoteBar:g.emoteBar,trade:g.trade,pedLock:g.pedLock,pedSel:g.pedSel,drag:g.drag};
       keepPad={aSpent:PAD.aSpent,xAfterTrade:PAD.xAfterTrade,announced:PAD.announced};
       g.mapOpen=false; g.bagOpen=false; g.emoteBar=false; g.trade=null; g.drag=null; PAD.aSpent=0; PAD.xAfterTrade=0;
       // The raid's own Peddler, else one made beside him. The pad branch reads only his stock, and G.ents is not touched.
       var pd=null;
       for(var i=0;i<g.ents.length;i++) if(g.ents[i]&&g.ents[i].kind==='peddler'){ pd=g.ents[i]; break; }
       if(!pd) pd=mkPeddler(g.player.x+40,g.player.y,g.map);
       shut();
       if(up()) return 'SKIP: the pause box would not shut here';
       padWith(-1); pollPad(); pollPad();
       if(up()) return 'SKIP: an idle faked controller opened the pause box here';
       // CONTROL: with the stall shut, a fresh Menu opens the box through the raid tap loop, so the faked Menu reaches the game.
       padWith(9); pollPad();
       if(!up()) return 'SKIP: a fresh Menu on the faked controller with the stall shut did not open the pause box here, so the press cannot be read';
       shut(); padWith(-1); pollPad();
       if(up()) return 'SKIP: the pause box would not stay shut after the first Menu here';
       // The stall opens, and an idle poll leaves it open and the box shut.
       g.trade=pd; g.pedLock=0; g.pedSel=0;
       pollPad();
       if(g.trade!==pd||up()) return 'SKIP: an idle poll with the stall open shut the stall or opened the pause box here';
       // CONTROL: keyboard P at the open stall opens the box and leaves the stall open, so a pause at the stall is offered.
       clearKeys(); raidKey('KeyP',false,null); clearKeys();
       if(!up()) return 'SKIP: keyboard P at the open stall did not open the pause box here, so a pause at the stall is not offered';
       if(g.trade!==pd) return 'SKIP: keyboard P at the open stall shut the stall here';
       shut(); padWith(-1); pollPad();
       if(up()||g.trade!==pd) return 'SKIP: the box did not stay shut with the stall open after the keyboard P here';
       // THE FIX: a fresh Menu at the open stall opens the box over it.
       padWith(9); pollPad();
       if(!up()) bad.push('with the Peddler stall open on a controller, a fresh Menu left the pause box shut, so the raid ran on behind the stall with no pause, while keyboard P at the same stall opens it');
       else {
         if(g.trade!==pd) bad.push('a fresh Menu at the open stall opened the pause box but shut the stall behind it, which keyboard P does not');
         // The same Menu still held on the next poll is not a second press.
         pollPad();
         if(!up()) bad.push('Menu at the open stall opened the pause box and the next poll with the same Menu still held shut it again');
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       clearKeys();
       try{ if(up()) togglePauseBox(false); }catch(_pb){}
       try{ navigator.getGamepads=function(){ return []; }; pollPad(); }catch(_p0){}
       try{ padSetFocus(null); PAD.focus=null; PAD.focusIx=-1; PAD.focusMd=null; padRelease(); }catch(_pr){}
       try{ navigator.getGamepads=NG; }catch(_p){}
       try{ if(keepPad){ PAD.aSpent=keepPad.aSpent; PAD.xAfterTrade=keepPad.xAfterTrade; PAD.announced=keepPad.announced; } }catch(_kp){}
       clearKeys();
       try{ if(g&&keep){ g.mapOpen=keep.mapOpen; g.bagOpen=keep.bagOpen; g.emoteBar=keep.emoteBar; g.trade=keep.trade; g.pedLock=keep.pedLock; g.pedSel=keep.pedSel; g.drag=keep.drag; } }catch(_g){}
       try{ if(g&&!g.over) __endRaid('abandon'); }catch(_e){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'15.49',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
