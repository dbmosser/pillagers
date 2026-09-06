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
      // v12.12: AN EMPTY THROWABLE CELL DOES NOT OWN THE TRIGGER. Selected empty
      // (cells 3 to 5 on a first raid), the press started nothing and said
      // nothing, or cooked a different grenade than the cell named. By v2.92's
      // own rule the press selects the gun; the next click fires it, never this
      // one, which is the automatic-weapon safety that rule was written for.
      if(!p.cooking&&!p.fired&&!((HSC.count|0)>0)){
        p.fired=true; setHot(0);
        if(!G.sim) say('Nothing in that cell. '+((p.wep&&p.wep.name)||'Your gun')+' up.');
      }
      else if(!p.cooking){ if(!p.fired){ p.fired=true; startCook(); } }
      else {
'@

# STAMPS.
SubRx @'
var VER='12.11';
'@ @'
var VER='12.12';
'@
SubRx @'
var WHATSNEW_VER='12.11';
'@ @'
var WHATSNEW_VER='12.12';
'@
SubRx @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
'@ @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
  'THE TRIGGER IS NEVER DEAD ON AN EMPTY GRENADE CELL: the press brings your gun up and says so, and it never throws a grenade the cell did not name.',
'@
$cnt=([regex]::Matches($s,"now:'v12\.11:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v12.11 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v12\.11:[^']*'",{ param($m) "now:'v12.12: from the 2026-09-06 first-ten-minutes audit, an empty throwable cell selected on the belt left the trigger dead, or cooked a different grenade than the cell named. The press selects the gun and says so; the next click fires it. Check 12.12 selects an empty Frag cell with Smoke in the pouch, presses the trigger through the real player update, and requires the gun selected, nothing cooking and the Smoke untouched; fails on v12.11.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
