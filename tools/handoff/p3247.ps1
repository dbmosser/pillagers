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

# Rewards fill the card, bar rows bigger (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
#root #barmodal .row button:not(:disabled):not(:hover):not(:focus){ background:transparent; color:#e6ff3d; border:1px solid #e6ff3d; }
'@ @'
#root #barmodal .row button:not(:disabled):not(:hover):not(:focus){ background:transparent; color:#e6ff3d; border:1px solid #e6ff3d; }
/* v28.xx (cw-uc-rewbar2) b-31 step 7, critic on 13 (list stops 285px short of the card edge) and 16 (a 1060x185 list in a 1700 card, 20px names, 15px blurbs): rewards fill the card width; bar content 1400 wide with 120px rows, 72px icons, 28px names, 18px blurbs, 32px prices, 200x56 buttons. */
#root #opane_rew{ max-width:none !important; }
#root #barmodal .msub, #root #barmodal .plist{ max-width:1400px !important; width:100%; }
#root #barmodal .plist .row{ min-height:120px !important; }
#root #barmodal .row img{ width:72px !important; height:72px !important; }
#root #barmodal .plist .row b{ font-size:28px !important; }
#root #barmodal .row .hint{ font-size:18px; }
#root #barmodal .plist .row .vl{ font-size:32px !important; font-family:var(--f-cond,inherit); font-weight:800; }
#root #barmodal button[data-bz]{ min-width:200px !important; min-height:56px !important; font-size:20px !important; }
'@

SubRx @'
var VER='32.46';
'@ @'
var VER='32.47';
'@

$pat = "(?m)^  now:'v32\.46:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v32.47: The rewards list runs the full card width; the last pour rows and buttons are bigger. Check 32.47 fails on v32.46',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
