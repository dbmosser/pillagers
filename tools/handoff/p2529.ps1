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

# GUNS AND GEAR SOUND LIKE GEAR (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function swapGuns(){
'@ @'
// v25.29 (usefoleyh), HIS ORDER 2026-10-12 (about 21:10): "add sounds for bandaging, applying armor, etc". GUNS AND GEAR SOUND LIKE
// GEAR. Swapping guns and equipping one from the backpack played the menu chirp, and dropping an item made no sound. Now (the v25.20
// bank) a swap or an equip is a strap and holster rattle and the draw clacking up, lighter and quicker for a pistol, an SMG or the
// Magnum and heavier for a rifle, the LMG, a shotgun, the Longshot or the Lance; a drop is a soft thump. Yours is centred; your
// teammates hear it where you stand. Cosmetic only: no seeded draw, nothing under G.sim, no game state.
var GEAR_LIGHT={pistol:1,tacker:1,magnum:1,smg:1,sputter:1,whisper:1,fists:1};
function gearFoley(kind,w){
  if((G&&G.sim)||typeof foley!=='function') return false;
  if(kind==='drop'){ foley('pickup',null,null,{rate:0.7,g:0.8,gap:0.08}); return true; }
  var lt=!!(w&&GEAR_LIGHT[w.id]);
  foley('equip',null,null,{rate:lt?1.25:0.9,g:lt?0.8:1});
  foley('boltLatch',null,null,{at:lt?0.1:0.15,rate:lt?1.5:1.0,g:lt?0.45:0.6,dur:0.15,gap:0});
  return true;
}
function swapGuns(){
'@

SubRx @'
  // v22.73 (R28): no line for the swap; the gun card shows the gun in his hands. drawGun still says where the other gun went.
  blip('pick');
'@ @'
  // v22.73 (R28): no line for the swap; the gun card shows the gun in his hands. drawGun still says where the other gun went.
  if(!gearFoley('swap',pp.wep)) blip('pick');   // v25.29 (usefoleyh): the holster and the draw
'@

SubRx @'
  say(_newLine,'info',null);
  blip('pick');
'@ @'
  say(_newLine,'info',null);
  if(!gearFoley('swap',p.wep)) blip('pick');   // v25.29 (usefoleyh): the holster and the draw
'@

SubRx @'
  var p=G.player,key=G.bag[idx];
  G.bag.splice(idx,1);
'@ @'
  var p=G.player,key=G.bag[idx];
  G.bag.splice(idx,1);
  gearFoley('drop');   // v25.29 (usefoleyh): a soft thump
'@

SubRx @'
var VER='25.28';
'@ @'
var VER='25.29';
'@

$pat = "(?m)^  now:'v25\.28:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v25.29: Swapping or equipping a gun now rattles the holster and clacks the draw, and dropping an item thumps. Check 25.29 fails on v25.28',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
