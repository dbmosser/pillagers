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

# PAUSE SCRIM AND KEYS INTRO (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
#root #setdetail .sdh{ font-size:var(--fs-body); line-height:1.5; }
'@ @'
#root #setdetail .sdh{ font-size:var(--fs-body); line-height:1.5; }   /* v28.xx (cw-pausescrim) critic c-31 (pause 2, keys 2): the HUD showed through the pause card, and the Keys window opened with an explaining sentence above the list */ #root #pausebox{ background:color-mix(in srgb,var(--ui-void) 97%,transparent); } #root #keysmodal .msub{ display:none; }
'@

SubRx @'
var VER='29.41';
'@ @'
var VER='29.42';
'@

$pat = "(?m)^  now:'v29\.41:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v29.42: The pause screen covers the HUD behind it, and the Keys window opens straight on the list. Check 29.42 fails on v29.41',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
