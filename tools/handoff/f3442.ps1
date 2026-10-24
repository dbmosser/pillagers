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

if ($s.Contains("  {v:'34.42',what:")) { throw "check 34.42 is in the fixture already" }

SubRx @'
  {v:'34.41',what:
'@ @'
  {v:'34.42',what:'the press any key pulse never dips below .85 (critic on 52 and 55: the prompt reads dim)',
   run:function(){
     if(typeof attEl!=='function') return 'SKIP: no attEl';
     attEl();
     var low=null, seen=0;
     for(var i=0;i<document.styleSheets.length;i++){ var rs; try{ rs=document.styleSheets[i].cssRules; }catch(e){ continue; }
       for(var j=0;j<rs.length;j++){ var r=rs[j]; if(r.name==='attpulse'){ seen=1; for(var k=0;k<r.cssRules.length;k++){ var o=parseFloat(r.cssRules[k].style.opacity); if(o<.85) low=o; } } } }
     if(!seen) return 'no attpulse keyframes found';
     if(low!==null) return 'the pulse dips to '+low;
     return null; }},
  {v:'34.41',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
