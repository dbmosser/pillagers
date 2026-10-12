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

if ($s.Contains("  {v:'23.58',what:")) { throw "check 23.58 is in the fixture already" }

SubRx @'
  {v:'23.57',what:
'@ @'
  {v:'23.58',what:'the title always fits the screen: measured even while hidden, at a large menu zoom, with every mode row in it',
   run:function(){
     if(!__vpAlive()) return 'SKIP: the pane has no layout';
     var ti=document.getElementById('title'), col=ti&&ti.querySelector('.titlecol'), bad=[], z0=P.menuZoom, wasOn, over, z;
     if(!col) return 'SKIP: no title column';
     wasOn=ti.classList.contains('on');
     try{
       ti.classList.remove('on');
       P.menuZoom=2.4; applyMenuZoom();
       ti.classList.add('on');
       z=+getComputedStyle(ti).zoom||1; over=Math.round(col.scrollHeight*z-(window.innerHeight||1080));
       if(over>0) bad.push('at menu zoom 2.4 the title runs '+over+' px past the bottom when it comes up');
       if(typeof titleFit!=='function') bad.push('there is no titleFit to measure the title when it shows');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ if(z0===undefined) delete P.menuZoom; else P.menuZoom=z0; try{ applyMenuZoom(); }catch(_z){} if(!wasOn) ti.classList.remove('on'); }
     return bad.length?bad.join('; '):null; }},
  {v:'23.57',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
