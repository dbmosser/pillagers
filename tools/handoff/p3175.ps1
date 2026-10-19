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

# SETTINGS AND KEYS LISTS FADE OUT, FULL HEIGHT DETAIL PANE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
#root #pausex:hover, #root #pausex:focus-visible, #root #settingsmodal #closesettings:hover, #root #settingsmodal #closesettings:focus-visible, #root #keysmodal #closekeys:hover, #root #keysmodal #closekeys:focus-visible{ border-color:var(--ui-line-hi); }
'@ @'
#root #pausex:hover, #root #pausex:focus-visible, #root #settingsmodal #closesettings:hover, #root #settingsmodal #closesettings:focus-visible, #root #keysmodal #closekeys:hover, #root #keysmodal #closekeys:focus-visible{ border-color:var(--ui-line-hi); }
/* v31.xx (cw-pset16) critic on Settings 72 (3), Pause box 25 (3) and Keys 32 (3): "the list runs right down to the footer line and crosshair colour is cut off mid row", "the pane ends at y=354 with 640px of empty dark space below it", "the report a problem box has a bluer fill than settings", "feedback and what is new labels are about 14px in tx-2", "the scroll area cuts the next row in half". Now: the settings list and the keys table fade out over their last 24px with 16px of padding so a cut row reads as a scroll, the settings detail pane runs the full height of the list, the pause box report field takes the line border of the buttons under it, and feedback and what is new read in the main text colour. Q43 keeps the near full screen card. */
#root #settingsmodal #setlist, #root #keysmodal #keyslist{ padding-bottom:var(--sp-5); -webkit-mask-image:linear-gradient(to bottom, #000 calc(100% - 24px), transparent); mask-image:linear-gradient(to bottom, #000 calc(100% - 24px), transparent); }
#root #settingsmodal #setwrap > #setdetail{ align-self:stretch; }
#root #pausebox #pausefb{ border:1px solid var(--ui-line-hi); }
#root #pausebox > div:has(> #resumebtn) > #fbbtn, #root #pausebox > div:has(> #resumebtn) > #wnbtn{ color:var(--tx-1); }
'@

SubRx @'
var VER='31.74';
'@ @'
var VER='31.75';
'@

$pat = "(?m)^  now:'v31\.74:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v31.75: The settings and keys lists fade out over the last 24px, the settings detail pane is as tall as the list, the pause report field and small buttons match the rest. Check 31.75 fails on v31.74',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
