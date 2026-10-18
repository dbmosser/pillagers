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

# TITLE: ROOM AROUND THE LINE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
#root #title #titletag{ margin-top:var(--sp-3); font:700 var(--fs-title)/1.1 var(--f-cond); letter-spacing:var(--track); color:var(--tx-1); }
'@ @'
#root #title #titletag{ margin:24px 0 16px; font:700 var(--fs-title)/1.1 var(--f-cond); letter-spacing:var(--track); color:var(--tx-1); }   /* v28.xx (cw-title-gap): the one line had 12px above it and sat on the fullscreen row; 24px above, 16px below the key row. */
'@

SubRx @'
<div id="titletag" style="max-width:760px;margin:0 auto">
'@ @'
<div id="titletag" style="max-width:760px">
'@

SubRx @'
var VER='30.42';
'@ @'
var VER='30.43';
'@

$pat = "(?m)^  now:'v30\.42:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v30.43: The title line has more room around it. Check 30.43 fails on v30.42',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
