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

if ($s.Contains("  {v:'23.44',what:")) { throw "check 23.44 is in the fixture already" }

SubRx @'
  {v:'23.43',what:
'@ @'
  {v:'23.44',what:'arcade21, his yes 2026-10-11: the operator lock, in an arcade raid ESC and a click on every visible pause button never leave the arcade, the box shows only RESUME and END RUN, the attract has no pause box, and only Ctrl+Shift+F10 leaves the arcade, from the attract and from a raid, while a normal raid ignores the chord',
   run:function(){
     var bad=[], g=null, g2=null, i, bs, vis, b, ids, nm, pb='pause'+'box';
     function el(id){ return document.getElementById(id); }
     function shown(e){ try{ return !!e&&e.style.display!=='none'&&getComputedStyle(e).display!=='none'; }catch(_s){ return false; } }
     function boxOn(){ var x=el(pb); return !!x&&x.classList.contains('on'); }
     function visBtns(){ var r=[], j, all=el(pb).querySelectorAll('button'); for(j=0;j<all.length;j++) if(shown(all[j])) r.push(all[j]); return r; }
     function key(code,o){ o=o||{}; var t=document.body||window;
       t.dispatchEvent(new KeyboardEvent('keydown',{code:code,key:code,ctrlKey:!!o.c,shiftKey:!!o.s,bubbles:true,cancelable:true}));
       t.dispatchEvent(new KeyboardEvent('keyup',{code:code,key:code,ctrlKey:!!o.c,shiftKey:!!o.s,bubbles:true,cancelable:true})); keys={}; }
     try{
       __topClear(); __runPrep();
       if(typeof arcadeDeploy!=='function'||typeof ARCADE!=='object'||typeof arcadeLeave!=='function') return 'no arcadeDeploy in this build';
       if(ARCADE.on) return 'SKIP: the arcade is on after __topClear';
       if(!arcadeDeploy({mapIx:0,seed:4242})) return 'SKIP: arcadeDeploy built no arcade raid';
       g=__state(); keys={}; ARCADE.holdT=0; ARCADE.waveT=0; ARCADE.ownAt=Date.now();
       if(!g||!g.arcade) return 'SKIP: the arcade drop is not an arcade raid';
       key('Escape');
       if(!ARCADE.on) bad.push('ESC in an arcade raid left the arcade');
       if(!boxOn()) togglePauseBox(true);
       if(!boxOn()) bad.push('the arcade pause box does not open');
       vis=visBtns(); ids=vis.map(function(x){ return x.id; }).sort().join(',');
       if(ids!=='arcendbtn,resumebtn') bad.push('the arcade pause box shows '+ids+', not only RESUME and END RUN');
       nm=el('resumebtn')?el('resumebtn').textContent:'';
       if(nm!=='RESUME') bad.push('the arcade resume button reads '+nm);
       for(i=0;i<vis.length;i++){
         b=vis[i]; if(b.id==='arcendbtn') continue;
         if(!__state()) break;
         if(!boxOn()) togglePauseBox(true);
         b.click();
         if(!ARCADE.on) bad.push('a click on '+b.id+' left the arcade');
         key('Escape');
         if(!ARCADE.on) bad.push('ESC after '+b.id+' left the arcade');
       }
       if(__state()&&!boxOn()) togglePauseBox(true);
       if(el('arcendbtn')) el('arcendbtn').click();
       if(!ARCADE.on) bad.push('END RUN left the arcade');
       if(__state()&&__state().arcade) bad.push('END RUN left the arcade raid up');
       togglePauseBox(true);
       if(boxOn()){ bs=visBtns().map(function(x){ return x.id; }).join(','); bad.push('the arcade attract opens a pause box ('+bs+')'); togglePauseBox(false); }
       if(!ARCADE.on) bad.push('the attract pause try left the arcade');
       key('F10');
       if(!ARCADE.on) bad.push('a plain F10 left the arcade');
       if(__state()&&__state().arcade){ try{ arcadeRaidStop('end'); }catch(_rs){} }
       try{ if(ARCADE.over) ARCADE.over=null; }catch(_ov){}
       key('F10',{c:1,s:1});
       if(ARCADE.on) bad.push('Ctrl+Shift+F10 on the attract did not leave the arcade');
       if(!ARCADE.on){
         if(!arcadeDeploy({mapIx:0,seed:4242})) bad.push('no second arcade drop');
         else {
           g=__state(); ARCADE.ownAt=Date.now(); keys={};
           togglePauseBox(true);
           key('F10',{c:1,s:1});
           if(ARCADE.on) bad.push('Ctrl+Shift+F10 in an arcade raid did not leave the arcade');
           if(__state()&&__state().arcade) bad.push('Ctrl+Shift+F10 left the arcade raid up');
           if(boxOn()) bad.push('Ctrl+Shift+F10 left the pause box open');
         }
       }
       try{ if(ARCADE.on) arcadeLeave(); }catch(_l1){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e1){}
       __topClear(); __runPrep();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g2=__state();
       if(!g2) return bad.length?bad.join('; '):'SKIP: __deploy built no raid';
       if(g2.arcade) bad.push('a normal raid is flagged arcade');
       key('F10',{c:1,s:1});
       if(__state()!==g2||g2.over) bad.push('the chord touched a normal raid');
       if(ARCADE.on) bad.push('the chord turned the arcade on');
       togglePauseBox(true);
       if(!shown(el('pausesetbtn'))||!shown(el('abandonbtn'))) bad.push('a normal pause box lost Settings or Abandon run');
       if(el('resumebtn')&&el('resumebtn').textContent==='RESUME') bad.push('a normal pause box reads RESUME');
       togglePauseBox(false);
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       try{ if(typeof pauseOpen!=='undefined'&&pauseOpen) togglePauseBox(false); }catch(_p){}
       keys={};
       try{ if(typeof ARCADE==='object'&&ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       try{ if(typeof ARCADE==='object'){ ARCADE.over=null; ARCADE.mine=0; ARCADE.holdT=0; ARCADE.waveT=0; ARCADE.ownAt=0; ARCADE.mateAt=0; ARCADE.idleSaid=0; } }catch(_m){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'23.43',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
