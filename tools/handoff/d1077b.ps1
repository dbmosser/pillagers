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
Not verified: an ultrawide, where the older aspect-gated rule still exists in
'@ @'
### A second check with the same fault, found the same way

Running the corpus at 4K also failed v10.69, which requires the briefing's
scrollbar to be at least ten pixels wide so a player can see there is more
below. On a 3840x2160 screen the whole briefing FITS: eighteen cards, none
under the fold, and the cue correctly stays hidden. There is then no
scrollbar at all and the one pixel it measures is the border, so the check
failed a build that was doing exactly the right thing. It only asks about the
bar when the list actually scrolls now.

Two checks, both mine, both asserting something about a screen too small to
hold the content and both treating a bigger screen as a fault. Worth naming
as a class: an assertion about overflow is only meaningful where the content
overflows.

Not verified: an ultrawide, where the older aspect-gated rule still exists in
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
