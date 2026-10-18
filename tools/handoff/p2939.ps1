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

# Pause box and Settings move onto the shared UI look (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
</style><canvas id="cv"></canvas>
'@ @'
/* v28.xx (cw-ps-look), his order 2026-10-18 (UI step 6): the PAUSE BOX and the SETTINGS window (screens 18, 25-32, 42, 49, 68-75) on the shared look.
   The critic scored Settings 2 of 5 (two nav strips, 13px sentences under every row, no focus on the row, steppers a screen away from their labels).
   Pause: the title is the 32px title size in light text (the one amber thing in the box is Resume run), the key legend and the note line are 16px grey.
   Settings: rows are 20px names on a 56px pitch with the sentence moved to the detail pane (it shows the sentence for the row under the pad or mouse, so
   nothing is lost), the focused row is raised with a 3px amber edge, the section chips are text tabs with a 3px underline, the list is 960px wide so the
   stepper sits by its label, the detail pane reads at 32 and 20px. No wording moved. */
#root #pausebox h3{ font:700 var(--fs-title)/1.1 var(--f-cond); letter-spacing:var(--track); color:var(--tx-1); }
#root #pausebox #pausekeys{ font-size:var(--fs-label) !important; color:var(--tx-2) !important; letter-spacing:var(--track) !important; line-height:1.8 !important; }
#root #pausebox > div[style*="margin-top:6px"]{ font-size:var(--fs-label) !important; color:var(--tx-2) !important; margin-top:var(--sp-1) !important; }
#root #settingsmodal .tpane{ max-width:calc(var(--sp-5) * 33); }
#root #setwrap > #setlist{ flex:0 1 calc(var(--sp-5) * 20); padding-bottom:var(--sp-3); }
#root #setlist .row:not(.setjump){ min-height:var(--btn-h); }
#root #setlist .row > div:first-child > b{ font-size:var(--fs-body); font-weight:600; letter-spacing:var(--track); text-transform:none; }
#root #setlist .row > div:first-child > .hint{ display:none; }
#root #setlist .row:not(.setjump):hover, #root #setlist .row:not(.setjump):has(.padfocus), #root #setlist .row:not(.setjump):focus-within{ background:var(--ui-raised); box-shadow:inset 3px 0 0 var(--acc); }
#root #setlist .row > button{ min-width:calc(var(--sp-5) * 4) !important; min-height:var(--btn-h-sm); font-size:var(--fs-body); letter-spacing:var(--track); border-radius:var(--rad); }
#root #setlist .row > button:hover:not(:disabled), #root #setlist .row > button.padfocus{ color:var(--acc); }
#root #setlist .setjump{ padding:0 var(--sp-2); }
#root #setlist .setjump .sj{ gap:var(--sp-3); }
#root #setlist .setjump button{ min-height:var(--btn-h-sm); padding:0 var(--sp-1); border:0 !important; border-bottom:3px solid transparent !important; border-radius:0; background:transparent; clip-path:none; font:600 var(--fs-body)/1 var(--f-cond); letter-spacing:var(--track); color:var(--tx-2); }
#root #setlist .setjump button:hover:not(:disabled):not(.on){ background:transparent; color:var(--tx-1); border-bottom-color:var(--ui-line-hi) !important; }
#root #setlist .setjump button.on{ background:transparent; color:var(--tx-1); border-bottom-color:var(--acc) !important; }
#root #setlist .row[style*="opacity:.7"] > div:first-child > b{ font-size:var(--fs-label); font-weight:600; letter-spacing:var(--track); color:var(--tx-2); padding-left:0; box-shadow:none; }
#root #setlist .row[style*="opacity:.7"]{ padding-top:var(--sp-3); }
#root #setdetail .sdk{ font-size:var(--fs-title); letter-spacing:var(--track); text-transform:none; }
#root #setdetail .sdv{ font-size:var(--fs-body); letter-spacing:var(--track); text-transform:none; border-radius:var(--rad); }
#root #setdetail .sdh{ font-size:var(--fs-body); line-height:1.5; }
</style><canvas id="cv"></canvas>
'@

SubRx @'
var VER='29.38';
'@ @'
var VER='29.39';
'@

$pat = "(?m)^  now:'v29\.38:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v29.39: Pause and Settings screens are cleaner and easier to read. Check 29.39 fails on v29.38',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
