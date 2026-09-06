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

# HIS ORDER, 2026-09-06: "add some decent green and blue guns to crafting, make
# them moderately expensive to craft". This reverses half of his 2026-08-29
# rule, which took gun recipes out and left guns to the Peddler and the surface
# (confirmed true at v9.84): blue is back on the bench, green with it; purple
# and gold stay where he put them. Four recipes, two of each colour, the guns
# a new player would actually want. Each obeys the rule the table records:
# inputs worth MORE than the gun sells for, so nothing prints money, and LESS
# than buying it, so nothing is a trap. Compact SMG 1300 in parts against 900
# sold; Burst Carbine 1400 against 1100; Auto Rifle 1900 against 1500; Riot
# Scattergun 1800 against 1300. No contract item is used as an input.
SubRx @'
  {name:'Frag Charge',out:{frag:1},need:{comp:2,cell:2,scrap:2}}
];
'@ @'
  {name:'Frag Charge',out:{frag:1},need:{comp:2,cell:2,scrap:2}},
  // v11.79, HIS ORDER: green and blue guns on the bench, moderately expensive.
  // Reverses the 2026-08-29 rule for these two colours only; purple and gold
  // are still the Peddler and the surface. Parts worth more than the gun sells
  // for and less than buying it, the same window every recipe above sits in.
  {name:'Compact SMG',out:{gun_smg:1},need:{comp:4,cell:3,board:2,servo:1}},
  {name:'Burst Carbine',out:{gun_carbine:1},need:{comp:4,servo:2,board:2}},
  {name:'Auto Rifle',out:{gun_rifle:1},need:{comp:5,servo:2,board:3,optic:1}},
  {name:'Riot Scattergun',out:{gun_shotgun:1},need:{comp:5,cell:4,board:2,servo:2}}
];
'@

# STAMPS.
SubRx @'
var VER='11.78';
'@ @'
var VER='11.79';
'@
SubRx @'
var WHATSNEW_VER='11.78';
'@ @'
var WHATSNEW_VER='11.79';
'@
SubRx @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
'@ @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
  'FOUR GUNS ON THE CRAFTING BENCH: the Compact SMG and Burst Carbine in green, the Auto Rifle and Riot Scattergun in blue. Moderately expensive in parts. Purple and gold guns are still the Peddler and the surface.',
'@
$cnt=([regex]::Matches($s,"now:'v11\.78:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v11.78 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v11\.78:[^']*'",{ param($m) "now:'v11.79: HIS ORDER of 2026-09-06, decent green and blue guns on the crafting bench, moderately expensive. Reverses his 2026-08-29 rule for those two colours only. Four recipes: Compact SMG and Burst Carbine (green), Auto Rifle and Riot Scattergun (blue), each with parts worth more than the gun sells for and less than buying it, no contract items as inputs. Check 11.79 requires exactly those four gun recipes with those rarities, the price window on each, and drives the real craft row with the parts in the stash and requires the gun in the stash and the parts gone.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
