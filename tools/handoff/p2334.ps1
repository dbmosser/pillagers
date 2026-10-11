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

# ARCADE: AN UPGRADE NEVER REPLACES THE GUN IN HAND (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
      if(autoEquipOn()&&(tierUp||condUp)&&_secFree){
'@ @'
      // v23.34, HIS ORDER (2026-10-11), build 12 of 20 (arcade12): AN UPGRADE NEVER REPLACES THE GUN IN HAND. In the arcade arcadeGunLoot
      // routes the found gun (stowed slot, backpack on key 3 or 4, or scrapped for points) and p.wep is never touched.
      if(G.arcade&&!G.sim){ var _agl=arcadeGunLoot(ct,key,itm,found); _ptags[l]=_agl.tag; if(_agl.line) _gunLine=_agl.line; }
      else if(autoEquipOn()&&(tierUp||condUp)&&_secFree){
'@

SubRx @'
// A kill this window credited to its own player. Returns the points.
'@ @'
// v23.34, HIS ORDER (2026-10-11), build 12 of 20 (arcade12): AN UPGRADE NEVER REPLACES THE GUN IN HAND. A walk-up player keeps the gun
// he is shooting. In an arcade raid a found gun with a higher tier than the stowed gun (Bare Hands counts as nothing) takes the
// stowed slot and the hand key the old one had, and the stowed gun goes into the backpack on key 3 or 4 (tag STOWED). Otherwise a gun better than the worst gun
// he carries (hands and backpack) goes into the backpack on key 3 or 4 (gunKeysSettle deploy, tag KEY n). Otherwise it is scrapped
// for points like a valuable (arcadeLoot, tag SCRAPPED +N). A copy of a gun already in his hands or backpack is scrapped. Only
// grantLoot calls this, behind G.arcade, so a normal raid is unchanged.
function arcadeGunLoot(ct,key,itm,found){
  var p=G.player, T=G.tel, gk=itm.gk, ft=WTIER[gk]||0, st, worst=99, j, it2, k, n, push=null, oi, pk;
  function real(w){ return !!(w&&w.id&&w.id!=='fists'&&w.mag!==0); }
  function held(id){ return !!((p.wep&&p.wep.id===id)||(p.sec&&p.sec.id===id)); }
  function keyOf(ik){ var A=G.hotAssign||{}, kk; for(kk in A) if(A[kk]===ik) return +kk; return -1; }
  st=real(p.sec)?(WTIER[p.sec.id]||0):-1;
  if(ft>st&&!held(gk)){
    if(real(p.sec)&&!p.secIssued&&ITEMS['gun_'+p.sec.id]){
      push=p.sec.id;
      G.bag.push('gun_'+push); stowRounds(push,p.secAmmo); gunQPush(p.sec);
      if(p.secFromArmory&&P&&P.weapons){ oi=P.weapons.indexOf(push); if(oi>=0){ P.weapons.splice(oi,1); (G.spliced=G.spliced||[]).push(push); (P.raidSpliced=P.raidSpliced||[]).push(push); } }
    }
    p.sec=found; p.secAmmo=(ct&&ct.dropped)?takeRounds(found.id,found.mag):Math.ceil(found.mag/2); p.secIssued=false; p.secFromArmory=false;
    // the new stowed gun takes the hand key the old one had (an automatic pin only), and the old one moves to key 3 or 4
    if(push&&G.hotAssign&&G.hotAuto) for(pk in G.hotAssign) if(G.hotAssign[pk]==='gun_'+push&&G.hotAuto[pk]&&(+pk)<2){ delete G.hotAssign[pk]; delete G.hotAuto[pk]; }
    gunKeysSettle({pushed:push,arrived:found.id});
    if(push) gunKeysSettle({deploy:1});
    if(T) T.gunsEquipped=(T.gunsEquipped||0)+1;
    k=keyOf('gun_'+found.id);
    _lootSub=(padOn()?padB('LB or RB to swap'):('Press '+keyLabel('Digit'+((k<0?1:k)+1),String((k<0?1:k)+1))+' to swap')).toUpperCase();
    if(found.qRank>=2) blip('pickGun');
    return {tag:'STOWED',line:(found.name+' stowed').toUpperCase()};
  }
  if(real(p.wep)) worst=Math.min(worst,WTIER[p.wep.id]||0);
  if(real(p.sec)) worst=Math.min(worst,WTIER[p.sec.id]||0);
  for(j=0;j<G.bag.length;j++){ it2=ITEMS[G.bag[j]]; if(it2&&it2.use==='gun'&&it2.gk) worst=Math.min(worst,WTIER[it2.gk]||0); }
  if(worst===99) worst=-1;
  if(ft>worst&&!held(gk)&&G.bag.indexOf(key)<0){
    G.bag.push(key);
    if(ct&&ct.dropped) gunQTrim(gk,gunQCount(gk)-1); else gunQPush(found);
    gunKeysSettle({deploy:1});
    k=keyOf(key);
    if(found.qRank>=2) blip('pickGun');
    return {tag:(k>=0?'KEY '+(k+1):'BACKPACK'),line:''};
  }
  if(ct&&ct.dropped) gunQTrim(gk);
  n=arcadeLoot(key);
  return {tag:'SCRAPPED +'+n.toLocaleString(),line:''};
}
// A kill this window credited to its own player. Returns the points.
'@

SubRx @'
var VER='23.33';
'@ @'
var VER='23.34';
'@

$pat = "(?m)^  now:'v23\.33:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v23.34: In the arcade a found gun never replaces the gun in your hands: it is stowed, packed on key 3 or 4, or scrapped for points. Check 23.34 fails on v23.33',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
