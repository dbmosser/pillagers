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

# PAUSE CARD AS A BUTTON COLUMN (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
#root #keysmodal .msub{ display:none; }
'@ @'
#root #keysmodal .msub{ display:none; }
/* v28.xx (cw-pausestack) critic c-31 (pause 2, 25/42/49): the pause card was a keybind cheat-sheet over a row of mixed buttons. Now: title, then one column of 56px buttons at the menu width (16px gap, sentence case), Abandon set apart, and the key legend and the feedback sentence out of the keyboard card (F1 and Settings > Controls hold the keys; a pad keeps its legend) */
#root #pausebox{ gap:var(--sp-3); }
#root #pausebox #pausekeys, #root #pausebox > div[style*="margin-top:6px"]{ display:none !important; }
body.padon #root #pausebox #pausekeys{ display:block !important; }
#root #pausebox > div:has(> #resumebtn){ flex-direction:column; align-items:stretch; width:var(--menu-w); max-width:100%; gap:var(--sp-2) !important; margin-top:0; }
#root #pausebox > div:has(> #resumebtn) > button{ box-sizing:border-box; width:100%; min-width:0 !important; min-height:var(--btn-h); padding:0 var(--sp-3) !important; border-radius:var(--rad); font:600 var(--fs-body)/1 var(--f-cond); letter-spacing:var(--track); text-transform:none; }
#root #pausebox #abandonbtn, #root #pausebox #arcendbtn{ margin-top:var(--sp-3); }
'@

SubRx @'
var VER='29.54';
'@ @'
var VER='29.55';
'@

$pat = "(?m)^  now:'v29\.54:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v29.55: The pause screen is a clean button column. Check 29.55 fails on v29.54',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
