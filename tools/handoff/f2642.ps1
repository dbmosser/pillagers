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

if ($s.Contains("  {v:'26.42',what:")) { throw "check 26.42 is in the fixture already" }

SubRx @'
  {v:'26.41',what:
'@ @'
  {v:'26.42',what:'gunkeys3, his bar for looks: on the Stash screen every name on the GUN KEYS and WHEEL plates is drawn whole (MARKSMAN is not cut), the nine gun tiles are wider than the eight wheel tiles, and both plates stay inside the loadout column',
   run:function(){
     if(!(window.__P&&window.__applyLoaded&&window.__hubEnter)) return 'SKIP: this fixture cannot reach the Stash screen';
     if(typeof kitSetupRender!=='function') return 'this build has no stash setup';
     if(window.__vpAlive&&!__vpAlive()) return 'SKIP: the pane has no layout, so nothing can be measured';
     if(typeof G!=='undefined'&&G&&(G.sim||!G.over)) return 'SKIP: a raid or a sim is live';
     var hub=document.getElementById('hub'), kc=document.getElementById('kitcol');
     if(!hub||!kc||!document.getElementById('kitsetup')) return 'this page has no stash setup plates';
     var bad=[], snap=null, hubWas=hub.classList.contains('on'), f0=kc.style.flex, w0=kc.style.width, sp, t, i, a, b, r, cr, cut=[];
     try{
       __topClear(); if(window.__resetCfg) __resetCfg(); __cleanProfile();
       snap=JSON.parse(JSON.stringify(P));
       try{ __hubEnter(); }catch(_h){}
       [].forEach.call(document.querySelectorAll('.modal.on'),function(m){ m.classList.remove('on'); });
       delete P.gunKeys; delete P.wheelOrder; P.freeKit=0; renderHub(); hub.classList.add('on');
       t=document.querySelectorAll('#kitsetup .kst');
       if(t.length!==17) return 'SKIP: the plates drew '+t.length+' tiles, not 17';
       for(i=0;i<t.length;i++){ sp=t[i].querySelector('span'); if(sp&&sp.scrollWidth>sp.clientWidth+1) cut.push(String(sp.textContent)); }
       if(cut.length) bad.push('names cut on the plates: '+cut.join(', '));
       a=document.querySelector('#kitsetup [data-gk="0"]'); b=document.querySelector('#kitsetup [data-wh="0"]');
       if(a&&b&&!(a.getBoundingClientRect().width>b.getBoundingClientRect().width+4)) bad.push('a gun key tile ('+Math.round(a.getBoundingClientRect().width)+' px) is not wider than a wheel tile ('+Math.round(b.getBoundingClientRect().width)+' px)');
       cr=kc.getBoundingClientRect();
       for(i=0;i<t.length;i++){ r=t[i].getBoundingClientRect(); if(r.right>cr.right+1||r.left<cr.left-1){ bad.push('a tile sticks out of the loadout column ('+String(t[i].textContent)+')'); break; } }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ kc.style.flex=f0; kc.style.width=w0; }catch(_k){}
       try{ if(snap) __applyLoaded(snap); }catch(_r){}
       try{ if(hubWas){ renderHub(); hub.classList.add('on'); } else hub.classList.remove('on'); }catch(_hb){}
       try{ __topClear(); if(window.__resetCfg) __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'26.41',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
