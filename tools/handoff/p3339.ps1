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

# CORNER BLOCK: CASH LABEL, WIDER GAP (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
cw=(g.bw-28)/2, cx=g.x+8+(i&1)*(cw+12);
'@ @'
cw=(g.bw-36)/2, cx=g.x+8+(i&1)*(cw+20);   // v33.xx (cw-cornercompact2): 20 between the two columns, so a figure never touches the next label
'@

SubRx @'
trRow(i++,'','$'+TRV.c);
'@ @'
trRow(i++,'cash','$'+TRV.c); /* v33.xx (cw-cornercompact2): the critic found the money figure with no label read as part of the xp pair; a short word names it */
'@

SubRx @'
var VER='33.38';
'@ @'
var VER='33.39';
'@

$pat = "(?m)^  now:'v33\.38:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v33.39: The corner block names the money figure cash and spaces its two columns wider. Check 33.39 fails on v33.38',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
