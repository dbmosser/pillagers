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

if ($s.Contains("  {v:'21.29',what:")) { throw "check 21.29 is in the fixture already" }

SubRx @'
  {v:'21.28',what:
'@ @'
  {v:'21.29',what:'the FASHION racks keep their status words level: a rack tile whose name breaks over two lines puts its OWNED or WORN line level with the tiles beside it, not a line lower',
   run:function(){
     if(!window.__hubEnter||!window.__station) return 'SKIP: this fixture cannot open FASHION';
     if(typeof COSMETICS==='undefined'||typeof renderCosmetics!=='function') return 'SKIP: no racks in this build';
     var bad=[], md, pk, t, c=null, n0=null, i, tiles, me=null, row=[], r0, q, hh, h1=0, h2=0, b, lo=1e9, hi=-1e9;
     function shut(){ var a=document.querySelectorAll('.modal.on'), k; for(k=0;k<a.length;k++) a[k].classList.remove('on'); }
     try{
       __topClear(); __runPrep(); __cleanProfile();
       t=document.getElementById('title'); if(t) t.classList.remove('on');
       __hubEnter(); __station('mirror','KeyE');
       md=document.getElementById('appearmodal'); pk=document.getElementById('appavatarpicker');
       if(!md||!pk||!md.classList.contains('on')) return 'SKIP: FASHION did not open';
       for(i=0;i<COSMETICS.length;i++) if(COSMETICS[i]&&COSMETICS[i].kind==='outfit'&&COSMETICS[i].id!=='outnone'){ c=COSMETICS[i]; break; }
       if(!c) return 'SKIP: no outfit on the racks';
       // a name that must break over two lines in a rack tile, whatever the font
       n0=c.name; c.name='Qz Wwwww Mmmmm Qz';
       renderCosmetics(pk,null,'appavatar','appavatarpicker');
       me=pk.querySelector('.costile[data-id="'+c.id+'"]');
       if(!me) return 'SKIP: the staged outfit tile is not on the racks';
       r0=me.getBoundingClientRect();
       if(!(r0.width>0&&r0.height>0)) return 'SKIP: the racks have no size here';
       tiles=pk.querySelectorAll('.costile[data-kind="outfit"]');
       for(i=0;i<tiles.length;i++){ q=tiles[i].getBoundingClientRect(); if(Math.abs(q.top-r0.top)<2) row.push(tiles[i]); }
       if(row.length<2) return 'SKIP: the staged tile has no neighbour on its row';
       q=me.querySelector('.cosname'); h2=q?q.getBoundingClientRect().height:0;
       for(i=0;i<row.length;i++) if(row[i]!==me){ q=row[i].querySelector('.cosname'); if(q){ hh=q.getBoundingClientRect().height; if(hh>0&&(!h1||hh<h1)) h1=hh; } }
       if(!(h1>0&&h2>h1*1.5)) return 'SKIP: the long staged name did not break over two lines here';
       for(i=0;i<row.length;i++){ b=row[i].querySelector('.cosreq'); if(!b) continue; q=b.getBoundingClientRect(); if(!(q.height>0)) continue; lo=Math.min(lo,q.bottom); hi=Math.max(hi,q.bottom); }
       if(!(hi>lo-1)) return 'SKIP: no status lines measured on the row';
       if(hi-lo>2) bad.push('on the OUTFIT rack the status line under a two line name sits '+Math.round(hi-lo)+' px lower than under the one line names beside it');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ if(c&&n0!==null) c.name=n0; }catch(_n){}
       try{ if(pk&&c&&n0!==null) renderCosmetics(pk,null,'appavatar','appavatarpicker'); }catch(_r){}
       shut(); __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'21.28',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
