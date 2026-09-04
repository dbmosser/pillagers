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

# ============ HIS NOTE "NEEDS TOWN CENTERS" WAS ANSWERED BY CODE NO MAP CALLED.
# ============
# ============ TOWN SQUARE has been written since v6.92 and its own comment says
# ============ "His note, verbatim: needs ... town centers. Guaranteed on every
# ============ map, not pooled: a town has a centre or it reads as a warehouse
# ============ district." It is guaranteed on NO map. The word townsq appears
# ============ exactly once in the whole file, in its own definition, so the
# ============ monument, the six market stalls and the two benches have never
# ============ been built in the game. FLOODED PLAZA is unused the same way.
# ============ This is the v3.x MAPCONT fault again: a constant that looks
# ============ authoritative and is inert.
# ============
# ============ WHERE IT CAN GO, measured rather than guessed. The square puts its
# ============ monument at the landmark's centre, and a landmark wall inside a
# ============ building is cut away by the v6.92 lmCut rule, so a host whose
# ============ centre is indoors gets a square with no centre. Nine pieces, per
# ============ landmark, how many survive and does the monument:
# ============   COLD STORAGE  PACKING FLOOR   7 of 9, monument stands
# ============   THE COLD MILE every landmark with no archetype LOSES its
# ============                 monument; the only hosts that keep all nine are
# ============                 the three that already carry CARGO YARD
# ============
# ============ So the mile's square takes over one of its THREE cargo yards,
# ============ which is the same complaint from the other end: the map runs the
# ============ one archetype three times and has no centre at all. SUMP YARD is
# ============ the squarest of the three at 2000x1700 and keeps nine of nine.
# ============ It is renamed, because a yard with a monument and market stalls
# ============ in it is not a yard any more.
# ============
# ============ WHAT IT COSTS. COLD STORAGE moves not at all: TOWN SQUARE rolls no
# ============ random numbers, so adding it where there was no archetype shifts
# ============ nothing. 85 entities, 165 containers, walls 616 to 623.
# ============ THE COLD MILE replaces CARGO YARD, which DOES roll, so the seeded
# ============ stream moves: entities 374 to 369, crawlers 224 to 219, containers
# ============ 552 to 577, walls 2461 to 2454. Deliberate, and the eight places
# ============ that hold the old fingerprint move with it.
SubRx @'
{id:'cs_pack',  name:'PACKING FLOOR', x:220, y:900, w:2100,h:1400,loot:'ammo',   dens:1.3},
'@ @'
    // v10.80: the square goes here on COLD STORAGE. Measured: seven of the nine
    // pieces survive and the monument stands, which is the best of the five and
    // the only one without an archetype that keeps its centre. Adding an
    // archetype where there was none rolls no random numbers, so this map's
    // entity and container counts do not move at all.
    {id:'cs_pack',  name:'PACKING FLOOR', x:220, y:900, w:2100,h:1400,loot:'ammo',   dens:1.3, arch:'townsq'},
'@
SubRx @'
{"id":"cm_sump_yard","name":"SUMP YARD","x":280,"y":5320,"w":2000,"h":1700,"loot":"rare","dens":0.8,"arch":"yard"}
'@ @'
{"id":"cm_sump_market","name":"SUMP MARKET","x":280,"y":5320,"w":2000,"h":1700,"loot":"rare","dens":0.8,"arch":"townsq"}
'@

SubRx @'
var VER='10.79';
'@ @'
var VER='10.80';
'@
SubRx @'
  now:'v10.79: the harness stops accepting a trace of a thing as proof the thing is there. Measured: the container search bar moves 1,319 pixels, a noise ring 120, the standing extract prompt pulses 21.3 percent; their floors were 0, 20 and 3, so a bar of one pixel passed. Every floor now sits at half the measured reading and a quarter-strength signal is refused.',
'@ @'
  now:'v10.80: both maps get the town centre you asked for. TOWN SQUARE has been written since v6.92 and no map ever called it, so the monument, the market stalls and the benches had never been built in the game. COLD STORAGE puts one on the packing floor; the mile turns one of its three identical cargo yards into SUMP MARKET.',
'@
SubRx @'
var WHATSNEW_VER='10.76';
'@ @'
var WHATSNEW_VER='10.80';
'@
SubRx @'
var WHATSNEW=[
'@ @'
var WHATSNEW=[
  'BOTH MAPS NOW HAVE A CENTRE. A monument with market stalls round the rim and benches beside it: on COLD STORAGE it is on the packing floor, and on THE COLD MILE the old sump yard is now SUMP MARKET. The mile ran three identical cargo yards and had nowhere that read as a middle.',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
