$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\DESIGN.md'
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
Not verified: whether the seven cards under the fold are the right seven to
'@ @'
### The count changed the thing it was counting

My first cut was wrong and the new check caught it on its first run: the line
said 10 more below and 11 cards were actually hidden. The line lives in the
same column as the list, so showing it shortens the box by its own height and
pushes one more card under the fold. The number was out of date the instant
it was printed. It is counted twice now, so what is printed is what is true
once the line is on the page. It cannot flip back and forth, because a line
that is wanted stays wanted once it is up.

Not verified: whether the seven cards under the fold are the right seven to
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
