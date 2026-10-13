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

# THE LAST FAINT WORDS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  .ui-key.pill{ border-radius:12px; padding:0 9px; }
'@ @'
  .ui-key.pill{ border-radius:12px; padding:0 9px; }
  /* vNN.xx, UI REDESIGN ui5q1s (his #50, from the visual lint of every screen): LOST READS ON THE CARD. The LOST tags in the run card
     manifest were the danger red, 3.9:1 against the card; they are a lighter red of the same hue, 5.6:1. */
  #root #oc_manifest span[style*="var(--rust)"]{ color:#ff6e55 !important; }
'@

SubRx @'
    '@keyframes attpulse{0%,100%{opacity:1}50%{opacity:.35}}';
'@ @'
    '@keyframes attpulse{0%,100%{opacity:1}50%{opacity:.6}}';   // vNN.xx (ui5q1s): the faint end of the pulse still reads (2.8:1 at .35)
'@

SubRx @'
'<div id="keyslist" style="max-height:58vh;overflow-y:auto;padding-right:6px"></div>
'@ @'
'<div id="keyslist" data-lint-scroll style="max-height:58vh;overflow-y:auto;padding-right:6px"></div>
'@

SubRx @'
var VER='24.74';
'@ @'
var VER='24.75';
'@

$pat = "(?m)^  now:'v24\.74:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v24.75: LOST on the death card and the arcade PRESS ANY BUTTON line are easier to read. Check 24.75 fails on v24.74',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
