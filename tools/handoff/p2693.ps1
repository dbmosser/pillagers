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

# THE PARTY SEED (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function arcadePartyAt(){ var t=0; try{ t=+localStorage.getItem(ARCADE_PARTY_KEY)||0; }catch(_pa){ t=0; } return t; }
'@ @'
// v26.xx (party6), HIS YES (2026-10-14) to suggestion 38, "sure, seed function": THE PARTY SEED. NEW PARTY now also locks one seed and the sector for the night. The
// party record is {t: when, s: the seed, m: the sector} under ARCADE_PARTY_KEY (an older record that is just a time still reads as a party with no seed).
// The seed is picked the way a raid picks its own, from Math.random (buildRaid does the same when nothing forces a seed), so no seeded stream is touched; it
// is the raid seed itself, handed to arcadeDeploy as pendSeed for every run until the party is 12 hours old (the board's night) or NEW PARTY is pressed again.
// So every DEMO run that night plays the same raid (the layout, the loot, the golden enemy and everything else that grows from the seed) and the board is fair.
// A seed passed to arcadeDeploy still wins. The board page and the operator card say it is a SEEDED NIGHT, with a four letter code for the seed.
function arcadePartyRec(){ var o=null, s; try{ s=localStorage.getItem(ARCADE_PARTY_KEY); if(s) o=(s.charAt(0)==='{')?JSON.parse(s):{t:+s||0}; }catch(_pr){ o=null; } return (o&&typeof o==='object')?o:{t:0}; }
function arcadePartyAt(){ return +arcadePartyRec().t||0; }
function arcadePartySeed(){ var o=arcadePartyRec(), s=(+o.s)>>>0; return (s&&(+o.t||0)>0&&Date.now()-o.t<ARCADE_BOARD.night)?s:0; }
function arcadePartyMap(){ var o=arcadePartyRec(); return (arcadePartySeed()&&typeof o.m==='number'&&o.m>=0&&o.m<FIXED_MAPS.length)?(o.m|0):-1; }
function arcadePartyCode(){ var s=arcadePartySeed(); return s?s.toString(36).toUpperCase().slice(-4):''; }
'@

SubRx @'
  try{ localStorage.setItem(ARCADE_PARTY_KEY,String(Date.now())); }catch(_np){ return false; }
'@ @'
  var _sd=((Math.random()*4294967296)>>>0)||1;   // v26.xx (party6): the night seed, picked as a raid picks its own
  try{ localStorage.setItem(ARCADE_PARTY_KEY,JSON.stringify({t:Date.now(),s:_sd,m:(ARCADE.mapIx|0)})); }catch(_np){ return false; }
'@

SubRx @'
  if(o.seed!==undefined) pendSeed=(o.seed>>>0);
'@ @'
  if(o.seed!==undefined) pendSeed=(o.seed>>>0);
  else { var _ps=arcadePartySeed(); if(_ps) pendSeed=_ps; }   // v26.xx (party6): the party seed, unless a seed was passed
'@

SubRx @'
  var mi=(o.mapIx!==undefined)?o.mapIx:ARCADE.mapIx;
'@ @'
  var mi=(o.mapIx!==undefined)?o.mapIx:((arcadePartyMap()>=0)?arcadePartyMap():ARCADE.mapIx);   // v26.xx (party6): the party sector
'@

SubRx @'
  arcadeAttLine(pg,'aph','TONIGHT\u2019S BEST');
'@ @'
  arcadeAttLine(pg,'aph','TONIGHT\u2019S BEST');
  try{ if(arcadePartyCode()) arcadeAttLine(pg,'apb','SEEDED NIGHT  \u00b7  '+arcadePartyCode()); }catch(_pc){}   // v26.xx (party6): the board says the night is seeded
'@

SubRx @'
+' ON THE BOARD'; d.style.cssText
'@ @'
+' ON THE BOARD'+(arcadePartyCode()?'  \u00b7  SEED '+arcadePartyCode():''); d.style.cssText
'@

SubRx @'
?'NEW PARTY  \u00b7  BOARD CLEARED':
'@ @'
?'NEW PARTY  \u00b7  BOARD CLEARED  \u00b7  SEED '+arcadePartyCode():
'@

SubRx @'
'CLEARS TONIGHT\u2019S BEST  \u00b7  BEST EVER STAYS'
'@ @'
'CLEARS TONIGHT\u2019S BEST  \u00b7  NEW SEED  \u00b7  BEST EVER STAYS'
'@

SubRx @'
var VER='26.92';
'@ @'
var VER='26.93';
'@

$pat = "(?m)^  now:'v26\.92:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v26.93: NEW PARTY locks one seed for the night, so every demo run plays the same raid. Check 26.93 fails on v26.92',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
