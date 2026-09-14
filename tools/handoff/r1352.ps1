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

# HARNESS REPAIR for v13.43: check 9.84 sets only the Machines row and then applies every
# Settings row, so each row it does not name takes its default. Since v13.43 the Pillagers
# row defaults to Few, which rewrites the pinned nRaider 10 to 5 and cost its Standard
# control world 4 pillagers on COLD STORAGE (85 entities became 81). The check measures the
# Machines row; the Pillagers row is now named at Standard so its control world is the one
# the fingerprint describes.
SubRx @'
       var P2=__P(); P2.gameOpts={robots:ix};
'@ @'
       var P2=__P(); P2.gameOpts={robots:ix,raiders:1};   // r1352: pillagers held at Standard; the row defaults to Few since v13.43
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
