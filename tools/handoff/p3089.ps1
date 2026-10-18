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

# SETTINGS AND KEYS FILL THE SCREEN AS A CARD (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
#root #settingsmodal #settabs{ top:calc(var(--py) + var(--sp-1)); }
'@ @'
#root #settingsmodal #settabs{ top:calc(var(--py) + var(--sp-1)); }
/* v28.xx (cw-cardwide), his Q43 (2026-10-18): windows are "a centred card with an X in the corner that takes up NEARLY THE WHOLE screen". The earlier critic rounds (cw-setnear2, cw-setheight) shrank Settings and Keys to 720 x 720; his word is later and wins (Q7). Now the card is the screen less 48 px each side and top and bottom, the frame sits 24 px outside that, the X stays in the card corner, and the rows keep one 960 wide column in the middle so a label never sits far from its stepper. */
#root #settingsmodal, #root #keysmodal{ --cw:calc(100% - var(--sp-5) * 2); --py:var(--sp-5); }
#root #settingsmodal .tpane, #root #settingsmodal #setwrap{ max-width:calc(var(--sp-5) * 20); margin-left:auto; margin-right:auto; width:100%; box-sizing:border-box; }
#root #keysmodal #keyslist, #root #keysmodal #keysnote, #root #keysmodal .msub{ max-width:calc(var(--sp-5) * 20); margin-left:auto; margin-right:auto; width:100%; box-sizing:border-box; }
#root #keysmodal #keyslist{ max-height:calc(100vh - var(--sp-5) * 6); }
'@

SubRx @'
var VER='30.88';
'@ @'
var VER='30.89';
'@

$pat = "(?m)^  now:'v30\.88:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v30.89: Settings and Keys now fill nearly the whole screen as one card with the X in the corner. Check 30.89 fails on v30.88',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
