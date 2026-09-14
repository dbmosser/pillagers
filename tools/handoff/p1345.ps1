param([string]$Html='C:\claudecode\dark raiders\dark_raiders.html',[string]$Fix='C:\claudecode\dark raiders\tools\mkfixture.ps1')
$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$d = [IO.File]::ReadAllText('C:\claudecode\dark raiders\tools\handoff\km1345.json') | ConvertFrom-Json
$T = @{ h = [IO.File]::ReadAllText($Html); f = [IO.File]::ReadAllText($Fix) }; $n = 0
foreach ($e in $d.edits) {
  $pat = (($e.old -split "`n") | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($T[$e.kind], $pat)).Count
  if ($c -ne 1) { throw "edit $n matched $c times: $($e.old.Substring(0,[Math]::Min(80,$e.old.Length)))" }
  $nv = $e.new; $T[$e.kind] = [regex]::Replace($T[$e.kind], $pat, { param($m) $nv }); $n++
}
$c = ([regex]::Matches($T.h, $d.nowPat)).Count; if ($c -ne 1) { throw "DEVNOW now line matched $c times" }
$nl = $d.nowLine; $T.h = [regex]::Replace($T.h, $d.nowPat, { param($m) $nl })
[IO.File]::WriteAllText($Html, $T.h, (New-Object Text.UTF8Encoding $false))
[IO.File]::WriteAllText($Fix, $T.f, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"