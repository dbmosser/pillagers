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

# SETTINGS AND PAUSE POLISH: HINT ALIGNED, FOCUS ROW, QUIET ABANDON (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
#root #keyslist{ padding-bottom:var(--sp-4); }
'@ @'
#root #keyslist{ padding-bottom:var(--sp-4); }
/* v31.xx (cw-pset8) critic c-31w (Settings 72 and 18 at 3: "esc close is not aligned to the X right edge (1822 against 1870)", "focus is weak: 3px edge, label stays white", "arrows stay grey"; pause 25 at 3: "report a problem uses a different type style from its siblings, muted grey on a bluish fill", "abandon is as big and loud as the primary"). Now: the key hint line ends exactly under the X (full width of the card content), the list rows read tx-2 until you point at one, the pointed row gets a 4px accent bar, a tx-1 label and accent arrows, the detail strip sits 16px under the list, the report box is condensed 600 tx-1 on the panel fill like its siblings, and abandon is a quiet red text button (no box) until it asks. */
#root #settingsmodal::after, #root #keysmodal::after{ width:100%; }
#root #setlist .row:not(.setjump) > div:first-child > b{ color:var(--tx-2); }
#root #setlist .row:not(.setjump):hover > div:first-child > b, #root #setlist .row:not(.setjump):focus-within > div:first-child > b, #root #setlist .row.dshow:not(.setjump) > div:first-child > b, #root #setlist .row:not(.setjump):has(.padfocus) > div:first-child > b{ color:var(--tx-1); }
#root #setlist .row:not(.setjump):hover, #root #setlist .row:not(.setjump):focus-within, #root #setlist .row.dshow:not(.setjump), #root #setlist .row:not(.setjump):has(.padfocus){ box-shadow:inset 4px 0 0 var(--acc); }
#root #setlist .row:not(.setjump):hover > button::before, #root #setlist .row:not(.setjump):hover > button::after, #root #setlist .row:not(.setjump):focus-within > button::before, #root #setlist .row:not(.setjump):focus-within > button::after, #root #setlist .row.dshow:not(.setjump) > button::before, #root #setlist .row.dshow:not(.setjump) > button::after{ color:var(--acc) !important; }
#root #setdetail{ margin-top:var(--sp-2); }
#root #pausebox #pausefb{ font:600 var(--fs-body)/26px var(--f-cond); letter-spacing:var(--track); }
#root #pausebox #pausefb::placeholder{ color:var(--tx-1); }
#root #pausebox:not(.asking) #abandonbtn, #root #pausebox:not(.asking) #arcendbtn, #root #pausebox:not(.asking) #charselbtn{ border-color:transparent !important; background:transparent; font-weight:600; }
'@

SubRx @'
var VER='31.48';
'@ @'
var VER='31.49';
'@

$pat = "(?m)^  now:'v31\.48:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v31.49: The Settings hint lines up under the X, the pointed row reads clearly, the report box matches the buttons and abandon is a quiet red text button. Check 31.49 fails on v31.48',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
