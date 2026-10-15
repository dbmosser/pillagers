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

# THE MEDALS SOUND BY TIER (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  try{ styTone(STY_SND[txt]); }catch(_sn){}
  return pts;
}
'@ @'
  try{ styTone(STY_SND[txt]); }catch(_sn){}
  try{ styTone(STY_TIER_SND[styTierOf(txt)]); }catch(_tn){}   // v27.39 (partyp2): and the voice of its tier on top
  return pts;
}
// v27.39 (partyp2), HIS ORDER (2026-10-14, the party playtest): the medals are polished like Halo's, and a Halo medal has a sound for its tier. Every medal keeps
// its own note (STY_SND, the note of its picture); on top of it the tier adds its voice: the plain medals (tier 1, copper) add nothing, the skilled ones (tier 2,
// amber) a two note shimmer high above, and the rare ones (tier 3, gold) a low thump and a rising run of six bright notes, so a rare medal is heard across the
// room and a plain one is a tick. Sound only: no score, no seeded draw.
var STY_TIER_SND=[null,null,
  [[0.05,2093,2093,0.3,'sine',0.022],[0.1,2637,2637,0.3,'sine',0.016]],
  [[0,98,49,0.5,'sine',0.1],[0.03,196,196,0.14,'triangle',0.04],[0.1,2093,2093,0.12,'triangle',0.03],[0.16,2637,2637,0.12,'triangle',0.03],[0.22,3136,3136,0.12,'triangle',0.03],[0.28,4186,4186,0.5,'sine',0.026]]];
'@

SubRx @'
var VER='27.38';
'@ @'
var VER='27.39';
'@

$pat = "(?m)^  now:'v27\.38:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v27.39: Rarer medals sound bigger: a plain tick, a high shimmer, or a low thump and a rising run. Check 27.39 fails on v27.38',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
