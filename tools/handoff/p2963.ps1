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

# SETTINGS CARD (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
#root #keysmodal .msub{ display:none; }
'@ @'
#root #keysmodal .msub{ display:none; }

/* v28.xx (cw-setcard) critic c-31 (Settings 2, Keys 2): "a full-screen wall instead of a centred card", "no 48x48 header X", "two stacked tab strips", chamfer corner. Now the Settings and Keys windows are centred cards (content --cw wide, frame 24px beyond it) with a flat 4px frame, the one Close is a 48x48 X at the top right of the header row (the same button, moved: no second close), the Game and Send play data tabs sit on the title row, and the title is 32px. */
#root #settingsmodal, #root #keysmodal{ --cw:calc(var(--sp-5) * 28); padding:var(--sp-5) max(var(--sp-5), calc(50% - var(--cw) / 2)); }
#root #keysmodal{ --cw:calc(var(--sp-5) * 22); }
#root #settingsmodal::before, #root #keysmodal::before{ inset:calc(var(--sp-5) - var(--sp-3)) max(var(--sp-3), calc(50% - var(--cw) / 2 - var(--sp-3))); border-color:var(--ui-line-hi); border-radius:var(--rad); clip-path:none;
  background:linear-gradient(var(--acc),var(--acc)) var(--sp-3) 0/calc(var(--sp-4) + var(--sp-1)) 3px no-repeat, var(--ui-bg); background-origin:border-box; }
#root #settingsmodal > h3, #root #keysmodal > h3{ font-size:var(--fs-title); text-transform:none; letter-spacing:var(--track); min-height:var(--sp-5); box-sizing:border-box; }
#root #settingsmodal #closesettings, #root #keysmodal #closekeys{ position:absolute; top:var(--sp-5); right:max(var(--sp-5), calc(50% - var(--cw) / 2)); z-index:5; width:var(--sp-5); height:var(--sp-5); min-width:0 !important; min-height:0 !important; padding:0 !important; font-size:0 !important; line-height:1; display:flex; align-items:center; justify-content:center; }
#root #settingsmodal #closesettings::after, #root #keysmodal #closekeys::after{ content:'\00d7'; font:400 var(--fs-title)/1 var(--f-cond); color:var(--tx-1); }
#root #settingsmodal #closesettings:hover::after, #root #keysmodal #closekeys:hover::after{ color:var(--acc); }
#root #settingsmodal > div:has(> #closesettings){ height:0; margin:0; padding:0; }
#root #keysmodal #keysreset{ margin-right:auto; }
#root #settingsmodal #settabs{ position:absolute; top:calc(var(--sp-5) + var(--sp-1)); left:calc(max(var(--sp-5), calc(50% - var(--cw) / 2)) + calc(var(--sp-5) * 4)); padding:0 !important; border:0 !important; background:transparent; width:auto; }
#root #settingsmodal .msub{ font-size:var(--fs-label); }
'@

SubRx @'
var VER='29.62';
'@ @'
var VER='29.63';
'@

$pat = "(?m)^  now:'v29\.62:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v29.63: Settings and Keys are centred cards with a close X at the top. Check 29.63 fails on v29.62',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
