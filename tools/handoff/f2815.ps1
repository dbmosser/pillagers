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

if ($s.Contains("  {v:'28.15',what:")) { throw "check 28.15 is in the fixture already" }

SubRx @'
  {v:'28.14',what:
'@ @'
  {v:'28.15',what:'cloud-menus-belt-key9-fits: at the default menu size (zoom 1.3, the 2560x1440 layout) the nine tactical belt keys on the stash share one row inside the LOADOUT panel and on screen, and stay square',
   run:function(){
     if(!(window.__P&&window.__applyLoaded&&window.__hubEnter&&window.__menuZoom&&window.__forceSize)) return 'SKIP: this fixture cannot reach the Stash screen at a set menu size';
     if(typeof renderHub!=='function') return 'SKIP: this build has no stash screen';
     if(window.__vpAlive&&!__vpAlive()) return 'SKIP: the pane has no layout, so nothing can be measured';
     if(typeof G!=='undefined'&&G&&(G.sim||!G.over)) return 'SKIP: a raid or a sim is live';
     var hub=document.getElementById('hub');
     if(!hub) return 'SKIP: no stash screen';
     var bad=[], snap=null, hubWas=hub.classList.contains('on'), mz0=null, w, k1, k9, col, r9, r1, c, i, kr;
     try{
       __topClear(); if(window.__resetCfg) __resetCfg(); __cleanProfile();
       snap=JSON.parse(JSON.stringify(P));
       try{ __hubEnter(); }catch(_h){}
       [].forEach.call(document.querySelectorAll('.modal.on'),function(m){ m.classList.remove('on'); });
       __forceSize(1920,1080);
       if(Math.abs(__menuZoom.titleRes()-1)>0.01) return 'SKIP: the pane is not 1920x1080';
       mz0=__menuZoom.get(); __menuZoom.set(1.3);
       P.hotAssign={}; renderHub(); hub.classList.add('on');
       w=document.getElementById('hotplanwrap');
       k1=w&&w.querySelector('[data-plan="0"]'); k9=w&&w.querySelector('[data-plan="8"]'); col=w&&w.closest('.losec')&&w.closest('.losec').parentElement;
       if(!k1||!k9||!col) return 'SKIP: the stash drew no tactical belt keys 1 and 9';
       r9=k9.getBoundingClientRect(); r1=k1.getBoundingClientRect(); c=col.getBoundingClientRect();
       if(r9.right>c.right+1) bad.push('key 9 ends at '+Math.round(r9.right)+', past the LOADOUT panel at '+Math.round(c.right));
       if(r9.right>window.innerWidth+1) bad.push('key 9 runs off the screen ('+Math.round(r9.right)+' of '+window.innerWidth+')');
       if(Math.abs(r9.top-r1.top)>1) bad.push('key 9 is not on the row of key 1');
       for(i=0;i<9;i++){ kr=w.querySelector('[data-plan="'+i+'"]'); if(!kr) continue; kr=kr.getBoundingClientRect(); if(Math.abs(kr.width-kr.height)>1.5){ bad.push('key '+(i+1)+' is not square ('+kr.width.toFixed(1)+' by '+kr.height.toFixed(1)+')'); break; } }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ if(mz0!==null) __menuZoom.set(mz0); }catch(_z){}
       try{ if(snap) __applyLoaded(snap); }catch(_r){}
       try{ if(hubWas){ renderHub(); hub.classList.add('on'); } else hub.classList.remove('on'); }catch(_hb){}
       try{ cv.style.width=''; cv.style.height=''; hcv.style.width=''; hcv.style.height=''; resize(); }catch(_fz){}
       try{ __topClear(); if(window.__resetCfg) __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'28.14',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
