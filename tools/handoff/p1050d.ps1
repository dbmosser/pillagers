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

# v10.50, fourth part. The full corpus caught what the batch did not: the
# Spartan helmet and the ghost mask (v10.45) stopped at ty-21.4 and ty-21.7,
# and the full beard now reaches the chin at ty-20.4, so a beard showed under
# both. Same fault as the dust mask, fixed the same way: both reach the chin.
SubRx @'
      wc.fillStyle=INK;       rrF(hx2-10.2,ty-42.2,20.4,20.8,6);
      wc.fillStyle='#3f6a3a'; rrF(hx2-9.6,ty-41.7,19.2,19.8,5.4);
'@ @'
      wc.fillStyle=INK;       rrF(hx2-10.2,ty-42.2,20.4,22.6,6);     // v10.50: to the chin, over the lowered beards
      wc.fillStyle='#3f6a3a'; rrF(hx2-9.6,ty-41.7,19.2,21.6,5.4);
'@
SubRx @'
      wc.fillStyle='#2a4a28'; rrF(hx2-9.2,ty-26.2,18.4,3.8,1.6);   // the chin guard, over where a beard would be
'@ @'
      wc.fillStyle='#2a4a28'; rrF(hx2-9.2,ty-26.2,18.4,6.0,1.6);   // the chin guard, over where a beard would be (v10.50: to the chin)
'@
SubRx @'
      wc.fillStyle=INK;       rrF(hx2-8.4,ty-38.6,16.8,17.4,6);
      wc.fillStyle='#f0ede4'; rrF(hx2-7.8,ty-38.1,15.6,16.4,5.4);   // down past the chin, over a beard
'@ @'
      wc.fillStyle=INK;       rrF(hx2-8.4,ty-38.6,16.8,19.2,6);     // v10.50: to the chin, over the lowered beards
      wc.fillStyle='#f0ede4'; rrF(hx2-7.8,ty-38.1,15.6,18.2,5.4);   // down past the chin, over a beard
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
