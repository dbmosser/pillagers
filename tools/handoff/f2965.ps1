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

if ($s.Contains("  {v:'29.65',what:")) { throw "check 29.65 is in the fixture already" }

SubRx @'
  {v:'29.64',what:
'@ @'
  {v:'29.65',what:'Settings has one tab strip: Send play data is a chip of the section strip, the title tabs show only on the Send play data page',
   run:function(){
     if(typeof openSettings!=='function') return 'SKIP: no Settings here';
     var bad=[], tb, go, rec;
     try{
       openSettings('display'); tb=document.getElementById('settabs'); go=document.querySelector('#setlist .setjump button[data-go]');
       if(!tb) return 'SKIP: no tabs';
       if(getComputedStyle(tb).visibility!=='hidden') bad.push('the title tabs show on the Game page');
       if(!go) bad.push('no Send play data chip in the section strip');
       else {
         go.click(); rec=document.getElementById('spane_rec');
         if(!rec||rec.style.display==='none') bad.push('the chip did not open Send play data');
         if(getComputedStyle(tb).visibility==='hidden') bad.push('no way back on the Send play data page');
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ openSettings('display'); }catch(_o){} try{ ['settingsmodal'].forEach(function(i){ var q=document.getElementById(i); if(q) q.classList.remove('on'); }); }catch(_k){} try{ __topClear(); }catch(_c){} }
     return bad.length?bad.join('; '):null; }},
  {v:'29.64',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
