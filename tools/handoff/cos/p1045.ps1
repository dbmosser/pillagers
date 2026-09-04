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

# ============ HIS NOTE, 2026-09-03 about 14:10, and the Reach research:
# ============ commendations "tracked how you play", so play style became the
# ============ collection.
#
# Every gate on the racks was a count of raids, extractions, levels or
# Wardens. Three gates that read how he plays: kills across every machine and
# pillager, extractions in the dark, and extractions in a row without a death
# or an abandon. Two new counters on the profile (night extractions, best
# streak) written where the run is banked; kills are summed from the tally
# that is already kept. Three patches prove them: Night Owl, Headhunter,
# Unbroken.

SubRx @'
  P.runs++;
'@ @'
  P.runs++;
  // v10.45: the streak. Extractions in a row; a death or an abandon ends it.
  P.extStreak=(how==='extract')?((P.extStreak||0)+1):0;
  if(P.extStreak>(P.bestStreak||0)) P.bestStreak=P.extStreak;
'@

SubRx @'
  if(how==='extract'){
    P.ext++;
'@ @'
  if(how==='extract'){
    P.ext++;
    if(typeof isDay==='function'&&!isDay()) P.nightExt=(P.nightExt||0)+1;   // v10.45: out in the dark
'@

SubRx @'
  if(k==='warden')   return ((P.kills&&P.kills.warden)||0)>=v;
  if(k==='buy')      return !!((P.cosBought||{})[c.id]);
  return false;
}
'@ @'
  if(k==='warden')   return ((P.kills&&P.kills.warden)||0)>=v;
  if(k==='buy')      return !!((P.cosBought||{})[c.id]);
  // v10.45: gates that read how he plays.
  if(k==='kills')    return cosKillsTotal()>=v;
  if(k==='night')    return (P.nightExt||0)>=v;
  if(k==='streak')   return (P.bestStreak||0)>=v;
  return false;
}
function cosKillsTotal(){ var t=0, K=(typeof P!=='undefined'&&P&&P.kills)||{}; for(var k in K) t+=(K[k]||0); return t; }
'@

SubRx @'
  if(k==='warden')   return 'put a Warden down';
  if(k==='buy')      return '$'+v+' from the Peddler';
  return '';
}
'@ @'
  if(k==='warden')   return 'put a Warden down';
  if(k==='buy')      return '$'+v+' from the Peddler';
  if(k==='kills')    return v+' kills';                       // v10.45
  if(k==='night')    return v+' extraction'+(v==='1'?'':'s')+' in the dark';
  if(k==='streak')   return v+' extractions in a row';
  return '';
}
'@

SubRx @'
  if(k==='board')    return {k:k,cur:(P.spClaimed||[]).length,need:SEASON_TIERS.length,unit:'board reward'};
  return null;
}
'@ @'
  if(k==='board')    return {k:k,cur:(P.spClaimed||[]).length,need:SEASON_TIERS.length,unit:'board reward'};
  if(k==='kills')    return {k:k,cur:cosKillsTotal(),need:v,unit:'kill'};                 // v10.45
  if(k==='night')    return {k:k,cur:P.nightExt||0,need:v,unit:'extraction in the dark'};
  if(k==='streak')   return {k:k,cur:P.extStreak||0,need:v,unit:'extraction in a row'};
  return null;
}
'@

SubRx @'
  {id:'patchflag', name:'Flag',           how:'warden:1',    kind:'patch'},
'@ @'
  {id:'patchflag', name:'Flag',           how:'warden:1',    kind:'patch'},
  // v10.45: three patches that read how he plays.
  {id:'patchowl',  name:'Night Owl',      how:'night:3',     kind:'patch'},
  {id:'patchhunt', name:'Headhunter',     how:'kills:50',    kind:'patch'},
  {id:'patchchain',name:'Unbroken',       how:'streak:3',    kind:'patch'},
'@

SubRx @'
var PATCHCOL={patchcross:['#f2f2f2','#c82828'],patchskull:['#14161b','#e8e2d2'],patchstar:['#1e2a5a','#ffd24a'],patchchev:['#3a3a2a','#e0c060'],patchflag:['#1e3a6a','#d8d8d8']};
'@ @'
var PATCHCOL={patchcross:['#f2f2f2','#c82828'],patchskull:['#14161b','#e8e2d2'],patchstar:['#1e2a5a','#ffd24a'],patchchev:['#3a3a2a','#e0c060'],patchflag:['#1e3a6a','#d8d8d8'],
              patchowl:['#1a1f3a','#f0d060'],patchhunt:['#4a1e1e','#e05040'],patchchain:['#1e2e2a','#a8f0c8']};   // v10.45
'@

# Each new patch gets a mark of its own; a bare dark square did not read on the
# sprite at all (measured: Headhunter drew nothing a pixel test could find).
SubRx @'
  else if(id==='patchflag'){ c.fillRect(x+s*0.15,y+s*0.2,s*0.7,s*0.2); c.fillRect(x+s*0.15,y+s*0.6,s*0.7,s*0.2); }
'@ @'
  else if(id==='patchflag'){ c.fillRect(x+s*0.15,y+s*0.2,s*0.7,s*0.2); c.fillRect(x+s*0.15,y+s*0.6,s*0.7,s*0.2); }
  // v10.45: two eyes for the owl, a crosshair for the hunter, two links for the chain.
  else if(id==='patchowl'){ c.fillRect(x+s*0.15,y+s*0.25,s*0.28,s*0.28); c.fillRect(x+s*0.57,y+s*0.25,s*0.28,s*0.28); c.fillRect(x+s*0.4,y+s*0.6,s*0.2,s*0.25); }
  else if(id==='patchhunt'){ c.fillRect(x+s*0.42,y+s*0.1,s*0.16,s*0.8); c.fillRect(x+s*0.1,y+s*0.42,s*0.8,s*0.16); c.fillStyle=pc[0]; c.fillRect(x+s*0.38,y+s*0.38,s*0.24,s*0.24); }
  else if(id==='patchchain'){ c.fillRect(x+s*0.1,y+s*0.3,s*0.4,s*0.4); c.fillRect(x+s*0.5,y+s*0.3,s*0.4,s*0.4); c.fillStyle=pc[0]; c.fillRect(x+s*0.2,y+s*0.4,s*0.2,s*0.2); c.fillRect(x+s*0.6,y+s*0.4,s*0.2,s*0.2); }
'@

SubRx @'
var VER='10.44';
'@ @'
var VER='10.45';
'@
SubRx @'
  now:'v10.44: a raid that earns a piece says so. The outcome card names every piece the racks gained during the raid, above the next one coming.',
'@ @'
  now:'v10.45: three gates that read how you play: kills, extractions in the dark, extractions in a row. Three patches hang on them: Night Owl, Headhunter, Unbroken.',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
