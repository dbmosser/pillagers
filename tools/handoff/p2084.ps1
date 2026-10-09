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

# THE HOT GROUND STARTS AWAY FROM YOU (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  var hotZone={x:clamp(_hz.x,620,WORLD_W-620),y:clamp(_hz.y,620,WORLD_H-620),r:620,at:0,moves:0};
'@ @'
  var hotZone={x:clamp(_hz.x,620,WORLD_W-620),y:clamp(_hz.y,620,WORLD_H-620),r:620,at:0,moves:0};
  // v20.84, from the whole-game bug hunt of 2026-10-08 (H63): THE HOT GROUND STARTS AWAY FROM THE DROP POINT, as the note above
  // promises. Nothing measured it, so about one raid in eleven on COLD STORAGE landed you inside the disc: every box paid the
  // bonus from the first second and there was no choice to go or to avoid. A centre nearer than 920 (the disc and 300 more) is
  // chosen again on its own side stream, the first of up to 40 tries that is far enough, else the farthest. The draw above is
  // kept and the side stream is put back after, so the seeded map build does not move.
  if(dist(hotZone,start)<620+300) sideStream(seed,6,function(){
    var _hb=null, _hbd=-1, _hq, _hc, _ht;
    for(_ht=0;_ht<40&&_hbd<620+300;_ht++){
      _hq=freeSpot(map,60); _hc={x:clamp(_hq.x,620,WORLD_W-620),y:clamp(_hq.y,620,WORLD_H-620)};
      if(dist(_hc,start)>_hbd){ _hbd=dist(_hc,start); _hb=_hc; }
    }
    if(_hb&&_hbd>dist(hotZone,start)){ hotZone.x=_hb.x; hotZone.y=_hb.y; }
  });
'@

SubRx @'
var VER='20.83';
'@ @'
var VER='20.84';
'@

$pat = "(?m)^  now:'v20\.83:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v20.84: The hot ground no longer starts on top of your drop point. Check 20.84 fails on v20.83',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
