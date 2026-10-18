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

# a name typed on the title goes into a new save (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function netSaveLocked(){
'@ @'
// v30.xx (cw-newsavename), HIS ORDER (2026-10-18): "if I type a name into the text input bar on the title screen and then click 'create a
// new save', it should pick up that name". CREATE A NEW SAVE reloads the game onto an empty slot, and a fresh save is always named
// PILLAGER, so the typed name was dropped. The typed name (when it was typed, or is not the open save's own name) is kept beside the
// save pointer for that reload, and the fresh save takes it as it boots: only the slot it was meant for, only a save with no raids
// yet, only within two minutes, and only once.
var NEWNAME_KEY='salvagerun:newname';
function newNameKeep(v,slot,typed){
  var k=NEWNAME_KEY+':'+slotPtrKey();
  v=String(v||'').trim().slice(0,16);
  try{
    if(!v||(!typed&&v===P.pname)){ localStorage.removeItem(k); return ''; }
    localStorage.setItem(k,JSON.stringify({s:String(slot),n:v,t:Date.now()}));
  }catch(_nk){ return ''; }
  return v;
}
function newNameTake(){
  var k=NEWNAME_KEY+':'+slotPtrKey(), o=null;
  try{ o=JSON.parse(localStorage.getItem(k)||'null'); localStorage.removeItem(k); }catch(_nt){ o=null; }
  if(!o||typeof o.n!=='string'||!o.n.trim()) return '';
  if(String(o.s)!==String(SLOT)) return '';
  if(Math.abs(Date.now()-(+o.t||0))>120000) return '';
  if((P.runs|0)>0) return '';
  P.pname=o.n.trim().slice(0,16);
  try{ saveProfile(); }catch(_ns){}
  return P.pname;
}
function netSaveLocked(){
'@

SubRx @'
  PLOADED=true;

'@ @'
  PLOADED=true;
  try{ newNameTake(); }catch(_nnt){}   // v30.xx (cw-newsavename): a fresh save takes the name typed before CREATE A NEW SAVE

'@

SubRx @'
          try{ if(!netSaveLocked()) localStorage.setItem(slotPtrKey(),key); }catch(e){}   // v15.74: a ?netslot copy never moves the save pointer; v15.76: nor the player 2 window

'@ @'
          try{ if(!netSaveLocked()) localStorage.setItem(slotPtrKey(),key); }catch(e){}   // v15.74: a ?netslot copy never moves the save pointer; v15.76: nor the player 2 window
          if(!netSaveLocked()) newNameKeep(pin&&pin.value,key,pin&&pin.__typed);   // v30.xx (cw-newsavename): the typed name goes with the new save

'@

SubRx @'
    if(pin) pin.value=P.pname||'';

'@ @'
    if(pin) pin.value=P.pname||'';
    if(pin) pin.oninput=function(){ pin.__typed=1; };   // v30.xx (cw-newsavename): a name typed here, even the same one, goes into a new save

'@

SubRx @'
var VER='30.79';
'@ @'
var VER='30.80';
'@

$pat = "(?m)^  now:'v30\.79:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v30.80: Type a name on the title and click create a new save: the new save has that name. Check 30.80 fails on v30.79',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
