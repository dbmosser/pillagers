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

# PARTY CARD PROMPT IS 24PX, WITH A FOOTER RULE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
body #attract .arcover .aobmt > div:first-child{ font-size:max(16px, calc(var(--fs-label) * var(--attz,1))) !important; }

'@ @'
body #attract .arcover .aobmt > div:first-child{ font-size:max(16px, calc(var(--fs-label) * var(--attz,1))) !important; }
/* v31.xx (cw-partylook7), the critic on 46 55 56 64 (3 each, after v31.68): "press any key is the primary action on a walk-up screen but it is the same size as the table text, the eye never lands on it", "no footer row". The prompt is 24px (the 24px spacing step; was 20px, the title stays the largest word) with a 32px glyph (was 24px), and a 1px hairline sits above the footer row on every party card, so the card reads header, body, footer. Restyle only. */
body #attract[style*="block"]:has(.arcpage[style*="block"]) .attpress, body #attract[style*="block"]:has(.arcover[style*="block"]) .attpress{ font-size:calc(var(--sp-3) * var(--attz,1)); gap:calc(var(--sp-2) * var(--attz,1)); }
body #attract[style*="block"]:has(.arcpage[style*="block"]) .attpress::before, body #attract[style*="block"]:has(.arcover[style*="block"]) .attpress::before{ width:calc(var(--sp-4) * var(--attz,1)); height:calc(var(--sp-4) * var(--attz,1)); }
body #attract .arcpage, body #attract .arcover{ background-image:linear-gradient(var(--ui-line), var(--ui-line)); background-repeat:no-repeat; background-size:calc(100% - var(--sp-5) * var(--attz,1)) 1px; background-position:center calc(100% - (var(--sp-3) + var(--btn-h) + var(--sp-2)) * var(--attz,1)); }

'@

SubRx @'
var VER='31.72';
'@ @'
var VER='31.73';
'@

$pat = "(?m)^  now:'v31\.72:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v31.73: The press any key prompt on the how to play page, the board and the run over card is 24px with a footer rule above it. Check 31.73 fails on v31.72',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
