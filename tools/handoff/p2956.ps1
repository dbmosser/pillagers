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

# PAUSE CARD TIDY (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
#root #pausebox #abandonbtn, #root #pausebox #arcendbtn{ margin-top:var(--sp-3); }
'@ @'
#root #pausebox #abandonbtn, #root #pausebox #arcendbtn, #root #pausebox #charselbtn{ margin-top:var(--sp-3); }
/* v28.xx (cw-pausetidy) critic c-31 round 2 (pause 3, 25/42/49): the card was 780 wide round a 560 column, the HUD still ghosted through at 97 percent, the way out was not shown, and the leave buttons were the same grey as Feedback. Now: card 640 wide on a keyboard (a pad keeps its legend width), scrim 99 percent, an Esc hint under the buttons, leave buttons in --danger */
body:not(.padon) #root #pausebox::before{ width:min(calc(var(--menu-w) + var(--sp-5) + var(--sp-4)),calc(100% - var(--sp-4))) !important; }
#root #pausebox{ background:color-mix(in srgb,var(--ui-void) 99%,transparent); }
#root #pausebox::after{ content:'Esc  Resume'; font:600 var(--fs-label)/1 var(--f-cond); letter-spacing:var(--track); color:var(--tx-2); margin-top:var(--sp-1); }
body.padon #root #pausebox::after, #root #pausebox.asking::after{ display:none; }
#root #pausebox #abandonbtn, #root #pausebox #arcendbtn, #root #pausebox #charselbtn{ color:var(--danger) !important; border-color:var(--danger) !important; }
'@

SubRx @'
var VER='29.55';
'@ @'
var VER='29.56';
'@

$pat = "(?m)^  now:'v29\.55:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v29.56: The pause card is tighter, shows Esc to resume, and the leave buttons are red. Check 29.56 fails on v29.55',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
