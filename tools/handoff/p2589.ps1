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

# GUNS GO ON KEYS 1 TO 4 (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
        else {
          // v22.52, the four-gun belt, build 5 (his order of 2026-10-09: the player can load up the belt with all guns or whatever else
          // they want): ANY GUN ON ANY KEY. A gun in his hands dragged onto a key past the gun keys was refused in words (gun keys
          // only). It is now bound there as his key, flushed to his plan as any drag onto the belt is (minus the automatic pins), and
          // its gun key pin comes off, so the gun key it left shows the fill. What he had on that key goes to the key the gun came
          // from, as the trade above sends it. The guns in his hands do not change.
          var _gaA=(G.hotAssign=G.hotAssign||{}), _gaU=(G.hotAuto=G.hotAuto||{}), _gaP=_gaA[_onCell], _gaPu=_gaU[_onCell]?1:0, _gaK, _gaM=null, _gaI;
          for(_gaK in _gaA) if(_gaA[_gaK]===d.key){ delete _gaA[_gaK]; delete _gaU[_gaK]; }
          delete _gaU[_onCell];
          _gaA[_onCell]=d.key;
          if(_gaP!==undefined&&_gaP!==d.key&&d.fromHot!==undefined&&_gaA[d.fromHot]===undefined){
            _gaA[d.fromHot]=_gaP; if(_gaPu) _gaU[d.fromHot]=1;
            _gaI=ITEMS[_gaP]; if(_gaI) _gaM={sub:(_gaI.name+' to slot '+(d.fromHot+1)).toUpperCase()};   // v22.xx (R52): the slot word
          }
          for(_gaK in _gaU) if(_gaA[_gaK]===undefined) delete _gaU[_gaK];
          if(!G.sim){ var _gaF={}; for(_gaK in _gaA) if(!_gaU[_gaK]) _gaF[_gaK]=_gaA[_gaK]; P.hotAssign=JSON.parse(JSON.stringify(hotKeepPruned(_gaF))); try{ saveProfile(); }catch(_gaE){} }
          G.hot=gunCell(); blip('pick');
          say((_gw8n+' to slot '+(_onCell+1)).toUpperCase(),'info',_gaM);   // the shooter voice   // v22.xx (R52): the slot word
        }
'@ @'
        else {
          // v25.xx (belt2), HIS ORDER 2026-10-13: "so player can only carry 4 guns max". A gun belongs on keys 1 to GUNKEYS, so a gun in his
          // hands dragged onto a key past them is refused in words and nothing moves. This reverses v22.52 (ANY GUN ON ANY KEY).
          say('GUNS GO ON KEYS 1 TO '+GUNKEYS,'info',null); sndUi('deny');
        }
'@

SubRx @'
        // v8.67, HIS ORDER: a gun goes on any slot. This used to refuse with
'@ @'
        // v25.xx (belt2), HIS ORDER 2026-10-13: a gun belongs on keys 1 to GUNKEYS; one dropped on a key past them is refused in words (v8.67 and v22.52 let it go anywhere).
        if(_dit&&_dit.use==='gun'&&HC.i>=GUNKEYS){
          say('GUNS GO ON KEYS 1 TO '+GUNKEYS,'info',null); sndUi('deny');
          dropped=true; break;
        }
        // v8.67, HIS ORDER: a gun goes on any slot. This used to refuse with
'@

SubRx @'
            if(d.fromHot===_H.i) return;
            var _hb8s=hotbarSlots()
'@ @'
            if(d.fromHot===_H.i) return;
            if(_H.i>=GUNKEYS){ hubToast('GUNS GO ON KEYS 1 TO '+GUNKEYS); return; }   // v25.xx (belt2): a gun belongs on keys 1 to GUNKEYS (v22.45 let it go anywhere)
            var _hb8s=hotbarSlots()
'@

SubRx @'
          if(d.fromHot===_H.i) return;
          G.hotAssign=G.hotAssign||{};
