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

if ($s.Contains("  {v:'18.79',what:")) { throw "check 18.79 is in the fixture already" }

SubRx @'
  {v:'18.78',what:
'@ @'
  {v:'18.79',what:'an outfit tile shows the outfit: each outfit swatch is a painted preview of the operator in it, two outfits give two different pictures, and the worn outfit and ownership are untouched after',
   run:function(){
     if(typeof cosSwatch!=='function'||typeof OUTFITS==='undefined') return 'SKIP: no outfits here';
     var ids=Object.keys(OUTFITS), bad=[], a, b, k=COSKEY.outfit, w0=P[k], ow0=cosOwned;
     if(ids.length<2) return 'SKIP: fewer than two outfits';
     a=cosSwatch({kind:'outfit',id:ids[0],name:'a'}); b=cosSwatch({kind:'outfit',id:ids[1],name:'b'});
     if(String(a).indexOf('<img')<0||String(a).indexOf('data:image/png')<0) bad.push('an outfit tile is still a plain swatch');
     else if(a===b) bad.push('two outfits show the same picture');
     if(P[k]!==w0) bad.push('drawing the previews changed the worn outfit');
     if(cosOwned!==ow0) bad.push('drawing the previews left the ownership test replaced');
     return bad.length?bad.join('; '):null; }},
  {v:'18.78',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
