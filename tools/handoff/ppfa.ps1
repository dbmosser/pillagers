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

# GUNS COST TWICE AS MUCH TO CRAFT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  {name:'Compact SMG',out:{gun_smg:1},need:{comp:4,cell:3,board:2,servo:1}},
  {name:'Burst Carbine',out:{gun_carbine:1},need:{comp:4,servo:2,board:2}},
  {name:'Auto Rifle',out:{gun_rifle:1},need:{comp:5,servo:2,board:3,optic:1}},
  {name:'Riot Scattergun',out:{gun_shotgun:1},need:{comp:5,cell:4,board:2,servo:2}}

'@ @'
  // v28.xx (cw-guncraft), HIS ORDER (2026-10-15): "guns more expensive to craft". Every gun recipe below costs exactly twice what it did
  // (SMG was comp4 cell3 board2 servo1, Carbine comp4 servo2 board2, Rifle comp5 servo2 board3 optic1, Scattergun comp5 cell4 board2 servo2).
  // The other recipes above are untouched.
  {name:'Compact SMG',out:{gun_smg:1},need:{comp:8,cell:6,board:4,servo:2}},
  {name:'Burst Carbine',out:{gun_carbine:1},need:{comp:8,servo:4,board:4}},
  {name:'Auto Rifle',out:{gun_rifle:1},need:{comp:10,servo:4,board:6,optic:2}},
  {name:'Riot Scattergun',out:{gun_shotgun:1},need:{comp:10,cell:8,board:4,servo:4}}

'@

SubRx @'
var VER='28.82';
'@ @'
var VER='28.83';
'@

$pat = "(?m)^  now:'v28\.82:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v28.83: The four guns on the crafting bench now cost twice the parts they did. Other recipes are unchanged. Check 28.83 fails on v28.82',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
