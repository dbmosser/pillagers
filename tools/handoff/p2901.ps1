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

# THE GATE BREACH NEEDS THE HOLD AND THE GARRISON STAYS IN THE HOUSE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function shTick(dt){
  var SS=shS(), i, k, s, p=G.player, near, alive, p2;

'@ @'
// v28.xx (cw-breachhold), HIS ORDER (2026-10-15): "Hold-to-breach door: he did not have to hold, then got slaughtered by crawlers. Breach must really need the hold,
// and the enemies in breach houses should not leave the house." The ring filled just by standing at the gate; it now fills only while the search key is HELD
// (E, or the pad search button) at the gate from outside. And once the gate is open the defenders of that building (both waves) are kept inside its walls
// (shLeash): they fight in the doorway but a body that was inside is put back inside the building, so none of them runs out across the map.
function shHeld(){ return !!(keys['KeyE']||keys['PadSearch']); }
function shLeash(s){
  var L=(s.def||[]).concat(s.def2||[]), i, e, r;
  for(i=0;i<L.length;i++){
    e=L[i]; if(!shAlive(e)) continue;
    r=Math.max(8,(e.r||12)*0.5);
    if(e.x>s.x&&e.x<s.x+s.w&&e.y>s.y&&e.y<s.y+s.h) e.shIn=1;
    else if(e.shIn){ e.x=Math.min(s.x+s.w-r,Math.max(s.x+r,e.x)); e.y=Math.min(s.y+s.h-r,Math.max(s.y+r,e.y)); }
  }
}
function shTick(dt){
  var SS=shS(), i, k, s, p=G.player, near, alive, p2;

'@

SubRx @'
      near=(!p.downed&&!p.dying&&shNear(s,p))||p2;

'@ @'
      near=(!p.downed&&!p.dying&&shNear(s,p)&&shHeld())||p2;   // v28.xx (cw-breachhold): standing there is not enough, the key is held

'@

SubRx @'
    if(s.open&&!s.clear&&(s.def.length||s.def2.length)){
'@ @'
    if(s.open&&s.kind==='b') shLeash(s);   // v28.xx (cw-breachhold): the defenders stay in the house
    if(s.open&&!s.clear&&(s.def.length||s.def2.length)){
'@

SubRx @'
    near=shNear(s,p);
    s.prog=near?Math.min(0.999
'@ @'
    near=shNear(s,p)&&shHeld();   // v28.xx (cw-breachhold): the ring fills while the key is held, and player 2 only tells the host then
    s.prog=near?Math.min(0.999
'@

SubRx @'
var VER='29.00';
'@ @'
var VER='29.01';
'@

$pat = "(?m)^  now:'v29\.00:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v29.01: Hold E at a stronghold gate to breach it, and its garrison stays in the house. Check 29.01 fails on v29.00',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
