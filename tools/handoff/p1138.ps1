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

# THE MELEE SWING HIT YOUR OWN MERC. The fists sweep excluded downed and
# finished entities but not the man you hired; the bullet path has excluded him
# since v6.72 ("a hired companion takes no friendly fire from you"). So a punch
# thrown near your merc damaged him, and the killing blow set byPlayer and
# billed you. Same exclusion as the round.
SubRx @'
        var _me=G.ents[_mi];
        if(_me.downed||_me.finished) continue;
        if(dist(sh,_me)>wep.rng+_me.r) continue;
'@ @'
        var _me=G.ents[_mi];
        if(_me.downed||_me.finished) continue;
        if(_me.merc&&!_me.downed) continue;   // v11.38: your fists pass through your hire, like your rounds (v6.72)
        if(dist(sh,_me)>wep.rng+_me.r) continue;
'@

# STAMPS.
SubRx @'
var VER='11.37';
'@ @'
var VER='11.38';
'@
SubRx @'
var WHATSNEW_VER='11.37';
'@ @'
var WHATSNEW_VER='11.38';
'@
SubRx @'
  'A ROBOT HITTING A PILLAGER NO LONGER TURNS HIM ON YOU. A pillager who was leaving you alone would go hostile the instant a sentry or a crawler hit him, as if you had done it, and a pillager you had won over would hold a grudge for it forever. Only your own shots, charges and strikes provoke now.',
'@ @'
  'YOUR PUNCH NO LONGER HITS YOUR OWN MERC. A melee swing near the man you hired used to hurt him and, on the killing blow, bill you for it. Your fists pass through him now, the same as your bullets always have.',
  'A ROBOT HITTING A PILLAGER NO LONGER TURNS HIM ON YOU. A pillager who was leaving you alone would go hostile the instant a sentry or a crawler hit him, as if you had done it, and a pillager you had won over would hold a grudge for it forever. Only your own shots, charges and strikes provoke now.',
'@
SubRx @'
  now:'v11.37: the peaceful-flip and the friendlyPC grudge read e.hitT, which every damage source writes (crawler bite, frag, Howler splash, cross-fire), so a machine hitting a peaceful pillager flipped him onto YOU and a man you had revived took a -3 standing saved to disk, from a hit you never landed. A player-attribution timer pHitT is set only at the three player hit sites (your bullet, your charge, your strike) and the two branches read it. Dial provokeReal 1 shipped, 0 restores the old hitT. Bug fix, not a dial move; the paired sim size is in the entry.',
'@ @'
  now:'v11.38: the melee swing hit your own merc. The fists sweep excluded downed and finished entities but not the man you hired, while the bullet path has passed through him since v6.72; so a punch near your merc hurt him and a killing blow billed you. One line, the same merc exclusion the round uses. Reproduced: a swing next to a merc dropped his health. From the combat agent.',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
