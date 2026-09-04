$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\AUDIT.md'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

SubRx @'
- EXTRACTED/DEATH SCREEN: drop "Anything you drank or took is gone".
- XP CEILING: "what happens at 1.2m XP? death screen isn't clear".
'@ @'
- ~~EXTRACTED/DEATH SCREEN: drop "Anything you drank or took is gone".~~ DONE at
  v8.87; grepped at v10.74 and the string exists nowhere but in the comment that
  records the removal.
- ~~XP CEILING: "what happens at 1.2m XP? death screen isn't clear".~~ ALREADY
  ANSWERED, measured at v10.74 by driving both cards at the cap. The line under
  the total reads "All 100 rewards earned. XP keeps counting, but there is
  nothing left that it pays for." on the death card AND on the extraction card.
  XP is held at 1,200,000 so it reads 1,200,000 of 1,200,000. My first probe
  said this was missing and my probe was wrong: it searched for a "Next:" line,
  which is exactly the line the ceiling replaces.
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
