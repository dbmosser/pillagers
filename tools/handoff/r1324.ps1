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

# CHECK 12.73 ENCODED THE RETIRED WORDING, and the v13.24 corpus failed on it.
#
# 12.73 guards that the found-gun line, the one naming the slot it armed and how to
# swap to it, survives the Found summary instead of being overwritten in the same
# frame. It proved "the line survived" by looking for the word swaps, because the
# line used to end "X swaps". v13.24 corrected that sentence, since X searches, and
# it now ends "Select <gun> on your tactical belt to swap." The line survived: the
# failure message itself quotes it, whole, on screen. Only the needle broke.
#
# SAME PRECEDENT AS r1287, where check 12.26 asserted a spec the build had just
# reversed: the check is repaired in the same build, and the correct fix is not
# reverted to satisfy a check that was measuring the old text.
#
# THE NEEDLE NOW ACCEPTS EITHER FORM of the verb, so it guards what 12.73 was
# written to guard, that the swap instruction survives, without depending on the
# exact wording of an instruction that has already had to change once.
SubRx @'
       if(m1.indexOf('swaps')<0)
'@ @'
       if(!/\bswaps?\b/.test(m1))   // r1324: the line ends "to swap." since v13.24 corrected "X swaps"
'@

SubRx @'
       if(m2.indexOf('swaps')<0)
'@ @'
       if(!/\bswaps?\b/.test(m2))   // r1324: the same needle, either form of the verb
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
