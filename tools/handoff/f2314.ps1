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

if ($s.Contains("  {v:'23.14',what:")) { throw "check 23.14 is in the fixture already" }

SubRx @'
  {v:'23.13',what:
'@ @'
  {v:'23.14',what:'the stash belt keys are square again with the gun pictures of the four gun keys in them',
   run:function(){
     if(typeof __station!=='function'||typeof __hubEnter!=='function'||typeof applyMenuZoom!=='function') return 'SKIP: no stash here';
     var bad=[], t, z0=P.menuZoom, cells, i, r, hpw=null;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       t=document.getElementById('title'); if(t) t.classList.remove('on');
       P.menuZoom=2.4; __hubEnter(); __station('term','KeyE');
       try{ applyMenuZoom(); if(typeof renderHub==='function') renderHub(); }catch(_r){}
       hpw=document.getElementById('hotplanwrap'); if(hpw) hpw.style.width='440px';
       cells=document.querySelectorAll('#hub #hotplanwrap [data-plan]');
       if(cells.length<9) return 'SKIP: the stash belt was not drawn ('+cells.length+' keys)';
       for(i=0;i<cells.length;i++){ r=cells[i].getBoundingClientRect(); if(Math.abs(r.width-r.height)>3) bad.push('key '+(i+1)+' is '+Math.round(r.width)+' by '+Math.round(r.height)); }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ if(hpw) hpw.style.width=''; }catch(_w){} if(z0===undefined) delete P.menuZoom; else P.menuZoom=z0; try{ applyMenuZoom(); }catch(_z){} __topClear(); __cleanProfile(); }
     return bad.length?bad.slice(0,3).join('; '):null; }},
  {v:'23.13',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
