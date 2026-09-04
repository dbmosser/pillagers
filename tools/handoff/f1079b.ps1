$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# ==== MY OWN NUMBER, CORRECTED BEFORE IT SHIPPED. I first read the standing
# ==== prompt pulse as 25.7 percent, but that reading came off a setup that had
# ==== put him DOWN first and then stood him up again. Driven the way v9.08's own
# ==== control drives it, six runs read 21.2, 21.4, 21.4, 21.2, 21.4, 21.2.
# ==== The bar, the fill and the ring are exact to the pixel across three runs:
# ==== 1319, 1319, 120 every time. So one number moves and the pulse floor comes
# ==== down with it, to stay at half of what was actually measured.
SubRx @'
//   pulse 25.7 %,  the standing extract prompt breathing
'@ @'
//   pulse 21.3 %,  the standing extract prompt breathing, 21.2 to 21.4 over six
'@
SubRx @'
window.__FLOORS={bar:600,prog:600,ring:60,pulse:12,
  live:{bar:1319,prog:1319,ring:120,pulse:25.7}};
'@ @'
window.__FLOORS={bar:600,prog:600,ring:60,pulse:10,
  live:{bar:1319,prog:1319,ring:120,pulse:21.3}};
'@
SubRx @'
       // v10.79: the floor was 3 percent against a measured 25.7, so a pulse
'@ @'
       // v10.79: the floor was 3 percent against a measured 21.3, so a pulse
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
