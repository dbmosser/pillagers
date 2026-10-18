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

# SETTINGS SLIM (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
#root #keyslist .keybtn{ min-width:calc(var(--sp-1) * 20) !important; }
'@ @'
#root #keyslist .keybtn{ min-width:calc(var(--sp-1) * 20) !important; }

/* v28.xx (cw-setslim) critic c-31 (Settings 2, Keys 2, pause 3): "the modal is about 1390x1030 against a 960 maximum", "labels sit 700px from their steppers", "stepper boxes are heavy outlines repeated on every row", "the detail pane is a 220px card above 650px of void", "the close X is a tiny glyph", "chevrons about 12px". Now: Settings and Keys cards are 960 wide (20 x 48), the detail text is one strip under the list (name, value, line) instead of a side pane, steppers are plain text with 32px chevrons and show their box only on the row you point at (value amber there), the header X is two 24px strokes, and the pause stack is 400 wide. */
#root #settingsmodal, #root #keysmodal{ --cw:calc(var(--sp-5) * 20); }
#root #setwrap{ flex-direction:column; gap:0; }
#root #setwrap > #setlist{ flex:1 1 0; min-height:0; }
#root #setdetail{ flex:0 0 auto; align-self:stretch; max-width:none; min-height:calc(var(--sp-5) * 2); padding:var(--sp-3) var(--sp-4); border:0; border-top:1px solid var(--ui-line-hi); background:var(--ui-raised); box-shadow:none; display:flex; flex-wrap:wrap; align-items:baseline; column-gap:var(--sp-3); row-gap:var(--sp-1); }
#root #setdetail .sdk{ font-size:var(--fs-body); font-weight:700; }
#root #setdetail .sdv{ margin:0; padding:0; border:0; color:var(--acc); font-weight:600; }
#root #setdetail .sdh{ flex:1 1 100%; margin:0; font-size:var(--fs-label); line-height:1.4; }
#root #setlist .row > button{ border-color:transparent; background:transparent; }
#root #setlist .row:hover > button, #root #setlist .row:focus-within > button, #root #setlist .row > button.padfocus{ border-color:var(--ui-line-hi); background:var(--ui-void); color:var(--acc); }
#root #setlist .row > button::before, #root #setlist .row > button::after{ color:var(--tx-1) !important; font-size:var(--fs-title) !important; }
#root #settingsmodal #closesettings::after, #root #keysmodal #closekeys::after{ content:''; --xc:var(--tx-1); width:var(--sp-3); height:var(--sp-3); background:linear-gradient(45deg, transparent 44%, var(--xc) 44% 56%, transparent 56%), linear-gradient(-45deg, transparent 44%, var(--xc) 44% 56%, transparent 56%); }
#root #settingsmodal #closesettings:hover::after, #root #keysmodal #closekeys:hover::after{ --xc:var(--acc); }
#root #pausebox{ --pw:calc(var(--sp-1) * 50); }
#root #pausebox > div:has(> #resumebtn){ width:var(--pw); }
body:not(.padon) #root #pausebox::before{ width:min(calc(var(--pw) + var(--sp-5) + var(--sp-4)),calc(100% - var(--sp-4))) !important; }
'@

SubRx @'
var VER='29.66';
'@ @'
var VER='29.67';
'@

$pat = "(?m)^  now:'v29\.66:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v29.67: Settings and Keys are 960 cards with a detail strip. Check 29.67 fails on v29.66',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
