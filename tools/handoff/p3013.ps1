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

# SETTINGS KEY-HINT LINE AND CLEAN BACKDROP (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
#root #setdetail:not(:has(.sdh)){ display:none; }
'@ @'
/* v28.xx (cw-sethint) critic c-31 round 13 (Settings 18 and 72 at 2, Pad buttons 74 at 2: "no key-hint strip anywhere, no Esc or B glyph"; "the blurred backdrop still shows ghosted menu text"). Now: Settings and Keys end in one key-hint line under the card (Esc Close on a keyboard, A Change and B Back on a pad) and their backdrop is 98 percent void so no menu text reads through. */
#root #settingsmodal::after, #root #keysmodal::after{ content:'Esc  Close'; flex:none; align-self:center; box-sizing:border-box; width:var(--cw); max-width:100%; padding-top:var(--sp-2); text-align:right; font:600 var(--fs-label)/1 var(--f-cond); letter-spacing:var(--track); color:var(--tx-2); }
body.padon #root #settingsmodal::after{ content:'LB RB  Tabs      A  Change      B  Back'; }
body.padon #root #keysmodal::after{ content:'A  Rebind      B  Back'; }
#root #settingsmodal, #root #keysmodal{ background:rgba(6,7,8,.98); -webkit-backdrop-filter:blur(14px); backdrop-filter:blur(14px); }
#root #setdetail:not(:has(.sdh)){ display:none; }
'@

SubRx @'
var VER='30.12';
'@ @'
var VER='30.13';
'@

$pat = "(?m)^  now:'v30\.12:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v30.13: Settings and Keys show a key hint under the card and a cleaner backdrop. Check 30.13 fails on v30.12',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
