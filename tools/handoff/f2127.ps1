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

if ($s.Contains("  {v:'21.27',what:")) { throw "check 21.27 is in the fixture already" }

SubRx @'
  {v:'21.26',what:
'@ @'
  {v:'21.27',what:'a called extraction already past its closing time shows no closes in 0:00 line on the map',
   run:function(){
     if(typeof drawMapOverlayRaw!=='function') return 'SKIP: no map here';
     var src=String(drawMapOverlayRaw), nd='G.timeLeft>'+'Z.closeAt';
     if(src.indexOf('_zAct||_zHold')<0) return 'SKIP: no closing row on a called ring here';
     if(src.indexOf(nd)<0) return 'a called ring past its closing time still reads closes in 0:00';
     return null; }},
  {v:'21.26',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
