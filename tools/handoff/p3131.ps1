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

# THE STASH IS A 90 PERCENT CARD (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
body:has(.modal.ui-win.on:not(#settingsmodal):not(#welcomemodal)) #topright{ top:calc(5vh + 14px) !important; right:calc(5vw + 82px) !important; }
'@ @'
body:has(.modal.ui-win.on:not(#settingsmodal):not(#welcomemodal)) #topright{ top:calc(5vh + 14px) !important; right:calc(5vw + 82px) !important; }
/* v28.xx (cw-stashcard), his Q43 (2026-10-18): "centred card with an X in the corner ... nearly the entire screen", Settings, stash and the rest. The stash (the Undercroft terminal) was the one window still edge to edge. Now it is the same 90 percent card as the shop: 5 percent margin on every side, 4 px corners, the scrim around it, the X and the credits readout inside its top right, the toast inside its foot. */
#root #hub{ inset:5vh 5vw; border-radius:4px; border:1px solid var(--ui-line-hi); box-shadow:0 0 0 100vmax rgba(6,7,8,.82); }
body:has(#hub.on) #topright{ top:calc(5vh + 14px) !important; right:calc(5vw + 82px) !important; }
body:has(#hub.on) #hubtoast{ bottom:calc(5vh + 26px); }
'@

SubRx @'
var VER='31.30';
'@ @'
var VER='31.31';
'@

$pat = "(?m)^  now:'v31\.30:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v31.31: The stash is a centred 90 percent card like the shop. Check 31.31 fails on v31.30',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
