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

# the initials card has its heading again (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
\u00b7 enter initials');   // v28.xx (cw-iniplayer), his Q62 c.appendChild(el);
'@ @'
\u00b7 enter initials'); c.appendChild(el);   // v28.xx (cw-iniplayer), his Q62: the heading says whose turn it is. v31.xx (cw-inihead): the appendChild sat inside this comment from v30.36 on, so the card was drawn with no heading at all
'@

SubRx @'
var VER='31.44';
'@ @'
var VER='31.45';
'@

$pat = "(?m)^  now:'v31\.44:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v31.45: The initials card shows its heading again: player 1 then player 2 enter initials in a two player run, and top 10 tonight, enter initials in a one player run. Check 31.45 fails on v31.44',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
