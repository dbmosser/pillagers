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

# SETTINGS NEAR (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
body:not(.padon) #root #pausebox::before{ width:min(calc(var(--pw) + var(--sp-5) + var(--sp-4)),calc(100% - var(--sp-4))) !important; }
'@ @'
body:not(.padon) #root #pausebox::before{ width:min(calc(var(--pw) + var(--sp-5) + var(--sp-4)),calc(100% - var(--sp-4))) !important; }

/* v28.xx (cw-setnear) critic c-31 (Settings 2, pause 3): "controls ~700px from labels (limit 400)", "type 14/15/18 drift", "title still centred". Now: the Settings card is 17 x 48 wide, the name column is 8 x 48 and the stepper sits right after it (never 700px away), the section chips sit 16px apart, and the pause title is left-aligned over the button column with a hairline under it and the Esc hint right-aligned to the column edge. */
#root #settingsmodal{ --cw:calc(var(--sp-5) * 17); }
#root #setlist .row:not(.setjump) > div:first-child{ flex:0 0 calc(var(--sp-5) * 8) !important; min-width:0; }
#root #setlist .row:not(.setjump){ justify-content:flex-start; }
#root #setlist .setjump .sj{ gap:var(--sp-2); }
#root #pausebox h3{ box-sizing:border-box; width:var(--pw); max-width:100%; margin:0; padding-bottom:var(--sp-2); border-bottom:1px solid var(--ui-line); text-align:left; }
#root #pausebox::after{ box-sizing:border-box; width:var(--pw); max-width:100%; text-align:right; }
'@

SubRx @'
var VER='29.71';
'@ @'
var VER='29.72';
'@

$pat = "(?m)^  now:'v29\.71:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v29.72: Settings steppers sit beside their names; the pause title is left-aligned. Check 29.72 fails on v29.71',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
