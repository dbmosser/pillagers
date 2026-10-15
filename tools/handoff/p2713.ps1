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

# DAMAGE NUMBERS ARE A SETTING (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  {k:'showFps', label:'SHOW FPS', sec:'DISPLAY',
   hint:'THE FRAMES EACH SECOND, SMALL, IN THE TOP LEFT CORNER.',
   opts:[
     {n:'OFF', cfg:{showFps:0}},
     {n:'ON',  cfg:{showFps:1}}
   ], def:0},
'@ @'
  {k:'showFps', label:'SHOW FPS', sec:'DISPLAY',
   hint:'THE FRAMES EACH SECOND, SMALL, IN THE TOP LEFT CORNER.',
   opts:[
     {n:'OFF', cfg:{showFps:0}},
     {n:'ON',  cfg:{showFps:1}}
   ], def:0},
  // v27.xx (dmgnums), HIS ANSWER 33 (2026-10-13): the damage numbers "become a setting, on by default". They have floated off every hit since
  // v8.35 under a hidden dial (CFG.dmgNumbers, 1 unless 0: yours on a target, the red ones over you for your teammate, the shock arcs); the row
  // is that dial. ON is today and the default, OFF takes every one of them off the screen. Cosmetic only: the damage is not touched.
  {k:'dmgNumbers', label:'DAMAGE NUMBERS', sec:'DISPLAY',
   hint:'THE NUMBERS THAT FLOAT OFF A TARGET WHEN YOU HIT IT, AND OFF YOU WHEN YOU ARE HIT.',
   opts:[
     {n:'OFF', cfg:{dmgNumbers:0}},
     {n:'ON',  cfg:{dmgNumbers:1}}
   ], def:1},
'@

SubRx @'
var VER='27.12';
'@ @'
var VER='27.13';
'@

$pat = "(?m)^  now:'v27\.12:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v27.13: Settings has a DAMAGE NUMBERS row in DISPLAY, ON by default. Turn it off to hide the numbers. Check 27.13 fails on v27.12',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
