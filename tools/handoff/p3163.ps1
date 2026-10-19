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

# SETTINGS TABS AS A LEFT RAIL (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
#root #setdetail{ background:var(--ui-panel); }
'@ @'
#root #setdetail{ background:var(--ui-panel); }
/* v31.xx (cw-pset12) critic c-31y/c-31z (Settings 18, 70, 72 at 3: "a narrow 960px column floating in a 1870px card, 450px of empty void each side", "move the six tabs into a 280px left rail aligned with the list", "tiny low-contrast tabs", "send play data: move it into the list or the footer"). Now: the section tabs are a 288px left rail beside the 960px rows (one 1248px block centred in the card), 56px rail buttons at 20px with a 3px accent bar on the section in view, send play data is the last rail button, the detail strip lines up with the rows. The tab strip sticks as a zero-height anchor, so a row never hides under it. Q61 keeps send play data; Q43 keeps the near full screen card. */
#root #settingsmodal #setwrap{ max-width:calc(var(--sp-5) * 26); }
#root #settingsmodal #setlist{ --rail:calc(var(--sp-5) * 6); box-sizing:border-box; padding-left:var(--rail); }
#root #settingsmodal #setlist .setjump{ position:sticky; top:0; margin:0 0 0 calc(var(--rail) * -1); width:var(--rail); height:0; min-height:0; padding:0; border:0; background:transparent; overflow:visible; z-index:3; }
#root #settingsmodal #setlist .setjump .sj{ position:absolute; top:0; left:0; width:100%; box-sizing:border-box; padding-right:var(--sp-3); flex-direction:column; align-items:stretch; flex-wrap:nowrap; gap:var(--sp-1); }
#root #settingsmodal #setlist .setjump button{ width:100%; min-height:var(--btn-h); padding:0 var(--sp-2); text-align:left; justify-content:flex-start; border:0 !important; border-left:3px solid transparent !important; margin:0; }
#root #settingsmodal #setlist .setjump button:hover:not(:disabled):not(.on){ background:var(--ui-hover); color:var(--tx-1); border-left-color:var(--ui-line-hi) !important; }
#root #settingsmodal #setlist .setjump button.on{ background:var(--ui-raised); color:var(--tx-1); border-left-color:var(--acc) !important; }
#root #settingsmodal #setlist .setjump button[data-go]{ margin-top:var(--sp-3); }
#root #settingsmodal #setdetail{ margin-left:var(--sp-5); }
#root #settingsmodal #setlist .row > button[id^="go_"]{ border-color:var(--ui-line-hi); }
'@

SubRx @'
var VER='31.62';
'@ @'
var VER='31.63';
'@

$pat = "(?m)^  now:'v31\.62:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v31.63: The settings section tabs are a left rail beside the rows, with send play data last in the rail. Check 31.63 fails on v31.62',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
