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
Not verified: 1440p and 4K, where the pane cannot be made big enough to
'@ @'
### The corpus caught this and it was right to

v9.17 pinned 16:9 to the 820 pixel column ON PURPOSE, as the control proving
its own ultrawide rule was really gated, and the full run failed on it. That
is the corpus doing its job. His note is newer than that check and says the
opposite, so the intent has changed and the check had to change with it
rather than the build quietly stepping over a control.

What that control was FOR is kept. It exists to prove the cap follows the
screen instead of widening everything everywhere. The gate is the 820 floor
now, so a NARROW screen is what must still be pinned, and that is what it
asserts. Its ultrawide half is untouched, its rule that the column may never
exceed 90 percent of an ultrawide is untouched, and its stylesheet check now
looks for the 820 wherever it sits in the rule rather than as the whole cap.
Run against a v10.72 fixture, the updated v9.17 fails too, which is what
makes it a check rather than a comment.

Not verified: 1440p and 4K, where the pane cannot be made big enough to
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
