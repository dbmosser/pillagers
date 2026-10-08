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

if ($s.Contains("  {v:'19.27',what:")) { throw "check 19.27 is in the fixture already" }

SubRx @'
  {v:'19.26',what:
'@ @'
  {v:'19.27',what:'the bar shows its drinks: each drink row leads with a picture, and Liquor and Blotter have different pictures',
   run:function(){
     if(!window.__station||!window.__hubEnter||typeof renderBar!=='function') return 'SKIP: no bar here';
     var bad=[], t, rows, ims=[], i, im;
     try{
       __topClear(); __runPrep(); __cleanProfile();
       t=document.getElementById('title'); if(t) t.classList.remove('on');
       __hubEnter(); __station('bar','KeyE');
       rows=[].slice.call(document.querySelectorAll('.modal.on .row')).filter(function(r){ return !!r.querySelector('[data-bz]'); });
       if(rows.length<2) return 'SKIP: fewer than two drink rows';
       for(i=0;i<rows.length;i++){ im=rows[i].querySelector('img'); if(!im||String(im.getAttribute('src')||'').indexOf('data:image/png')!==0) bad.push('the '+(rows[i].querySelector('b')?rows[i].querySelector('b').textContent:'drink')+' row has no picture'); else ims.push(im.getAttribute('src')); }
       if(ims.length>=2&&ims[0]===ims[1]) bad.push('the two drinks have the same picture');
       if(ims.length&&rows[0].querySelector('img').getBoundingClientRect().width<30) bad.push('the drink picture is drawn '+Math.round(rows[0].querySelector('img').getBoundingClientRect().width)+' px wide');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'19.26',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
