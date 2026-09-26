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

# THE IMPORTED FRIEND REMEMBERS WHAT YOU DID TO HIM. v13.93 keyed the imported friend's body as ghost_<tag> so the ledger writes
# for killing, reviving or shooting him land on his own record, and the game says he will remember that; but applyGhost never read
# that record back. It set him friendly with no grudge every raid and left e.standing as mkRaider rolled it from the body's own
# identity. Three lines in applyGhost: his record is read the way mkRaider reads a pillager's.
SubRx @'
    e.ident='ghost_'+String(P.ghost.tag).slice(0,24); e.rival=0;
    e.hostile=false; e.friendlyPC=1; e.grudge=false;
'@ @'
    e.ident='ghost_'+String(P.ghost.tag).slice(0,24); e.rival=0;
    // v15.98, ghost audit finding: THE IMPORTED FRIEND REMEMBERS WHAT YOU DID TO HIM. The three ledger writers (the death path,
    // the revive and the friendly-shot flip) key on e.ident, so since v13.93 they land on this ghost_ record, and the game says
    // he will remember that; but nothing ever read the record back. The line below used to set him friendly with no grudge
    // every raid, and e.standing stayed as mkRaider rolled it from the BODY's own identity, so a friend you killed walked up
    // again with the FRIENDLY plate and nodded at you or watched you by a stranger's standing. His record is now read the way
    // mkRaider reads a pillager's: a kill on it makes him hostile with a grudge, shoot on sight the way a parleyed man you
    // killed is, and his own standing drives the nods at you line; with no kill he is friendly as before. idRec draws nothing
    // from the seeded stream and applyGhost bails on G.sim, so the map fingerprint is untouched. No number moved.
    var _gr=idRec(e.ident); e.standing=_gr.standing||0;
    if(_gr.kills>0){ e.hostile=true; e.grudge=true; e.friendlyPC=0; }
    else { e.hostile=false; e.friendlyPC=1; e.grudge=false; }
'@
SubRx @'
var VER='15.97';
'@ @'
var VER='15.98';
'@

$pat = "(?m)^  now:'v15\.97:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v15.98: THE IMPORTED FRIEND REMEMBERS WHAT YOU DID TO HIM. Killing the friend imported from a run report wrote a kill on his own record and the game said he will remember that, but every raid after built him friendly again with the FRIENDLY plate, and his nod or his watching came from the standing of the pillager whose body he took. His own record is now read when the raid is built: a kill on it makes him hostile with a grudge, and his standing is his own, while with no kill he is friendly as before. Check 15.98 stages his record at one kill, at a revive with no kill, and at nothing, and builds a raid on each; it fails on v15.97',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
