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

# THE KIT ON THE MAP SELECT SCREEN (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
<button id="askrand" style="flex:2;display:none">RANDOM FROM STASH</button>
'@ @'
<button id="askrand" style="flex:2;display:none">RANDOM KIT</button>
'@

SubRx @'
<button id="asktop" style="flex:2;display:none">TOP GEAR</button>
'@ @'
<button id="asktop" style="flex:2;display:none">BEST KIT</button>
'@

SubRx @'
'YOUR NOTES. RANDOM FROM STASH gives two random guns
'@ @'
'YOUR NOTES. RANDOM KIT gives two random guns
'@

SubRx @'
  <div id="sectorkit" style="margin-top:11px;font-size:15px;line-height:1.5;padding:9px 12px;
'@ @'
  <!-- v26.xx (kit1), HIS WORD (2026-10-14): the kit is part of the MAP SELECT screen, not a separate later card. One choice at a time, the last one kept in the save. -->
  <div id="sectorkitpick" style="display:flex;align-items:stretch;gap:8px;margin-top:9px;flex-wrap:wrap">
    <span style="font-size:13px;letter-spacing:.14em;color:var(--ash);min-width:5.8em;align-self:center">KIT</span>
    <button class="deploy ghost kitb" data-kit="mine"><span>MY LOADOUT</span><span class="kd">YOUR PACK</span></button>
    <button class="deploy ghost kitb" data-kit="free"><span>FREEBIE KIT</span><span class="kd">SCAV PISTOL &middot; 4 ITEMS</span></button>
    <button class="deploy ghost kitb" data-kit="rand"><span>RANDOM KIT</span><span class="kd">2 GUNS &middot; 1 EACH</span></button>
    <button class="deploy ghost kitb" data-kit="best"><span>BEST KIT</span><span class="kd">3 GUNS &middot; UP TO 3 EACH</span></button>
  </div>
  <div id="sectorkit" style="margin-top:11px;font-size:15px;line-height:1.5;padding:9px 12px;
'@

SubRx @'
  ASKALT=function(){
    // v12.13: THE SAME AS THE STASH SCREEN'S FREEBIE BUTTON, which clears the
    // belt plan (a key pointing at something you are not carrying is the v5.72
    // fault). This one did not, so a friend who took the free kit here landed
    // with keys bound to items left in the stash and, because an assigned heal
    // key replaces the derived Medical cell, two Bandages with no key to use.
    // v12.26, HIS NOTE: "when you gave my loadout back i am not sure i got the
    // whole thing back including everything in my backpack". The stash button
    // (v12.16) empties P.kit into P.kitSaved when the kit is taken there, and this
    // answer, still offered at the lift, re-snapshotted the emptied kit over it, so
    // commitKit kept an empty list and the death restore gave nothing back. Kept
    // aside only when the kit is not already taken: the stash button's own rule.
    // v13.06: the gun slot is gone from this snapshot. It was written here, cleared
    // here, kept aside and put back, and read by nothing in the file: what a raid arms
    // him with comes from P.equipped and P.equippedSec, which none of that touched.
    if(!P.freeKit) P.kitSaved={kit:(P.kit||[]).slice(),hot:JSON.parse(JSON.stringify(P.hotAssign||{}))};   // kept aside for the restore, as the stash button does since v12.16
    P.hotAssign={};
    P.freeKit=1; P.kitBeforeFree=null; saveProfile();
    try{ renderStage(); }catch(_e){}
    then();
  };
'@ @'
  ASKALT=function(){ kitAnswer('free',then); };   // v26.xx (kit1): the answer lives in kitApply, shared with the sector page
'@

SubRx @'
  ASKYES=function(){ if(P.freeKit) freeKitRestore(); P.freeKit=0; saveProfile(); then(); };   // v12.16: MY LOADOUT gets his packing back too
'@ @'
  ASKYES=function(){ kitAnswer('mine',then); };   // v12.16: MY LOADOUT gets his packing back too (v26.xx kit1: in kitApply)
'@

SubRx @'
  ASKRAND=function(){ if(P.freeKit) freeKitRestore(); P.freeKit=0; kitFill(true); saveProfile(); then(); };
'@ @'
  ASKRAND=function(){ kitAnswer('rand',then); };
'@

SubRx @'
  ASKTOP=function(){ if(P.freeKit) freeKitRestore(); P.freeKit=0; kitFill(false); saveProfile(); then(); };
'@ @'
  ASKTOP=function(){ kitAnswer('best',then); };
'@

