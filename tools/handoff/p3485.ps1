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

# NO LOCK-ON SIREN IN A SUPERHOT FREEZE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    if(!_shAct&&!netAnyActing()) dt=0;
'@ @'
    var _shStill=(!_shAct&&!netAnyActing());   // v28.xx (cw-shsiren), HIS NOTE (2026-10-25, played with Superhot on): "weird noise lingering". Time holds still this frame (no input here, no teammate acting); the lock-on siren is told below
    if(_shStill) dt=0;
'@

SubRx @'
  try{ tickMachSiren(dt); }catch(_ms){}
'@ @'
  try{ tickMachSiren(dt,!!_shStill); }catch(_ms){}   /* v28.xx (cw-shsiren): and whether Superhot holds time still */
'@

SubRx @'
function tickMachSiren(dt){
  var p=G&&G.player, i, e, d, n=0, near=null, nd=1e9, a, out, v, t, k, per, lv, pl, kw=0;
  if(!G||G.sim||!p||!G.ents||G.over||G.paused||G.nuking||(G.deathBeat!==undefined&&G.deathBeat!==null)||G.goT>0||p.specOut||(typeof NET==='object'&&NET&&NET.specTick)){
'@ @'
// v28.xx (cw-shsiren), HIS NOTE (2026-10-25, played with Superhot on): "weird noise lingering". still: Superhot holds time still this frame (the loop set dt to 0:
// no input in this window and no teammate acting). The siren wailed on through the freeze: its sight stamp ages in game time, which stands still, and every frame
// pushed its fifth of a second fade on, so a low wail held over a frozen, silent world for as long as he held still (aiming with the mouse, lying downed). A still
// frame now takes the normal off path. The lock, its hold and the LOCKED ON word are kept, so the first frame time moves brings it straight back while the machine
// still has him. In two players time moves while either player acts, and it sounds on. Every other caller passes no still and is unchanged.
function tickMachSiren(dt,still){
  var p=G&&G.player, i, e, d, n=0, near=null, nd=1e9, a, out, v, t, k, per, lv, pl, kw=0;
  if(!G||G.sim||!p||!G.ents||G.over||G.paused||G.nuking||(G.deathBeat!==undefined&&G.deathBeat!==null)||G.goT>0||p.specOut||(typeof NET==='object'&&NET&&NET.specTick)||still){
'@

SubRx @'
var VER='34.84';
'@ @'
var VER='34.85';
'@

$pat = "(?m)^  now:'v34\.84:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v34.85: With Superhot on, the machine lock-on siren no longer drones on while time stands still. It fades when you stop and is back the moment time moves if the machine still has you. Watch for: the siren cutting in and out as you stop and go in Superhot while a machine has you. Check 34.85 fails on v34.84',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
