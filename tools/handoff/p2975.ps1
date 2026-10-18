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

# SETTINGS RIGHT STEPPERS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
#root #pausebox::after{ box-sizing:border-box; width:var(--pw); max-width:100%; text-align:right; }
'@ @'
#root #pausebox::after{ box-sizing:border-box; width:var(--pw); max-width:100%; text-align:right; }

/* v28.xx (cw-setnear2) critic c-31 round 2 (Settings 2): "steppers float 400px from the label with 200px of dead space to their right", "the section label Controls repeats the active tab", "the toast overlaps the card footer". Now: the card is 15 x 48 wide, the stepper is right-aligned at the row edge (6 x 48 wide), the section label that sits straight under the tab strip is gone (the tab already says it), and the toast moves to the top while Settings is open. */
#root #settingsmodal{ --cw:calc(var(--sp-5) * 15); }
#root #setlist .row:not(.setjump) > div:first-child{ flex:1 1 auto !important; }
#root #setlist .row:not(.setjump) > button{ margin-left:auto; min-width:calc(var(--sp-5) * 6) !important; }
#root #setlist .setjump + .row[style*="opacity:.7"]{ display:none; }
#root #settingsmodal .msub{ display:none; }
body:has(#settingsmodal.on) #hubtoast, body:has(#keysmodal.on) #hubtoast{ bottom:auto; top:var(--sp-5); }
'@

SubRx @'
var VER='29.74';
'@ @'
var VER='29.75';
'@

$pat = "(?m)^  now:'v29\.74:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v29.75: Settings steppers sit at the row edge; the toast moves to the top. Check 29.75 fails on v29.74',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
