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

# PRO SOUND MIX: BUSES, COMPRESSOR, LIMITER (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
// ---------------------------------------------------------------- the room
'@ @'
// v23.67, HIS ORDER 2026-10-12 (his #45): "pro sound mix -- improve all sound as much as possible", punchy arcade like CoD and
// Fortnite (his answer 25 b). THE MIX BUSES. Every sound went raw into BUS at whatever level its own generator chose, so a grenade,
// a footstep and a pickup fought each other and a big fight turned to mush or clipped. Now each kind of sound rides its own bus
// (guns, impacts, machines, foley, the bed, voices, the HUD and the stings), and everything in the world runs through one
// compressor and then a limiter before BUS: quiet sounds come up, a blast cannot clip, and the mix hits harder. The HUD and the
// stings skip the compressor, so a pickup is never squashed under a fight. BUS stays the master, so the volume rows and SPLIT
// SPEAKERS (player 1 left, player 2 right) are untouched, and bus() itself makes the same nodes it always did. The buses are made
// the first time a sound asks for one, once for each BUS. The compressor adds its own make up gain (about 7 dB at this setting,
// the limiter about 2), so the trim after them brings a quiet sound back to about 4 dB over what it was.
var SND=null;
var SND_CAT={shot:'gun',reload:'gun',reloadin:'gun',dry:'gun',
  boom:'imp',hit:'imp',clank:'imp',
  servo:'mach',skitter:'mach',drone:'mach',hydraul:'mach',dish:'mach',stepHeavy:'mach',seen:'mach',alarm:'mach',
  foot:'foley',step:'foley',
  pick:'ui',pickRare:'ui',pickElite:'ui',pickGun:'ui',clockwarn:'ui',clocktick:'ui',
  heart:'vox',flap:'amb'};
var SND_CATS=['gun','imp','mach','foley','amb','vox','ui','sting','world'];
function sndBuild(a,B){
  var S={out:B,bus:{},world:null,comp:null,lim:null,trim:null}, i, c, gn;
  try{
    S.world=a.createGain(); S.world.gain.value=1.15;
    if(a.createDynamicsCompressor){
      S.comp=a.createDynamicsCompressor();
      S.comp.threshold.value=-16; S.comp.knee.value=10; S.comp.ratio.value=3.5; S.comp.attack.value=0.004; S.comp.release.value=0.22;
      S.lim=a.createDynamicsCompressor();
      S.lim.threshold.value=-3; S.lim.knee.value=0; S.lim.ratio.value=20; S.lim.attack.value=0.001; S.lim.release.value=0.1;
      S.trim=a.createGain(); S.trim.gain.value=0.5;
      S.world.connect(S.comp); S.comp.connect(S.lim); S.lim.connect(S.trim); S.trim.connect(B);
    } else S.world.connect(B);
    for(i=0;i<SND_CATS.length;i++){ c=SND_CATS[i]; gn=a.createGain(); gn.gain.value=1; gn.connect((c==='ui'||c==='sting')?B:S.world); S.bus[c]=gn; }
  }catch(e){ return null; }
  return S;
}
function sndBus(cat){
  var B=bus(), a=AC, S;
  if(!B||!a) return null;
  if(!SND||SND.out!==B){
    S=(B.__snd&&B.__snd.out===B)?B.__snd:sndBuild(a,B);
    if(!S) return B;
    try{ B.__snd=S; }catch(e){}
    SND=S;
  }
  return SND.bus[cat]||SND.bus.world||B;
}
// ---------------------------------------------------------------- the room
'@

SubRx @'
  var OUT=bus()||a.destination;
'@ @'
  var OUT=sndBus(SND_CAT[type]||'world')||bus()||a.destination;   // v23.67 (his #45): onto the bus for its kind of sound
'@

SubRx @'
function voxGrunt(hard){
  if(G&&G.sim) return;
  var a=ac(); if(!a) return; var out=bus(); if(!out) return;
'@ @'
function voxGrunt(hard){
  if(G&&G.sim) return;
  var a=ac(); if(!a) return; var out=sndBus('vox'); if(!out) return;
'@

SubRx @'
function voxBreath(){
  if(G&&G.sim) return;
  var a=ac(); if(!a) return; var out=bus(); if(!out) return;
'@ @'
function voxBreath(){
  if(G&&G.sim) return;
  var a=ac(); if(!a) return; var out=sndBus('vox'); if(!out) return;
'@

SubRx @'
  var out=bus(); if(!out) return null;
'@ @'
  var out=sndBus('amb'); if(!out) return null;
'@

SubRx @'
var VER='23.66';
'@ @'
var VER='23.67';
'@

$pat = "(?m)^  now:'v23\.66:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v23.67: Every sound rides its own mix bus and the world runs through a compressor and a limiter, so the mix hits harder and never clips. Check 23.67 fails on v23.66',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
