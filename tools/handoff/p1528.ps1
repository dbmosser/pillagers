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

SubRx @'
  // is now attributable - see explodeFrag.
  G.frags.push({x:foe.x+rnd(-26,26),y:foe.y+rnd(-26,26),t:0,fuse:FRAG_FUSE,by:e});
  if(!G.sim) sfx('clank',e.x,e.y);
  return true;
'@ @'
  // is now attributable - see explodeFrag.
  // v15.28, sound audit finding: A GRENADE A PILLAGER THROWS SOUNDS WHERE IT LANDS. His charge does not fly: it appears within
  // 26 units of his target with a 1.1 second fuse, and the only sound was a quiet clank at his own hand, 242 to 520 units away,
  // the same clank a bullet makes on a wall. Nothing sounded where the charge lay until the boom. The rising charge warning,
  // the one a machine winds up with and lightning marks its strike with, now plays at the charge itself. The two scatter
  // draws are taken in the same order as before, so the seeded stream does not move, and sfx draws nothing from it.
  var _rf={x:foe.x+rnd(-26,26),y:foe.y+rnd(-26,26),t:0,fuse:FRAG_FUSE,by:e};
  G.frags.push(_rf);
  if(!G.sim){ sfx('clank',e.x,e.y); sfx('charge',_rf.x,_rf.y); }
  return true;
'@
SubRx @'
var VER='15.27';
'@ @'
var VER='15.28';
'@

$pat = "(?m)^  now:'v15\.27:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v15.28: A GRENADE A PILLAGER THROWS SOUNDS WHERE IT LANDS. A pillager Frag Charge does not fly: it appears beside you with a 1.1 second fuse, and the only sound was a quiet clank at his hand up to 520 units away, the same clank a bullet makes on a wall. The rising charge warning now plays at the charge itself, and the two scatter draws keep their order so the seeded stream does not move. Check 15.28 pins the draws, has a pillager throw from his band and requires the warning at the charge beside the clank at his hand; it fails on v15.27',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
