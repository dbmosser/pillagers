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

# THE HEAL BAR IS DRAWN OVER THE WALLS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  var _pbs=[p.prep,p.prepA], _pbi;
  for(_pbi=0;_pbi<2;_pbi++) if(_pbs[_pbi]){
    var _pb=_pbs[_pbi];
    var _pf=clamp(_pb.t/_pb.max,0,1);
    var _py=p.y-68-((_pbi&&p.prep)?13:0);   // v18.75: a size bigger (was 48 by 8), with the HUD bar (drawUseBar) as well
    wc.fillStyle='rgba(6,9,13,.85)';
    wc.fillRect(p.x-32,_py,64,11);
    wc.strokeStyle='rgba(255,255,255,.22)'; wc.lineWidth=1;
    wc.strokeRect(p.x-31.5,_py+0.5,63,10);
    wc.fillStyle=_pb.kind==='armor'?'#5aa9e6':'#6fe0a0';
    wc.fillRect(p.x-31,_py+1,62*_pf,9);
  }

'@ @'
  // v28.xx (cw-headbars), HIS ORDER (2026-10-15): "player reload bar and the other bars above the head draw on top of buildings and are never
  // blocked by buildings or other raid elements". The heal and plate bar above the head was drawn here, before the depth-sorted pass, so a
  // wall in front of the player covered it. It is drawn in the world text pass (_wtA) now, after every wall (the reload bar is a HUD bar already).

'@

SubRx @'
  var _wtA=function(){

'@ @'
  var _wtA=function(){
  // v28.xx (cw-headbars): the heal and plate bars over the head, over every wall (HIS ORDER 2026-10-15: bars "never blocked by buildings")
  var _pbs=[p.prep,p.prepA], _pbi;
  for(_pbi=0;_pbi<2;_pbi++) if(_pbs[_pbi]){
    var _pb=_pbs[_pbi];
    var _pf=clamp(_pb.t/_pb.max,0,1);
    var _py=p.y-68-((_pbi&&p.prep)?13:0);   // v18.75: a size bigger (was 48 by 8), with the HUD bar (drawUseBar) as well
    wc.fillStyle='rgba(6,9,13,.85)';
    wc.fillRect(p.x-32,_py,64,11);
    wc.strokeStyle='rgba(255,255,255,.22)'; wc.lineWidth=1;
    wc.strokeRect(p.x-31.5,_py+0.5,63,10);
    wc.fillStyle=_pb.kind==='armor'?'#5aa9e6':'#6fe0a0';
    wc.fillRect(p.x-31,_py+1,62*_pf,9);
  }

'@

SubRx @'
var VER='28.95';
'@ @'
var VER='28.96';
'@

$pat = "(?m)^  now:'v28\.95:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v28.96: The heal and plate bar over your head is never hidden behind a wall. Check 28.96 fails on v28.95',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
