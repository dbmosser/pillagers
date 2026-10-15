# mkall.ps1 : HEAD source + every uic draft applied in order -> tools\shots\uic-all.html (a fixture to look at the result of the whole set)
param([string[]]$Keys=@('uic1','uic2','uic3','uic4','uic5','uic6','uic7','uic8','uic9','uic10'))
$ErrorActionPreference='Stop'
$S='C:\Users\User1\AppData\Local\Temp\claude\C--Users-User1-Desktop-dark-raiders\8a09e991-b4f4-4b23-b10f-ded92e837fc3\scratchpad'
$R='C:\claudecode\dark raiders'
$src=Join-Path $env:TEMP 'uic-all-src.html'
cmd /c ("git -C `"$R`" show HEAD:dark_raiders.html > `"$src`"")
foreach($k in $Keys){
  $json=Join-Path $env:TEMP "uic-all-$k.json"
  & powershell -NoProfile -ExecutionPolicy Bypass -File "$S\mk-$k.ps1" -Src $src -Out $json | Out-Null
  if(-not (Test-Path $json)){ throw "no draft for $k" }
  $d=[IO.File]::ReadAllText($json) | ConvertFrom-Json
  $t=[IO.File]::ReadAllText($src).Replace("`r",'')
  foreach($e in @($d.edits)){ $i=$t.IndexOf([string]$e.anchor); if($i -lt 0){ throw "$k : anchor missing" }; $t=$t.Substring(0,$i)+[string]$e.replacement+$t.Substring($i+([string]$e.anchor).Length) }
  [IO.File]::WriteAllText($src,$t,(New-Object Text.UTF8Encoding $false))
  Write-Output "$k applied ($(@($d.edits).Count) edits)"
}
& powershell -NoProfile -ExecutionPolicy Bypass -File "$R\tools\mkfixture.ps1" -Src $src -Dst "$R\tools\shots\uic-all.html" | Out-Null
Write-Output 'fixture tools\shots\uic-all.html written'
