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

if ($s.Contains("  {v:'24.75',what:")) { throw "check 24.75 is in the fixture already" }

SubRx @'
  {v:'24.74',what:
'@ @'
  {v:'24.75',what:'his #50 (UI redesign ui5q1s, from the visual lint of every screen): a LOST tag on the run card is not the danger red that read at 3.9:1, the attract press line never pulses below 50 percent, and the Keys list is marked as a list that scrolls',
   run:function(){
     var bad=[], m=document.getElementById('oc_manifest'), s, c, src, i, k;
     if(m){ s=document.createElement('span'); s.setAttribute('style','color:var(--rust)'); s.textContent='  LO'+'ST'; m.appendChild(s); c=getComputedStyle(s).color; m.removeChild(s);
       if(c==='rgb(229, 72, 47)') bad.push('a LOST tag on the run card is the danger red ('+c+')'); }
     for(i=0;i<document.styleSheets.length;i++){ try{ var R=document.styleSheets[i].cssRules; for(k=0;k<R.length;k++){ if(R[k].name==='attpulse'){ src=R[k].cssText; } } }catch(_s){} }
     if(src){ var mm=/50%\s*\{\s*opacity:\s*([\d.]+)/.exec(src); if(mm&&parseFloat(mm[1])<0.5) bad.push('the attract press line pulses down to '+mm[1]); }
     if(typeof openKeys==='function'||true){ var kd=[].slice.call(document.scripts).map(function(x){ return x.text||''; }).join(''); if(kd.indexOf('id="keys'+'list" data-lint-scroll')<0) bad.push('the Keys list is not marked as a list that scrolls'); }
     return bad.length?bad.join('; '):null; }},
  {v:'24.74',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
