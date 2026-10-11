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

# ARCADE SANDBOX: YOUR SAVE IS NEVER TOUCHED (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function storeSet(v){
'@ @'
function storeSet(v){
  if(typeof ARCADE==='object'&&ARCADE&&ARCADE.on) return;   // v23.20 (arcade1): an arcade session never writes his save, by any path
'@

SubRx @'
  if(SAVE_STALE) return;   // v17.24: another tab has written this save
'@ @'
  if(typeof ARCADE==='object'&&ARCADE&&ARCADE.on) return;   // v23.20 (arcade1): the arcade plays on a sandbox copy of the profile; nothing of it is saved
  if(SAVE_STALE) return;   // v17.24: another tab has written this save
'@

SubRx @'
// The containers as this window holds them, for the test page handle.
'@ @'
// ===================== 2 PLAYER ARCADE DEMO =====================
// v23.20, HIS ORDER (2026-10-11): a walk-up party mode for Halloween, the 2 PLAYER ARCADE DEMO. Build 1 of 20 (arcade1): THE SANDBOX.
// Everything the arcade adds is gated on ARCADE.on or G.arcade, so a normal raid is byte for byte unchanged, and an arcade session
// never writes his save. While ARCADE.on the P in memory is a sandbox copy of his profile, put in place (every closure holds P):
// one rifle, no stash, no kit, no merc, no contracts, no intel, no notoriety, default keys, autoloot on, and the name PLAYER 1 or
// PLAYER 2. His HUD layout and the kid settings of a player 2 save are kept. saveProfile and storeSet both refuse while it is on.
// Leaving puts his own profile back exactly as it was, keeps any crash entries the sandbox logged, and saves once. A tab closed
// mid-arcade therefore leaves the save as it was before the arcade began. Later builds add the raid, the pads and the attract.
var ARCADE={on:0,role:'',realJs:null,cfg0:null,mapIx:0};
var ARCADE_SBX={weapons:['rifle'],equipped:'rifle',equippedSec:'none',kitChosen:1,dropKit:[],stash:[],kit:[],hotAssign:null,
  merc:null,mercOut:null,intel:0,terms:[],contracts:[],gunPiled:[],raidSpliced:[],notoriety:0,runs:0,autoloot:1,keymap:{},crashes:[]};
function arcadeSandboxIn(role){
  if(ARCADE.on) return false;
  try{ saveProfile(); }catch(_sf){}   // flush once: the save on disk is his profile as it stands now
  var js=netUpSnapP(), sb=null, k;
  if(!js) return false;
  try{ sb=JSON.parse(js); }catch(_sp){ sb=null; }
  if(!sb||typeof sb!=='object') return false;
  for(k in ARCADE_SBX) if(Object.prototype.hasOwnProperty.call(ARCADE_SBX,k)) sb[k]=JSON.parse(JSON.stringify(ARCADE_SBX[k]));
  ARCADE.role=(role==='p2')?'p2':'host';
  sb.pname=(ARCADE.role==='p2')?'PLAYER 2':'PLAYER 1';
  ARCADE.realJs=js; ARCADE.on=1;
  netUpPutP(JSON.stringify(sb));
  try{ KEYS.inv=null; keysInv(); }catch(_ki){}
  return true;
}
function arcadeSandboxOut(){
  if(!ARCADE.on) return false;
  var cr=Array.isArray(P.crashes)?P.crashes.slice():[], k;
  if(ARCADE.cfg0){
    for(k in ARCADE.cfg0) if(Object.prototype.hasOwnProperty.call(ARCADE.cfg0,k)){ if(ARCADE.cfg0[k]===undefined) delete CFG[k]; else CFG[k]=ARCADE.cfg0[k]; }
    ARCADE.cfg0=null;
  }
  ARCADE.on=0;
  if(ARCADE.realJs) netUpPutP(ARCADE.realJs);
  ARCADE.realJs=null; ARCADE.role='';
  if(cr.length){
    if(!Array.isArray(P.crashes)) P.crashes=[];
    for(k=0;k<cr.length;k++) P.crashes.push(cr[k]);
    try{ while(P.crashes.length>CRASH_KEEP) P.crashes.shift(); }catch(_ck){}
  }
  try{ KEYS.inv=null; keysInv(); }catch(_ko){}
  try{ saveProfile(); }catch(_so){}
  return true;
}
// Leaving the arcade. For now it is the sandbox out; later builds stop the arcade raid and put the pad picks back first.
function arcadeLeave(){
  if(!ARCADE.on) return false;
  return arcadeSandboxOut();
}
// The containers as this window holds them, for the test page handle.
'@

SubRx @'
var VER='23.19';
'@ @'
var VER='23.20';
'@

$pat = "(?m)^  now:'v23\.19:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v23.20: Groundwork for the 2 PLAYER ARCADE DEMO: an arcade session plays on a copy of your profile and never writes your save. Check 23.20 fails on v23.19',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
