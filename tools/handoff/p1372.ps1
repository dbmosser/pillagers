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

# HIRE AND PEDDLER AUDIT OF 2026-09-14, finding 4, a fault in my own v13.49: ON A CONTROLLER, X
# CLOSED THE STALL AND IT OPENED AGAIN ON THE NEXT FRAME. The stall branch closes on the X press
# and releases E. On the next frame the stall is shut, so the ordinary pad path runs, finds X
# still held, holds E for it, and updatePlayer opens the stall again: the Peddler is in reach,
# E is down and the lock was cleared on the frame E was up. X never walked away; only walking
# 74 units off did. The press that closes the stall is now spent until X is let go.
SubRx @'
    if(pressed(2)&&!PAD.prev[2]){ raidKey('KeyE',false,null); keys['KeyE']=false; G.pedSel=0; }
'@ @'
    if(pressed(2)&&!PAD.prev[2]){ raidKey('KeyE',false,null); keys['KeyE']=false; G.pedSel=0; PAD.xAfterTrade=1; }
'@
SubRx @'
  var _xDown=pressed(2);
'@ @'
  var _xDown=pressed(2);
  // v13.72, hire and peddler audit: the X that walked away from the stall is spent until it is
  // let go. Still held on the next frame, it held E here and the stall opened again.
  if(PAD.xAfterTrade){ if(_xDown) _xDown=false; else PAD.xAfterTrade=0; }
'@
SubRx @'
var VER='13.71';
'@ @'
var VER='13.72';
'@

$pat = "(?m)^  now:'v13\.71:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v13.72: X WALKS AWAY FROM THE STALL AND STAYS AWAY. Hire and peddler audit of 2026-09-14, finding 4, a fault in v13.49: on a controller X closed the stall and released E, but on the next frame the ordinary pad path found X still held, held E for it, and updatePlayer opened the stall again, so X never walked away. The X press that closes the stall is now spent until it is let go. Check 13.72 holds X on a fake pad through three real frames beside the Peddler and requires the stall shut on every one, with the keyboard E opening it as the control; it fails on v13.71',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
