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
Not verified: whether a found gun that is WORSE than the one in his hands
'@ @'
### Found while driving a first session, not built here

FIRST TIME OUT, measured on the real game at 1920x1080 from an empty
browser: 18 cards, 1558 pixels of them, inside a 912 pixel box. Eleven are
on screen and seven are not, the scrollbar is 5 pixels wide, and nothing in
the card says there is more. The seven below the fold are the radio, the
Pillbox, arranging the HUD, the Bulwark and its slab, contracts that judge
how you played, junk building the Mainframe, and Settings being a station.
The three it calls the ones that get people killed are all above the fold,
and so is calling extraction, so a friend can still finish a raid; the
Bulwark card is the one worth a life. Two columns is not the answer, because
halving the width roughly doubles each card's height. Written up as an open
line in AUDIT.md rather than folded into this build.

Not verified: whether a found gun that is WORSE than the one in his hands
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
