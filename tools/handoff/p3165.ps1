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

# SETTINGS FILL THE CARD WITH A DETAIL PANE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
#root #settingsmodal #setlist .row > button[id^="go_"]{ border-color:var(--ui-line-hi); }
'@ @'
#root #settingsmodal #setlist .row > button[id^="go_"]{ border-color:var(--ui-line-hi); }
/* v31.xx (cw-pset13) critic on Settings 18/72 after cw-pset12 (both 3): "the rail plus list is about 1245px wide and floats in a 1870px card, 300px of dead space each side... use one content frame, x=49 to x=1871... or add a 480px detail pane at the right", "the description is the loudest block in the lower third". Now: the settings block fills the card (rail at the left margin), the detail pane is a 480px column on the right beside the rows, and its sentence drops to the 16px label size in tx-2. Q43 keeps the near full screen card. */
#root #settingsmodal #setwrap{ max-width:none; flex-direction:row; gap:var(--sp-4); }
#root #settingsmodal #setwrap > #setlist{ flex:1 1 0; min-width:0; min-height:0; }
#root #settingsmodal #setdetail{ flex:0 0 calc(var(--sp-5) * 10); max-width:none; margin:0; align-self:flex-start; }
#root #settingsmodal #setdetail .sdh{ font-size:var(--fs-label); color:var(--tx-2); }
'@

SubRx @'
var VER='31.64';
'@ @'
var VER='31.65';
'@

$pat = "(?m)^  now:'v31\.64:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v31.65: Settings fills the card, with the setting detail in a pane at the right of the rows. Check 31.65 fails on v31.64',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
