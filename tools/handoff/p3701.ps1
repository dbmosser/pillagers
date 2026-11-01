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

# THE ANSWER LINE KEEPS THE NEWEST PRESS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  var s=String(m), now=statusNow(), A=G.ans, seen=(G.ansSeen=G.ansSeen||{}), last=seen[s];
'@ @'
  var s=String(m), now=statusNow(), A=G.ans, seen=(G.ansSeen=G.ansSeen||{}), last=seen[s], prev=G.ansPrev;   // v36.xx (cw-ansgap), job 208: prev is the text said just before this one
  G.ansPrev=s;
'@

SubRx @'
  if(last!==undefined&&now-last<ANSGAP) return A;                 // the key is still held: it does not come back
'@ @'
  if(last!==undefined&&now-last<ANSGAP&&prev===s) return A;      // the key is still held: it does not come back. v36.xx (cw-ansgap): only when nothing else was said in between, so on, off, on within 0.35 s leaves on
'@

SubRx @'
var VER='37.00';
'@ @'
var VER='37.01';
'@

$pat = "(?m)^  now:'v37\.00:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v37.01: Quick presses of a key that flips a state always leave the answer line on the state just set. A held key still does not repeat the line. Check 37.01 fails on v37.00',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
