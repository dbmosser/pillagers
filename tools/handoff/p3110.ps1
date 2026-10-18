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

# WINDOWS ARE A 90 PERCENT CARD (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
body:has(.modal.ui-win.on:not(#settingsmodal):not(#welcomemodal)) #topright, body:has(#hub.on) #topright{ right:90px !important; }
'@ @'
body:has(.modal.ui-win.on:not(#settingsmodal):not(#welcomemodal)) #topright, body:has(#hub.on) #topright{ right:90px !important; }
/* v28.xx (cw-cardmargin), his Q43 (2026-10-18): windows are "a centred card with an X in the corner ... nearly the entire screen". The shop, codex, trophies, fashion, mainframe, gamble, bar, terms, party and sector windows were a slab 14 px from the screen edge with a clipped corner tick. Now the card is 90 percent of the screen both ways (5 percent margin all round, the scrim shows around it), 4 px corners, no corner tick, no accent tab, and the X and the credits readout sit inside its top right. Style guide: Window, 90 x 90. */
#root .modal.ui-win:not(#settingsmodal):not(#welcomemodal){ padding:calc(5vh + 22px) calc(5vw + 22px); }
#root .modal.ui-win:not(#settingsmodal):not(#welcomemodal)::before{ inset:5vh 5vw; border-radius:4px; clip-path:none; border-color:var(--ui-line-hi); background:var(--ui-bg); }
#root .modal.ui-win:not(#settingsmodal):not(#welcomemodal) > .ui-foot > .ui-back{ top:calc(5vh + 12px); right:calc(5vw + 16px); }
body:has(.modal.ui-win.on:not(#settingsmodal):not(#welcomemodal)) #topright{ top:calc(5vh + 14px) !important; right:calc(5vw + 82px) !important; }
'@

SubRx @'
var VER='31.09';
'@ @'
var VER='31.10';
'@

$pat = "(?m)^  now:'v31\.09:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v31.10: Shop, codex, trophies and the other windows are a centred 90 percent card. Check 31.10 fails on v31.09',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
