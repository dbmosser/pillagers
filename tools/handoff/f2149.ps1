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

if ($s.Contains("  {v:'21.49',what:")) { throw "check 21.49 is in the fixture already" }

SubRx @'
  {v:'21.48',what:
'@ @'
  {v:'21.49',what:'F9 on the title records nothing and says where to press it',
   run:function(){
     if(typeof recStart!=='function'||typeof REC!=='object'||typeof attTitleUp!=='function') return 'SKIP: no recorder here';
     var bad=[], t=document.getElementById('title'), was=t&&t.classList.contains('on'), m;
     if(!t) return 'SKIP: no title';
     try{
       t.classList.add('on');
       var r=recStart();
       if(r||REC.on){ bad.push('F9 on the title started a recording of an empty screen'); if(REC.mr) REC.mr.onstop=function(){ REC.chunks=[]; }; recStop(); }
       m=document.getElementById('recmark');
       if(!m||!/raid|Undercroft/.test(m.textContent||'')) bad.push('F9 on the title said nothing about where to press it');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ if(REC.on){ if(REC.mr) REC.mr.onstop=function(){ REC.chunks=[]; }; recStop(); } recMark(false); }catch(_s){} if(!was) t.classList.remove('on'); }
     return bad.length?bad.join('; '):null; }},
  {v:'21.48',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
