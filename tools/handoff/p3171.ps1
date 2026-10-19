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

# SETTINGS FOCUS, DETAIL PANE AND PAUSE BOX ROWS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
#root #settingsmodal #setdetail .sdh{ font-size:var(--fs-label); color:var(--tx-2); }
'@ @'
/* v31.xx (cw-pset15) critic on Settings 72 (3), Pad buttons 74 (3) and Raid pause box 25 (3): "the focus state stacks a 1px lime outline, a 3px left bar, a raised fill, a lime value and lime chevrons", "the pane is a title and one 16px line floating in a huge empty column", "four identical full width 56px outline buttons stack with equal weight", "abandon run floats 76px below the last button", "the X is the heaviest element in the header". Now: a focused settings row keeps the raised fill and the 4px lime bar only (no ring, no box round the value); label column 336px so the value sits near its label; the rows are one 1008px column and the detail pane takes the rest with a 32px title, 20px text and a line frame; the pause box keeps resume and settings as full rows, puts feedback and what is new side by side as 40px quiet buttons (the report box and feedback button stay, Q61), and abandon stays a quiet red link at 40px (an older check wants no box); the three X buttons lose their border until hovered. Q43 keeps the near full screen card. */
#root #settingsmodal #setlist .row:not(.setjump):hover, #root #settingsmodal #setlist .row:not(.setjump):focus-within, #root #settingsmodal #setlist .row.dshow:not(.setjump), #root #settingsmodal #setlist .row:not(.setjump):has(.padfocus){ background:var(--ui-raised); box-shadow:inset 4px 0 0 var(--acc), inset 0 -1px 0 var(--ui-line-hi); }
#root #settingsmodal #setlist .row:not(.setjump):hover > button, #root #settingsmodal #setlist .row:not(.setjump):focus-within > button, #root #settingsmodal #setlist .row.dshow:not(.setjump) > button, #root #settingsmodal #setlist .row > button.padfocus{ border-color:transparent; background:transparent; }
#root #settingsmodal #setlist .row:not(.setjump) > div:first-child{ flex:0 0 calc(var(--sp-5) * 7) !important; }
#root #settingsmodal #setwrap > #setlist{ flex:0 1 calc(var(--sp-5) * 21); }
#root #settingsmodal #setwrap > #setdetail{ flex:1 1 0; min-width:0; box-sizing:border-box; padding:var(--sp-3); border:1px solid var(--ui-line-hi); border-top:3px solid var(--acc); min-height:calc(var(--sp-5) * 5); }
#root #settingsmodal #setdetail .sdk{ font-size:var(--fs-title); font-weight:700; }
#root #settingsmodal #setdetail .sdh{ font-size:var(--fs-body); color:var(--tx-2); }
#root #settingsmodal #setlist::-webkit-scrollbar{ width:8px; }
#root #settingsmodal #setlist::-webkit-scrollbar-thumb{ background:var(--ui-line-hi); border-radius:4px; }
#root #keysmodal #keyslist button.padfocus{ outline:2px solid var(--acc); outline-offset:2px; color:var(--acc); }
#root #pausebox > div:has(> #resumebtn){ flex-direction:row; flex-wrap:wrap; align-content:flex-start; }
#root #pausebox > div:has(> #resumebtn) > *{ flex:0 0 100%; }
#root #pausebox > div:has(> #resumebtn) > #fbbtn, #root #pausebox > div:has(> #resumebtn) > #wnbtn{ flex:1 1 0; min-height:var(--btn-h-xs); font-size:var(--fs-label); color:var(--tx-2); border-color:var(--ui-line); }
#root #pausebox:not(.asking) > div:has(> #resumebtn) > #abandonbtn, #root #pausebox:not(.asking) > div:has(> #resumebtn) > #arcendbtn, #root #pausebox:not(.asking) > div:has(> #resumebtn) > #charselbtn{ min-height:var(--btn-h-xs); margin-top:var(--sp-2); }
#root #pausex, #root #settingsmodal #closesettings, #root #keysmodal #closekeys{ border-color:transparent; }
#root #pausex:hover, #root #pausex:focus-visible, #root #settingsmodal #closesettings:hover, #root #settingsmodal #closesettings:focus-visible, #root #keysmodal #closekeys:hover, #root #keysmodal #closekeys:focus-visible{ border-color:var(--ui-line-hi); }
'@

SubRx @'
var VER='31.70';
'@ @'
var VER='31.71';
'@

$pat = "(?m)^  now:'v31\.70:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v31.71: Settings focus is a bar only, the detail pane is a framed wide pane, the pause box shows feedback and whats new side by side and abandon as a quiet button. Check 31.71 fails on v31.70',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
