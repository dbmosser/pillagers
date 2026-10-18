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

# SETTINGS STEPPERS SIT NEXT TO THEIR LABELS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
#root #keysmodal #keyslist{ max-height:calc(100vh - var(--sp-5) * 6); }
'@ @'
#root #keysmodal #keyslist{ max-height:calc(100vh - var(--sp-5) * 6); }
/* v28.xx (cw-cardwide2) critic on Settings 18 after cw-cardwide (2 of 5): "the label is at x=500 and the control at x=1150 to 1400, about 650px away, keep them within 400px". Now the name column is 8 x 48 wide (384) and the stepper sits straight after it in the 960 column, so a label and its value are never more than 400px apart on the wide card. */
#root #settingsmodal #setlist .row:not(.setjump) > div:first-child{ flex:0 0 calc(var(--sp-5) * 8) !important; }
#root #settingsmodal #setlist .row:not(.setjump) > button{ margin-left:0; }
'@

SubRx @'
var VER='30.94';
'@ @'
var VER='30.95';
'@

$pat = "(?m)^  now:'v30\.94:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v30.95: Settings values sit right next to their names. Check 30.95 fails on v30.94',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
