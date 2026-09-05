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

# v11.14's OLD ARM IS ALL THREE FURNITURE RULES OFF. The gap rule of v11.17
# drops a piece standing in a doorway on its own, because such a piece leaves
# under 30 units to the jamb walls either side, so with only furnDoor off the
# doorways read 0 and 1 plugged against the 11 and 35 the control asks for.
# The old placement is the one with none of the three rules, which is what the
# dial-off arm has to be.
SubRx @'
       __runPrep(); __resetCfg(); __pinDefaults(0); __cfg({furnDoor:0});
'@ @'
       __runPrep(); __resetCfg(); __pinDefaults(0); __cfg({furnDoor:0,furnGap:0,furnIDoor:0});
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
