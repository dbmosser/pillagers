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

# GRAPHICS SETTINGS ROWS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
     {n:'Reduced', cfg:{fxLevel:0}}
   ], def:0},
'@ @'
     {n:'Reduced', cfg:{fxLevel:0}}
   ], def:0},
  // v23.xx (gfx3), HIS ORDER (2026-10-12) on the graphics program: "add ALL of this stuff". The four graphics rows the upgrade
  // reads, placed beside Effects. New words are short caps, as he asked for game text. Undefined means the default, as for
  // wallBake and fxLevel: readers test CFG.gfxLight!==0 and so on. Each row starts to change the picture as its own build lands;
  // CLASSIC with POST FX OFF is the look of v23.58 exactly, the rollback and the A/B arm.
  {k:'gfxLight', label:'LIGHTING',
   hint:'HIGH: LAMPS CAST SHADOWS. STANDARD: LAMPS, NO SHADOWS. CLASSIC: THE ORIGINAL LOOK.',
   opts:[
     {n:'HIGH',     cfg:{gfxLight:2}},
     {n:'STANDARD', cfg:{gfxLight:1}},
     {n:'CLASSIC',  cfg:{gfxLight:0}}
   ], def:0},
  {k:'gfxPost', label:'POST FX',
   hint:'BLOOM AND COLOUR GRADE. OFF RUNS FASTER.',
   opts:[
     {n:'ON',  cfg:{gfxPost:1}},
     {n:'OFF', cfg:{gfxPost:0}}
   ], def:0},
  {k:'fxInt', label:'EFFECT INTENSITY',
   hint:'SHAKE, HIT PAUSE, HIT FLASH, BLOOM AND GRAIN.',
   opts:[
     {n:'FULL', cfg:{fxInt:1}},
     {n:'HALF', cfg:{fxInt:0.5}},
     {n:'OFF',  cfg:{fxInt:0}}
   ], def:0},
  {k:'hudTv', label:'HUD SIZE',
   hint:'LARGE FOR TV: BIGGER RAID TEXT FOR A SCREEN ACROSS THE ROOM.',
   opts:[
     {n:'STANDARD',     cfg:{hudTv:0}},
     {n:'LARGE FOR TV', cfg:{hudTv:1}}
   ], def:0},
'@

SubRx @'
var VER='23.82';
'@ @'
var VER='23.83';
'@

$pat = "(?m)^  now:'v23\.82:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v23.83: Settings has four new graphics rows: LIGHTING, POST FX, EFFECT INTENSITY and HUD SIZE. Check 23.83 fails on v23.82',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
