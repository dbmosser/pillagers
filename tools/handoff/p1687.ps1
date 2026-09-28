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

# RANDOM FROM STASH AND TOP GEAR AT THE KIT QUESTION (his ask 2026-09-27, during his co-op session).

SubRx @'
      <button id="askalt" style="flex:2;display:none">FREEBIE KIT</button>
'@ @'
      <button id="askalt" style="flex:2;display:none">FREEBIE KIT</button>
      <button id="askrand" style="flex:2;display:none">RANDOM FROM STASH</button>
      <button id="asktop" style="flex:2;display:none">TOP GEAR</button>
'@

SubRx @'
var ASKYES=null, ASKALT=null, ASKBACK=null;
'@ @'
var ASKYES=null, ASKALT=null, ASKBACK=null, ASKRAND=null, ASKTOP=null;
// v16.87, HIS ASK: RANDOM FROM STASH AND TOP GEAR. Two more answers on the kit question, beside MY LOADOUT and FREEBIE KIT, in
// every window of a party too. Each fills the packing list from what the stash holds (P.kit names stash items, which leave the
// stash only when the raid starts, so nothing is made or lost) and equips a gun he already owns (the rule the stash Equip as
// your gun uses), then goes up exactly as MY LOADOUT does. TOP GEAR: his highest tier gun, two of each grenade, then the
// biggest plate (only with a rig that holds plates), the biggest ammo and the two biggest heals, the size of the auto-pack.
// RANDOM FROM STASH: a gun he owns picked at random and six stash items of those kinds picked at random.
function kitFill(rand){
  var own=(P.weapons||[]).filter(function(g){ return g&&g!=='fists'&&WEAPONS[g]; }), g=null, pool=(P.stash||[]).slice(), out=[], i, j, t, cap=0, tc={}, c;
  if(own.length){ if(rand) g=own[Math.floor(Math.random()*own.length)]; else { own.sort(function(a,b){ return (WTIER[b]||0)-(WTIER[a]||0); }); g=own[0]; } }
  if(g){ if(P.equippedSec===g) P.equippedSec='none'; P.equipped=g; }
  try{ cap=rigCeil(myRig()); }catch(_rc){ cap=0; }
  function ok(k){ var q=ITEMS[k]; return !!q&&(q.use==='throw'||q.use==='ammo'||q.use==='heal'||(q.use==='armor'&&cap>0)); }
  if(rand){
    c=pool.filter(ok);
    for(i=0;i<6&&c.length;i++){ j=Math.floor(Math.random()*c.length); out.push(c[j]); c.splice(j,1); }
  } else {
    for(i=0;i<pool.length;i++){ t=ITEMS[pool[i]]; if(t&&t.use==='throw'&&(tc[pool[i]]||0)<2){ tc[pool[i]]=(tc[pool[i]]||0)+1; out.push(pool[i]); pool[i]=null; } }
    ['armor','ammo','heal','heal'].forEach(function(u){
      var bi=-1, bv=-1, j2, q;
      for(j2=0;j2<pool.length;j2++){ if(!pool[j2]||!ok(pool[j2])) continue; q=ITEMS[pool[j2]]; if(q.use===u&&(q.amt||0)>bv){ bi=j2; bv=q.amt||0; } }
      if(bi>=0){ out.push(pool[bi]); pool[bi]=null; }
    });
  }
  P.kit=out;
  return {gun:g,kit:out};
}
function kitExtraHide(){ ['askrand','asktop'].forEach(function(id){ var b=document.getElementById(id); if(b) b.style.display='none'; }); ASKRAND=null; ASKTOP=null; }
'@

SubRx @'
  ASKYES=function(){ if(P.freeKit) freeKitRestore(); P.freeKit=0; saveProfile(); then(); };   // v12.16: MY LOADOUT gets his packing back too
'@ @'
  ASKYES=function(){ if(P.freeKit) freeKitRestore(); P.freeKit=0; saveProfile(); then(); };   // v12.16: MY LOADOUT gets his packing back too
  // v16.87, his ask: RANDOM FROM STASH and TOP GEAR fill the packing list and go up as MY LOADOUT does.
  ASKRAND=function(){ if(P.freeKit) freeKitRestore(); P.freeKit=0; kitFill(true); saveProfile(); then(); };
  ASKTOP=function(){ if(P.freeKit) freeKitRestore(); P.freeKit=0; kitFill(false); saveProfile(); then(); };
  (function(){ var _kr=document.getElementById('askrand'), _kt=document.getElementById('asktop'); if(_kr) _kr.style.display=''; if(_kt) _kt.style.display=''; })();
'@

SubRx @'
  var f=ASKYES; ASKYES=null;
'@ @'
  var f=ASKYES; ASKYES=null; kitExtraHide();   // v16.87
'@

SubRx @'
  askRestore();   // v12.68: a question he declined does not cost him the window
'@ @'
  kitExtraHide();   // v16.87
  askRestore();   // v12.68: a question he declined does not cost him the window
'@

SubRx @'
document.getElementById('askalt').onclick=function(){
  var f=ASKALT; ASKYES=null; ASKALT=null;
'@ @'
['askrand','asktop'].forEach(function(id){   // v16.87: RANDOM FROM STASH and TOP GEAR close the card the way the other answers do
  var b=document.getElementById(id); if(!b) return;
  b.onclick=function(){
    var f=(id==='askrand')?ASKRAND:ASKTOP; kitExtraHide(); ASKYES=null; ASKALT=null;
    document.getElementById('askmodal').classList.remove('on');
    askRestore();
    if(f) f();
  };
});
document.getElementById('askalt').onclick=function(){
  var f=ASKALT; ASKYES=null; ASKALT=null; kitExtraHide();   // v16.87
'@

SubRx @'
var VER='16.86';
'@ @'
var VER='16.87';
'@

$pat = "(?m)^  now:'v16\.86:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v16.87: RANDOM FROM STASH AND TOP GEAR. His ask during his co-op session: two more answers on the kit question beside MY LOADOUT and the freebie kit, in both windows of a party. TOP GEAR equips his highest tier gun and packs two of each grenade and the biggest plate, ammo and heals from the stash; RANDOM FROM STASH equips a gun he owns at random and packs six stash items at random. Both pack only what the stash holds and go up as MY LOADOUT does. Check 16.87 fails on v16.86',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
