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

# EVERY CONTAINER SEARCHES IN ITS OWN SOUND (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var SRCHFX={t:0,last:'',n:0,dig:4,hit:0};
'@ @'
// v26.xx (searchmix), HIS WORDS 2026-10-14 (playing): "switch the sound up a little bit more when i search one crate after the next it
// starts to get repetitive". v25.xx (searchvary) varied the hits inside one search, but v25.xx (searchfix) then made EVERY search open on
// the rummage and count from the same start, so crate after crate began with the same sound and the same early pattern. Now every
// container has a character of its own: a key from where it stands (a hash of its position and kind, no random draw at all, so one crate
// always sounds like itself) picks the clip a search opens on, the order the clips come in and a base pitch about 10 percent either way.
// The clips follow the material: a locker, a safe, a wreck or a jackpot box on the metal (plate clack, bolt latch, heavy box clack, case
// snap), a crate on the knocks and the rummage, a body or a dropped pack on the cloth (strap, tear, rummage), a cache a mix of them all.
// A search never opens on the clip the search before it opened on. The rest is as it was: a hit every 0.25 to 0.6 s, a heavier dig every
// third to fifth hit, the completion cue. Cosmetic only: no seeded draw, nothing under G.sim, no game state.
var SRCHFX={t:0,last:'',n:0,dig:4,hit:0,open:'',ix:0,dir:1,pr:1,key:0,sig:0};
// ord: the clips of a material in the order a search walks them (turned and started by the container's key); dig: the heavier hits;
// sig: the clips that carry the material (one of them always sounds in the first four hits); rt and lv: its pitch and level
var SRCHMAT={
  metal:{ord:['plateClack','rummage','boltLatch','plateClack','lmgClack','medkitSnap'],dig:['plateClack','boltLatch','lmgClack'],sig:['plateClack','boltLatch'],rt:1.1,lv:1},
  wood:{ord:['rummage','lmgClack','equip','rummage','pinClick','equip'],dig:['lmgClack','equip'],sig:['rummage','lmgClack'],rt:0.95,lv:1},
  cloth:{ord:['strapRip','rummage','bandageTear','strapRip','rummage','equip'],dig:['strapRip','equip'],sig:['strapRip','bandageTear'],rt:0.8,lv:0.8},
  mixed:{ord:['rummage','plateClack','strapRip','boltLatch','equip','lmgClack'],dig:['plateClack','lmgClack','strapRip'],sig:[],rt:1,lv:1}
};
function srchMat(ct){
  var ty=String((ct&&ct.type)||'');
  if(ty==='body'||(ct&&(ct.mercSrc||ct.dropped))) return SRCHMAT.cloth;
  if(ty==='locker'||ty==='safe'||ty==='botwreck'||ty==='jackpot') return SRCHMAT.metal;
  if(ty==='cache') return SRCHMAT.mixed;
  return SRCHMAT.wood;
}
// a whole number from where a container stands and what it is (a hash, never the random stream), the same every time for the same box
function srchKey(ct){
  var s='k'+Math.round((ct&&+ct.x)||0)+','+Math.round((ct&&+ct.y)||0)+String((ct&&ct.type)||''), h=2166136261, i;
  for(i=0;i<s.length;i++) h=Math.imul(h^s.charCodeAt(i),16777619)>>>0;
  h^=h>>>15; h=Math.imul(h,2246822519)>>>0; h^=h>>>13;
  return h>>>0;
}
'@

