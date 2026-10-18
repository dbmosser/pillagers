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

# WINDOWS CLOSE WITH AN X IN THE CORNER (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
body:has(#settingsmodal.on) #hubtoast, body:has(#keysmodal.on) #hubtoast{ visibility:hidden; }
'@ @'
body:has(#settingsmodal.on) #hubtoast, body:has(#keysmodal.on) #hubtoast{ visibility:hidden; }
/* v28.xx (cw-closex), his Q43 (2026-10-18): windows are "a centred card with an X in the corner". Settings, Keys and the pause card had the X; the shop, codex, trophies, fashion, mainframe, gamble, bar, terms, party and the stash still ended in a CLOSE button at the bottom right. Now each one's CLOSE is the same 48 px X at the top right of the frame (the same button, so B, Esc and the controller still find it by its word); a footer that held only CLOSE shrinks to nothing, and the credits readout steps left of the X. Style guide: one close place, the corner. */
#root .modal.ui-win:not(#settingsmodal):not(#welcomemodal) > .ui-foot > .ui-back, #root #hub #stashclose{ position:absolute; top:22px; right:22px; bottom:auto; z-index:5; width:var(--sp-5); height:var(--sp-5); min-width:0 !important; min-height:0 !important; padding:0 !important; margin:0 !important; font-size:0 !important; line-height:1; display:flex; align-items:center; justify-content:center; background:transparent; border-color:var(--ui-line-hi); }
#root #hub #stashclose{ top:8px; }
#root .modal.ui-win:not(#settingsmodal):not(#welcomemodal) > .ui-foot > .ui-back::after, #root #hub #stashclose::after{ content:''; --xc:var(--tx-2); width:var(--sp-3); height:var(--sp-3); background:linear-gradient(45deg, transparent 44%, var(--xc) 44% 56%, transparent 56%), linear-gradient(-45deg, transparent 44%, var(--xc) 44% 56%, transparent 56%); }
#root .modal.ui-win:not(#settingsmodal):not(#welcomemodal) > .ui-foot > .ui-back:hover::after, #root .modal.ui-win:not(#settingsmodal):not(#welcomemodal) > .ui-foot > .ui-back:focus-visible::after, #root #hub #stashclose:hover::after, #root #hub #stashclose:focus-visible::after{ --xc:var(--tx-1); }
#root .modal.ui-win:not(#settingsmodal):not(#welcomemodal) > .ui-foot:not(:has(> button:not(.ui-back):not([style*="display: none"]):not([style*="display:none"]))){ border-top:0; padding:0; height:0; min-height:0; }
body:has(.modal.ui-win.on:not(#settingsmodal):not(#welcomemodal)) #topright, body:has(#hub.on) #topright{ right:90px !important; }
'@

SubRx @'
var VER='31.01';
'@ @'
var VER='31.02';
'@

$pat = "(?m)^  now:'v31\.01:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v31.02: Every window closes with the same X at its top right corner. Check 31.02 fails on v31.01',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
