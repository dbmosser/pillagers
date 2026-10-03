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

# THE RAID CONTROLS LEGEND: COLUMNS APART, AND OUT OF THE WAY AFTER THREE RAIDS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    var COLW=LH(88),MROW=LH(10),MW=COLW*2+LH(24),MH=MROW*6+LH(16);
'@ @'
    var COLW=LH(112),MROW=LH(10),MW=COLW*2+LH(24),MH=MROW*6+LH(16);   // v17.76: wide enough for TACTICAL BELT beside its key
'@

SubRx @'
      ctx.fillText(MN[mi][1],cx0+LH(46),cy0);
'@ @'
      ctx.fillText(MN[mi][1],cx0+LH(44),cy0);
'@

SubRx @'
  legendOn:1,sprinting:false,     // v6.68, his note: always open on arrival. H cycles it.
'@ @'
  legendOn:(((typeof P!=='undefined'&&P&&P.runs)||0)>=3)?0:1,sprinting:false,     // v6.68, his note: always open on arrival. H cycles it. v17.76: after three raids it starts collapsed
'@

SubRx @'
var VER='17.75';
'@ @'
var VER='17.76';
'@

$pat = "(?m)^  now:'v17\.75:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v17.76: The raid controls legend no longer overlaps itself, and after your first three raids it starts collapsed (H opens it). Check 17.76 fails on v17.75',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
