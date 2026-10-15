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

# THE CAMERA ZOOMS OUT WHEN YOU SPRINT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function adsZf(){
'@ @'
var SPRINT_ZK=0.93;   // v27.xx (sprintzoom), HIS ANSWER 43 (2026-10-13): the camera zooms out "a little" while you sprint, as a setting, ON by default; the same ease as the scope (G.adsZ)
function adsZf(){
'@

SubRx @'
):1, d=Math.max(0,Math.min(0.1,+dt||0));
'@ @'
):((CFG.sprintZoom!==0&&G.sprinting&&!G.sim&&!G.over&&!p.downed)?SPRINT_ZK:1), d=Math.max(0,Math.min(0.1,+dt||0));
'@

SubRx @'
  {k:'gam', label:'BRIGHTNESS', sec:'DISPLAY',
'@ @'
  // v27.xx (sprintzoom), HIS ANSWER 43 (2026-10-13): SPRINT ZOOM-OUT, in DISPLAY. The camera pulls back about seven percent while you sprint (a little more
  // street shows), easing in and out with the sprint, the way the scope eases. ON is the default; OFF holds the camera still. The view only: nothing a
  // fight reads moves.
  {k:'sprintZoom', label:'SPRINT ZOOM-OUT', sec:'DISPLAY',
   hint:'The camera pulls back a little while you sprint, so you see more of the street.',
   opts:[
     {n:'OFF', cfg:{sprintZoom:0}},
     {n:'ON',  cfg:{sprintZoom:1}}
   ], def:1},
  {k:'gam', label:'BRIGHTNESS', sec:'DISPLAY',
'@

SubRx @'
var VER='28.23';
'@ @'
var VER='28.24';
'@

$pat = "(?m)^  now:'v28\.23:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v28.24: The camera now pulls back a little while you sprint. Settings has a SPRINT ZOOM-OUT row in DISPLAY. Check 28.24 fails on v28.23',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
