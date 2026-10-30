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

# SHARED MACHINE POINTS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function arcadeBmDamage(e,n,seat){
  var b, v;
'@ @'
// v28.xx (cw-cx-sharedmachine), HIS DECISION 10-28: "last 2.5 secs". The body authority timestamps real damage, in raid seconds.
function sharedMachineMark(e,n,seat){
  if(!G||G.sim||!NET.on||NET.role!=='host'||!(G.arcade||G.career)||!e||!ELEM_MACH[e.kind]||e.finished||!(e.hp>0)||!(n>0)||seat<0) return;
  if(!e.sharedHits) e.sharedHits={};
  e.sharedHits[seat|0]=G.t;
}
// v28.xx (cw-cx-sharedmachine): score only; the killing blow still owns kills, contracts, streaks, perks and drops.
function sharedMachineScore(e){
  if(!G||G.sim||G.over||!e||!ELEM_MACH[e.kind]||!G.player||G.player.specOut) return 0;
  var st=G.arcade&&ARCADE.on?ARCADE:(G.career?G.cs:null), n;
  if(!st) return 0;
  n=arcadeKillPts(e.kind,e.affix&&e.elite?3:e.elite,e.boss);
  if(!(n>0)) return 0;
  if(G.hotZone&&Number.isFinite(e.x)&&Number.isFinite(e.y)&&Math.hypot(e.x-G.hotZone.x,e.y-G.hotZone.y)<=G.hotZone.r) n=Math.round(n*HOT_KILLX);
  if(G.arcade){ if(arcadeRushOn()) n=Math.round(n*1.05); ARCADE.mine=(ARCADE.mine|0)+n; arcadeScSend(); }
  else { G.cs.s=(G.cs.s|0)+n; csTally('kill',n); }
  return n;
}
// v28.xx (cw-cx-sharedmachine): settle at death, before a later entity snapshot can age the last hit past the cutoff.
function sharedMachineDeath(e){
  if(!G||G.sim||!NET.on||NET.role!=='host'||!(G.arcade||G.career)||!e||!ELEM_MACH[e.kind]||e.hp>0||e.sharedPaid) return;
  e.sharedPaid=1;
  var hits=e.sharedHits||{}, seats=[], k, s, q, killer=e.byPlayer?0:(e.bySeat>0?e.bySeat:-1);
  for(k in hits) if(Object.prototype.hasOwnProperty.call(hits,k)&&G.t-hits[k]>=0&&G.t-hits[k]<=2.5) seats.push(+k);
  if(seats.length<2) return;
  for(k=0;k<seats.length;k++){
    s=seats[k]; if(s===killer) continue;
    if(s===0) sharedMachineScore(e);
    else { q=netPeerOfSeat(s); if(q) netSend(q,{t:'kill',share:1,seat:s,id:e.nid,k:e.kind,el:e.elite?1:0,af:e.affix?1:0,boss:!!e.boss,x:e.x,y:e.y}); }
  }
}
function arcadeBmDamage(e,n,seat){
  sharedMachineMark(e,n,seat);
  var b, v;
'@

SubRx @'
      try{ feedKillEnt(e); }catch(_fke){}   // v27.24 (feed1): the kill in the feed, his, a teammate's or nobody's
'@ @'
      sharedMachineDeath(e);   // v28.xx (cw-cx-sharedmachine): both recent contributors receive full machine SP.
      try{ feedKillEnt(e); }catch(_fke){}   // v27.24 (feed1): the kill in the feed, his, a teammate's or nobody's
'@

SubRx @'
  if(!k) return 'bad';
  if(T.kills&&T.kills[k]!==undefined) T.kills[k]++;
'@ @'
  if(!k) return 'bad';
  // v28.xx (cw-cx-sharedmachine): addressed score-only credit, even if the gone snapshot has not arrived yet.
  if(m.share===1){
    if(!ELEM_MACH[k]||!Number.isFinite(m.x)||!Number.isFinite(m.y)||!(m.id>0)) return 'bad';
    var seen=G.sharedSpSeen||(G.sharedSpSeen={});
    if(seen[m.id]) return 'ignored';
    seen[m.id]=1;
    sharedMachineScore({kind:k,elite:!!m.el,affix:!!m.af,boss:!!m.boss,x:m.x,y:m.y});
    return 'shared';
  }
  if(T.kills&&T.kills[k]!==undefined) T.kills[k]++;
'@

SubRx @'
var VER='36.62';
'@ @'
var VER='36.63';
'@

$pat = "(?m)^  now:'v36\.62:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v36.63: Recent machine contributors each receive full kill SP. Kill counts and kill rewards still belong to the finishing player. Check 36.63 fails on v36.62',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
