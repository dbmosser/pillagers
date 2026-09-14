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

# 2026-09-13 AUDIT ITEM 4: A CONTROLLER CANNOT SEARCH INSIDE AN EXTRACTION POINT. Since
# v13.10 the keyboard searches a body lying in a ring with X, because E there calls the
# dropship. The pad X button holds E, no pad button reaches X, and the prompt reads
# [X] SEARCH, so a pad player standing on the way out could not search what was at his
# feet. In a ring with something to search in reach, pad X now holds X; everywhere else
# it holds E exactly as before.
SubRx @'
  for(var h in PADHOLD){
    var hn=+h;
    // dpad down browses the bag rather than using medical while it is open
    padHold(PADHOLD[h], pressed(hn)&&!(bagNav&&hn===13));
  }
'@ @'
  // v13.48, audit item 4: X SEARCHES IN AN EXTRACTION POINT ON A PAD TOO. In a ring E is
  // the way out and only X searches, and the pad X button held E, so the [X] SEARCH
  // prompt named a button that called the dropship. With something to search in reach
  // inside a ring, pad X holds X; the other key is let go so a switch mid-hold is clean.
  var _xSearch=!!(G.nearPad&&G.nearContainer);
  for(var h in PADHOLD){
    var hn=+h;
    if(hn===2){ padHold(_xSearch?'KeyE':'KeyX',false); padHold(_xSearch?'KeyX':'KeyE',pressed(2)); continue; }
    // dpad down browses the bag rather than using medical while it is open
    padHold(PADHOLD[h], pressed(hn)&&!(bagNav&&hn===13));
  }
'@
SubRx @'
var VER='13.47';
'@ @'
var VER='13.48';
'@

$pat = "(?m)^  now:'v13\.47:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v13.48: A CONTROLLER CAN SEARCH INSIDE AN EXTRACTION POINT. Audit item 4 of 2026-09-13: since v13.10 the keyboard searches a body in a ring with X, because E there calls the dropship, but the pad X button held E and no pad button reached X, while the prompt read [X] SEARCH. With something to search in reach inside a ring, pad X now holds X; everywhere else it holds E as before. Check 13.48 fakes a pad on a ring with a box at his feet and requires X to search it, and with the box moved off requires X to hold E again; it fails on v13.47',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
