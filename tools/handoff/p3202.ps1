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

# Codex tiles fill the card (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
#root #codexmodal .cxt .cxr, #root #codexmodal .cxt .cxk{ font-size:var(--fs-label); }
'@ @'
#root #codexmodal .cxt .cxr, #root #codexmodal .cxt .cxk{ font-size:var(--fs-label); }
/* v28.xx (cw-uc-codexfill) b-31 step 7, critic on 65 (P0 "card 40 percent empty", P1 "14px tag text, small art"): the 16 tiles stretch to fill the card (rows share the height, 150px at least), art 96px, name 24px, rarity and kills 18px, new tag 16px. Looks only. */
#root #codexmodal .cxgrid{ grid-auto-rows:minmax(150px, 1fr); align-content:stretch; gap:var(--sp-3); }
#root #codexmodal .cxt .cxi{ width:96px; height:96px; }
#root #codexmodal .cxt .cxi img{ width:88px; height:88px; }
#root #codexmodal .cxt .cxn{ font-size:24px; }
#root #codexmodal .cxt .cxr, #root #codexmodal .cxt .cxk{ font-size:18px; }
#root #codexmodal .cxt .cxnew{ font-size:16px; }
'@

SubRx @'
var VER='32.01';
'@ @'
var VER='32.02';
'@

$pat = "(?m)^  now:'v32\.01:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v32.02: The armory codex fills its card with larger tiles and bigger text. Check 32.02 fails on v32.01',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
