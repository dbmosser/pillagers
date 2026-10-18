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

# SETTINGS HINT 20PX, SHORTER LIST FADE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
body.padon #root #keysmodal::after{ content:'A  Rebind      B  Back'; }
'@ @'
body.padon #root #keysmodal::after{ content:'A  Rebind      B  Back'; }
/* v28.xx (cw-sethint2) critic c-31 round 14 (Pad buttons 74 at 2: "the Esc Close hint is about 14px"; "the fade clips the Gear row mid-glyph"; "a 3-line label is crammed against the row above"). Now: the hint is 20px, the list fade is 24px instead of 32 (with 24px of padding under the last row), and a pad row has 8px of air above and below its label. */
#root #settingsmodal::after, #root #keysmodal::after{ font-size:var(--fs-body); }
#root #keyslist, #root #setlist{ padding-bottom:var(--sp-3); -webkit-mask-image:linear-gradient(to bottom, var(--ui-void) calc(100% - var(--sp-3)), transparent); mask-image:linear-gradient(to bottom, var(--ui-void) calc(100% - var(--sp-3)), transparent); }
#root #keyslist .row{ padding-block:var(--sp-1); }
'@

SubRx @'
var VER='30.14';
'@ @'
var VER='30.15';
'@

$pat = "(?m)^  now:'v30\.14:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v30.15: Bigger key hint, shorter list fade, air around pad rows. Check 30.15 fails on v30.14',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
