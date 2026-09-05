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

# v11.14's FURNITURE FLOOR NOW SPANS THREE RULES. Its old arm has all three
# furniture rules off since v11.17, so the on arm is measured against a map
# with doorway pieces, interior doorway pieces and wedged pieces all standing.
# Measured: 169 to 108 on COLD STORAGE and 540 to 336 on THE COLD MILE, 0.64
# and 0.62 kept. A floor of a half sits under both readings and still catches
# a rule that starts dropping pieces standing in the open.
SubRx @'
       if(on[mi].furn<off[mi].furn*0.7) bad.push(NM[mi]+': furniture fell from '+off[mi].furn+' to '+on[mi].furn+', more than three tenths lost against the fifth measured, so pieces that were never in a doorway are being dropped');
'@ @'
       // v11.17: the old arm has all three furniture rules off now, so this
       // reads the three together: 169 to 108 and 540 to 336, 0.64 and 0.62.
       if(on[mi].furn<off[mi].furn*0.5) bad.push(NM[mi]+': furniture fell from '+off[mi].furn+' to '+on[mi].furn+', more than half lost against the 0.64 and 0.62 measured for the three rules together, so pieces standing in the open are being dropped');
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
