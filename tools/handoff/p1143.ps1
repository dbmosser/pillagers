param([string]$Target='C:\claudecode\dark raiders\dark_raiders.html')
$ErrorActionPreference='Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$SP='C:\Users\User1\AppData\Local\Temp\claude\C--Users-User1-Desktop-dark-raiders\c6801b49-bb04-49e7-8681-639ade6b3be0\scratchpad'
$s=[IO.File]::ReadAllText($Target)
$json=[IO.File]::ReadAllText((Join-Path $SP 'textedits.norm.json'),[Text.Encoding]::UTF8).Trim()
$n=0
function SubRx([string]$old,[string]$new){
  $pat=($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c=([regex]::Matches($script:s,$pat)).Count
  if($c -ne 1){ throw "regex matched $c times: $($old.Substring(0,[Math]::Min(60,$old.Length)))" }
  $script:s=[regex]::Replace($script:s,$pat,{param($m) $new})
  $script:n++
}

# UPDATE the shipped edit map to his latest set (adds the 4 title-screen/tutorial
# lines he edited after the v11.42 snapshot). The TXSHIP declaration is one line.
$cnt=([regex]::Matches($s,'(?m)^var TXSHIP=.*$')).Count
if($cnt -ne 1){ throw "TXSHIP line matched $cnt times" }
$s=[regex]::Replace($s,'(?m)^var TXSHIP=.*$',{param($m) 'var TXSHIP='+$json+';'})
$n++

# STAMPS.
SubRx "var VER='11.42';" "var VER='11.43';"
SubRx "var WHATSNEW_VER='11.42';" "var WHATSNEW_VER='11.43';"
SubRx @'
  now:'v11.42: his in-game text edits, baked permanently. 67 wording changes from the text editor (P.txt in his run export) are shipped as a default map TXSHIP that TX consults under the profile, so his words are the game words for everyone; number-shaped lines are derived into the same blanked patterns txSet builds, so lines like the credit counter refill their numbers at draw time. The export double-encoded the middot and it was normalized before baking. His own profile edits still win. From his instruction to pick the edits up permanently.',
'@ @'
  now:'v11.43: his text edits refreshed to the latest set from his export, 71 now, adding the four title-screen and tutorial lines he rewrote after the v11.42 snapshot (the intro card, the loot/extract/lift lines). Same bake as v11.42: TXSHIP default map plus derived TXPSHIP patterns, consulted by TX under his P.txt, encoding normalized. From his instruction to pick the edits up permanently while he was still editing.',
'@

$script:s=$s
[IO.File]::WriteAllText($Target,$script:s,(New-Object Text.UTF8Encoding $false))
Write-Output ("OK, $n edits applied to " + $Target)
