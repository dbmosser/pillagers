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

# A DOWNED CONTROLLER PLAYER CALLS THE EXTRACTION WITH X AGAIN (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  var _xSearch=!!(G.nearPad&&G.nearContainer&&(PAD.xSearched||PAD.xDownAt==null||(G.t-PAD.xDownAt)<0.35));
'@ @'
  var _xSearch=!!(G.nearPad&&G.nearContainer&&(PAD.xSearched||PAD.xDownAt==null||(G.t-PAD.xDownAt)<0.35));
  // v17.04, co-op hunt 2026-09-28: ON THE FLOOR X IS E. What is in reach (the ring, a box, a door) is looked up only on a standing
  // frame, so a player who went down outside a ring and crawled into it chose X from where he fell: it held R, which does nothing
  // on the floor, and never E, the key the downed screen names to call for extraction, and player 2 on one PC has no keyboard E
  // to fall back on. Downed, X never searches (a search is standing only) and holds E, the one key the floor reads (below).
  if(G.player&&G.player.downed) _xSearch=false;
'@

SubRx @'
      PAD.xWas=_xDown;
'@ @'
      if(_xDown&&G.player&&G.player.downed) PAD.xMode='KeyE';   // v17.04, co-op hunt 2026-09-28: downed, X holds E, also a hold carried onto the floor (above)
      PAD.xWas=_xDown;
'@

SubRx @'
var VER='17.03';
'@ @'
var VER='17.04';
'@

$pat = "(?m)^  now:'v17\.03:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v17.04: Downed, pad X is E: pollPad chose X on the press from G.nearPad, G.nearContainer and the other reach flags, which are only written on a standing frame, so a player who went down outside a ring and crawled in got R (nothing on the floor) and never started the 1.6 s call the downed overlay asks for; player 2 in a same machine pair has only the pad. A downed player now has the ring search grace switched off and X held on the floor holds E, including a hold carried over from before he went down. Standing play is unchanged. Check 17.04 fails on v17.03',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
