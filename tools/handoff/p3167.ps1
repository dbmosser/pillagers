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

# SETTINGS STEPPERS AND KEYS TABLE POLISH (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
#root #settingsmodal #setlist .row > button[id^="go_"]{ border-color:var(--ui-line-hi); }
'@ @'
/* v31.xx (cw-pset14) critic on Settings 72 after cw-pset13 (3): "twelve identical 1px-bordered boxes make a dense grid of chrome... on idle rows drop the box border and show the box only on the focused row" (cw-pset12 had put a border on every stepper by mistake; removed), and on Pad buttons 74 (2): "headers are the same size and weight as the row labels", "dead 190px strip on the left, scrollbar floats at x1673". Now: steppers show their box on the row in focus only, the section names in Keys get a 3px accent tab and the 16px label size, and the Keys table spans the whole card (two column pairs with a 48px gutter) with an 8px scroll thumb at the card edge. Q43 keeps the near full screen card. */
#root #settingsmodal #setlist .row:not(:hover):not(:focus-within) > button:not(.padfocus){ border-color:transparent; background:transparent; }
#root #settingsmodal #setdetail{ border-top:3px solid var(--acc); }
#root #keysmodal #keyslist, #root #keysmodal #keysnote{ max-width:none; column-gap:var(--sp-5); }
#root #keysmodal #keyslist .keysec{ font-size:var(--fs-label); color:var(--tx-2); letter-spacing:.08em; padding-left:var(--sp-2); box-shadow:inset 3px 0 0 var(--acc); }
'@

SubRx @'
var VER='31.66';
'@ @'
var VER='31.67';
'@

$pat = "(?m)^  now:'v31\.66:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v31.67: Settings box only the focused stepper; the key bindings table spans the card with accent section tabs. Check 31.67 fails on v31.66',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
