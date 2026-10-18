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

# Attract pages: no dark bands, one accent, no operator shadow (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
body #attract .arcpage .apk{ font-weight:500; }
'@ @'
body #attract .arcpage .apk{ font-weight:500; }
/* v28.xx (cw-party-att2), his order 2026-10-18 (UI step 3, party screens 46, 56, 64): the critic scored the pages 2 and 3 ("black bands behind the title and the prompt
   look like a letterbox, two amber stubs, one under the wordmark and one on the card"). The soft dark bands are for the recorded clip (v21.53); while a page or the run over
   card is up there is no clip behind, so the bands go, the wordmark loses its underline (the card keeps the one accent tab) and the shadows go. Restyle only. */
body #attract:has(.arcpage[style*="block"]) .attname, body #attract:has(.arcover[style*="block"]) .attname,
body #attract:has(.arcpage[style*="block"]) .attpress, body #attract:has(.arcover[style*="block"]) .attpress{ background:none; text-shadow:none; }
body #attract:has(.arcpage[style*="block"]) .attname::after, body #attract:has(.arcover[style*="block"]) .attname::after{ display:none; }
'@

SubRx @'
box-shadow:0 24px 64px rgba(0,0,0,.6);color:var(--tx-1);font:600 var(--fs-body)/1.3 var(--f-cond);letter-spacing:var(--track);cursor:default
'@ @'
box-shadow:none;color:var(--tx-1);font:600 var(--fs-body)/1.3 var(--f-cond);letter-spacing:var(--track);cursor:default
'@

SubRx @'
var VER='29.68';
'@ @'
var VER='29.69';
'@

$pat = "(?m)^  now:'v29\.68:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v29.69: The attract pages and the operator card look cleaner. Check 29.69 fails on v29.68',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
