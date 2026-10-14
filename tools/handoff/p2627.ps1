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

# THE BAR HOLDS NINE GUNS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var GUNKEYS=4;
'@ @'
var GUNKEYS=9;   // v26.xx (wheel4), HIS ORDER 2026-10-14: "Lets ONLY show guns at the bottom of the screen, only 9 of them." Nine gun keys; grenades, heals and plates live on the item wheel (hold Q)
'@

SubRx @'
var BELT_CLASS=['gun','gun','gun','gun','throw','throw','med','med','plate'];
'@ @'
var BELT_CLASS=['gun','gun','gun','gun','gun','gun','gun','gun','gun'];   // v26.xx (wheel4): was four guns, two throwables, two medical and a plate; the items moved to the wheel
'@

SubRx @'
  if(code==='KeyH'&&G&&!G.over&&!G.paused&&!repeat){ HHOLD.arm=1; HHOLD.t=0; }   // v25.xx (holdhplate): H is armed here; a tap heals and a hold slots a plate, decided in holdHTick
'@ @'
  // v26.xx (wheel4), HIS ORDER 2026-10-14: EVERYTHING GOES THROUGH THE WHEEL. H (tap heal and hold plate), G (quick throw), U and J (cycling) and the item keys 5 to 9 are gone; hold Q.
'@

SubRx @'
  if(code==='KeyU'&&G&&!G.over&&!repeat) cycleThrow();   // v25.xx (keyswap): switch throwable moved from Q (now the crowbar) to U
'@ @'
  // (U, J and G: see above)
'@

SubRx @'
  if(code==='KeyJ'&&G&&!G.over&&!repeat) cycleHeal();   // v26.02 (beltkeys): J picks the next heal on the medical keys, as U picks the next grenade
'@ @'
  // (U, J and G: see above)
'@

SubRx @'
  if(code==='KeyG'&&G&&!G.over&&!G.paused&&!repeat){ throwSelFix(); doThrow(); }   // v23.46 (arcade23): in the arcade G is the quick heal   // v25.xx (belt5a): G throws the kind on a throwable key
'@ @'
  // (U, J and G: see above)
'@

SubRx @'
['F1','controls list'],['KeyH','quick heal (tap), armour plate (hold)'],
'@ @'
['F1','controls list'],
'@

SubRx @'
['KeyG','quick throw'],['KeyU','switch throwable'],['KeyJ','switch medical'],['KeyZ'
'@ @'
['KeyZ'
'@

SubRx @'
'KeyF','KeyG','KeyU','KeyH','KeyJ']]
'@ @'
'KeyF']]
'@

SubRx @'
+s('KeyF')+' next gun &nbsp; '+s('KeyG')+' throw &nbsp; '+s('KeyU')+' next grenade &nbsp; '+s('KeyH')+' heal, hold for plate &nbsp; '+s('KeyJ')+' next heal &nbsp; '+k('1-4')+' guns &nbsp; '+k('5-6')+' throw that grenade &nbsp; '+k('7-8')+' use that heal &nbsp; '+k('9')+' plate &nbsp; '
'@ @'
+s('KeyF')+' next gun &nbsp; '+k('1-9')+' guns &nbsp; '
'@

SubRx @'
['1-4','guns'],['5-6','throw that grenade'],['7-8','use that heal'],['9','plate'],['FIRE','use selected key'],['G','throw the chosen grenade'],['U','next grenade'],['H','use the chosen heal, hold plate'],['J','next heal'],
'@ @'
['1-9','guns'],['HOLD Q','item wheel: aim at a grenade, heal or plate and let go'],['FIRE','use the item in hand, or fire'],
'@

SubRx @'
['G','throw'],['H','heal'],['U / J','next throw, heal'],
'@ @'
['Q','item wheel'],
'@

SubRx @'
['1-4','guns'],['B / I','backpack'],['5-9','throw, heal, plate'],
'@ @'
['1-9','guns'],['B / I','backpack'],['LMB','use item in hand'],
'@

SubRx @'
_lbH=Math.round(_lbP*1.5)+LH(3);
'@ @'
_lbH=0;
'@

