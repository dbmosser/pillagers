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

# HIS TELEMETRY, three runs: heals 0, downs 2, every single time. He carries
# medical, he goes down twice a raid, and he never applies one.
#
# I CHECKED THE OBVIOUS CAUSES FIRST AND BOTH ARE REFUTED. The freebie kit does
# issue two Bandages, so he is not going up empty; and the tactical belt builds
# its medical cell from the backpack automatically, so the item is on the belt
# under a key whether or not anything was dragged. Nothing is broken. He simply
# does not use it, and nothing has ever told him so.
#
# HIS OWN PRIORITY LINE ASKS FOR EXACTLY THIS: "deeper coaching to follow if the
# telemetry does not move". It has not moved. And the card's own v3.08 note says
# the number worth putting in front of him at the moment of death is the one that
# is the difference between an epitaph and feedback.
#
# ONE CLAUSE, ONLY WHEN IT IS TRUE, AND IT IS A FACT ABOUT HIS OWN RUN. It says
# nothing when he healed, and nothing when he had nothing to heal with.
SubRx @'
      closestExtract:1e9,deathKiller:null,deathDistExtract:null,
'@ @'
      closestExtract:1e9,deathKiller:null,deathDistExtract:null,diedWithMed:0,
'@

SubRx @'
  G.tel.deathKiller=p.pendKiller||src||'other';
'@ @'
  G.tel.deathKiller=p.pendKiller||src||'other';
  // v13.15: died carrying medical he never applied. Read HERE, at the moment of
  // death, because the backpack is emptied on the way to the card and a scan
  // done there would always come back with nothing.
  if(!(G.tel.heals>0)){
    for(var _dm=0;_dm<G.bag.length;_dm++){
      var _dmi=ITEMS[G.bag[_dm]];
      if(_dmi&&_dmi.use==='heal'){ G.tel.diedWithMed=1; break; }
    }
  }
'@

# ANCHORED ON THE COMMENT BELOW, not on the NEVER SPOTTED line above it, because
# that line carries a real middot character and a .ps1 on this machine is read as
# ANSI. The separator is written as a JS escape here for the same reason.
SubRx @'
    // THE FEED. Newest last so it reads forward in time, which is how he will
'@ @'
    // v13.15, from his telemetry: three runs, two knock-downs each, medical
    // carried every time and applied zero times. The belt cell for it is built
    // automatically and the freebie kit issues two Bandages, so nothing was
    // stopping him; nothing had ever said so either. Only when it is true.
    if(T.diedWithMed)
      s.textContent+='   \u00b7   YOU DIED CARRYING MEDICAL YOU NEVER USED';
    // THE FEED. Newest last so it reads forward in time, which is how he will
'@

SubRx @'
    shots:T.shots,hits:T.hits,acc:acc,reloads:T.reloads,heals:T.heals,eliteKills:T.eliteKills||0,
'@ @'
    shots:T.shots,hits:T.hits,acc:acc,reloads:T.reloads,heals:T.heals,diedWithMed:T.diedWithMed||0,eliteKills:T.eliteKills||0,
'@

SubRx @'
    if(r.outcome==='dead'&&r.lastHitName) line+=' lastHit:'+r.lastHitName;
'@ @'
    if(r.outcome==='dead'&&r.lastHitName) line+=' lastHit:'+r.lastHitName;
    if(r.diedWithMed) line+=' unusedMed:1';
'@

SubRx @'
var VER='13.14';
'@ @'
var VER='13.15';
'@

$pat = "(?m)^  now:'v13\.14:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v13.15: from HIS TELEMETRY again. Three runs, heals 0 and downs 2 every single time: he carries medical, he goes down twice a raid, and he never applies one. I checked the two obvious causes first and both are refuted, so neither was built: the freebie kit DOES issue two Bandages so he is not going up empty, and the tactical belt builds its medical cell from the backpack automatically so the item is under a key whether or not anything was dragged. Nothing is broken. He simply does not use it, and nothing had ever told him so. His own priority line asks for exactly this, deeper coaching to follow if the telemetry does not move, and it has not moved; the card own v3.08 note already says the number worth putting in front of him at the moment of death is the one that makes it feedback rather than an epitaph. So the KILLED IN ACTION card gains one clause, and only when it is true: died carrying medical never used. It says nothing when he healed and nothing when he had nothing to heal with. The flag is read at the moment of death rather than on the card, because the backpack is emptied on the way there and a scan done at the card would always come back with nothing, which is the fault this would otherwise have shipped with. It also goes into the run record and the export line as unusedMed, so the next three runs answer whether saying it changes anything, which is the only way to know if coaching works',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
