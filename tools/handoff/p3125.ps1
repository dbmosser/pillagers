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

# CAREER TOP RIGHT IN ONE ROW (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  #topright small:nth-last-child(2){ margin-right:0; }   /* v28.xx (cw-stashbag): the STASH and BAG line is the last child now */
'@ @'
  #topright small:nth-last-child(2){ margin-right:22px; }   /* v28.xx (cw-trrow), HIS ANSWER Q58 (2026-10-18): career top right goes into one row. The XP label is followed by the stash and bag figures on the same line now. */
'@

SubRx @'
  #topright .trsub{ position:absolute; right:0; top:40px; line-height:16px; font-size:15px; font-weight:700; letter-spacing:.1em; color:var(--ash); }
'@ @'
  #topright .trsub{ position:static; display:inline; line-height:inherit; font-size:16px; font-weight:700; letter-spacing:.1em; color:var(--ash); }   /* v28.xx (cw-trrow): was a second line hanging under the readout (absolute, top 40px); now inline in the one row */
'@

SubRx @'
var VER='31.24';
'@ @'
var VER='31.25';
'@

$pat = "(?m)^  now:'v31\.24:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v31.25: In career the top right corner is one row: credits, XP, stash and bag side by side. Check 31.25 fails on v31.24',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
