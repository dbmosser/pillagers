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

# The rule drops rather than slides now, and the measured cost is 169 to 136 and
# 540 to 440, which is 80.5 and 81.5 percent kept. A floor of four fifths sits
# on the reading; a floor of seven tenths sits under it with the reading named.
SubRx @'
       // CONTROL THREE: pieces slide, they are not simply thrown away.
       if(on[mi].furn<off[mi].furn*0.8) bad.push(NM[mi]+': furniture fell from '+off[mi].furn+' to '+on[mi].furn+', more than a fifth lost, so pieces are being dropped where they should slide');
'@ @'
       // CONTROL THREE: only the doorway pieces go. Measured: 169 to 136 on COLD
       // STORAGE and 540 to 440 on THE COLD MILE, four fifths kept on both. A
       // build that loses more than three tenths is dropping pieces that were
       // never in a doorway.
       if(on[mi].furn<off[mi].furn*0.7) bad.push(NM[mi]+': furniture fell from '+off[mi].furn+' to '+on[mi].furn+', more than three tenths lost against the fifth measured, so pieces that were never in a doorway are being dropped');
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