SubRx @'
function searchHit(ct,first){
  var ty=String((ct&&ct.type)||''), metal=(ty==='locker'||ty==='safe'||ty==='botwreck'||ty==='cache'||ty==='jackpot'), cloth=(ty==='body'||!!(ct&&ct.mercSrc));
  var acc=metal?['boltLatch','plateClack','medkitSnap']:(cloth?['strapRip','equip']:['equip','strapRip','boltLatch']), role, pool, i, isDig, gap, lv, rt, pz;
  if((G&&G.sim)||typeof foley!=='function') return false;
  // v25.xx (searchfix): a search OPENS on the rummage itself. The counters rode over from the search before, so an opening could land on
  // a dig left due by the last search, or lose the rummage to the no-repeat rule when the last search ended on it.
  if(first){ SRCHFX.hit=0; SRCHFX.n=0; SRCHFX.last=''; }
  SRCHFX.hit++; SRCHFX.n++;
  isDig=SRCHFX.n>=SRCHFX.dig;
  if(isDig){ SRCHFX.n=0; SRCHFX.dig=fxi(3,5); pool=metal?['plateClack','boltLatch']:['equip','strapRip']; }
  else pool=(SRCHFX.hit%2===1)?['rummage']:acc;
  pool=pool.filter(function(r){ return r!==SRCHFX.last; });
  if(!pool.length) pool=['rummage','equip'].filter(function(r){ return r!==SRCHFX.last; });
  role=fxpick(pool); SRCHFX.last=role;
  lv=(cloth?0.8:1)*(1+fxn(-0.2,0.2))*(isDig?1.3:1);
  rt=(metal?1.1:(cloth?0.8:0.95))*(1+fxn(-0.08,0.08))*(isDig?0.8:1);
  foley(role,null,null,{rate:rt,g:lv,off:fxn(0,0.05),gap:0.05,vary:0,dig:isDig?1:0});
  gap=fxn(0.25,0.6); pz=fxn(0,1)<0.12; if(pz&&!first) gap+=fxn(0.5,1.0);   // and now and then a breath in the rhythm, never right after the first hit
  SRCHFX.t=gap;
  return true;
}
'@ @'
function searchHit(ct,first){
  var m=srchMat(ct), n=m.ord.length, role='', pool, tries, isDig, gap, lv, rt, pz, st, k, o;
  if((G&&G.sim)||typeof foley!=='function') return false;
  if(!first&&!SRCHFX.hit) first=1;   // a hit with no opening before it opens the search
  // v25.xx (searchfix): the counters start over with every search, so an opening never lands on a dig left due by the search before.
  // v26.xx (searchmix): and the container sets its own character here: base pitch, the way round it walks its clips and where it starts.
  if(first){
    k=srchKey(ct);
    SRCHFX.hit=0; SRCHFX.n=0; SRCHFX.last=''; SRCHFX.sig=0; SRCHFX.key=k;
    SRCHFX.pr=1+(((k>>>5)%2001)-1000)/10000;   // 0.9 to 1.1
    SRCHFX.dir=((k>>>17)&1)?1:-1;
    SRCHFX.ix=(k>>>11)%n;
    for(tries=0;tries<n&&m.ord[SRCHFX.ix]===SRCHFX.open;tries++) SRCHFX.ix=(SRCHFX.ix+SRCHFX.dir+n)%n;   // never the clip the last search opened on
  }
  SRCHFX.hit++; SRCHFX.n++;
  isDig=!first&&SRCHFX.n>=SRCHFX.dig;
  if(first) role=m.ord[SRCHFX.ix];
  else if(isDig){
    SRCHFX.n=0; SRCHFX.dig=fxi(3,5);
    pool=m.dig.filter(function(r){ return r!==SRCHFX.last; });
    role=fxpick(pool.length?pool:m.dig);
  } else {
    st=(fxn(0,1)<0.4)?2:1;   // mostly the next clip round, now and then one skipped
    for(tries=0;tries<n;tries++){
      SRCHFX.ix=(SRCHFX.ix+SRCHFX.dir*st+3*n)%n; role=m.ord[SRCHFX.ix];
      if(role!==SRCHFX.last) break;
      st=1;
    }
  }
  if(SRCHFX.hit>=4&&!SRCHFX.sig&&m.sig.length){   // the clips that carry the material: one sounds in the first four hits, whatever the walk did
    pool=m.sig.filter(function(r){ return r!==SRCHFX.last; });
    if(pool.length) role=fxpick(pool);
  }
  if(m.sig.indexOf(role)>=0) SRCHFX.sig=1;
  SRCHFX.last=role;
  if(first) SRCHFX.open=role;
  lv=m.lv*(1+fxn(-0.2,0.2))*(isDig?1.3:1);
  rt=m.rt*SRCHFX.pr*(1+fxn(-0.08,0.08))*(isDig?0.8:1);
  o={rate:rt,g:lv,off:fxn(0,0.05),gap:0.05,vary:0,dig:isDig?1:0};
  if(role==='bandageTear') o.dur=0.32;   // the long tear is cut short: a tug at a pocket, not a bandage
  foley(role,null,null,o);
  gap=fxn(0.25,0.6); pz=fxn(0,1)<0.12; if(pz&&!first) gap+=fxn(0.5,1.0);   // and now and then a breath in the rhythm, never right after the first hit
  SRCHFX.t=gap;
  return true;
}
'@

SubRx @'
var VER='26.14';
'@ @'
var VER='26.15';
'@

$pat = "(?m)^  now:'v26\.14:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v26.15: Every container now searches with its own mix of sounds. Check 26.15 fails on v26.14',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
