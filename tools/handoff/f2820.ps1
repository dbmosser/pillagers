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

if ($s.Contains("  {v:'28.20',what:")) { throw "check 28.20 is in the fixture already" }

SubRx @'
  {v:'28.19',what:
'@ @'
  {v:'28.20',what:'cloud-menus-kit-tile-names-fit: at the default menu size (zoom 1.3, the 2560x1440 layout) every GUN KEYS and ITEM WHEEL tile name on the stash shows whole, and no picture overlaps its name',
   run:function(){
     if(!(window.__P&&window.__applyLoaded&&window.__hubEnter&&window.__menuZoom&&window.__forceSize)) return 'SKIP: this fixture cannot reach the Stash screen at a set menu size';
     if(typeof kitSetupRender!=='function'||typeof renderHub!=='function') return 'SKIP: this build has no stash setup';
     if(window.__vpAlive&&!__vpAlive()) return 'SKIP: the pane has no layout, so nothing can be measured';
     if(typeof G!=='undefined'&&G&&(G.sim||!G.over)) return 'SKIP: a raid or a sim is live';
     var hub=document.getElementById('hub');
     if(!hub||!document.getElementById('kitsetup')) return 'SKIP: this page has no stash setup plates';
     var bad=[], snap=null, hubWas=hub.classList.contains('on'), mz0=null, t, i, sp, ic, a, b, cut=[], ov=[];
     try{
       __topClear(); if(window.__resetCfg) __resetCfg(); __cleanProfile();
       snap=JSON.parse(JSON.stringify(P));
       try{ __hubEnter(); }catch(_h){}
       [].forEach.call(document.querySelectorAll('.modal.on'),function(m){ m.classList.remove('on'); });
       __forceSize(1920,1080);
       if(Math.abs(__menuZoom.titleRes()-1)>0.01) return 'SKIP: the pane is not 1920x1080';
       mz0=__menuZoom.get(); __menuZoom.set(1.3);
       delete P.gunKeys; delete P.wheelOrder; P.freeKit=0; renderHub(); hub.classList.add('on');
       t=document.querySelectorAll('#kitsetup .kst');
       if(t.length!==17) return 'SKIP: the plates drew '+t.length+' tiles, not 17';
       for(i=0;i<t.length;i++){
         sp=t[i].querySelector('span'); if(!sp) continue;
         if(sp.scrollWidth>sp.clientWidth) cut.push(String(sp.textContent)+' '+sp.scrollWidth+'>'+sp.clientWidth);
         ic=t[i].querySelector('.ic'); if(ic){ a=ic.getBoundingClientRect(); b=sp.getBoundingClientRect(); if(a.right>b.left+0.5) ov.push(String(sp.textContent)); }
       }
       if(cut.length) bad.push('names cut on the plates at the default menu size: '+cut.join(', '));
       if(ov.length) bad.push('the picture overlaps the name on: '+ov.join(', '));
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ if(mz0!==null) __menuZoom.set(mz0); }catch(_z){}
       try{ if(snap) __applyLoaded(snap); }catch(_r){}
       try{ if(hubWas){ renderHub(); hub.classList.add('on'); } else hub.classList.remove('on'); }catch(_hb){}
       try{ cv.style.width=''; cv.style.height=''; hcv.style.width=''; hcv.style.height=''; resize(); }catch(_fz){}
       try{ __topClear(); if(window.__resetCfg) __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'28.19',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
