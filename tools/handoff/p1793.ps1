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

# PLAYER 2 PICKS A CHARACTER LIKE PLAYER 1 (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function netSaveLocked(){ return !!((typeof NETSLOT!=='undefined'&&NETSLOT)||(typeof NETP2!=='undefined'&&NETP2)); }
'@ @'
// v17.93, HIS ORDER (2026-10-03): PLAYER 2 PICKS A CHARACTER LIKE PLAYER 1. The second window played one hidden save
// (salvagerun:profile:p2) chosen for it. Now it plays a numbered save like any window: its own pointer (activeSlot2) says which,
// never the save player 1 has open (the two windows share this storage, and two windows on one save would write over each
// other), and the old hidden save moves into a free slot once, so that character can be played in 1 PLAYER too. The saves list
// in either window greys the save the other window has open: IN USE BY PLAYER 1 (or 2).
function p2PtrKey(){ return 'salvagerun:activeSlot2'; }
function p1SlotNow(){ try{ return localStorage.getItem('salvagerun:activeSlot')||'1'; }catch(e){ return '1'; } }
function slotKeyOf(sn){ return sn==='1'?'salvagerun:profile':('salvagerun:profile:'+sn); }
function slotHas(sn){ try{ return !!localStorage.getItem(slotKeyOf(sn)); }catch(e){ return false; } }
function p2SlotPick(){
  var p1=p1SlotNow(), want=null, i, k, old=null;
  try{ want=localStorage.getItem(p2PtrKey()); }catch(e){ want=null; }
  if(want&&want!==p1&&/^[1-8]$/.test(want)) return want;
  try{ old=localStorage.getItem('salvagerun:profile:p2'); }catch(e1){ old=null; }
  if(old){ for(i=2;i<=8;i++){ k=String(i); if(k!==p1&&!slotHas(k)){ try{ localStorage.setItem(slotKeyOf(k),old); localStorage.removeItem('salvagerun:profile:p2'); localStorage.setItem(p2PtrKey(),k); }catch(e2){} return k; } } }
  for(i=1;i<=8;i++){ k=String(i); if(k!==p1&&slotHas(k)){ try{ localStorage.setItem(p2PtrKey(),k); }catch(e3){} return k; } }
  for(i=1;i<=8;i++){ k=String(i); if(k!==p1&&!slotHas(k)){ try{ localStorage.setItem(p2PtrKey(),k); }catch(e4){} return k; } }
  return (p1==='8')?'7':'8';
}
function slotBlocked(sn){
  var p2=null;
  if(typeof NETP2!=='undefined'&&NETP2) return sn===p1SlotNow();
  if(typeof NET==='object'&&NET&&NET.same==='host'){ try{ p2=localStorage.getItem(p2PtrKey()); }catch(e){ p2=null; } return !!p2&&sn===p2; }
  return false;
}
function slotPtrKey(){ return (typeof NETP2!=='undefined'&&NETP2)?p2PtrKey():'salvagerun:activeSlot'; }
function netSaveLocked(){ return !!(typeof NETSLOT!=='undefined'&&NETSLOT); }   // v17.93: the player 2 window moves its own pointer now
'@

SubRx @'
else if(NETP2) SKEY=netP2Key();
'@ @'
else if(NETP2){ SLOT=p2SlotPick(); SKEY=(SLOT==='1')?'salvagerun:profile':('salvagerun:profile:'+SLOT); }   // v17.93: player 2 plays a numbered save of its own
'@

SubRx @'
      if(_ngl) _ngl.style.display=_p2w?'none':'';
'@ @'
      if(_ngl) _ngl.style.display='';   // v17.93: player 2 creates a save too
'@

SubRx @'
      if(_sln) _sln.style.display=_p2w?'none':'';
'@ @'
      if(_sln) _sln.style.display='';
'@

SubRx @'
      if(_p2w){
'@ @'
      if(false){   // v17.93: player 2 picks a character from the same list; the one-save note is gone
'@

SubRx @'
        var me=(key===SLOT);
'@ @'
        var me=(key===SLOT), blk=slotBlocked(key);   // v17.93: blk, the save the other window has open
'@

SubRx @'
        h+='<div data-slot="'+key+'" style="cursor:pointer;border:1px solid '+(me?'var(--amber)':'var(--steel-hi)')+
'@ @'
        h+='<div data-slot="'+key+'" style="cursor:'+(blk?'default':'pointer')+';opacity:'+(blk?'.55':'1')+';border:1px solid '+(me?'var(--amber)':'var(--steel-hi)')+
'@

SubRx @'
           (me?' <span style="font-size:10px;letter-spacing:.14em">'+((inf&&inf.runs>0)?'CONTINUING':'NEW')+'</span>':'')+'</b>'+
'@ @'
           (me?' <span style="font-size:10px;letter-spacing:.14em">'+((inf&&inf.runs>0)?'CONTINUING':'NEW')+'</span>':(blk?' <span style="font-size:10px;letter-spacing:.14em;color:var(--ash)">IN USE BY PLAYER '+((typeof NETP2!=='undefined'&&NETP2)?'1':'2')+'</span>':''))+'</b>'+
'@

SubRx @'
           (me?'':' <button data-del="'+key+'" class="deploy ghost" style="margin-left:8px;padding:2px 8px;font-size:10px">DELETE</button>')+
'@ @'
           ((me||blk)?'':' <button data-del="'+key+'" class="deploy ghost" style="margin-left:8px;padding:2px 8px;font-size:10px">DELETE</button>')+
'@

SubRx @'
          if(sn===SLOT) return;
'@ @'
          if(sn===SLOT||slotBlocked(sn)) return;   // v17.93: never the save the other window has open
'@

SubRx @'
        if(!slotInfo(key)&&key!==SLOT){
'@ @'
        if(!slotInfo(key)&&key!==SLOT&&!slotBlocked(key)){
'@

SubRx @'
          try{ if(!netSaveLocked()) localStorage.setItem('salvagerun:activeSlot',sn); }catch(e){}
'@ @'
          try{ if(!netSaveLocked()) localStorage.setItem(slotPtrKey(),sn); }catch(e){}
'@

SubRx @'
          try{ if(!netSaveLocked()) localStorage.setItem('salvagerun:activeSlot',key); }catch(e){}
'@ @'
          try{ if(!netSaveLocked()) localStorage.setItem(slotPtrKey(),key); }catch(e){}
'@

SubRx @'
var VER='17.92';
'@ @'
var VER='17.93';
'@

$pat = "(?m)^  now:'v17\.92:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v17.93: Player 2 now picks a character from the same saves list as player 1 (or creates one), and every character can be played in 1 PLAYER. The save the other window has open shows as IN USE. Check 17.93 fails on v17.92',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
