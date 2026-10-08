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

# THE STAT CARDS ARE READABLE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  .scard .ss b{ color:var(--amber); font-weight:600; }
'@ @'
  .scard .ss b{ color:var(--amber); font-weight:600; }
  /* v20.26, seen on the 4K YOUR STATS screenshot (2026-10-08): the card titles were 11px and the lines under them 12px, and the
     150px cards stood seven to a row with empty space beside them. Bigger print and wider cards that fill the row. */
  #statgrid{ grid-template-columns:repeat(auto-fit,minmax(190px,1fr)); gap:9px; }
  .scard{ padding:10px 12px; }
  .scard .sk{ font-size:13px; }
  .scard .sv{ font-size:28px; }
  .scard .sv.word{ font-size:19px; }
  .scard .ss{ font-size:14px; line-height:1.35; }
'@

SubRx @'
var VER='20.25';
'@ @'
var VER='20.26';
'@

$pat = "(?m)^  now:'v20\.25:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v20.26: YOUR STATS is easier to read. Check 20.26 fails on v20.25',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
