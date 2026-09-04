$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# ==== AND I PUT MY NEW LINE AT THE TOP OF THE WHAT IS NEW CARD, which v10.38
# ==== requires to open with what an alpha is. That check caught it. The line
# ==== goes second, under the alpha warning, where every other build has put it.
SubRx @'
var WHATSNEW=[
  'BOTH MAPS NOW HAVE A CENTRE. A monument with market stalls round the rim and benches beside it: on COLD STORAGE it is on the packing floor, and on THE COLD MILE the old frost yard is now THE FROST MARKET.
'@ @'
var WHATSNEW=[
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
  'BOTH MAPS NOW HAVE A CENTRE. A monument with market stalls round the rim and benches beside it: on COLD STORAGE it is on the packing floor, and on THE COLD MILE the old frost yard is now THE FROST MARKET.
'@
SubRx @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
  'THE CARD AT THE END OF A RAID HAS A COPY REPORT BUTTON.
'@ @'
  'THE CARD AT THE END OF A RAID HAS A COPY REPORT BUTTON.
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
