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

# BELT KEYS SOUND LIKE WHAT THEY PICK (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var GEAR_LIGHT={pistol:1,tacker:1,magnum:1,smg:1,sputter:1,whisper:1,fists:1};
'@ @'
var GEAR_LIGHT={pistol:1,tacker:1,magnum:1,smg:1,sputter:1,whisper:1,fists:1};
var GEAR_AT=-1;   // v25.xx (plopswap): the raid clock at the last holster clack, so the belt key does not add a second sound over it
'@

SubRx @'
  var lt=!!(w&&GEAR_LIGHT[w.id]);
'@ @'
  var lt=!!(w&&GEAR_LIGHT[w.id]);
  GEAR_AT=G.t||0;
'@

SubRx @'
function setHot(i){
'@ @'
// v25.xx (plopswap), HIS NOTE 2026-10-13: "in places where you use the plop, consider if something else would be better". A belt key (the
// number keys, the wheel, the pad bumpers) ended in the plain pick chirp, after the holster clack of a gun swap had already played and
// as the ONLY sound for a grenade, a medical item or a plate. Now the key sounds like what it picks: a gun swap or a draw keeps its own
// holster clack and adds nothing; a throwable is a pouch rustle, a bandage or medkit the cloth wrap, a plate a short armour clack, and
// anything else (an empty cell, a gun already in hand) the soft menu tick. Cosmetic only: no seeded draw, nothing under G.sim.
function beltSound(s2){
  var kd=s2&&s2.kind, ok=false, t=G&&G.t;
  if(G&&G.sim) return false;
  if(kd==='gun'&&GEAR_AT===(t||0)) return true;
  if(typeof foley==='function'){
    if(kd==='throw') ok=foley('rummage',null,null,{g:0.7,rate:1.2,dur:0.14,gap:0.1});
    else if(kd==='heal') ok=foley('bandageWrap',null,null,{g:0.8,dur:0.16,gap:0.1});
    else if(kd==='armor') ok=foley('plateClack',null,null,{g:0.5,dur:0.14,gap:0.1});
  }
  if(ok) return true;
  return sndUi('move');
}
function setHot(i){
'@

SubRx @'
    if(!G.sim) say(('Gun slot '+(i+1)+' empty').toUpperCase());
    blip('pick');
    return;
'@ @'
    if(!G.sim) say(('Gun slot '+(i+1)+' empty').toUpperCase());
    sndUi('deny');   // v25.xx (plopswap): the dull buzz of something locked, not the pick chirp
    return;
'@

SubRx @'
  // v22.73 (R28): no line naming the cell and its count; the belt band shows the selected key and the count on it.
  blip('pick');
'@ @'
  // v22.73 (R28): no line naming the cell and its count; the belt band shows the selected key and the count on it.
  beltSound(s2);   // v25.xx (plopswap): what the key picks, not the pick chirp
'@

SubRx @'
    if(!G.sim) say(String(sl[i].name||'Gun').toUpperCase(),'info',{sub:padB('RT TO DRAW')});
    blip('pick');
    return;
'@ @'
    if(!G.sim) say(String(sl[i].name||'Gun').toUpperCase(),'info',{sub:padB('RT TO DRAW')});
    sndUi('move');   // v25.xx (plopswap): the soft menu tick for a highlight that only moves
    return;
'@

SubRx @'
var VER='25.73';
'@ @'
var VER='25.74';
'@

$pat = "(?m)^  now:'v25\.73:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v25.74: Belt keys now sound like what they pick instead of the plain chirp: a pouch rustle, a cloth wrap, an armour clack or a soft tick. Check 25.74 fails on v25.73',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
