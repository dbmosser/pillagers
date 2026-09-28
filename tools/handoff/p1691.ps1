$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $new = $new.Replace("`r`n", "`n")
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# THE PARTY WINDOW CODE BOXES ARE IN THE GAME FONT (his rule of v11.09: every menu in one font; the sweep on v16.88).

SubRx @'
  #partymodal textarea{ font-family:ui-monospace,Consolas,monospace; font-size:12px; word-break:break-all; }
'@ @'
  #partymodal textarea{ font-size:12px; word-break:break-all; }   /* v16.91: the game font, as every text box (his v11.09 rule) */
'@

SubRx @'
var VER='16.90';
'@ @'
var VER='16.91';
'@

$pat = "(?m)^  now:'v16\.90:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v16.91: THE PARTY WINDOW CODE BOXES ARE IN THE GAME FONT. His rule since v11.09 is one font on every menu, and the three invite code boxes of the PARTY window were set in a typewriter font; the full sweep flagged it. They are in the game font now. Check 16.91 fails on v16.90',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
