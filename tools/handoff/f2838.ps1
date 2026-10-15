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

if ($s.Contains("  {v:'28.38',what:")) { throw "check 28.38 is in the fixture already" }

SubRx @'
  {v:'28.37',what:
'@ @'
  {v:'28.38',what:'cloud-coop-pad-settings-under-bar: walking up Settings with the D-pad from CLOSE never leaves the highlighted control under the sticky jump bar at the top of the list, and highlighting a jump chip does not scroll the list',
   run:function(){
     if(typeof openSettings!=='function'||typeof padOpenModal!=='function'||typeof padFocusables!=='function'||typeof padStep!=='function'||typeof padSetFocus!=='function'||typeof PAD!=='object'||!PAD) return 'SKIP: no Settings window or pad menu here';
     if(typeof G!=='undefined'&&G&&G.sim) return 'SKIP: a sim is running';
     var sm=document.getElementById('settingsmodal'), z0=sm?sm.style.zoom:'', bad=[], md, host, bar, L, cur, i, nx, hid=0, first='', s0, s1, cs, k, f0=PAD.focus, oSnd=(typeof sndUi==='function')?sndUi:null;
     if(!sm) return 'SKIP: no Settings window in this build';
     try{
       if(oSnd) sndUi=function(){};
       __topClear(); __runPrep(); if(typeof __hubEnter==='function') __hubEnter();
       [].forEach.call(document.querySelectorAll('.modal.on'),function(m){ m.classList.remove('on'); });
       openSettings();
       md=padOpenModal(); host=document.getElementById('setlist'); bar=host&&host.querySelector('.setjump');
       if(md!==sm||!host||!bar) return 'SKIP: Settings is not the panel on top, or it has no list with a jump bar here';
       if(getComputedStyle(bar).position!=='sticky') return 'SKIP: the jump bar is not sticky in this build';
       L=padFocusables(md); if(!L||L.length<10) return 'SKIP: too few controls in Settings here';
       [0,0.665].forEach(function(zz){
         if(zz) md.style.zoom=zz;   // the menu scale a 1280x720 window gets (titleRes below 1080p)
         hid=0; first=''; L=padFocusables(md); cur=L[L.length-1]; host.scrollTop=host.scrollHeight; padSetFocus(cur);
         for(i=0;i<300;i++){
           nx=padStep(padFocusables(md),cur,0,-1); if(!nx) break; padSetFocus(nx); cur=nx;
           if(bar.contains(cur)) continue;
           var r=cur.getBoundingClientRect(), br=bar.getBoundingClientRect(), hr=host.getBoundingClientRect();
           if(r.bottom>hr.top+1&&r.top<br.bottom-2){ hid++; if(!first) first=(cur.id||cur.textContent||cur.tagName).trim().slice(0,24)+' covered '+Math.round(Math.min(r.bottom,br.bottom)-r.top)+' of '+Math.round(r.height)+' px'; }
         }
         if(hid) bad.push('at menu zoom '+(zz||'as set')+', walking up from CLOSE, '+hid+' highlighted controls sat under the jump bar (first: '+first+')');
       });
       md.style.zoom=z0;
       cs=[].slice.call(bar.querySelectorAll('button'));
       if(cs.length){
         host.scrollTop=2000; s0=Math.round(host.scrollTop);
         for(k=0;k<3;k++) cs.forEach(function(b){ padSetFocus(b); });
         s1=Math.round(host.scrollTop);
         if(Math.abs(s1-s0)>1) bad.push('highlighting the jump chips moved the list from '+s0+' to '+s1);
       }
       return bad.length?bad.join('; '):null;
     }catch(e){ return 'threw: '+(e&&e.message||e); }
     finally{
       try{ var o=document.querySelector('.padfocus'); if(o) o.classList.remove('padfocus'); }catch(_f){}
       try{ PAD.focus=f0; }catch(_p){}
       try{ if(host) host.scrollTop=0; }catch(_h){}
       try{ sm.style.zoom=z0; }catch(_z){}
       try{ sm.classList.remove('on'); }catch(_m){}
       if(oSnd) sndUi=oSnd;
       try{ __topClear(); }catch(_t){}
     }
   }},
  {v:'28.37',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
