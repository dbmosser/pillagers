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

if ($s.Contains("  {v:'18.98',what:")) { throw "check 18.98 is in the fixture already" }

SubRx @'
  {v:'18.97',what:
'@ @'
  {v:'18.98',what:'the stash belt keys share one row: with little room all nine tactical belt keys sit on one line and stay square',
   run:function(){
     if(typeof __station!=='function'||typeof __hubEnter!=='function'||typeof applyMenuZoom!=='function') return 'SKIP: no stash here';
     var bad=[], t, z0=P.menuZoom, cells, tops, i, r;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       t=document.getElementById('title'); if(t) t.classList.remove('on');
       P.menuZoom=2.4; __hubEnter(); __station('term','KeyE');
       try{ applyMenuZoom(); if(typeof renderHub==='function') renderHub(); }catch(_r){}
       var hpw=document.getElementById('hotplanwrap'), w0=hpw?hpw.style.width:''; if(hpw) hpw.style.width='440px';
       cells=document.querySelectorAll('#hub #hotplanwrap [data-plan]');
       if(cells.length<9) return 'SKIP: the stash belt was not drawn ('+cells.length+' keys)';
       tops=[]; for(i=0;i<cells.length;i++){ r=cells[i].getBoundingClientRect(); tops.push(Math.round(r.top)); if(Math.abs(r.width-r.height)>3) bad.push('key '+(i+1)+' is '+Math.round(r.width)+' by '+Math.round(r.height)); }
       if(Math.max.apply(null,tops)-Math.min.apply(null,tops)>2) bad.push('the belt keys wrap onto '+(new Set(tops)).size+' lines');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ var hpw2=document.getElementById('hotplanwrap'); if(hpw2) hpw2.style.width=''; }catch(_w){} if(z0===undefined) delete P.menuZoom; else P.menuZoom=z0; try{ applyMenuZoom(); }catch(_z){} __topClear(); __cleanProfile(); }
     return bad.length?bad.slice(0,3).join('; '):null; }},
  {v:'18.97',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