SubRx @'
function kitFill(rand){
'@ @'
// v26.xx (kit1), HIS WORD (2026-10-14): "it should be PART OF THE MAP SELECT SCREEN, not a separate later screen". The kit is a row of four on the map select screen
// (the sector page, opened by the lift E, by the staging screen ASCEND and by the stash): MY LOADOUT, FREEBIE KIT, RANDOM KIT (was RANDOM FROM STASH) and BEST KIT (was TOP
// GEAR), one on at a time, each with its caps detail under it, the last one kept in the save (P.kitPick, an old save reads MY LOADOUT). ASCEND TO THIS SECTOR applies the
// chosen kit and goes straight up, so the loadout question no longer comes after it. The card (askKit) is still what a PARTY MATE sees for his own kit on his own save, with
// the auto-ascend timer (NET_KIT_WAIT) as before, and its four answers are the same four. The staging screen ASCEND now opens the sector page, so every route up ends there; the
// lift R quick ascent skips the page as it always did and takes the kept kit if it is not MY LOADOUT.
var KIT_PICKS=['mine','free','rand','best'];
var KIT_INFO={mine:['MY LOADOUT','YOUR PACK'],free:['FREEBIE KIT','SCAV PISTOL \u00b7 4 ITEMS'],rand:['RANDOM KIT','2 GUNS \u00b7 1 EACH'],best:['BEST KIT','3 GUNS \u00b7 UP TO 3 EACH']};
function kitPickOf(){ var k=(typeof P==='object'&&P)?P.kitPick:''; return KIT_PICKS.indexOf(k)>=0?k:'mine'; }
// the four answers, without the going up: MY LOADOUT gets his packing back, FREEBIE KIT sets it aside, RANDOM KIT and BEST KIT fill the packing list
function kitApply(kind){
  if(kind==='free'){
    // v12.13: THE SAME AS THE STASH SCREEN'S FREEBIE BUTTON, which clears the
    // belt plan (a key pointing at something you are not carrying is the v5.72
    // fault). This one did not, so a friend who took the free kit here landed
    // with keys bound to items left in the stash and, because an assigned heal
    // key replaces the derived Medical cell, two Bandages with no key to use.
    // v12.26, HIS NOTE: "when you gave my loadout back i am not sure i got the
    // whole thing back including everything in my backpack". The stash button
    // (v12.16) empties P.kit into P.kitSaved when the kit is taken there, and this
    // answer, still offered at the lift, re-snapshotted the emptied kit over it, so
    // commitKit kept an empty list and the death restore gave nothing back. Kept
    // aside only when the kit is not already taken: the stash button's own rule.
    // v13.06: the gun slot is gone from this snapshot. It was written here, cleared
    // here, kept aside and put back, and read by nothing in the file: what a raid arms
    // him with comes from P.equipped and P.equippedSec, which none of that touched.
    if(!P.freeKit) P.kitSaved={kit:(P.kit||[]).slice(),hot:JSON.parse(JSON.stringify(P.hotAssign||{}))};   // kept aside for the restore, as the stash button does since v12.16
    P.hotAssign={};
    P.freeKit=1; P.kitBeforeFree=null; saveProfile();
    try{ renderStage(); }catch(_e){}
    return;
  }
  if(P.freeKit) freeKitRestore();
  P.freeKit=0;
  if(kind==='rand') kitFill(true); else if(kind==='best') kitFill(false);
  saveProfile();
}
function kitAnswer(kind,then){ kitApply(kind); (then||function(){ netKitGate(ascendNow); })(); }
function kitDeploy(){ kitAnswer(kitPickOf()); }
function syncSectorKitPick(){
  var host=document.getElementById('sectorkitpick'), bs, i, cur=kitPickOf();
  if(!host) return;
  bs=host.querySelectorAll('.kitb');
  for(i=0;i<bs.length;i++) bs[i].classList.toggle('on',bs[i].getAttribute('data-kit')===cur);
}
(function(){
  var bs=document.querySelectorAll('#sectorkitpick .kitb'), i;
  for(i=0;i<bs.length;i++) bs[i].onclick=function(){
    var k=this.getAttribute('data-kit');
    if(KIT_PICKS.indexOf(k)<0) return;
    P.kitPick=k; saveProfile(); syncSectorKitPick(); try{ syncSectorKit(); }catch(_sk){}
    try{ sndUi('click'); }catch(_su){}
  };
})();
careerStyle('careercss9',
  '.kitb{display:flex;flex-direction:column;align-items:flex-start;gap:3px;padding:7px 16px;flex:0 0 auto}'+
  '.kitb .kd{font-size:12px;letter-spacing:.12em;opacity:.72;font-weight:600}'+
  '.kitb.on{border-color:var(--amber);color:var(--amber);background:rgba(255,192,74,.10)}');
function kitFill(rand){
'@

SubRx @'
  syncSectorCond();
  syncSectorKit();
'@ @'
  syncSectorCond();
  syncSectorKit();
  try{ syncSectorKitPick(); }catch(_skp){}   // v26.xx (kit1)
'@

SubRx @'
function syncSectorKit(){
  var el=document.getElementById('sectorkit');
  if(!el) return;
'@ @'
function syncSectorKit(){
  var el=document.getElementById('sectorkit');
  if(!el) return;
  if(kitPickOf()!=='mine'){ var _kp=kitPickOf(); el.innerHTML='<b>Going up with:</b> '+KIT_INFO[_kp][0]+'  \u00b7  '+KIT_INFO[_kp][1]; return; }   // v26.xx (kit1): a kit picked on this page is what goes up
'@

SubRx @'
  askKit();
};
document.getElementById('closesector')
'@ @'
  kitDeploy();   // v26.xx (kit1): the kit was chosen on this page, so it goes straight up
};
document.getElementById('closesector')
'@

SubRx @'
document.getElementById('stagedrop').onclick=function(){ ascendNow(); };
'@ @'
document.getElementById('stagedrop').onclick=function(){   // v26.xx (kit1): every route up ends on the map select screen, with the kit row on it
  var sm=document.getElementById('stagemodal'); if(sm) sm.classList.remove('on');
  renderSector(); openModal('sectormodal');
};
'@

SubRx @'
liftResetDay(); commitKit(); ac(); startRaid(); }],
'@ @'
liftResetDay(); if(kitPickOf()!=='mine') kitApply(kitPickOf()); commitKit(); ac(); startRaid(); }],   // v26.xx (kit1): the kept kit, if it is not MY LOADOUT
'@

SubRx @'
var VER='27.19';
'@ @'
var VER='27.20';
'@

$pat = "(?m)^  now:'v27\.19:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v27.20: The kit is a row on the map select screen: MY LOADOUT, FREEBIE KIT, RANDOM KIT, BEST KIT. Check 27.20 fails on v27.19',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
