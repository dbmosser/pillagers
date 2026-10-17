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

# HARD ENEMIES DROP BETTER LOOT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  for(i=0;i<n;i++){ k=rollLoot(LOOT.safe); if(k) out.push(k); }
  return out;
}

'@ @'
  for(i=0;i<n;i++){ k=rollLoot(LOOT.safe); if(k) out.push(k); }
  out=out.concat(hardBonus(e));   // v28.xx (cw-hardloot): an elite pillager pays more again
  return out;
}
// v28.xx (cw-hardloot), HIS ORDER (2026-10-15): "Hard enemies drop better loot." A hard enemy is an elite of any kind, or a sentry, bulwark or
// howler. It always leaves a wreck (machines used to leave one 55 percent of the time) and adds one roll on a better table: the cache table
// for an elite, the safe table for a hard machine. Never a gun, since guns are meant to be rare. Rolled at the death, so the build is unchanged.
var HARD_M={sentry:1,bulwark:1,howler:1};
function isHard(e){ return !!(e&&!e.merc&&!e.friendlyPC&&(e.elite||HARD_M[e.kind])); }
function noGunRoll(t){ var k, j; for(j=0;j<8;j++){ k=rollLoot(t); if(k&&String(k).indexOf('gun_')!==0) return k; } return null; }
function hardBonus(e){
  var out=[], k;
  if(!isHard(e)||!LOOT||!LOOT.cache||!LOOT.safe) return out;
  k=noGunRoll(e.elite?LOOT.cache:LOOT.safe); if(k) out.push(k);
  if(e.elite&&e.kind!=='raider'&&HARD_M[e.kind]){ k=noGunRoll(LOOT.safe); if(k) out.push(k); }
  return out;
}
'@

SubRx @'
} else if(e.kind!=='snitch'&&rr()<.55){
'@ @'
} else if(e.kind!=='snitch'&&(rr()<.55||(e.kind!=='raider'&&isHard(e)))){   // v28.xx (cw-hardloot): a hard machine always leaves its wreck
'@

SubRx @'
setLoot(c2,mdrop);
'@ @'
setLoot(c2,mdrop.concat(e.kind==='raider'?[]:hardBonus(e)));   // v28.xx (cw-hardloot): and a better roll on top
'@

SubRx @'
var VER='28.88';
'@ @'
var VER='28.89';
'@

$pat = "(?m)^  now:'v28\.88:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v28.89: Elite pillagers and machines, sentries, bulwarks and howlers now drop better loot, and always leave a wreck. Check 28.89 fails on v28.88',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
