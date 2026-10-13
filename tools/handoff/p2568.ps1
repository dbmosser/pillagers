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

# THE SEARCH SOUND NO LONGER REPEATS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  foley('rummage',null,null,{rate:cloth?0.8:(metal?1.1:0.95),g:cloth?0.8:1,gap:0.2});
  if(metal) foley('boltLatch',null,null,{rate:1.8,g:0.25,dur:0.1,at:0.08,local:1});
  return true;
}
'@ @'
  searchHit(ct,1); return true;   // v25.xx (searchvary): the rhythm lives in searchHit and searchTick
}
// v25.xx (searchvary), HIS ORDER 2026-10-13: "can you make the scavenging noise not so repetitve". v25.30 played the one rummage clip,
// at one pitch and one level, on a fixed half second beat for as long as he searched. Now a search is a rhythm that does not repeat:
// each hit takes a different clip from the bank (the rummage itself on every other hit, between them the strap, the holster rattle, a
// metal latch or clack, a case snap, never the same clip twice running), at its own pitch (8 percent either way), level (20 percent
// either way) and trim start, the next one 0.25 to 0.6 s later, every third to fifth hit a heavier dig (lower and louder), and now and
// then a pause in the rhythm. The beat is drawn from the cosmetic stream (fxn), never the seeded one. Letting go stops it at once; the
// search still ends on its own completion cue. Cosmetic only: no seeded draw, nothing under G.sim, no game state.
var SRCHFX={t:0,last:'',n:0,dig:4,hit:0};
function searchHit(ct,first){
  var ty=String((ct&&ct.type)||''), metal=(ty==='locker'||ty==='safe'||ty==='botwreck'||ty==='cache'||ty==='jackpot'), cloth=(ty==='body'||!!(ct&&ct.mercSrc));
  var acc=metal?['boltLatch','plateClack','medkitSnap']:(cloth?['strapRip','equip']:['equip','strapRip','boltLatch']), role, pool, i, isDig, gap, lv, rt, pz;
  if((G&&G.sim)||typeof foley!=='function') return false;
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
// the next hit of a search that is running, on the search's own clock (called every frame it runs)
function searchTick(ct,dt){
  if((G&&G.sim)||typeof foley!=='function'||!ct) return false;
  SRCHFX.t-=dt;
  if(SRCHFX.t>0) return false;
  return searchHit(ct);
}
'@

SubRx @'
        searchFoley(near,'rummage');   // v25.30 (usefoleyg): and every half second while it runs
'@ @'
        // v25.30 (usefoleyg): the rummage rode this half second tick; v25.xx (searchvary): it has its own varied beat now (searchTick, above)
'@

SubRx @'
      near.noiseAcc=(near.noiseAcc||0)+dt;
'@ @'
      searchTick(near,dt);   // v25.xx (searchvary): the next hit of the search sound, on its own varied beat
      near.noiseAcc=(near.noiseAcc||0)+dt;
'@

SubRx @'
var VER='25.67';
'@ @'
var VER='25.68';
'@

$pat = "(?m)^  now:'v25\.67:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v25.68: Searching a box now sounds different every few hits instead of repeating one rummage. Check 25.68 fails on v25.67',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
