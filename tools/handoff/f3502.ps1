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

if ($s.Contains("  {v:'35.02',what:")) { throw "check 35.02 is in the fixture already" }

SubRx @'
  {v:'35.01',what:
'@ @'
  {v:'35.02',what:'cw-fsgate, his order (2026-10-27): play fullscreen or hold 5 s to play windowed; a pause screen at the start and every time fullscreen is left that says esc leaves fullscreen so pause with tab and f11 works any time on chrome; go fullscreen on the pause menu and on the raid screen when windowed. The gate pauses the raid and keeps esc, p and tab from the game, going fullscreen closes it onto the pause menu, the windowed hold writes nothing to storage, the raid button shows only in a windowed live raid, and a test page never sees the gate unless forced',
   run:function(){
     if(typeof fsGateShow!=='function'||typeof FSG!=='object'||!document.getElementById('pausefsbtn')) return 'no fullscreen gate here (fsGateShow, FSG or the pause menu go fullscreen button is missing)';
     var bad=[], ff0=fsFull, fsg0={ok:FSG.ok,force:FSG.force,why:FSG.why,was:FSG.was};
     function vis(id){ var e=document.getElementById(id); return !!(e&&e.style.display!=='none'&&getComputedStyle(e).display!=='none'); }
     function key(c,k){ window.dispatchEvent(new KeyboardEvent('keydown',{code:c,key:k,bubbles:true,cancelable:true})); }
     function snap(){ var o=[]; for(var i=0;i<localStorage.length;i++){ var k=localStorage.key(i); o.push(k+'='+localStorage.getItem(k)); } return o.sort().join('\n'); }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       fsFull=function(){ return false; }; FSG.force=0; FSG.ok=0;
       if(fsGateWant()) bad.push('a test page would get the gate without FSG.force');
       FSG.force=1;
       fsGateShow('start');
       var tx=((document.getElementById('fsgate')||{}).textContent||'');
       if(!vis('fsgate')) bad.push('the start gate did not show');
       ['play fullscreen','go fullscreen','f11 any time on chrome','esc leaves fullscreen','tab','hold 5s to play windowed','may cause glitches'].forEach(function(w){ if(tx.indexOf(w)<0) bad.push('the start gate does not say '+w); });
       if(tx!==tx.toLowerCase()) bad.push('the start gate has capitals');
       var s0=snap(); fsGateWindowed(); var s1=snap();
       if(s1!==s0) bad.push('the windowed choice wrote to storage (it must ask again after every exit)');
       if(FSG.open||vis('fsgate')||!FSG.ok) bad.push('the 5 s hold did not close the start gate for windowed play');
       FSG.ok=0;
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       if(state!=='raid'||!G||G.over) throw new Error('no live raid to test on');
       G.mapFirst=0; G.mapOpen=false; if(pauseOpen) togglePauseBox(false); syncPause();
       if(G.paused) bad.push('the raid was paused before the gate (test setup)');
       FSG.was=0;
       fsGateShow('lost');
       if(!vis('fsgate')||!FSG.open) bad.push('the lost gate did not show');
       if(((document.getElementById('fsgtitle')||{}).textContent||'')!=='fullscreen lost') bad.push('the lost gate does not say fullscreen lost');
       if(!G.paused) bad.push('the raid kept running under the gate');
       G.paused=false; fsRaidBtnSync();
       if(!G.paused) bad.push('a fresh raid state under the gate was not paused on the next frame');
       key('Escape','Escape'); key('KeyP','p'); key('Tab','Tab');
       if(pauseOpen) bad.push('esc, p or tab reached the game through the gate (the pause box opened)');
       if(vis('raidfsbtn')) bad.push('the raid go fullscreen button showed over the gate');
       fsFull=function(){ return true; }; fsSync();
       if(FSG.open||vis('fsgate')) bad.push('going fullscreen did not close the gate');
       if(!pauseOpen) bad.push('the gate closed straight into the fight instead of onto the pause menu');
       if(!G.paused) bad.push('the raid ran while the pause menu was up after the gate');
       if(vis('pausefsbtn')) bad.push('the pause menu go fullscreen button showed in fullscreen');
       document.getElementById('resumebtn').onclick();
       if(pauseOpen||G.paused) bad.push('resume did not restart the raid after the gate');
       fsFull=function(){ return false; }; fsSync();
       if(!FSG.open) bad.push('leaving fullscreen did not bring the gate back');
       fsGateWindowed();
       if(FSG.open||vis('fsgate')) bad.push('the 5 s hold did not close the lost gate');
       if(!pauseOpen) bad.push('the hold closed the lost gate straight into the fight');
       if(!vis('pausefsbtn')) bad.push('the pause menu has no go fullscreen button while windowed');
       document.getElementById('resumebtn').onclick();
       fsRaidBtnSync();
       if(FSG.open) bad.push('the gate came back after the windowed choice without a fullscreen exit');
       if(!vis('raidfsbtn')) bad.push('no go fullscreen button on the raid screen while windowed');
       fsFull=function(){ return true; }; fsRaidBtnSync();
       if(vis('raidfsbtn')) bad.push('the raid go fullscreen button stayed up in fullscreen');
       if(FSG.ok) bad.push('going fullscreen did not clear the windowed choice');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ fsFull=ff0; }catch(_r){}
       try{ FSG.why='start'; fsGateHide(); }catch(_h){}
       try{ for(var q in fsg0) FSG[q]=fsg0[q]; }catch(_q){}
       try{ var rb=document.getElementById('raidfsbtn'); if(rb) rb.style.display='none'; }catch(_b){}
       try{ if(pauseOpen) togglePauseBox(false); }catch(_p){}
       try{ var K2=__keys(); for(var q2 in K2) delete K2[q2]; }catch(_k){}
       try{ if(state==='raid'&&G&&!G.over) __endRaid('abandon'); }catch(_e){}
       try{ __topClear(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'35.01',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
