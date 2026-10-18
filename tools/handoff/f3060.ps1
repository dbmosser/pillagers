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

if ($s.Contains("  {v:'30.60',what:")) { throw "check 30.60 is in the fixture already" }

SubRx @'
  {v:'30.59',what:
'@ @'
  {v:'30.60',what:'the title is cleaned: 96px logo, no best-in-fullscreen sentence, no first-time sentence, version in a footer, key legend a fixed bottom strip, Go fullscreen top-right',
   run:function(){
     var t=document.getElementById('title'), wm=t&&t.querySelector('.wordmark'), tr=document.getElementById('titleres'), kb=t&&t.querySelector('.kbrow'), ft=document.getElementById('titlefoot'), was, bad=[];
     if(!t||!wm||!tr||!kb) return 'SKIP: no title here';
     was=t.classList.contains('on'); if(!was) t.classList.add('on');
     var keep={runs:P.runs,welcomed:P.welcomed};
     try{
       if(parseFloat(getComputedStyle(wm).fontSize)<90) bad.push('the logo is '+getComputedStyle(wm).fontSize+', not 96px');
       if(/best in fullscreen/i.test(tr.textContent||'')) bad.push('the best-in-fullscreen sentence is still on the title');
       if(getComputedStyle(tr).position!=='fixed') bad.push('Go fullscreen and Settings are not a fixed top-right row');
       if(getComputedStyle(kb).position!=='fixed') bad.push('the key legend is not a fixed bottom strip');
       if(!ft||!ft.querySelector('#titlever')) bad.push('the version is not in the footer');
       if(ft&&/extraction raid/i.test(ft.textContent||'')) bad.push('the subtitle is still on the title');
       if(typeof titleRefresh==='function'){
         P.runs=0; try{ titleRefresh(); }catch(_t){}
         var sub=document.getElementById('titlesub');
         if(sub&&(sub.textContent||'').trim()) bad.push('the first-time sentence is still on the title: '+sub.textContent);
       }
     } finally { P.runs=keep.runs; P.welcomed=keep.welcomed; try{ titleRefresh(); }catch(_r){} if(!was) t.classList.remove('on'); }
     return bad.length?bad.join('; '):null; }},
  {v:'30.59',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
