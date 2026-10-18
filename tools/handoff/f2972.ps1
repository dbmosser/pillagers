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

if ($s.Contains("  {v:'29.72',what:")) { throw "check 29.72 is in the fixture already" }

SubRx @'
  {v:'29.71',what:
'@ @'
  {v:'29.72',what:'Settings: the stepper sits within 400px of its name and the card is 17 x 48; the pause title is left-aligned over the button column',
   run:function(){
     if(typeof openSettings!=='function') return 'SKIP: no Settings here';
     var bad=[], l, rows, i, r, k, b, h3, ta, w;
     try{
       openSettings('display'); l=document.getElementById('setlist');
       if(!l) return 'SKIP: no list';
       w=l.getBoundingClientRect().width;
       if(w>830) bad.push('settings list is '+Math.round(w)+'px wide (limit 830)');
       rows=l.querySelectorAll('.row:not(.setjump)');
       for(i=0;i<rows.length;i++){
         r=rows[i]; k=r.firstElementChild; b=r.querySelector(':scope > button');
         if(!k||!b||!b.offsetWidth) continue;
         var d=b.getBoundingClientRect().left-k.getBoundingClientRect().left;
         if(d>440){ bad.push('stepper is '+Math.round(d)+'px from its name (limit 440): '+(k.textContent||'').slice(0,24)); break; }
       }
       h3=document.querySelector('#pausebox h3'); ta=h3?getComputedStyle(h3).textAlign:'';
       if(!h3) bad.push('no pause title');
       else if(ta!=='left'&&ta!=='start') bad.push('pause title is '+ta+', not left-aligned');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ ['settingsmodal'].forEach(function(i){ var q=document.getElementById(i); if(q) q.classList.remove('on'); }); }catch(_k){} try{ __topClear(); }catch(_c){} }
     return bad.length?bad.join('; '):null; }},
  {v:'29.71',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
