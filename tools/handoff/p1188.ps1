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

# HIS NOTE, 2026-09-06 (his 06:39 export, run 5, @293s): "when Fulgerite is
# searched, it should only return the item 'Fulgerite', which should be like
# $2500 salvagable -- it makes no sense for it to be anything else, given that
# it resulted from a lightning strike." A new item, and the scorched cache
# holds only that. The two draws from the seeded stream are kept exactly as
# they were, because this block runs in the sim and a draw removed here would
# move every number after it.
SubRx @'
  wcore:{name:'Warden Core',val:3800,wt:5,r:'elite',c:'#ffc04a'},
'@ @'
  wcore:{name:'Warden Core',val:3800,wt:5,r:'elite',c:'#ffc04a'},
  // v11.88, HIS NOTE: what a lightning strike leaves in the ground, and the only
  // thing the scorched cache holds. Salvage, worth what he said.
  fulgurite:{name:'Fulgurite',val:2500,wt:2,r:'elite',c:'#e6d3ff'},
'@
SubRx @'
        var pool=['titan','core','blackbox','reactor','wcore'];
        var key=pool[Math.min(pool.length-1,Math.floor(rr()*pool.length))];
'@ @'
        // v11.88, HIS NOTE: the strike leaves Fulgurite and nothing else; a
        // Warden Core in the dirt made no sense to him. The draw is kept so the
        // seeded stream is unchanged.
        var _fdraw=rr();
        var key='fulgurite';
'@

# Built through setLoot, so the cache's glow knows what it holds (mkContainer
# stamped best from the roll it threw away).
SubRx @'
          ct.loot=[key]; ct.tag='FULGURITE'; ct.time=1.0; ct.cache=1;
'@ @'
          setLoot(ct,[key]); ct.tag='FULGURITE'; ct.time=1.0; ct.cache=1;   // v11.88: setLoot, so best is right
'@

# STAMPS.
SubRx @'
var VER='11.87';
'@ @'
var VER='11.88';
'@
SubRx @'
var WHATSNEW_VER='11.87';
'@ @'
var WHATSNEW_VER='11.88';
'@
SubRx @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
'@ @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
  'A LIGHTNING STRIKE THAT MISSES YOU SOMETIMES FUSES THE GROUND. What it leaves is FULGURITE, worth 2,500, and nothing else.',
'@
$cnt=([regex]::Matches($s,"now:'v11\.87:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v11.87 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v11\.87:[^']*'",{ param($m) "now:'v11.88: HIS NOTE of 2026-09-06, the scorched cache a strike leaves should hold only Fulgurite, worth about 2500 salvage. New item fulgurite (val 2500, elite); the strike cache holds it and nothing else; the seeded draws are kept so the stream is unchanged. Check 11.88 forces a strike to miss and leave a cache and requires its loot to be exactly one Fulgurite worth 2500; fails on v11.87 where the cache holds a core or a Warden Core.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
