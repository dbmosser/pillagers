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

if ($s.Contains("  {v:'32.89',what:")) { throw "check 32.89 is in the fixture already" }

SubRx @'
  {v:'32.88',what:
'@ @'
  {v:'32.89',what:'stash setup: all 17 gun key and wheel names fit below their pictures at menu zoom 1 and 1.3, with readable labels and no picture overlap',
   run:function(){
     if(!(window.__P&&window.__applyLoaded&&window.__hubEnter&&window.__menuZoom&&window.__forceSize)) return 'SKIP: no stash layout harness';
     if(window.__vpAlive&&!__vpAlive()) return 'SKIP: no layout';
     var hub=document.getElementById('hub'), snap=null, was=hub.classList.contains('on'), mz0=null, bad=[], sizes=[1,1.3], z,i,tiles,sp,ic,a,b,r;
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       snap=JSON.parse(JSON.stringify(P)); __hubEnter();
       [].forEach.call(document.querySelectorAll('.modal.on'),function(m){m.classList.remove('on');});
       __forceSize(1920,1080);
       if(Math.abs(__menuZoom.titleRes()-1)>0.01) return 'SKIP: pane is not 1920x1080';
       mz0=__menuZoom.get(); delete P.gunKeys; delete P.wheelOrder; P.freeKit=0;
       for(z=0;z<sizes.length;z++){
         __menuZoom.set(sizes[z]); renderHub(); hub.classList.add('on');
         tiles=document.querySelectorAll('#kitsetup .kst');
         if(tiles.length!==17) return 'expected 17 setup tiles, got '+tiles.length;
         for(i=0;i<tiles.length;i++){
           sp=tiles[i].querySelector('span'); ic=tiles[i].querySelector('.ic');
           if(!sp||!ic) return 'a setup tile has no name or picture';
           if(parseFloat(getComputedStyle(sp).fontSize)<16) bad.push('name below 16px');
           if(sp.scrollWidth>sp.clientWidth) bad.push('zoom '+sizes[z]+': clipped '+sp.textContent+' '+sp.scrollWidth+'>'+sp.clientWidth);
           a=ic.getBoundingClientRect(); b=sp.getBoundingClientRect(); r=tiles[i].getBoundingClientRect();
           if(!(a.width>0&&b.width>0&&b.height>0)) bad.push('hidden name or picture');
           if(a.right>b.left+0.5&&a.left<b.right-0.5&&a.bottom>b.top+0.5&&a.top<b.bottom-0.5) bad.push('picture overlaps '+sp.textContent);
           if(b.left<r.left-0.5||b.right>r.right+0.5||b.bottom>r.bottom+0.5) bad.push('name outside tile: '+sp.textContent);
         }
       }
     }catch(e){bad.push('threw: '+(e&&e.message||e));}
     finally{
       try{if(mz0!==null)__menuZoom.set(mz0);}catch(_z){}
       try{if(snap)__applyLoaded(snap);}catch(_r){}
       try{if(was){renderHub();hub.classList.add('on');}else hub.classList.remove('on');}catch(_h){}
       try{cv.style.width='';cv.style.height='';hcv.style.width='';hcv.style.height='';resize();}catch(_f){}
       try{if(__state()&&!__state().over)__endRaid('abandon');}catch(_e){}
       __topClear(); __resetCfg(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null;
   }},
  {v:'32.88',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
