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

# CONTRACTS, NOTORIETY AND WAVES AUDIT OF 2026-09-14, finding 1: YOUR HIRE'S IDENTITY ALSO SPAWNED AS AN
# ENEMY, AND KILLING THAT STRANGER BANNED YOUR HIRE FOREVER. The opening roster draws its names from a
# shuffle of all the identities with no look at who he hired, and the hire is built from the same
# identity. About half of raids put a second man with his hire's name on the map. The ledger keeps
# one record per identity, so killing the stranger wrote a kill against the hire: he spawned hostile
# from then on and the hire screen refused him for good. The hired identity now goes to the back of
# the shuffle, past every name the roster uses (only a raid of 28 or more pillagers reaches it), and
# no seeded draw moves.
SubRx @'
  var idPool=IDENTITIES.slice();
  for(var ip=idPool.length-1;ip>0;ip--){ var jp=ri(0,ip),tp=idPool[ip]; idPool[ip]=idPool[jp]; idPool[jp]=tp; }
'@ @'
  var idPool=IDENTITIES.slice();
  for(var ip=idPool.length-1;ip>0;ip--){ var jp=ri(0,ip),tp=idPool[ip]; idPool[ip]=idPool[jp]; idPool[jp]=tp; }
  // v13.92, contracts audit: the man he hired is not also a stranger on the map. His identity goes to
  // the back of the pool, after the draws above, so the seeded stream is untouched.
  if(!sim&&P&&P.merc){ for(var _mi=0;_mi<idPool.length;_mi++) if(idPool[_mi].id===P.merc){ idPool.push(idPool.splice(_mi,1)[0]); break; } }
'@
SubRx @'
var VER='13.91';
'@ @'
var VER='13.92';
'@

$pat = "(?m)^  now:'v13\.91:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v13.92: YOUR HIRE IS NOT ALSO A STRANGER ON THE MAP. Contracts, notoriety and waves audit of 2026-09-14, finding 1: the opening roster drew names from a shuffle of every identity with no look at the hire, who is built from the same identity, so about half of raids put a second man with his name on the map, and killing that stranger wrote a kill on the one ledger record, turning the hire hostile and refused for good. The hired identity now goes to the back of the shuffled pool after the draws. Check 13.92 deploys sixteen seeds with a hire and requires no stranger carrying his identity, with the same seeds and no hire showing that identity as a stranger as the control; it fails on v13.91',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
