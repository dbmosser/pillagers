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

# THE RACKS PAGE LINES UP (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  #opane_mf{ max-width:1080px; width:100%; margin:0 auto; }
'@ @'
  #opane_mf{ max-width:1080px; width:100%; margin:0 auto; }
  /* v20.97, from the 4K visual pass of 2026-10-08 (V-C3): THE RACKS PAGE STARTS ON ONE LEFT EDGE. The line at the top began at the
     page edge, the row of rack boxes and the three buttons a step in, and the cost lines under the buttons a second step in, so
     the page read as three ragged columns. The rack row and the buttons lose their inset (in the page below) and the cost lines
     lose theirs here, so everything starts where the top line starts. */
  #opane_mf .hint{ padding-left:0; padding-right:0; }
'@

SubRx @'
<div id="mfstatus" style="padding:6px 12px;font-size:14px"></div>
  <div style="padding:0 12px 8px">
'@ @'
<div id="mfstatus" style="padding:6px 0;font-size:14px"></div>
  <div style="padding:0 0 8px">
'@

SubRx @'
var VER='20.96';
'@ @'
var VER='20.97';
'@

$pat = "(?m)^  now:'v20\.96:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v20.97: The RACKS page at the Mainframe now lines up on one left edge. Check 20.97 fails on v20.96',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