SubRx @'
    // v25.xx (belt6a), HIS ORDER 2026-10-13: a small caps label under each group, amber while the highlight is in that group.
    (function(){
      var NM=['GUNS','THROW','MEDICAL','ARMOUR'], g0, f, l, qq, cxl, sg=beltGroupOf(sel);
      ctx.font=_lbF; ctx.textAlign='center';
      for(g0=0;g0<4;g0++){
        f=-1; l=-1;
        for(qq=0;qq<sl.length;qq++) if(beltGroupOf(qq)===g0){ if(f<0) f=qq; l=qq; }
        if(f<0) continue;
        cxl=hx+(f*bw+_gx[f]+l*bw+_gx[l]+bw)/2;
        ctx.fillStyle=(g0===sg)?UIC.acc:HUDC.dim;
        ctx.fillText(NM[g0],cxl,hy+bw+_lbP+LH(1));
      }
      ctx.textAlign='left';
    })();
'@ @'
    // v26.xx (wheel4): no group labels under the belt; it holds nine guns and nothing else.
'@

SubRx @'
for(_gi=0;_gi<4;_gi++) h+='<div style="background:rgba(20,23,26,.55)
'@ @'
for(_gi=0;_gi<1;_gi++) h+='<div style="background:rgba(20,23,26,.55)
'@

SubRx @'
  if(!beltClassOf(key)) return;   // v25.xx (belt3): a gun, a throwable, a heal, a stim or a plate; anything else has no key
'@ @'
  if(beltClassOf(key)!=='gun') return;   // v26.xx (wheel4): the belt takes guns only; a throwable, a heal, a stim or a plate waits for the wheel
'@

SubRx @'
function beltClassWord(cls){
  return cls==='gun'?('GUNS GO ON KEYS 1 TO '+GUNKEYS):(cls==='throw'?'THROWABLES GO ON KEYS 5 AND 6':(cls==='med'?'MEDICAL GOES ON KEYS 7 AND 8':(cls==='plate'?'PLATES GO ON KEY 9':'NOT A BELT ITEM')));
'@ @'
function beltClassWord(cls){
  return cls==='gun'?('GUNS GO ON KEYS 1 TO '+GUNKEYS):'ITEMS GO ON THE WHEEL';   // v26.xx (wheel4): the belt takes guns only
'@

SubRx @'
function beltThrowTick(){

'@ @'
function beltThrowTick(){
  return;   // v26.xx (wheel4): every grenade stays in the pouch; the wheel reads the pouch and the backpack

'@

SubRx @'
if(P.netEarn===undefined) P.netEarn=netEarnFromLog();
'@ @'
// v26.xx (wheel4): and the three plans lose every item that is not a gun, once (the belt holds guns only).
if((P.beltV|0)<5){
  P.hotAssign=beltItemsOff(P.hotAssign||{});
  if(P.kitSaved&&P.kitSaved.hot) P.kitSaved.hot=beltItemsOff(P.kitSaved.hot);
  if(P.hotBeforeFree) P.hotBeforeFree=beltItemsOff(P.hotBeforeFree);
  P.beltV=5;
}
if(P.netEarn===undefined) P.netEarn=netEarnFromLog();
'@

SubRx @'
function applyLoadedProfile(r){
'@ @'
// v26.xx (wheel4), HIS ORDER 2026-10-14: THE BELT HOLDS GUNS ONLY (P.beltV=5). Every binding that is not a gun comes off a saved plan; a gun stays on its key.
function beltItemsOff(h){
  if(!h||typeof h!=='object') return h;
  var out={}, k;
  for(k in h) if(Object.prototype.hasOwnProperty.call(h,k)){
    if(ITEMS[h[k]]&&ITEMS[h[k]].use==='gun') out[k]=h[k];
  }
  return out;
}
function applyLoadedProfile(r){
'@

SubRx @'
mig739:1,mig945:1,beltV:4,
'@ @'
mig739:1,mig945:1,beltV:5,
'@

SubRx @'
['SWITCH GUN','1-4',padB('LB')+' / '+padB('RB')],['HEAL',kn('KeyH'),padB('D-DOWN')],
'@ @'
['SWITCH GUN','1-9',padB('LB')+' / '+padB('RB')],['ITEMS','HOLD '+kn('KeyQ'),'HOLD '+padB('D-DOWN')],
'@

SubRx @'
var VER='26.26';
'@ @'
var VER='26.27';
'@

$pat = "(?m)^  now:'v26\.26:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v26.27: The bottom bar is nine gun slots, 1 to 9; grenades, heals and plates are only on the item wheel (hold Q). Check 26.27 fails on v26.26',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
