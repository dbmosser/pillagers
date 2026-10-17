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

# AN SP FIGURE IN THE FEED IS A FIGURE AGAIN (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  if((/^\s\+\$/).test(s)) return null;
'@ @'
  // v28.xx (cw-feedsp): lean2 turned score from $ into SP, so the skip for a medal's own figure label (" +100 SP") has to read SP too, else a medal makes two feed lines.
  if((/^\s\+(\$|[\d,]+ SP$)/).test(s)) return null;
'@

SubRx @'
  if((/^\+\$[\d,]+$/).test(s)) return feedMoney(s);
'@ @'
  // v28.xx (cw-feedsp): a kill popup "+50 SP" joins the kill line again, as "+$50" did before lean2.
  if((/^\+(\$[\d,]+|[\d,]+ SP)$/).test(s)) return feedMoney(s);
'@

SubRx @'
    else if((/^[+\-]\$/).test(s)){ fk='money';
'@ @'
    /* v28.xx (cw-feedsp): a "+70 SP" pick tag is a money row, SP as well as $ */ else if((/^[+\-](\$|[\d,]+ SP$)/).test(s)){ fk='money';
'@

SubRx @'
var VER='28.80';
'@ @'
var VER='28.81';
'@

$pat = "(?m)^  now:'v28\.80:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v28.81: A medal is one line in the feed again, and a kill popup joins its kill line. Check 28.81 fails on v28.80',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
