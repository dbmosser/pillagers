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

# SHORT REBIND CALLOUT, QUIETER SETTINGS DETAIL PANE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
#root #keyslist .keysec{ color:var(--tx-1); }
'@ @'
#root #keyslist .keysec{ color:var(--tx-1); }
/* v28.xx (cw-setnote) critic c-31 round 11 (Pad buttons 75 at 2: "an explaining sentence in a tinted bar at about 14px"; Settings 18 and 72 at 3: "the detail pane repeats Edit the words Off, which duplicates the focused row"; "its sentence is about 15px"). Now: the rebind callout is one short line at 20px with square corners, and the Settings detail pane shows only the row help line at 20px (the row above already wears the name and the value, so the pane drops its title and value, and hides when a row has no help). */
#root #keysnote{ clip-path:none; border-radius:var(--rad); font-size:var(--fs-body); }
#root #setdetail .sdk, #root #setdetail .sdv{ display:none; }
#root #setdetail:not(:has(.sdh)){ display:none; }
#root #setdetail{ min-height:0; }
#root #setdetail .sdh{ font-size:var(--fs-body); line-height:1.4; }
'@

SubRx @'
s='PRESS A KEY FOR '+keysActName(KEYS.waiting)+'. ESC CANCELS.';
'@ @'
s='PRESS A KEY FOR '+keysActName(KEYS.waiting)+'  \u00b7  ESC CANCELS';
'@

SubRx @'
s='PRESS A BUTTON FOR '+padActName(PADB.waiting)+'. ESC OR TEN SECONDS CANCELS.';
'@ @'
s='PRESS A BUTTON FOR '+padActName(PADB.waiting)+'  \u00b7  ESC CANCELS';
'@

SubRx @'
var VER='30.04';
'@ @'
var VER='30.05';
'@

$pat = "(?m)^  now:'v30\.04:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v30.05: Rebind callout is one short line, Settings detail pane shows only the help text. Check 30.05 fails on v30.04',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
