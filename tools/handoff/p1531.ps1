$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

SubRx @'
  if(!_xDown){ PAD.xDownAt=null; PAD.xSearched=false; }
  else { if(PAD.xDownAt==null) PAD.xDownAt=G.t; if(G.searching) PAD.xSearched=true; }
'@ @'
  if(!_xDown){ PAD.xDownAt=null; PAD.xSearched=false; }
  // v15.31, extraction audit finding: A HELD X ON A CONTROLLER SEARCHES ONE BOX, THEN CALLS OR EXTRACTS. The latch that keeps X
  // on a search was only cleared by letting go, so when the box was done the same hold went on to search the next box in reach,
  // and the next, and held E only when none was left: two wrecks at his feet after a siege put two seconds of searching in front
  // of the call or the 1.4 s hold while the window closed, and a backpack that filled part way through held X on the refusal for
  // as long as he held the button. A search that has ended in this hold now spends the latch and the grace, so the same hold
  // turns to E, the key the keyboard calls with; letting go and pressing again still searches the next box first (v13.51).
  else { if(PAD.xDownAt==null) PAD.xDownAt=G.t; if(G.searching) PAD.xSearched=true; else if(PAD.xSearched){ PAD.xSearched=false; PAD.xDownAt=-1e9; } }
'@
SubRx @'
var VER='15.30';
'@ @'
var VER='15.31';
'@

$pat = "(?m)^  now:'v15\.30:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v15.31: A HELD X ON A CONTROLLER SEARCHES ONE BOX, THEN CALLS OR EXTRACTS. Holding X in an extraction point searched the box in reach and then every other box in reach before it called or extracted, so two wrecks at his feet after a siege cost two seconds of the window. The same hold now turns to the call or the extraction once one box is done, and a fresh press still searches the next. Check 15.31 holds X over two wrecks in a landed ring; it fails on v15.30',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
