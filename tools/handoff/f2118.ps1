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

if ($s.Contains("  {v:'21.18',what:")) { throw "check 21.18 is in the fixture already" }

SubRx @'
  {v:'21.17',what:
'@ @'
  {v:'21.18',what:'F9 records the game: the first press starts a recording of the world and the HUD with a REC mark on the page, the second stops it',
   run:function(){
     if(typeof recStart!=='function'||typeof REC!=='object') return 'control: there is no recorder in this build';
     if(typeof MediaRecorder==='undefined'||!HTMLCanvasElement.prototype.captureStream) return 'SKIP: this browser cannot record';
     var bad=[], m;
     try{
       window.dispatchEvent(new KeyboardEvent('keydown',{code:'F9',key:'F9',bubbles:true}));
       if(!REC.on) bad.push('F9 did not start a recording');
       else{
         m=document.getElementById('recmark');
         if(!m||m.style.display!=='block') bad.push('no REC mark while recording');
         if(!REC.cv||!(REC.cv.width>=320)) bad.push('the recording canvas was not made');
         if(REC.mr) REC.mr.onstop=function(){ REC.chunks=[]; };   // the test keeps nothing and downloads nothing
       }
       window.dispatchEvent(new KeyboardEvent('keydown',{code:'F9',key:'F9',bubbles:true}));
       if(REC.on) bad.push('F9 again did not stop the recording');
       m=document.getElementById('recmark');
       if(m&&m.style.display!=='none') bad.push('the REC mark stayed after the recording stopped');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ if(REC.on){ if(REC.mr) REC.mr.onstop=function(){ REC.chunks=[]; }; recStop(); } }catch(_s){} }
     return bad.length?bad.join('; '):null; }},
  {v:'21.17',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
