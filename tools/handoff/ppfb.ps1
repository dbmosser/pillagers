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

# SETTINGS PANE NAMES THE ROW, BIGGER ARROWS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
#root #setdetail .sdk, #root #setdetail .sdv{ display:none; }
'@ @'
/* v28.xx (cw-setname) critic c-31 round 12 (Settings 18 and 72 at 2: "the footer shows only a warning with no setting name"; "the arrows are tiny, about 12px, thin and dim"; "the Display section label repeats the active tab name"). Now: the pane wears the row name at 20px over its help line, the value stays in the row, the stepper arrows are 28px. */
#root #setdetail .sdk{ display:block; font-size:var(--fs-body); font-weight:600; line-height:1.3; }
#root #setdetail .sdv{ display:none; }
#root #setdetail .sdh{ margin-top:var(--sp-1); }
#root #setlist .row > button[id^="go_"]::before, #root #setlist #set_text::before, #root #setlist #set_layout::before, #root #setlist #set_music::before,
#root #setlist #set_auto::before, #root #setlist #set_share::before, #root #setlist .row > button[id^="go_"]::after, #root #setlist #set_text::after, #root #setlist #set_layout::after, #root #setlist #set_music::after,
#root #setlist #set_auto::after, #root #setlist #set_share::after{ font-size:28px; color:var(--tx-2); }
#root #setlist .row > button.padfocus::before, #root #setlist .row > button.padfocus::after{ color:var(--acc); }
'@

SubRx @'
var VER='30.07';
'@ @'
var VER='30.08';
'@

$pat = "(?m)^  now:'v30\.07:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v30.08: Settings pane names the row, arrows are bigger, no repeated section label. Check 30.08 fails on v30.07',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
