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

# QUIET KEY CAPS, RAISED REBIND CALLOUT, PANEL DETAIL STRIP (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
#root #setdetail{ margin-bottom:var(--sp-2); }
'@ @'
#root #setdetail{ margin-bottom:var(--sp-2); }
/* v31.xx (cw-pset11) critic c-31y round 2 (Pad buttons 75 at 3: "the banner uses a muddy olive fill that does not match the raised or accent palette", "idle chips are 24 identical outlined boxes, drop their borders to --ui-line"; Settings 70 at 3: "the detail pane has the same fill as the focused row so the two compete", "the pane touches the list"). Now: the rebind callout is the raised fill with the 3px accent tab and tx-1 text (no olive), idle key caps have a quiet --ui-line border so only the waiting cap is loud, and the Settings detail strip is the panel fill so the pointed row stays the brightest thing. */
#root #keysnote.wait, #root #keysnote.set{ background:var(--ui-raised); }
#root #keyslist .keybtn:not(.wait){ border-color:var(--ui-line); }
#root #setdetail{ background:var(--ui-panel); }
'@

SubRx @'
var VER='31.60';
'@ @'
var VER='31.61';
'@

$pat = "(?m)^  now:'v31\.60:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v31.61: The rebind callout wears the raised fill, idle key caps have a quiet border, and the settings detail strip is the panel fill. Check 31.61 fails on v31.60',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
