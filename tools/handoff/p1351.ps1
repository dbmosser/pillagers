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

# MY REGRESSION FROM v13.48, found by the key prompt audit of 2026-09-14. In a ring with an
# unopened box in reach, pad X held only X, so a pad player there could search and could
# not call or board. A box that refuses the search (a full backpack) never opens, so he was
# held away from the way out for as long as he stood there, under a prompt telling him X
# calls for extraction. X now searches first; if no search has started within 0.35 s of
# the press it holds E instead, and once a search starts in a hold it keeps searching.
SubRx @'
  var _xSearch=!!(G.nearPad&&G.nearContainer);
  for(var h in PADHOLD){
    var hn=+h;
    if(hn===2){ padHold(_xSearch?'KeyE':'KeyX',false); padHold(_xSearch?'KeyX':'KeyE',pressed(2)); continue; }
'@ @'
  // v13.51: AND THE WAY OUT STAYS REACHABLE. v13.48 held X for as long as a box was in
  // reach, so a box that refuses the search (a full backpack) held him away from the
  // call. X searches first; with no search started 0.35 s into the press it holds E, and a
  // search that has started in this hold keeps X until the box is done.
  // Timed on the raid clock, not the wall clock between polls, so it means the same
  // 0.35 s of play however fast the frames arrive.
  var _xDown=pressed(2);
  if(!_xDown){ PAD.xDownAt=null; PAD.xSearched=false; }
  else { if(PAD.xDownAt==null) PAD.xDownAt=G.t; if(G.searching) PAD.xSearched=true; }
  var _xSearch=!!(G.nearPad&&G.nearContainer&&(PAD.xSearched||PAD.xDownAt==null||(G.t-PAD.xDownAt)<0.35));
  for(var h in PADHOLD){
    var hn=+h;
    if(hn===2){ padHold(_xSearch?'KeyE':'KeyX',false); padHold(_xSearch?'KeyX':'KeyE',_xDown); continue; }
'@
SubRx @'
var VER='13.50';
'@ @'
var VER='13.51';
'@

$pat = "(?m)^  now:'v13\.50:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v13.51: A CONTROLLER IN A RING CAN ALWAYS CALL FOR EXTRACTION AGAIN. My regression from v13.48, found by the key prompt audit of 2026-09-14: in a ring with an unopened box in reach, pad X held only X, so a pad player could search and could not call or board, and a box that refuses the search (a full backpack) never opens and held him away from the way out. X now searches first; with no search started 0.35 s into the press it holds E, and a search that has started in this hold keeps X until the box is done. Check 13.51 fakes a pad on a ring: a searchable box is still searched, a box refused by a full backpack gives the call after the grace, and with nothing in reach X calls at once; it fails on v13.50',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
