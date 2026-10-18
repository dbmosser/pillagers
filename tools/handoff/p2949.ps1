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

# The run over card is wider and the wordmark steps out (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
body #attract .arcover .aoq{ font-size:calc(var(--fs-label) * var(--attz,1)); color:var(--tx-2); opacity:1; }
'@ @'
body #attract .arcover .aoq{ font-size:calc(var(--fs-label) * var(--attz,1)); color:var(--tx-2); opacity:1; }
/* v28.xx (cw-party-over2): the critic scored screen 55 a 2: "a small, left-aligned box floating in a black void under a competing centred wordmark".
   The wordmark steps out while the run over card is up (the card is the one thing to read), and the card is wider: 840px x scale, the player rows in 20px, one clear block. */
body #attract:has(.arcover[style*="block"]) .attname{ display:none; }
body #attract .arcover{ min-width:calc(var(--menu-w) * 1.5 * var(--attz,1)); }
body #attract .arcover .aor + .aor{ margin-top:calc(var(--sp-1) * var(--attz,1)); }
'@

SubRx @'
var VER='29.48';
'@ @'
var VER='29.49';
'@

$pat = "(?m)^  now:'v29\.48:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v29.49: The run over card is bigger and the title no longer competes. Check 29.49 fails on v29.48',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