'@ @'
          if(d.fromHot===_H.i) return;
          if(_H.i>=GUNKEYS&&ITEMS[d.key]&&ITEMS[d.key].use==='gun'){ hubToast('GUNS GO ON KEYS 1 TO '+GUNKEYS); return; }   // v25.xx (belt2): a gun belongs on keys 1 to GUNKEYS
          G.hotAssign=G.hotAssign||{};
'@

SubRx @'
function rackPut(slot,key){
  var why=rackToStash(key); if(why) return why;
'@ @'
function rackPut(slot,key){
  var why=rackToStash(key); if(why) return why;
  if((slot|0)>=GUNKEYS) return 'GUNS GO ON KEYS 1 TO '+GUNKEYS;   // v25.xx (belt2): a gun belongs on keys 1 to GUNKEYS
'@

SubRx @'
function planPut(slot,key){
  if(!key||!ITEMS[key]) return 'Nothing to put there.';
'@ @'
function planPut(slot,key){
  if(!key||!ITEMS[key]) return 'Nothing to put there.';
  if(ITEMS[key].use==='gun'&&(slot|0)>=GUNKEYS) return 'GUNS GO ON KEYS 1 TO '+GUNKEYS;   // v25.xx (belt2): a gun belongs on keys 1 to GUNKEYS
'@

SubRx @'
function applyLoadedProfile(r){
'@ @'
// v25.xx (belt2), HIS ORDER 2026-10-13: AN OLD SAVED BELT PLAN LOSES THE GUN BINDINGS PAST THE GUN KEYS, ONCE (P.beltV=3). A gun
// bound to keys 5 to 9 comes off the plan (the gun itself is untouched); everything else stays where it is. A new profile is born set.
function beltGunsOff(h){
  if(!h||typeof h!=='object') return h;
  var out={}, k;
  for(k in h) if(Object.prototype.hasOwnProperty.call(h,k)){
    if(isFinite(+k)&&+k>=GUNKEYS&&ITEMS[h[k]]&&ITEMS[h[k]].use==='gun') continue;
    out[k]=h[k];
  }
  return out;
}
function applyLoadedProfile(r){
'@

SubRx @'
if(P.beltV!==2){
  P.hotAssign=beltSlidePlan(P.hotAssign||{});
  if(P.kitSaved&&P.kitSaved.hot) P.kitSaved.hot=beltSlidePlan(P.kitSaved.hot);
  if(P.hotBeforeFree) P.hotBeforeFree=beltSlidePlan(P.hotBeforeFree);
  P.beltV=2;
}
'@ @'
if((P.beltV|0)<2){   // v25.xx (belt2): was !==2, which would slide a plan stamped 3 or later again
  P.hotAssign=beltSlidePlan(P.hotAssign||{});
  if(P.kitSaved&&P.kitSaved.hot) P.kitSaved.hot=beltSlidePlan(P.kitSaved.hot);
  if(P.hotBeforeFree) P.hotBeforeFree=beltSlidePlan(P.hotBeforeFree);
  P.beltV=2;
}
// v25.xx (belt2): the same three plans lose their gun bindings past the gun keys, once.
if((P.beltV|0)<3){
  P.hotAssign=beltGunsOff(P.hotAssign||{});
  if(P.kitSaved&&P.kitSaved.hot) P.kitSaved.hot=beltGunsOff(P.kitSaved.hot);
  if(P.hotBeforeFree) P.hotBeforeFree=beltGunsOff(P.hotBeforeFree);
  P.beltV=3;
}
'@

SubRx @'
mig739:1,mig945:1,beltV:2,
'@ @'
mig739:1,mig945:1,beltV:3,
'@

SubRx @'
var VER='25.88';
'@ @'
var VER='25.89';
'@

$pat = "(?m)^  now:'v25\.88:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v25.89: Guns now go only on keys 1 to 4; a gun dragged onto any other key is refused. Check 25.89 fails on v25.88',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
