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

# SETTINGS TABS ONE ROW (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
body:has(#settingsmodal.on) #hubtoast, body:has(#keysmodal.on) #hubtoast{ bottom:auto; top:var(--sp-5); }
'@ @'
body:has(#settingsmodal.on) #hubtoast, body:has(#keysmodal.on) #hubtoast{ bottom:auto; top:var(--sp-5); }

/* v28.xx (cw-settab1) critic c-31 (Settings 2): "the tab strip is two rows, Send play data sits alone on a second line and the underline sits mid-header". Now the section strip is one row: no wrap, 16px between labels, no side padding, so all seven fit in the card. */
#root #setlist .setjump .sj{ flex-wrap:nowrap; gap:var(--sp-2); }
#root #setlist .setjump button{ padding:0; white-space:nowrap; flex:0 0 auto; }
'@

SubRx @'
var VER='29.76';
'@ @'
var VER='29.77';
'@

$pat = "(?m)^  now:'v29\.76:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v29.77: The Settings section tabs sit on one row. Check 29.77 fails on v29.76',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
