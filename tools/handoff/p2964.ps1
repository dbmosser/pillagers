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

# SETTINGS FEEL (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
#root #settingsmodal .msub{ font-size:var(--fs-label); }
'@ @'
#root #settingsmodal .msub{ font-size:var(--fs-label); }

/* v28.xx (cw-setfeel) critic c-31 (Settings 2, Keys 2): "the last row is clipped mid-control", "chevrons nearly invisible, values outshout the names", "no focused row", "the instruction banner is an explaining sentence", "labels are lowercase", "key text is tiny, caps are not raised", "reset button is below 44px". Settings: row names 20px, section labels 16px, values 20px at 600, chevrons tx-2, a fade on the list bottom, the row under the pointer gets a raised fill and an amber bar. Keys: the idle hint bar is gone (it shows again while listening or on a swap), action names start with a capital, caps are raised with 20px text, section labels 16px, Reset is 48px high. */
#root #setlist{ padding-bottom:var(--sp-4); -webkit-mask-image:linear-gradient(to bottom, var(--ui-void) calc(100% - var(--sp-4)), transparent); mask-image:linear-gradient(to bottom, var(--ui-void) calc(100% - var(--sp-4)), transparent); }
#root #setlist .row > div:first-child > b{ font-size:var(--fs-body); }
#root #setlist .row[style*="opacity:.7"] > div:first-child > b, #root #setlist .row[style*="opacity:.7"] b{ font-size:var(--fs-label); color:var(--tx-2); }
#root #setlist .row > button{ font-size:var(--fs-body); font-weight:600; }
#root #setlist .row > button::before, #root #setlist .row > button::after{ color:var(--tx-2) !important; }
#root #setlist .row:not([style*="opacity:.7"]):hover, #root #setlist .row:not([style*="opacity:.7"]):focus-within{ background:var(--ui-raised); box-shadow:inset 3px 0 0 var(--acc); }
#root #keysmodal #keysnote:not(.wait):not(.set):not(.clash){ display:none; }
#root #keyslist .row b{ display:block; }
#root #keyslist .row b::first-letter{ text-transform:uppercase; }
#root #keyslist .row b{ font-size:var(--fs-body); }
#root #keyslist .keybtn{ background:var(--ui-raised); border-color:var(--ui-line-hi); font-size:var(--fs-body); min-height:var(--sp-5); }
#root #keyslist .keybtn:hover:not(:disabled){ border-color:var(--acc); }
#root #keyslist .keybtn.wait{ background:var(--acc) !important; border-color:var(--acc) !important; }
#root #keyslist .keysec{ font-size:var(--fs-label); color:var(--tx-2); letter-spacing:var(--track); }
#root #keysmodal #keysreset{ min-height:var(--sp-5); font-size:var(--fs-body); }
'@

SubRx @'
var VER='29.63';
'@ @'
var VER='29.64';
'@

$pat = "(?m)^  now:'v29\.63:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v29.64: Settings and Keys read cleaner: bigger names, a fade on the list, a hint bar only when listening. Check 29.64 fails on v29.63',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
