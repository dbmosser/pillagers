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

# THE USE BAR CLEARS THE COUNTDOWN PLATE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
y=Math.min(y,Math.round(by-(LH(48)+LH(34))*Math.max(1,hudRes())-h));
'@ @'
y=Math.min(y,Math.round(by-(LH(48)+LH(34)+LH(34))*Math.max(1,hudRes())-h));   /* v28.xx (cw-useplate): the inbound banner stands on a plate 38 px above its line since v32.35 and v32.36, 14 px higher since v32.58, so the use bar went another 34 px up and now ends 8 px under that plate, not across the countdown */
'@

SubRx @'
var VER='32.84';
'@ @'
var VER='32.85';
'@

$pat = "(?m)^  now:'v32\.84:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v32.85: While extraction is inbound the use bar stands above the countdown plate, not across it. Check 32.85 fails on v32.84',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
