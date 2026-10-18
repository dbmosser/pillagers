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

if ($s.Contains("  {v:'31.53',what:")) { throw "check 31.53 is in the fixture already" }

SubRx @'
  {v:'31.52',what:
'@ @'
  {v:'31.53',what:'the caption over the belt (item name, fire, use) is prompt size (label, 15.6 px), not the 13 px micro print',
   run:function(){
     if(typeof beltCapFS!=='function') return 'SKIP: no beltCapFS';
     var cap=parseFloat(((/([\d.]+)px/).exec(String(beltCapFS(40)))||[0,0])[1])||0;
     var want=parseFloat(((/([\d.]+)px/).exec(String(FS(TYPE.label)))||[0,99])[1])||99;
     if(cap<want-0.01) return 'the belt caption is '+cap+' px, under the label size '+want+' px';
     return null; }},
  {v:'31.52',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
