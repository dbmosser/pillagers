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

# PARTY CARDS: SOLID FILL AND A READABLE RUN OVER TITLE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
body #attract .arcpage::before, body #attract .arcover::before{ width:calc(var(--sp-1) * 4.5 * var(--attz,1)); }
'@ @'
body #attract .arcpage::before, body #attract .arcover::before{ width:calc(var(--sp-1) * 4.5 * var(--attz,1)); }
/* v31.xx (cw-partylook4), the critic on 46 52 55 56 64 (2 of 5 on 52 and 64): "the card fill is translucent enough that blurred sprites show behind the stats, use --ui-panel at 95 percent or higher", "the run over title is dim grey and smaller than the stats, make it tx-1", "the ended early line is lime and out-shouts the title, lime is for focus and the main action", "the prompt is a footnote, 24px minimum". The two cards are 97 percent panel, the title is tx-1, the second line is tx-2 body text, and the any-key prompt never draws under 24px. Restyle only; the prompt stays the live any-key footer */
body #attract .arcpage, body #attract .arcover{ background:color-mix(in srgb, var(--ui-panel) 97%, transparent); }
body #attract .arcover .aoh:first-child{ color:var(--tx-1); }
body #attract .arcover .aoh + .aoh{ color:var(--tx-2); }
body #attract[style*="block"]:has(.arcpage[style*="block"]) .attpress, body #attract[style*="block"]:has(.arcover[style*="block"]) .attpress{ font-size:max(24px, calc(var(--fs-title) * var(--attz,1))); }
'@

SubRx @'
var VER='31.42';
'@ @'
var VER='31.43';
'@

$pat = "(?m)^  now:'v31\.42:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v31.43: The how to play, board and run over cards are solid, the run over title reads, and the any-key prompt is bigger. Check 31.43 fails on v31.42',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
