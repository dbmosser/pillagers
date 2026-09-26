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

if ($s.Contains("  {v:'16.18',what:")) { throw "check 16.18 is in the fixture already" }

SubRx @'
  {v:'16.17',what:
'@ @'
  {v:'16.18',what:'his words: knocked down while extracting says Extraction attempt reset',
   run:function(){
     var src='', i;
     try{ var ss=document.getElementsByTagName('script'); for(i=0;i<ss.length;i++) src+=ss[i].textContent||''; }catch(e){ return 'SKIP: the build cannot read its own script'; }
     var cut=src.indexOf('window.__frame=function'); if(cut>0) src=src.slice(0,cut);
     if(src.length<100000) return 'SKIP: the build cannot read its own script';
     if(src.indexOf('Knocked down. Extraction attempt reset. Hold E to try again.')<0) return 'the knocked down line does not say Extraction attempt reset';
     return null; }},
  {v:'16.17',what:
'@


SubRx @'
     if(src.indexOf('Knocked down. Extraction reset. Hold E to try again.')<0) return 'the knocked down line does not say Extraction reset. Hold E to try again.';
'@ @'
     if(src.indexOf('Knocked down. Extraction attempt reset. Hold E to try again.')<0) return 'the knocked down line does not say Extraction attempt reset. Hold E to try again.';
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
