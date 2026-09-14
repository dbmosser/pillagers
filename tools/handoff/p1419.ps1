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
  for(var b2=0;b2<bt.length;b2++) if(PAD.prev[b2]===undefined) PAD.prev[b2]=pressed(b2);
'@ @'
  // v14.19, controller audit finding 1: EVERY BUTTON'S LAST STATE IS RECORDED EVERY RAID FRAME. This line only filled in
  // buttons never seen, so A, X, Y and the stick clicks kept whatever the Undercroft, a menu or the stall last recorded,
  // and the stall compares against exactly that. The first X at the peddler after coming up opened the stall through the
  // X hold and read the same X as a fresh press on the next frame, shutting it again; and A held into the stall read as a
  // press of the marked row, which starts on SELL BACKPACK. A raid frame now records them all, so a press means a press.
  for(var b2=0;b2<bt.length;b2++) PAD.prev[b2]=pressed(b2);
'@
SubRx @'
var VER='14.18';
'@ @'
var VER='14.19';
'@

$pat = "(?m)^  now:'v14\.18:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v14.19: THE STALL READS REAL PRESSES ON A PAD. A raid frame recorded the last state only of the buttons it had never seen, so A and X kept the value the Undercroft or the stall left, and the stall compared against it: the first X at the peddler opened the stall and shut it on the next frame, and A held into the stall read as a press of SELL BACKPACK. Every button is now recorded every raid frame. Check 14.19 holds X, then A, from raid frames into an open stall with a faked pad; it fails on v14.18',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
