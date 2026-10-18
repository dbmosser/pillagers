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

# PARTY CARDS: PROMPT AT BODY SIZE, X ON THE PROMPT LINE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
body #attract[style*="block"]:has(.arcpage[style*="block"]) .attpress, body #attract[style*="block"]:has(.arcover[style*="block"]) .attpress{ font-size:max(24px, calc(var(--fs-title) * var(--attz,1))); }
'@ @'
/* v31.xx (cw-partylook5), the critic on v31.43 (46 52 64): "the prompt grew to about 30px and is now louder than the 32px title, set it to 20px f-cond 700 in tx-1", "the X right edge is 8px off the prompt right edge". The any-key prompt is body size (20px), so the title leads; the corner X sits on the same 32px right line as the prompt; the table heads are 16px labels. Restyle only; the prompt stays the live any-key footer */
body #attract[style*="block"]:has(.arcpage[style*="block"]) .attpress, body #attract[style*="block"]:has(.arcover[style*="block"]) .attpress{ font-size:calc(var(--fs-body) * var(--attz,1)); font-weight:700; }
body #attract .arcpage::after{ right:calc(var(--sp-4) * var(--attz,1)); }
body #attract .arcpage th{ font-size:calc(var(--fs-label) * var(--attz,1)); }
'@

SubRx @'
var VER='31.45';
'@ @'
var VER='31.46';
'@

$pat = "(?m)^  now:'v31\.45:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v31.46: The any-key prompt no longer out-shouts the title and lines up with the corner X. Check 31.46 fails on v31.45',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
