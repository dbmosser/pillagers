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

if ($s.Contains("  {v:'21.48',what:")) { throw "check 21.48 is in the fixture already" }

SubRx @'
  {v:'21.47',what:
'@ @'
  {v:'21.48',what:'the REC mark shows the time recorded against the 3 minute limit',
   run:function(){
     if(typeof recStart!=='function'||typeof REC!=='object') return 'SKIP: no recorder here';
     if(typeof MediaRecorder==='undefined'||!HTMLCanvasElement.prototype.captureStream) return 'SKIP: this browser cannot record';
     var bad=[], m, t;
     try{
       if(!recStart()) return 'SKIP: the recording did not start';
       if(REC.mr) REC.mr.onstop=function(){ REC.chunks=[]; };
       REC.t0=Date.now()-65000; recDraw();
       m=document.getElementById('recmark'); t=m?String(m.textContent):'';
       if(!/1:05/.test(t)) bad.push('65 seconds in, the REC mark reads '+JSON.stringify(t));
       if(!/3:00/.test(t)) bad.push('the REC mark does not show the 3 minute limit');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ if(REC.on){ if(REC.mr) REC.mr.onstop=function(){ REC.chunks=[]; }; recStop(); } }catch(_s){} }
     return bad.length?bad.join('; '):null; }},
  {v:'21.47',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
