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

# SETTINGS TAB FOCUS HAS NO HALO AND NO SECTION SLIVER (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
#root #settingsmodal #setwrap > #setdetail:not(.daily-restore-detail){ align-content:flex-start; }
'@ @'
#root #settingsmodal #setwrap > #setdetail:not(.daily-restore-detail){ align-content:flex-start; }
/* v34.35 (cw-setscroll2) job 107, my own pictures after cw-setscroll: the focused tab still wore the global halo ring, a clicked tab (mouse focus) left the list row lit, and the section line showed a sliver of its hidden label. */
#root #settingsmodal #setlist .setjump button:focus-visible, #root #settingsmodal #setlist .setjump button.padfocus{ box-shadow:none !important; }
#root #settingsmodal #setlist:has(.setjump button:focus):not(:has(.row:not(.setjump) .padfocus)) .row.dshow:not(.setjump):not(:hover){ background:transparent !important; box-shadow:inset 0 -1px 0 var(--ui-line-hi) !important; }
#root #settingsmodal #setlist .row[style*="opacity:.7"] > *{ visibility:hidden; }
#root #settingsmodal #setlist .row[style*="opacity:.7"]{ margin-top:var(--sp-3) !important; }
'@

SubRx @'
var VER='34.36';
'@ @'
var VER='34.37';
'@

$pat = "(?m)^  now:'v34\.36:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v34.37: Settings shows one clear focus and clean section lines. Check 34.37 fails on v34.36',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
