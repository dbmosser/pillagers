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

# CONTRACTS, NOTORIETY AND WAVES AUDIT OF 2026-09-14, finding 2: KILLING AN IMPORTED GHOST PUT A PERMANENT
# GRUDGE ON A PILLAGER NAME THE PLAYER NEVER SAW. applyGhost turns the first ordinary pillager into the
# ghost and renames him, but kept his identity. Every ledger write keys on the identity: killing the
# ghost wrote a kill on that pillager's record, so from the next raid that man spawned hostile, refused
# parley and could never be hired, and reviving or shooting the ghost moved his standing. Because only
# the name changed, a wave could also bring in a second man with that identity. The ghost now carries
# an identity of its own, outside the list spawns and the hire screen read, and none of the rival flag
# the old identity may have brought with it.
SubRx @'
    e.name=P.ghost.tag;
    e.ghost=1;
'@ @'
    e.name=P.ghost.tag;
    e.ghost=1;
    // v13.93, contracts audit: the ghost's own identity, keyed outside IDENTITIES, so the ledger writes
    // for killing, reviving or shooting him land on him and not on the pillager whose body he took.
    e.ident='ghost_'+String(P.ghost.tag).slice(0,24); e.rival=0;
'@
SubRx @'
var VER='13.92';
'@ @'
var VER='13.93';
'@

$pat = "(?m)^  now:'v13\.92:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v13.93: KILLING A GHOST DOES NOT BLAME A STRANGER. Contracts, notoriety and waves audit of 2026-09-14, finding 2: applyGhost renamed the first ordinary pillager into the imported ghost but kept his identity, so killing the ghost wrote a kill on that pillager record, which spawned him hostile, refused parley and barred his hire from the next raid on. The ghost now takes an identity of its own outside IDENTITIES and drops the old rival flag. Check 13.93 kills the ghost and requires no identity in IDENTITIES to gain a kill, with an ordinary pillager killed the same way recording one as the control; it fails on v13.92',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
