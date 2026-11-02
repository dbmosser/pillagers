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

# SEASON ZERO M2: A DEATH ENDS THE PILLAGER (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
// The one-time hub line for an old save's payout. Never in the demo, which plays on a copy.
'@ @'
// v37.xx (cw-m2death), HIS RULINGS OF 11-01 (round 5, answers 28 and 31), plan m2 "the lineage": a death ends the pillager and everything it wore and
// carried; stash cash, lifetime earnings, rank and the account stay; quitting a raid early counts as a death. Every raid that settles (never the free
// walk-back, never G.sim, never the demo) goes on the living pillager's record: raids, extracts, kills, and the best secured haul. A death or a quit
// then ends it into the hall with end {how dead or quit, map, zone, by, lost, items, worn, look} (the hall, m2d, reads this shape) and the next one is
// born at once (pilBirth; m2c puts a birth card here). Two players: only his own death reaches endRaid on his PC, so a revive keeps the pillager and a
// partner's death ends nothing here; a host who dies and spectates has died. The player 2 window on this PC keeps today's rules until m3f.
// P.worn is copied, never cleared here (m3c owns what a death takes from the worn slots).
function pilLookNow(){ return {hat:P.cosHat,cut:P.cosCut,skin:P.cosSkin,scheme:P.cosScheme,fit:P.cosFit,outfit:P.cosOutfit}; }
function pilZoneNow(){
  var p=G&&G.player, z;
  try{
    if(G.inLandmark&&G.inLandmark.name) return String(G.inLandmark.name).toLowerCase();
    if(p&&G.map&&G.map.zoneAt){ z=G.map.zoneAt(p.x,p.y); if(z&&z.name) return String(z.name).toLowerCase(); }
    if(G.inZoneName) return String(G.inZoneName).toLowerCase();
  }catch(_pz){}
  return '';
}
function pilRaidEnd(how,sec,lost){
  var q, k, n=0, tk, T, ix, kn, r;
  if(!G||G.sim||!P) return null;
  if(typeof ARCADE==='object'&&ARCADE&&ARCADE.on) return null;
  if(typeof NETP2!=='undefined'&&NETP2) return null;
  q=pilNow(); if(!q) return null;
  T=G.tel||{}; tk=T.kills||{};
  for(k in tk) if(Object.prototype.hasOwnProperty.call(tk,k)) n+=(+tk[k]||0);
  q.raids++; if(how==='extract') q.ext++; q.kills+=n;
  if(how==='extract'&&(+sec||0)>q.best) q.best=Math.round(+sec||0);
  if(how!=='dead'&&how!=='abandon') return null;
  ix=clamp(P.mapIx===undefined?0:P.mapIx,0,FIXED_MAPS.length-1);
  kn=(how==='dead')?((T.lastHitName&&T.deathKiller!=='timer')?T.lastHitName:String(T.deathKiller||'unknown')):'';   // the name the KIA card gives
  r=pilEnd(P,{how:how==='dead'?'dead':'quit', map:(FIXED_MAPS[ix]&&FIXED_MAPS[ix].id)||'', zone:pilZoneNow(), by:String(kn).toLowerCase(),
    lost:Math.max(0,Math.round((lost&&+lost.v)||0)), items:((lost&&Array.isArray(lost.k))?lost.k:[]).slice(0,7),
    worn:JSON.parse(JSON.stringify(P.worn||{})), look:pilLookNow()});
  pilBirth(P);
  if(r) P.pilNote={t:String(r.name).toLowerCase()+' is gone  pillager '+P.pilGen,shown:0};
  return r;
}
// The one short floor line after a death, at the next arrival there. Never in the demo.
function pilNoteShow(){
  var n=P&&P.pilNote;
  if(!n||n.shown||typeof n.t!=='string'||!n.t) return false;
  if(state!=='hub') return false;
  if(typeof ARCADE==='object'&&ARCADE&&ARCADE.on) return false;
  n.shown=1;
  hubToast(n.t,6);
  try{ saveProfile(); }catch(_pn){}
  return true;
}
// The one-time hub line for an old save's payout. Never in the demo, which plays on a copy.
'@

SubRx @'
    var _gunN=0,_gunVal=0;
'@ @'
    var _gunN=0,_gunVal=0,_pilGK=[];   // v37.xx (cw-m2death): the lost guns' keys, for the hall
'@

SubRx @'
      _gunN++; if(ITEMS['gun_'+gone[j].id]) _gunVal+=ival('gun_'+gone[j].id);
'@ @'
      _gunN++; if(ITEMS['gun_'+gone[j].id]){ _gunVal+=ival('gun_'+gone[j].id); _pilGK.push('gun_'+gone[j].id); }
'@

SubRx @'
  if(!G.sim) forgeSweep(how);   // v23.xx (forge12): a death takes the forge of the armoury gun lost; an abandon writes nothing
'@ @'
  if(!G.sim) forgeSweep(how);   // v23.xx (forge12): a death takes the forge of the armoury gun lost; an abandon writes nothing
  // v37.xx (cw-m2death), his rulings of 11-01: every raid on the pillager's record; a death or a quit ends it (pilRaidEnd). What was lost is what the
  // card counts: on a death the bag the ledger called LOST and its lost guns ($ the card says gone), on a quit the bag left behind.
  if(!G.sim){ try{
    var _plK=[], _plV=0, _pli;
    if(how==='dead'){ for(_pli=0;_pli<lostIdx.length;_pli++) _plK.push(G.bag[lostIdx[_pli]]); _plK=_plK.concat(_pilGK); _plV=(haul-savedVal-_dIss*ival('bandage'))+_gunVal; }
    else if(how==='abandon'){ _plK=G.bag.slice(); _plV=haul; }
    _plK.sort(function(a,b){ return ival(b)-ival(a); });
    pilRaidEnd(how,how==='extract'?(_secV||0):0,{v:_plV,k:_plK});
  }catch(_pre){} }
'@

SubRx @'
    try{ if(!szNoteShow()) rankNoteShow(); }catch(_szs){}
'@ @'
    try{ if(!pilNoteShow()&&!szNoteShow()) rankNoteShow(); }catch(_szs){}   // v37.xx (cw-m2death): first "<name> is gone  pillager <n>" after a death
'@

SubRx @'
var VER='37.28';
'@ @'
var VER='37.29';
'@

$pat = "(?m)^  now:'v37\.28:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v37.29: every raid that settles (never the free walk back, a sim raid or the demo) adds to the living pillager: raids, extracts, kills and the best secured haul. A death or a quit with anything done ends the pillager into the hall with how (dead or quit), map, zone, killer, value lost, up to 7 lost item keys, a copy of the worn slots and the body look, and the next generation is born at once. The floor says it once on the next arrival: name is gone  pillager n. Stash, cash, guns kept, lifetime earnings and rank are not touched. Only his own death ends his pillager in two player; the player 2 window keeps today rules Check 37.29 fails on v37.28',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
