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

# PAUSE BOX BUTTONS SHARE ONE LOOK (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
#root #pausebox > div:has(> #resumebtn) > #fbbtn, #root #pausebox > div:has(> #resumebtn) > #wnbtn{ color:var(--tx-1); }
'@ @'
#root #pausebox > div:has(> #resumebtn) > #fbbtn, #root #pausebox > div:has(> #resumebtn) > #wnbtn{ color:var(--tx-1); }
/* v28.xx (cw-pausebtn) critic on Pause box 25/42/49 (3): "five button styles", "report a problem gets as much emphasis as settings", "the abandon link has no hit area", "small button labels about 14px". Now: report a problem, settings, feedback and what is new share one 48px outline look, the small pair reads at 16px, and abandon is a 48px quiet red link with room above it. Q61 keeps all of them. */
#root #pausebox > div:has(> #resumebtn) > #fbbtn, #root #pausebox > div:has(> #resumebtn) > #wnbtn{ min-height:var(--btn-h-sm); font-size:var(--fs-label); background:var(--ui-panel); border-color:var(--ui-line-hi); }
#root #pausebox:not(.asking) > div:has(> #resumebtn) > #abandonbtn, #root #pausebox:not(.asking) > div:has(> #resumebtn) > #arcendbtn, #root #pausebox:not(.asking) > div:has(> #resumebtn) > #charselbtn{ min-height:var(--btn-h-sm); margin-top:var(--sp-3); }
'@

SubRx @'
var VER='32.07';
'@ @'
var VER='32.08';
'@

$pat = "(?m)^  now:'v32\.07:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v32.08: The pause box buttons are 48px high and the abandon link has room. Check 32.08 fails on v32.07',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
