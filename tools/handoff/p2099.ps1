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

# STAT CARDS SIT LEVEL (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  .scard .sv.word{ font-size:19px; }
'@ @'
  .scard .sv.word{ font-size:19px; }
  /* v20.99, from the 4K visual pass of 2026-10-08 (V-C5): A NAME ON A STAT CARD SITS LEVEL WITH THE NUMBERS BESIDE IT. A card that
     holds a name (MOST RAIDED, USUALLY KILLED BY) sets it smaller than a number, so its line was shorter, and the name and the line
     under it sat higher than the 0 and the 33% on the cards beside it. The name now takes the height of a number line (28px at
     1.15, as above) and sits at its foot, so the two lines of every card in a row are level. A long name still wraps. */
  .scard .sv.word{ min-height:calc(28px * 1.15); display:flex; flex-direction:column; justify-content:flex-end; }
'@

SubRx @'
var VER='20.98';
'@ @'
var VER='20.99';
'@

$pat = "(?m)^  now:'v20\.98:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v20.99: On YOUR STATS, a card showing a name (like MOST RAIDED) now lines up with the number cards beside it. Check 20.99 fails on v20.98',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
