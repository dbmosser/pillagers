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

# THE TEAMMATE ROWS STAY ON THE LEFT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  if(HUDBOX.raiders) _tt=Math.max(_tt,Math.round(HUDBOX.raiders.y+HUDBOX.raiders.h+16*_thr));
'@ @'
  // v19.47, from the review (2026-10-08): the rows followed the board down wherever it had been dragged, so a board moved to the right
  // or low put the teammate rows under the controls list or off the screen. They keep their own place at 30 percent and only step
  // below the board when it sits over that place in their left column, and then never past the bottom of the screen.
  var _trb=HUDBOX.raiders, _tun=0, _trh, _tj;
  try{ for(_tj=0;_tj<(NET.up||[]).length;_tj++) if(netUpShown(NET.up[_tj])) _tun++; }catch(_tu){}
  _trh=Math.max(1,_tun)*Math.round(44*_thr);
  if(_trb&&_trb.x<170*_thr&&_trb.x+_trb.w>12*_thr&&_trb.y<_tt+_trh+8*_thr&&_trb.y+_trb.h>_tt-8*_thr){
    _tt=Math.round(_trb.y+_trb.h+16*_thr);
    if(_tt+_trh>H-8*_thr) _tt=Math.max(0,Math.round(H-8*_thr-_trh));
  }
'@

SubRx @'
var VER='19.46';
'@ @'
var VER='19.47';
'@

$pat = "(?m)^  now:'v19\.46:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v19.47: Your teammate rows stay readable at the left wherever you drag the board. Check 19.47 fails on v19.46',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
