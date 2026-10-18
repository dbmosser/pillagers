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

# SETTINGS AND KEYS CARD HEIGHT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
body:has(#settingsmodal.on) #hubtoast, body:has(#keysmodal.on) #hubtoast{ visibility:hidden; }
'@ @'
body:has(#settingsmodal.on) #hubtoast, body:has(#keysmodal.on) #hubtoast{ visibility:hidden; }

/* v28.xx (cw-setheight) critic c-31 (Settings 18/70, Keys 32): "the card is about 1005x1030 and fills the screen height ... a modal never exceeds its content ... cap the card at 960x680". Now the Settings and Keys cards are 15 x 48 (720) tall and centred in the screen (top and bottom air --py, never under 48), the frame, the header X and the tab strip follow it. The list scrolls inside, as before. */
#root #settingsmodal, #root #keysmodal{ --py:max(var(--sp-5), calc((100vh - var(--sp-5) * 15) / 2)); padding-top:var(--py); padding-bottom:var(--py); }
#root #settingsmodal::before, #root #keysmodal::before{ inset-block:calc(var(--py) - var(--sp-3)); }
#root #settingsmodal #closesettings, #root #keysmodal #closekeys{ top:var(--py); }
#root #settingsmodal #settabs{ top:calc(var(--py) + var(--sp-1)); }
'@

SubRx @'
var VER='29.79';
'@ @'
var VER='29.80';
'@

$pat = "(?m)^  now:'v29\.79:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v29.80: Settings and Keys are centred cards, not full-height slabs. Check 29.80 fails on v29.79',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
