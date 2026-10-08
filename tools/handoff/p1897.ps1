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

# THE RUN CARD NOTE BOX NEVER SQUASHES (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  .outcome.on{ display:flex; }
'@ @'
  .outcome.on{ display:flex; }
  .ocwin > *{ flex-shrink:0; }   /* v18.97, seen on the 4K run card screenshot (2026-10-07): with three achievement lines the card ran past the screen and, a flex column, squeezed the note box to a sliver; nothing shrinks now, the card scrolls (the buttons stay pinned) */
  .ocwin{ max-height:min(86vh,calc(100% - 32px)); }   /* v18.97: and the card always fits inside the screen, at any menu zoom */
'@

SubRx @'
var VER='18.96';
'@ @'
var VER='18.97';
'@

$pat = "(?m)^  now:'v18\.96:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v18.97: The run card note box always has room to type, however long the card is. Check 18.97 fails on v18.96',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
