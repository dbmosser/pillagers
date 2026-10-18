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

if ($s.Contains("  {v:'29.67',what:")) { throw "check 29.67 is in the fixture already" }

SubRx @'
  {v:'29.66',what:
'@ @'
  {v:'29.67',what:'Settings is a 960 card: the detail text is a strip under the list, steppers are plain until pointed at, the header X is drawn strokes',
   run:function(){
     if(typeof openSettings!=='function') return 'SKIP: no Settings here';
     var bad=[], l, d, b, cx, cb;
     try{
       openSettings('display'); l=document.getElementById('setlist'); d=document.getElementById('setdetail');
       if(!l||!d) return 'SKIP: no list';
       try{ window.__setDetailSync(); }catch(_sy){}
       if(!d.textContent) bad.push('detail strip is empty');
       else if(d.getBoundingClientRect().top < l.getBoundingClientRect().bottom-2) bad.push('detail pane is beside the list, not under it');
       b=l.querySelector('.row > button');
       if(b){ var c=getComputedStyle(b).borderTopColor; if(!/rgba\(0, 0, 0, 0\)|transparent/.test(c)) bad.push('stepper box shows on every row: '+c); }
       cb=document.getElementById('closesettings'); cx=cb?getComputedStyle(cb,'::after').content:'';
       if(cx!=='""') bad.push('header X is a text glyph: '+cx);
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ ['settingsmodal'].forEach(function(i){ var q=document.getElementById(i); if(q) q.classList.remove('on'); }); }catch(_k){} try{ __topClear(); }catch(_c){} }
     return bad.length?bad.join('; '):null; }},
  {v:'29.66',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
