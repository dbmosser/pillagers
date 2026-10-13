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

if ($s.Contains("  {v:'24.80',what:")) { throw "check 24.80 is in the fixture already" }

SubRx @'
  {v:'24.79',what:
'@ @'
  {v:'24.80',what:'his #50 (UI redesign ui5q1v, from the 4K visual QA of the Keys window): the Keys window, built the first time it opens, takes the same menu zoom as the other windows',
   run:function(){
     if(typeof keysOpen!=='function'||typeof applyMenuZoom!=='function') return 'SKIP: no Keys window here';
     var bad=[], z0=P.menuZoom, old=document.getElementById('keysmodal'), km, sm=document.getElementById('settingsmodal'), zk, zs;
     try{
       if(old&&old.parentNode) old.parentNode.removeChild(old);
       P.menuZoom=1.5; applyMenuZoom();
       keysOpen();
       km=document.getElementById('keysmodal');
       if(!km||!sm) return 'SKIP: the Keys window did not build';
       zk=parseFloat(km.style.zoom)||1; zs=parseFloat(sm.style.zoom)||1;
       if(Math.abs(zk-zs)>0.01) bad.push('the Keys window is drawn at zoom '+zk+' while the other windows are at '+zs);
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ if(z0===undefined) delete P.menuZoom; else P.menuZoom=z0; try{ applyMenuZoom(); }catch(_a){} try{ var k2=document.getElementById('keysmodal'); if(k2) k2.classList.remove('on'); KEYS.waiting=null; }catch(_k){} try{ __topClear(); }catch(_c){} }
     return bad.length?bad.join('; '):null; }},
  {v:'24.79',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
