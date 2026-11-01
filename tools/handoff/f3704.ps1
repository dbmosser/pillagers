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

if ($s.Contains("  {v:'37.04',what:")) { throw "check 37.04 is in the fixture already" }

SubRx @'
  {v:'37.03',what:
'@ @'
  {v:'37.04',what:'dead functions with no caller are gone (cw-dead1)',
   run:function(){
     var bad=[];
     if(typeof forgeName!=='undefined') bad.push('forgeName');
     if(typeof forgeChamfer!=='undefined') bad.push('forgeChamfer');
     if(typeof msgVictim!=='undefined') bad.push('msgVictim');
     if(typeof msgQDrop!=='undefined') bad.push('msgQDrop');
     if(typeof cycleHeal!=='undefined') bad.push('cycleHeal');
     if(typeof unkeyedHeals!=='undefined') bad.push('unkeyedHeals');
     if(typeof countHeals!=='undefined') bad.push('countHeals');
     if(typeof gunDef!=='undefined') bad.push('gunDef');
     if(typeof placeName!=='undefined') bad.push('placeName');
     if(typeof netSndLabel!=='undefined') bad.push('netSndLabel');
     if(typeof netSndOtherLabel!=='undefined') bad.push('netSndOtherLabel');
     if(typeof sectorTitle!=='undefined') bad.push('sectorTitle');
     if(bad.length) return 'still defined: '+bad.join(', ');
     return null; }},
  {v:'37.03',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
