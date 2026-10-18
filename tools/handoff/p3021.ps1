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

# SETTINGS SECTION LABELS ARE BARE ANCHORS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
#root #setlist .setjump + .row[style*="opacity:.7"]{ display:none; }
'@ @'
#root #setlist .setjump + .row[style*="opacity:.7"]{ display:none; }
/* v28.xx (cw-setsechd) critic c-31 (Settings 72 at 3, P1): "the section label Display is 13px dim grey and repeats the active tab". The label row stays in the list as the jump anchor but shows no text: a 16px gap between groups. */
#root #setlist .row[style*="opacity:.7"]{ height:0 !important; min-height:0 !important; padding:0 !important; margin:var(--sp-2) 0 0 !important; border:0 !important; overflow:hidden; }
'@

SubRx @'
var VER='30.20';
'@ @'
var VER='30.21';
'@

$pat = "(?m)^  now:'v30\.20:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v30.21: Settings section labels hidden, 16px gap between groups. Check 30.21 fails on v30.20',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
