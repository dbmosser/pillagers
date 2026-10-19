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

# DETAIL STAT ROWS ON THE DARK PANE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  #root .vdet .vstat{ color:var(--tx-2); font-size:16px; }
'@ @'
  #root .vdet .vstat{ color:var(--tx-2); font-size:16px; }
  /* v31.xx (cw-uc-statrows), UI STEP 7 (b-31): the stat rows of the shop, craft and hire detail pane (heals, over, takes) carry an inline 15px size and a cream rule (#ddd5c4) from the paper card days, so on the dark pane they were the brightest lines and under the 16px floor. Now 16px, 6px rows, a --ui-line rule and the value in --tx-1. No words change. */
  #root .vdet .vstat[style]{ font-size:16px !important; padding:6px 0 !important; border-bottom:1px solid var(--ui-line) !important; }
  #root .vdet .vstat b{ color:var(--tx-1); font-weight:700; }
'@

SubRx @'
var VER='31.75';
'@ @'
var VER='31.76';
'@

$pat = "(?m)^  now:'v31\.75:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v31.76: Shop detail stat rows are 16px with a quiet grey rule instead of a bright cream one. Check 31.76 fails on v31.75',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
