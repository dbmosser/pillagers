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

if ($s.Contains("  {v:'18.12',what:")) { throw "check 18.12 is in the fixture already" }

SubRx @'
  {v:'18.11',what:
'@ @'
  {v:'18.12',what:'the icon fills its cell: a stash cell icon is sized by the cell (62 percent of it) rather than a fixed 30 or 40 px, the shop cell icon likewise (44 percent), and the icon painter draws a 30 px icon at least 150 px across so the big picture is sharp',
   run:function(){
     if(typeof itemIconURL!=='function') return 'SKIP: no icon painter here';
     var bad=[], hub=document.getElementById('hub'), host=hub||document.body, d, c, img, s, u, b64, bin='', w=0, v, vimg;
     d=document.createElement('div'); d.className='invgrid'; d.style.width='220px';
     c=document.createElement('div'); c.className='cell'; img=document.createElement('img'); img.className='ic'; img.style.width='30px'; img.style.height='30px';
     c.appendChild(img); d.appendChild(c); host.appendChild(d);
     v=document.createElement('div'); v.className='vcell'; v.style.width='190px'; vimg=document.createElement('img'); vimg.className='ic'; vimg.style.width='56px'; vimg.style.height='56px'; v.appendChild(vimg); host.appendChild(v);
     try{
       s=getComputedStyle(img); if(!(s.width==='62%'||parseFloat(s.width)>=110)) bad.push('the stash cell icon is '+s.width+' wide');
       s=getComputedStyle(vimg); if(!(s.width==='44%'||parseFloat(s.width)>=70)) bad.push('the shop cell icon is '+s.width+' wide');
       u=itemIconURL('bandage',30); b64=(String(u).split(',')[1]||'');
       try{ bin=atob(b64); w=((bin.charCodeAt(16)<<24)|(bin.charCodeAt(17)<<16)|(bin.charCodeAt(18)<<8)|bin.charCodeAt(19))>>>0; }catch(e){ bad.push('could not read the icon image'); }
       if(!(w>=150)) bad.push('the 30 px icon is drawn on a '+w+' px canvas');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ host.removeChild(d); }catch(_r){} try{ host.removeChild(v); }catch(_r2){} }
     return bad.length?bad.join('; '):null; }},
  {v:'18.11',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
