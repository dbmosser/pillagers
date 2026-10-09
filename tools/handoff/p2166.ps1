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

# THE SINGLE SHOT GUNS HIT HARDER (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var WTIER={
'@ @'
// v21.66, HIS NOTE (2026-10-09): "the shotgun and any single shot gun like the whisper, meridian lance etc need to deal more damage to be
// competitive against the automatics like the auto rifle and smg". Sustained damage with reloads was about 107 a second for the Auto
// Rifle and 85 to 99 for the SMG and the Support MG, against 45 to 70 for the single shots and 24 for the Whisper. Per shot now: Scav
// Pistol 23, Tacker 20, Scuttle 12 a pellet, Magnum 62, Marksman Rifle 64, Longshot 170, Meridian Lance 150, Riot Scattergun 16 a pellet,
// Whisper 24 and a shot every 0.40 s. The single shots land about 70 to 110 a second sustained; they still trade the magazine for reach and
// the hit that ends a fight. The Burst Carbine (three a pull, about 85) is unchanged.
var WTIER={
'@

SubRx @'
  pistol:{id:'pistol',name:'Scav Pistol',dmg:19,rof:290,spread:.055,mag:12,reload:1400,rng:420,auto:false,noise:330,tint:'#ffd48a'},
'@ @'
  pistol:{id:'pistol',name:'Scav Pistol',dmg:23,rof:290,spread:.055,mag:12,reload:1400,rng:420,auto:false,noise:330,tint:'#ffd48a'},
'@

SubRx @'
  tacker:{id:'tacker',name:'Tacker',dmg:17,rof:240,spread:.048,mag:14,reload:1300,rng:400,auto:false,noise:320,tint:'#ffd9a8',starter:1},
'@ @'
  tacker:{id:'tacker',name:'Tacker',dmg:20,rof:240,spread:.048,mag:14,reload:1300,rng:400,auto:false,noise:320,tint:'#ffd9a8',starter:1},
'@

SubRx @'
  scuttle:{id:'scuttle',name:'Scuttle',dmg:9,pellets:5,rof:780,spread:.200,mag:6,reload:2200,rng:210,auto:false,noise:470,tint:'#ffc98a',starter:1},
'@ @'
  scuttle:{id:'scuttle',name:'Scuttle',dmg:12,pellets:5,rof:780,spread:.200,mag:6,reload:2200,rng:210,auto:false,noise:470,tint:'#ffc98a',starter:1},
'@

SubRx @'
  magnum:{id:'magnum',name:'Magnum',dmg:46,rof:620,spread:.042,mag:6,reload:1900,rng:480,auto:false,noise:520,tint:'#ffb870'},
'@ @'
  magnum:{id:'magnum',name:'Magnum',dmg:62,rof:620,spread:.042,mag:6,reload:1900,rng:480,auto:false,noise:520,tint:'#ffb870'},
'@

SubRx @'
  dmr:{optic:1.9,id:'dmr',name:'Marksman Rifle',dmg:48,rof:680,spread:.016,mag:8,reload:2300,rng:760,auto:false,noise:520,tint:'#fff0c0'},
'@ @'
  dmr:{optic:1.9,id:'dmr',name:'Marksman Rifle',dmg:64,rof:680,spread:.016,mag:8,reload:2300,rng:760,auto:false,noise:520,tint:'#fff0c0'},
'@

SubRx @'
  sniper:{optic:2.4,id:'sniper',name:'Longshot',dmg:115,rof:1600,spread:.006,mag:5,reload:3200,rng:900,auto:false,noise:640,tint:'#e8f0ff'},
'@ @'
  sniper:{optic:2.4,id:'sniper',name:'Longshot',dmg:170,rof:1600,spread:.006,mag:5,reload:3200,rng:900,auto:false,noise:640,tint:'#e8f0ff'},
'@

SubRx @'
  lance:{optic:1.6,id:'lance',name:'Meridian Lance',dmg:96,rof:60,spread:.010,mag:3,reload:4000,rng:820,auto:false,noise:620,tint:'#d8b4ff'}
'@ @'
  lance:{optic:1.6,id:'lance',name:'Meridian Lance',dmg:150,rof:60,spread:.010,mag:3,reload:4000,rng:820,auto:false,noise:620,tint:'#d8b4ff'}
'@

SubRx @'
  shotgun:{id:'shotgun',name:'Riot Scattergun',dmg:12,pellets:6,rof:650,spread:.170,mag:7,reload:2400,rng:260,auto:false,noise:500,tint:'#ffbe7a'},
'@ @'
  shotgun:{id:'shotgun',name:'Riot Scattergun',dmg:16,pellets:6,rof:650,spread:.170,mag:7,reload:2400,rng:260,auto:false,noise:500,tint:'#ffbe7a'},
'@

SubRx @'
  whisper:{optic:1.1,id:'whisper',name:'Whisper',dmg:14,rof:520,spread:.048,mag:30,reload:2100,rng:430,auto:true,noise:90,tint:'#a8d8c0'},
'@ @'
  whisper:{optic:1.1,id:'whisper',name:'Whisper',dmg:24,rof:400,spread:.048,mag:30,reload:2100,rng:430,auto:true,noise:90,tint:'#a8d8c0'},
'@

SubRx @'
var VER='21.65';
'@ @'
var VER='21.66';
'@

$pat = "(?m)^  now:'v21\.65:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v21.66: Shotguns and single shot guns (Whisper, Meridian Lance, Longshot, Magnum, Marksman) hit harder. Check 21.66 fails on v21.65',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
