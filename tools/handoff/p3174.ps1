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

# CORNER READOUT ONE QUIET LABEL STYLE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  #topright .trsub{ position:static; display:inline; line-height:inherit; font-size:16px; font-weight:700; letter-spacing:.1em; color:var(--ash); }   /* v28.xx (cw-trrow): was a second line hanging under the readout (absolute, top 40px); now inline in the one row */
'@ @'
  #topright .trsub{ position:static; display:inline; line-height:inherit; font-size:16px; font-weight:700; letter-spacing:.1em; color:var(--ash); }   /* v28.xx (cw-trrow): was a second line hanging under the readout (absolute, top 40px); now inline in the one row */
  /* v28.xx (cw-uc-tr) b-31 step 7, critic on 04, 14, 65, 08 (P1 "four different treatments in the header readout"): credits and xp are the numbers (24px, bright); the labels credits, xp and the stash and bag figures are one quiet style, 16px, second text colour, 0.04em tracking (was 0.12em and 0.1em, 400 and 700), 24px between pairs. */
  #topright small, #topright .trsub{ font-size:16px; font-weight:600; letter-spacing:.04em; color:var(--tx-2); }
  #topright small{ margin-left:8px; margin-right:24px; }
  #topright small:nth-last-child(2){ margin-right:24px; }
'@

SubRx @'
var VER='31.73';
'@ @'
var VER='31.74';
'@

$pat = "(?m)^  now:'v31\.73:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v31.74: The corner readout labels match. Check 31.74 fails on v31.73',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
