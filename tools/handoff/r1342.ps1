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

# HARNESS REPAIR for v13.42: check 13.22 required PRESS B and the armour plate line in the
# top slots of the what-is-new card. v13.41 and v13.42 put his newer rulings (decks gone,
# no auto-switch to the gun) at the top, newest first, so those two older lines now sit
# below the drawn area. The newest changes own the top of the card; the two older lines
# must still be on it.
SubRx @'
     else if(idxB>2)
       bad.push('B backing out is entry '+(idxB+1)+' on the card, low enough to fall below where the card stops drawing, so it is on the list and never on the screen');
'@ @'
     // r1342: no slot bound. Since v13.41 the top slots belong to the newest rulings.
'@
SubRx @'
     else if(idxP>3)
       bad.push('the armour plate line is entry '+(idxP+1)+', low enough to fall below where the card stops drawing');
'@ @'
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
