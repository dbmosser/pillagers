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

# GHOST HEADER X, QUIETER FOCUS BOX, KEYS LABELS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
#root #keyslist .keysec{ font-size:var(--fs-body); padding-top:var(--sp-3); }
'@ @'
#root #keyslist .keysec{ font-size:var(--fs-body); padding-top:var(--sp-3); }
/* v28.xx (cw-xghost) critic c-31 round 10 (pause 25 at 3: "the X is a thin white-bordered square with a heavy glyph ... looks brighter than the title"; Settings 26 at 3: "focus is stacked as four cues, drop the bordered stepper box"; Keys 32 at 3: "the group heading is quieter than its items"). Now: all three header X buttons are ghosts (line-hi border, tx-2 glyph, tx-1 on hover and focus), the focused Settings value loses its box, and the Keys section labels are tx-1. */
#root #pausex, #root #settingsmodal #closesettings, #root #keysmodal #closekeys{ border-color:var(--ui-line-hi); background:transparent; }
#root #pausex::after, #root #settingsmodal #closesettings::after, #root #keysmodal #closekeys::after{ --xc:var(--tx-2); }
#root #pausex:hover::after, #root #pausex:focus-visible::after, #root #settingsmodal #closesettings:hover::after, #root #settingsmodal #closesettings:focus-visible::after, #root #keysmodal #closekeys:hover::after, #root #keysmodal #closekeys:focus-visible::after{ --xc:var(--tx-1); }
#root #setlist .row.dshow:not(.setjump) > button{ border-color:transparent; background:transparent; }
#root #keyslist .keysec{ color:var(--tx-1); }
'@

SubRx @'
var VER='29.97';
'@ @'
var VER='29.98';
'@

$pat = "(?m)^  now:'v29\.97:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v29.98: Header X buttons are quieter ghosts, Keys labels are brighter. Check 29.98 fails on v29.97',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
