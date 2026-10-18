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

if ($s.Contains("  {v:'29.64',what:")) { throw "check 29.64 is in the fixture already" }

SubRx @'
  {v:'29.63',what:
'@ @'
  {v:'29.64',what:'Keys hides its idle hint bar and capitalises action names; Settings fades the list bottom',
   run:function(){
     if(typeof openSettings!=='function'||typeof keysOpen!=='function') return 'SKIP: no Settings here';
     var bad=[], cs, l, b, n, mk;
     try{
       KEYS.waiting=null; KEYS.note=null; keysOpen(); try{ keysRender(); }catch(_r){}
       n=document.getElementById('keysnote'); l=document.getElementById('keyslist'); b=l&&l.querySelector('.row b');
       if(!n||!b) return 'SKIP: the Keys window did not build';
       if(getComputedStyle(n).display!=='none') bad.push('the idle Keys hint bar is still shown');
       if(getComputedStyle(b,'::first-letter').textTransform!=='uppercase') bad.push('Keys action names do not start with a capital');
       document.getElementById('keysmodal').classList.remove('on');
       openSettings('display'); l=document.getElementById('setlist');
       if(!l) return 'SKIP: no setlist';
       cs=getComputedStyle(l); mk=cs.webkitMaskImage||cs.maskImage||'';
       if(mk.indexOf('gradient')<0) bad.push('the Settings list has no bottom fade');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ KEYS.waiting=null; ['settingsmodal','keysmodal'].forEach(function(i){ var q=document.getElementById(i); if(q) q.classList.remove('on'); }); }catch(_k){} try{ __topClear(); }catch(_c){} }
     return bad.length?bad.join('; '):null; }},
  {v:'29.63',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
