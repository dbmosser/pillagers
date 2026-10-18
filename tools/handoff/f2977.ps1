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

if ($s.Contains("  {v:'29.77',what:")) { throw "check 29.77 is in the fixture already" }

SubRx @'
  {v:'29.76',what:
'@ @'
  {v:'29.77',what:'Settings: the section strip is one row (the seven tabs share one top)',
   run:function(){
     if(typeof openSettings!=='function') return 'SKIP: no Settings here';
     var bad=[], bs, i, t0, l;
     try{
       openSettings('display'); l=document.getElementById('setlist');
       if(!l) return 'SKIP: no list';
       bs=l.querySelectorAll('.setjump button');
       if(bs.length<6) return 'SKIP: strip too short';
       t0=bs[0].getBoundingClientRect().top;
       for(i=1;i<bs.length;i++){ if(Math.abs(bs[i].getBoundingClientRect().top-t0)>4){ bad.push('tab '+i+' ('+bs[i].textContent+') wraps to a second row'); break; } }
       for(i=0;i<bs.length;i++){ if(bs[i].scrollWidth>bs[i].clientWidth+1){ bad.push('tab '+bs[i].textContent+' is clipped'); break; } }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ var q=document.getElementById('settingsmodal'); if(q) q.classList.remove('on'); }catch(_k){} try{ __topClear(); }catch(_c){} }
     return bad.length?bad.join('; '):null; }},
  {v:'29.76',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
