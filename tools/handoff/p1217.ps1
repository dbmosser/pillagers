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

# FIRST TEN MINUTES AUDIT, 2026-09-06: with an EMPTY throwable cell selected
# (cells 3 to 5 on every first raid) the trigger was dead: startCook found
# nothing, or worse, cycled to a DIFFERENT grenade you happened to carry and
# cooked that one while the belt and the corner readout still named the cell
# you chose. v2.92's own rule is that the trigger is never dead: spending the
# last of a stack selects the gun. An empty cell now does the same on the
# press, and the next click fires the gun.
SubRx @'
    if(HSC&&HSC.kind==='throw'){
      if(!p.cooking){ if(!p.fired){ p.fired=true; startCook(); } }
      else {
'@ @'
    if(HSC&&HSC.kind==='throw'){
      // v12.17: AN EMPTY THROWABLE CELL DOES NOT OWN THE TRIGGER. Selected empty
      // (cells 3 to 5 on a first raid), the press started nothing and said
      // nothing, or cooked a different grenade than the cell named. By v2.92's
      // own rule the press selects the gun; the next click fires it, never this
      // one, which is the automatic-weapon safety that rule was written for.
      if(!p.cooking&&!p.fired&&!((HSC.count|0)>0)){
        p.fired=true; setHot(0); p.trigYield=1;   // the gun fires on the NEXT click, never on the hold that yielded
        if(!G.sim) say('Nothing in that cell. '+((p.wep&&p.wep.name)||'Your gun')+' up.');
      }
      else if(!p.cooking){ if(!p.fired){ p.fired=true; startCook(); } }
      else {
'@

SubRx @'
  else if(mouse.down&&p.reloading<=0&&p.jam<=0&&now-p.lastShot>p.wep.rof){
'@ @'
  else if(mouse.down&&!p.trigYield&&p.reloading<=0&&p.jam<=0&&now-p.lastShot>p.wep.rof){   // v12.17: not on the hold that yielded to the gun
'@
SubRx @'
  if(!mouse.down){
    // Let go of a cooked grenade and it goes. Done before p.fired clears so a
'@ @'
  if(!mouse.down){
    p.trigYield=0;   // v12.17: the latch lives for one hold
    // Let go of a cooked grenade and it goes. Done before p.fired clears so a
'@

# STAMPS.
SubRx @'
var VER='12.16';
'@ @'
var VER='12.17';
'@
SubRx @'
var WHATSNEW_VER='12.16';
'@ @'
var WHATSNEW_VER='12.17';
'@
SubRx @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
'@ @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
  'THE TRIGGER IS NEVER DEAD ON AN EMPTY GRENADE CELL: the press brings your gun up and says so, and it never throws a grenade the cell did not name.',
'@
$cnt=([regex]::Matches($s,"now:'v12\.16:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v12.16 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v12\.16:[^']*'",{ param($m) "now:'v12.17: from the 2026-09-06 first-ten-minutes audit, an empty throwable cell selected on the belt left the trigger dead, or cooked a different grenade than the cell named. The press selects the gun and says so; the next click fires it. Check 12.17 selects an empty Frag cell with Smoke in the pouch, presses the trigger through the real player update, and requires the gun selected, nothing cooking and the Smoke untouched; fails on v12.16.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
