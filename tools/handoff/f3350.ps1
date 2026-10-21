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

if ($s.Contains("  {v:'33.50',what:")) { throw "check 33.50 is in the fixture already" }

SubRx @'
  {v:'33.49',what:
'@ @'
  {v:'33.50',what:'the default camera is exactly 1.0 (pixel exact at 1080p, scale 2 at 4K) and a saved zoom stays his',
   run:function(){
     if(typeof ZDEFAULT==='undefined'||typeof loadZoom!=='function') return 'SKIP: no default camera';
     if(ZDEFAULT!==1) return 'the default camera is '+ZDEFAULT+', not 1';
     var had=Object.prototype.hasOwnProperty.call(P,'zoom'), saved=P.zoom, oldZT=ZT, oldZC=ZC, bad=null;
     try{
       delete P.zoom; loadZoom();
       if(ZT!==1||ZC!==1) bad='a fresh profile boots at '+ZT+'/'+ZC+', not 1';
       P.zoom=1.3; loadZoom();
       if(!bad&&(ZT!==1.3||ZC!==1.3)) bad='a saved zoom of 1.3 loaded as '+ZT;
     } finally { if(had) P.zoom=saved; else delete P.zoom; ZT=oldZT; ZC=oldZC; }
     return bad; }},
  {v:'33.49',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
