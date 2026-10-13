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

# SETTINGS READS AS ONE LAYOUT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  .ui-key.pill{ border-radius:12px; padding:0 9px; }
'@ @'
  .ui-key.pill{ border-radius:12px; padding:0 9px; }
  /* vNN.xx, UI REDESIGN ui5q1g (his #50, from the AAA judge of the Settings shot): SETTINGS READS AS ONE LAYOUT. The list was a
     centred 1080px column under a title and tabs on the left edge, so the page read as two layouts with a 400px gutter; the row
     labels mixed sentence case (Edit the words) with caps (LIGHTING); THE RAID head was faint grey; and the values were plain
     boxes with nothing to say they step through options. The list now starts on the left edge under the tabs and runs 1320px;
     every label is the same 18px condensed caps (the words are not changed, only drawn in caps), the hints are one 14px grey;
     the section heads are 20px bone caps with an amber tick; and a value that steps through options shows the arrows of a
     stepper either side of it. */
  #root #settingsmodal .tpane{ max-width:1320px; margin:0; }
  #root #setlist .row{ min-height:64px; padding:8px 16px; gap:24px; }
  #root #setlist .row > div:first-child > b{ display:block; font-family:var(--f-cond); font-weight:600; font-size:18px; line-height:1.2;
    letter-spacing:.06em; text-transform:uppercase; color:var(--tx-1); }
  #root #setlist .row > div:first-child > .hint{ padding:3px 0 0; font-size:14px; line-height:1.45; color:var(--tx-2); max-width:900px; }
  #root #setlist .row[style*="opacity:.7"]{ opacity:1 !important; min-height:0; padding:18px 16px 8px; background:transparent; }
  #root #setlist .row[style*="opacity:.7"] b{ font-size:20px; font-weight:700; letter-spacing:.1em; padding-left:12px; box-shadow:inset 3px 0 0 var(--acc); }
  #root #setlist .row > button{ min-width:180px !important; min-height:40px; font-size:16px; font-weight:700; letter-spacing:.08em; }
  #root #setlist .row > button[id^="go_"], #root #setlist #set_text, #root #setlist #set_layout, #root #setlist #set_music,
  #root #setlist #set_auto, #root #setlist #set_share{ display:inline-flex; align-items:center; justify-content:space-between; gap:10px; }
  #root #setlist .row > button[id^="go_"]::before, #root #setlist #set_text::before, #root #setlist #set_layout::before, #root #setlist #set_music::before,
  #root #setlist #set_auto::before, #root #setlist #set_share::before{ content:'\2039'; color:var(--tx-3); font-size:20px; line-height:1; }
  #root #setlist .row > button[id^="go_"]::after, #root #setlist #set_text::after, #root #setlist #set_layout::after, #root #setlist #set_music::after,
  #root #setlist #set_auto::after, #root #setlist #set_share::after{ content:'\203A'; color:var(--tx-3); font-size:20px; line-height:1; }
'@

SubRx @'
var VER='24.44';
'@ @'
var VER='24.45';
'@

$pat = "(?m)^  now:'v24\.44:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v24.45: Settings lines up on the left, every row name is in the same capitals, and the values show stepper arrows. Check 24.45 fails on v24.44',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
